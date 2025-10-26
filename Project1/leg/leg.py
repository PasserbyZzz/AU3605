import cv2
import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path
from typing import Tuple, List, Optional, Dict, Any
from sklearn.cluster import KMeans

plt.rcParams['font.sans-serif'] = ['SimHei']  
plt.rcParams['axes.unicode_minus'] = False  

def calculate_image_derivatives(image_gray: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
    """
    计算图像的梯度幅值和拉普拉斯算子。
    
    使用 8-邻域核，
    """
    image_float = image_gray.astype(np.float64)

    # 1. 梯度 (使用 3x3 Sobel)
    grad_x = cv2.Sobel(image_float, cv2.CV_64F, 1, 0, ksize=3)
    grad_y = cv2.Sobel(image_float, cv2.CV_64F, 0, 1, ksize=3)
    gradient_magnitude = np.sqrt(grad_x**2 + grad_y**2)

    # 2. 拉普拉斯 (使用 3x3 8邻域核)
    laplacian_kernel = np.array(
        [[1, 1, 1],
         [1, -8, 1],
         [1, 1, 1]], 
        dtype=np.float64
    )
    laplacian_image = cv2.filter2D(image_float, cv2.CV_64F, laplacian_kernel)

    return gradient_magnitude, laplacian_image

def find_boundary_sample_points(
    image_gray: np.ndarray, 
    gradient_magnitude: np.ndarray, 
    laplacian_image: np.ndarray, 
    T_g: float
) -> List[float]:
    """
    采样边界点的灰度值。
    """
    height, width = image_gray.shape
    boundary_samples = []
    
    image_float = image_gray.astype(np.float64)

    for i in range(height - 1):
        for j in range(width - 1):
            p1 = (i, j)
            p2_right = (i, j + 1)
            p3_bottom = (i + 1, j)

            l_p1 = laplacian_image[p1]
            g_p1 = gradient_magnitude[p1]
            f_p1 = image_float[p1]

            # 检查“右侧边”
            l_p2_r = laplacian_image[p2_right]
            g_p2_r = gradient_magnitude[p2_right]
            
            # [修正] 梯度检查条件 g1 + g2 >= T_g
            if (l_p1 * l_p2_r < 0) and (g_p1 + g_p2_r >= T_g):
                weight = abs(l_p1) / (abs(l_p1) + abs(l_p2_r))
                gray_sample = (1 - weight) * f_p1 + weight * image_float[p2_right]
                boundary_samples.append(gray_sample)

            # 检查“下方边”
            l_p3_b = laplacian_image[p3_bottom]
            g_p3_b = gradient_magnitude[p3_bottom]
            if (l_p1 * l_p3_b < 0) and (g_p1 + g_p3_b >= T_g):
                weight = abs(l_p1) / (abs(l_p1) + abs(l_p3_b))
                gray_sample = (1 - weight) * f_p1 + weight * image_float[p3_bottom]
                boundary_samples.append(gray_sample)
                
    return boundary_samples

def find_multilevel_thresholds_kmeans(
    boundary_samples: List[float], 
    n_clusters: int
) -> List[float]:
    """
    使用 K-Means 聚类寻找多个阈值。
    """
    if not boundary_samples or len(boundary_samples) < n_clusters:
        return []

    # 1. 将数据重塑为 K-Means 需要的 (n_samples, 1) 格式
    X = np.array(boundary_samples).reshape(-1, 1)
    
    # 2. 应用 K-Means 聚类
    kmeans = KMeans(n_clusters=n_clusters, n_init=10, random_state=42)
    kmeans.fit(X)
    
    # 3. 提取聚类中心（即“簇的均值”）
    centers = kmeans.cluster_centers_.flatten()
    
    # 4. 排序并返回，这些就是我们的阈值
    return sorted(list(centers))

def segment_image_by_thresholds(
    image_gray: np.ndarray, 
    thresholds: List[float]
) -> List[np.ndarray]:
    """
    使用一个阈值列表来分割图像，返回多个二值掩码。
    """
    segments = []
    # 确保阈值是排序的
    sorted_thresholds = sorted(thresholds)
    
    # 扩展阈值列表以方便循环 [0, t1, t2, ..., 256]
    bounds = [0.0] + sorted_thresholds + [256.0]
    
    # (论文图20有4个区域, 图23有3个区域)
    for i in range(len(bounds) - 1):
        lower_bound = bounds[i]
        upper_bound = bounds[i+1]
        
        # 第一个分段 (背景) 特殊处理，包含 0
        if i == 0:
            mask = ~((image_gray >= lower_bound) & (image_gray <= upper_bound-5))
        # 其他分段 (不包含下界，包含上界)
        else:
            mask = (image_gray > lower_bound-20) & (image_gray <= upper_bound-20)
            
        # 返回二值掩码 (0 或 255)
        segment_mask = (mask * 255).astype(np.uint8)
        segments.append(segment_mask)
        
    return segments

def generate_multilevel_plots(
    image_name: str,
    image_gray: np.ndarray,
    boundary_samples: List[float],
    thresholds: List[float],
    segments: List[np.ndarray],
    segment_names: List[str],
    output_dir: Path
):
    """
    生成并保存多阈值对比图表 。
    """
    num_segments = len(segments)
    
    # 动态布局：1行用于信息，(N)行用于分段
    # 每行最多放3个分段图
    num_segment_rows = int(np.ceil(num_segments / 3))
    num_rows = 1 + num_segment_rows
    fig, axes = plt.subplots(num_rows, 3, figsize=(18, 6 * num_rows))
    fig.suptitle(f'"{image_name}" 图像多阈值分割 (Wang & Bai, K-Means法)', fontsize=18)

    # 确保 axes 是 2D 数组
    if num_rows == 1:
        axes = axes.reshape(1, -1)

    # --- 第一行: 基本信息 ---
    
    # [0, 0] 原始图像
    axes[0, 0].imshow(image_gray, cmap='gray')
    axes[0, 0].set_title(f'原始图像 (论文图 {18 if "leg" in image_name else 21})')
    axes[0, 0].axis('off')
    
    # [0, 1] 全局直方图
    axes[0, 1].hist(image_gray.ravel(), bins=256, range=[0, 256], alpha=0.7, color='darkblue')
    axes[0, 1].set_title(f'全局直方图 (论文图 {19 if "leg" in image_name else 22} 下)')
    axes[0, 1].set_xlabel('灰度级')
    axes[0, 1].set_ylabel('像素数量')
    axes[0, 1].grid(True, linestyle='--', alpha=0.3)
    axes[0, 1].set_xlim([0, 255])
    
    # [0, 2] 边界点直方图
    if boundary_samples:
        axes[0, 2].hist(boundary_samples, bins=100, alpha=0.9, color='darkgreen')
        axes[0, 2].set_title(f'边界采样直方图 (论文图 {19 if "leg" in image_name else 22} 上)')
        axes[0, 2].set_xlabel('灰度级')
        axes[0, 2].set_ylabel('采样点数量 (N={len(boundary_samples)})')
        axes[0, 2].grid(True, linestyle='--', alpha=0.3)
        axes[0, 2].set_xlim([0, 255])
    else:
        axes[0, 2].text(0.5, 0.5, '未找到边界采样点', ha='center', va='center', color='red')
        axes[0, 2].set_title('边界采样直方图')

    # 在两个直方图上都画上阈值线
    threshold_colors = ['red', 'orange', 'yellow', 'cyan']
    for i, t in enumerate(thresholds):
        color = threshold_colors[i % len(threshold_colors)]
        label = f"T{i+1} (簇{i+1}均值): {t:.1f}"
        axes[0, 1].axvline(t, color=color, linestyle='--', label=label)
        axes[0, 2].axvline(t, color=color, linestyle='--', linewidth=2, label=label)
    if thresholds:
        axes[0, 1].legend()
        axes[0, 2].legend()

    # --- 后续行: 分割结果 ---
    ax_flat = axes.ravel()
    for i in range(num_segments):
        plot_index = 3 + i
        if plot_index < len(ax_flat):
            name = segment_names[i] if i < len(segment_names) else f'分段 {i+1}'
            ax_flat[plot_index].imshow(segments[i], cmap='gray')
            ax_flat[plot_index].set_title(name)
            ax_flat[plot_index].axis('off')
            
    # 隐藏未使用的子图
    for i in range(num_segments + 3, len(ax_flat)):
        ax_flat[i].axis('off')

    plt.tight_layout(rect=[0, 0.03, 1, 0.95])
    fig_path = output_dir / f"{image_name}_00_multilevel_kmeans_comparison.png"
    plt.savefig(fig_path, dpi=300)
    print(f"  已保存综合对比图: {fig_path}")
    plt.close()

def process_ct_image(
    image_name: str, 
    image_path: Path, 
    n_clusters: int,
    segment_names: List[str]
) -> Optional[Dict[str, Any]]:
    """
    对单张CT图像执行完整的多阈值复现流程。
    """
    output_dir = Path(f"./{image_name}")
    output_dir.mkdir(exist_ok=True)
    
    print(f"\n{'='*60}")
    print(f"正在处理多阈值图像: {image_name} (来自: {image_path})")
    print(f"预期聚类数 (n_clusters): {n_clusters}")
    print(f"结果将保存至: {output_dir}")
    print(f"{'='*60}")
    
    # 1. 读取图像
    image = cv2.imread(str(image_path))
    if image is None:
        print(f"  [错误] 无法读取图像文件: {image_path}")
        return None
        
    image_gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    cv2.imwrite(str(output_dir / f"{image_name}_01_original_gray.png"), image_gray)

    # 2. 计算梯度和拉普拉斯
    print("  1. 正在计算梯度和拉普拉斯 (8邻域核)...")
    gradient_magnitude, laplacian_image = calculate_image_derivatives(image_gray)
    
    # 3. 执行 Wang & Bai 核心算法
    # T_g 对CT图像可能需要调整，我们从一个中等值开始
    T_g_threshold = 15.0
    print(f"  2. 正在执行 Wang & Bai 边界采样 (T_g = {T_g_threshold})...")
    boundary_samples = find_boundary_sample_points(
        image_gray, gradient_magnitude, laplacian_image, T_g_threshold
    )
    
    if not boundary_samples:
        print("     [警告] 未找到边界点。尝试更低的 T_g = 20.0 ...")
        boundary_samples = find_boundary_sample_points(
            image_gray, gradient_magnitude, laplacian_image, 20.0
        )
        if not boundary_samples:
            print("     [错误] 仍未找到边界点。Wang & Bai 方法失败。")
            return None
        
    print(f"     找到 {len(boundary_samples)} 个边界点。")

    # 4. 计算多阈值 (使用 K-Means)
    print(f"  3. 正在使用 K-Means 寻找 {n_clusters} 个聚类中心...")
    wang_bai_thresholds = find_multilevel_thresholds_kmeans(
        boundary_samples, 
        n_clusters=n_clusters
    )
    
    if not wang_bai_thresholds:
        print(f"     [错误] K-Means 未能找到 {n_clusters} 个聚类。")
        return None
        
    print("\n  --- 阈值计算结果 (K-Means聚类中心) ---")
    for i, t in enumerate(wang_bai_thresholds):
        print(f"    T{i+1} (簇{i+1}均值): {t:.2f}")

    # 5. 执行多阈值分割
    print(f"\n  4. 正在生成 {len(wang_bai_thresholds) + 1} 个图像分段 (二值掩码)...")
    segments = segment_image_by_thresholds(image_gray, wang_bai_thresholds)
    
    # 保存分段图像
    for i, seg_img in enumerate(segments):
        cv2.imwrite(str(output_dir / f"{image_name}_02_segment_{i}.png"), seg_img)

    # 6. 生成图表
    print("\n  5. 正在生成对比图表...")
    generate_multilevel_plots(
        image_name, 
        image_gray, 
        boundary_samples, 
        wang_bai_thresholds, 
        segments, 
        segment_names,
        output_dir
    )

    print(f"  --- {image_name} 处理完成 ---")
    
    return {
        'image_name': image_name,
        'thresholds': wang_bai_thresholds,
        'boundary_points_found': len(boundary_samples),
        'output_dir': output_dir
    }

def main():
    """
    脚本主入口：运行 'leg' 和 'head' CT 图像的复现。
    """
    
    # --- 用户配置区 ---
    IMAGE_FILES = {
        'leg': Path("leg/leg.bmp"),      
    }

    CLUSTER_CONFIG = {
        # 图19(下) "three obvious clusters" -> 3个阈值, 4个分段
        'leg': {
            'n_clusters': 3,
            'segment_names': ['(a) 背景', '(b) 结缔组织', '(c) 肌肉', '(d) 骨头']
        },
    }
    # --- 结束配置区 ---

    all_results = []
    
    print("开始复现CT图像多阈值分割分析 (Wang & Bai, 2003)")
    print(f"将使用 K-Means 聚类方法 (对应论文 4.2节)")
    
    for image_name, image_path in IMAGE_FILES.items():
        if not image_path.exists():
            print(f"\n[跳过] 找不到图像文件: {image_path}")
            print(f"请将 {image_path.name} 放在脚本目录中。")
            continue
            
        if image_name not in CLUSTER_CONFIG:
            print(f"\n[跳过] 找不到 {image_name} 的聚类配置。")
            continue
            
        config = CLUSTER_CONFIG[image_name]
        result = process_ct_image(
            image_name, 
            image_path, 
            n_clusters=config['n_clusters'],
            segment_names=config['segment_names']
        )
        if result:
            all_results.append(result)
    
    # --- 打印最终总结报告 ---
    if all_results:
        print(f"\n\n{'='*70}")
        print("                 复 现 总 结 报 告 (多阈值 K-Means)")
        print(f"{'='*70}")
        
        for res in all_results:
            print(f"\n--- 图像: {res['image_name'].upper()} ---")
            print(f"  边界采样点: {res['boundary_points_found']} 个")
            print(f"  结果保存至: {res['output_dir']}/")
            print(f"  检测到的阈值 (聚类中心):")
            for i, t in enumerate(res['thresholds']):
                print(f"    T{i+1}: {t:.2f}")
            
    else:
        print("\n未处理任何图像。请检查 IMAGE_FILES 字典中的文件路径。")

if __name__ == "__main__":
    main()