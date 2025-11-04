import cv2
import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path
from typing import Tuple, List, Optional, Dict, Any

plt.rcParams['font.sans-serif'] = ['SimHei'] 
plt.rcParams['axes.unicode_minus'] = False  

def calculate_image_derivatives(image_gray: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
    """
    计算图像的梯度幅值和拉普拉斯算子。

    参数:
        image_gray (np.ndarray): 8位灰度图像 (uint8)

    返回:
        Tuple[np.ndarray, np.ndarray]: 
            - gradient_magnitude (float64): 梯度幅值
            - laplacian_image (float64): 拉普拉斯图像
    """
    # 转换为64位浮点数进行精确计算
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

    遍历每个像素，并检查其“右侧”和“下方”的像素边缘。
    如果边缘的两个顶点满足：
    1. 拉普拉斯值反号 (l(p1) * l(p2) < 0)
    2. 梯度和足够高 (g(p1) + g(p2) >= T_g)
    则通过线性插值计算该边界点的灰度值。

    参数:
        image_gray (np.ndarray): 原始灰度图像 (uint8)
        gradient_magnitude (np.ndarray): 梯度幅值图像 (float64)
        laplacian_image (np.ndarray): 拉普拉斯图像 (float64)
        T_g (float): 梯度阈值 T

    返回:
        List[float]: 所有采样到的边界点灰度值列表
    """
    height, width = image_gray.shape
    boundary_samples = []
    
    # 转换为浮点数以便插值
    image_float = image_gray.astype(np.float64)

    # 遍历所有像素，检查其“右侧”和“下方”的边缘
    # 确保网格中的每条边只被检查一次
    for i in range(height - 1):
        for j in range(width - 1):
            
            # 顶点坐标
            p1 = (i, j)
            p2_right = (i, j + 1)
            p3_bottom = (i + 1, j)

            # 提取顶点的值
            l_p1 = laplacian_image[p1]
            g_p1 = gradient_magnitude[p1]
            f_p1 = image_float[p1]

            # 1. 检查“右侧边” (p1 和 p2_right 之间)
            l_p2_r = laplacian_image[p2_right]
            g_p2_r = gradient_magnitude[p2_right]
            
            if (l_p1 * l_p2_r < 0) and (g_p1 + g_p2_r >= T_g):
                # 满足条件，进行线性插值
                weight = abs(l_p1) / (abs(l_p1) + abs(l_p2_r))
                gray_sample = (1 - weight) * f_p1 + weight * image_float[p2_right]
                boundary_samples.append(gray_sample)

            # 2. 检查“下方边” (p1 和 p3_bottom 之间)
            l_p3_b = laplacian_image[p3_bottom]
            g_p3_b = gradient_magnitude[p3_bottom]

            if (l_p1 * l_p3_b < 0) and (g_p1 + g_p3_b >= T_g):
                # 满足条件，进行线性插值
                weight = abs(l_p1) / (abs(l_p1) + abs(l_p3_b))
                gray_sample = (1 - weight) * f_p1 + weight * image_float[p3_bottom]
                boundary_samples.append(gray_sample)
                
    return boundary_samples

def calculate_kapur_entropy_threshold(image_gray: np.ndarray) -> int:
    """
    Kapur 最大熵阈值法。

    参数:
        image_gray (np.ndarray): 8位灰度图像

    返回:
        int: 计算得到的Kapur阈值
    """
    # 1. 计算灰度直方图
    hist, _ = np.histogram(image_gray.ravel(), 256, [0, 256])
    
    # 2. 归一化为概率分布
    total_pixels = image_gray.size
    prob_dist = hist.astype(np.float64) / total_pixels
    
    # 3. 计算累积分布函数 (CDF)
    cdf_p = prob_dist.cumsum()

    max_entropy = -np.inf
    best_threshold = 0

    # 遍历所有可能的阈值 t
    for t in range(1, 256):
        # 4. 分割为“背景” (0...t-1) 和“前景” (t...255)
        
        # 背景
        prob_background = cdf_p[t-1]
        if prob_background <= 0:
            entropy_background = 0
        else:
            # 计算背景的熵
            hist_background = prob_dist[:t] / prob_background
            # 避免 log(0)
            entropy_background = -np.sum(hist_background[hist_background > 0] * np.log(hist_background[hist_background > 0]))

        # 前景
        prob_foreground = 1.0 - prob_background
        if prob_foreground <= 0:
            entropy_foreground = 0
        else:
            # 计算前景的熵
            hist_foreground = prob_dist[t:] / prob_foreground
            entropy_foreground = -np.sum(hist_foreground[hist_foreground > 0] * np.log(hist_foreground[hist_foreground > 0]))

        # 5. 总熵 = 背景熵 + 前景熵
        total_entropy = entropy_background + entropy_foreground

        if total_entropy > max_entropy:
            max_entropy = total_entropy
            best_threshold = t
            
    return best_threshold

def generate_comparison_plots(
    image_name: str,
    image_gray: np.ndarray,
    boundary_samples: List[float],
    thresholds: Dict[str, Optional[float]],
    binaries: Dict[str, np.ndarray],
    output_dir: Path
):
    """
    生成并保存所有对比图表。
    """
    # --- 1. 综合对比图 (2x3) ---
    fig, axes = plt.subplots(2, 3, figsize=(18, 11))
    fig.suptitle(f'"{image_name}" 图像阈值分割方法对比', fontsize=18)

    # --- 第一行 ---
    
    # [0, 0] 原始图像
    axes[0, 0].imshow(image_gray, cmap='gray')
    axes[0, 0].set_title(f'原始图像')
    axes[0, 0].axis('off')
    
    # [0, 1] 全局直方图
    axes[0, 1].hist(image_gray.ravel(), bins=256, range=[0, 256], alpha=0.7, color='darkblue')
    axes[0, 1].set_title('全局直方图 (整图)')
    axes[0, 1].set_xlabel('灰度级')
    axes[0, 1].set_ylabel('像素数量')
    axes[0, 1].grid(True, linestyle='--', alpha=0.3)
    axes[0, 1].set_xlim([0, 255])
    
    # [0, 2] 边界点直方图 
    if boundary_samples:
        axes[0, 2].hist(boundary_samples, bins=50, alpha=0.9, color='darkgreen')
        axes[0, 2].set_title(f'边界采样直方图 (N={len(boundary_samples)})')
        axes[0, 2].set_xlabel('灰度级')
        axes[0, 2].set_ylabel('采样点数量')
        axes[0, 2].grid(True, linestyle='--', alpha=0.3)
        axes[0, 2].set_xlim([0, 255])
    else:
        axes[0, 2].text(0.5, 0.5, '未找到边界采样点', ha='center', va='center', fontsize=12, color='red')
        axes[0, 2].set_title('边界采样直方图')
        axes[0, 2].set_xlim([0, 255])

    # 在直方图上绘制阈值线
    if thresholds['wang_bai'] is not None:
        axes[0, 1].axvline(thresholds['wang_bai'], color='red', linestyle='--', label=f"Wang&Bai: {thresholds['wang_bai']:.1f}")
        axes[0, 2].axvline(thresholds['wang_bai'], color='red', linestyle='--', linewidth=2)
    axes[0, 1].axvline(thresholds['otsu'], color='cyan', linestyle=':', label=f"Otsu: {thresholds['otsu']:.1f}")
    axes[0, 1].axvline(thresholds['kapur'], color='yellow', linestyle=':', label=f"Kapur: {thresholds['kapur']:.1f}")
    axes[0, 1].legend()

    # --- 第二行: 分割结果 ---
    
    # [1, 0] Otsu
    axes[1, 0].imshow(binaries['otsu'], cmap='gray')
    axes[1, 0].set_title(f"Otsu 方法 (t = {thresholds['otsu']:.0f})")
    axes[1, 0].axis('off')
    
    # [1, 1] Kapur
    axes[1, 1].imshow(binaries['kapur'], cmap='gray')
    axes[1, 1].set_title(f"Kapur 方法 (t = {thresholds['kapur']:.0f})")
    axes[1, 1].axis('off')

    # [1, 2] Wang & Bai
    axes[1, 2].imshow(binaries['wang_bai'], cmap='gray')
    if thresholds['wang_bai'] is not None:
        axes[1, 2].set_title(f"Wang & Bai 方法 (t = {thresholds['wang_bai']:.1f})")
    else:
        axes[1, 2].set_title(f"Wang & Bai 方法 (失败)")
    axes[1, 2].axis('off')

    plt.tight_layout(rect=[0, 0.03, 1, 0.95])
    fig_path = output_dir / f"{image_name}_00_comprehensive_comparison.png"
    plt.savefig(fig_path, dpi=300)
    print(f"  已保存综合对比图: {fig_path}")
    plt.close()

def process_image_and_compare_methods(
    image_name: str, 
    image_path: Path, 
    expected_thresholds: Dict[str, float]
) -> Optional[Dict[str, Any]]:
    """
    对单张图像执行完整的复现流程。
    """
    output_dir = Path(f"./{image_name}")
    output_dir.mkdir(exist_ok=True)
    
    print(f"\n{'='*60}")
    print(f"正在处理图像: {image_name} (来自: {image_path})")
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
    print("  1. 正在计算梯度和拉普拉斯...")
    gradient_magnitude, laplacian_image = calculate_image_derivatives(image_gray)
    
    # 3. 执行 Wang & Bai 核心算法
    # T_g 选择 90
    T_g_threshold = 90.0
    print(f"  2. 正在执行 Wang & Bai 边界采样 (T_g = {T_g_threshold})...")
    boundary_samples = find_boundary_sample_points(
        image_gray, gradient_magnitude, laplacian_image, T_g_threshold
    )

    # 4. 计算各方法阈值
    print("  3. 正在计算各方法阈值...")
    
    # Wang & Bai (本文方法)
    # 为简单起见，使用均值(mean)
    if boundary_samples:
        wang_bai_thresh = np.mean(boundary_samples)
        print(f"     找到 {len(boundary_samples)} 个边界点。")
    else:
        # 尝试降低 T_g
        print("     未找到边界点。尝试更低的 T_g = 30.0 ...")
        boundary_samples = find_boundary_sample_points(
            image_gray, gradient_magnitude, laplacian_image, 30.0
        )
        if boundary_samples:
            wang_bai_thresh = np.mean(boundary_samples)
            print(f"     找到 {len(boundary_samples)} 个边界点。")
        else:
            print("     [警告] 仍未找到边界点。Wang & Bai 方法失败。")
            wang_bai_thresh = None

    # Otsu (OpenCV)
    otsu_thresh, binary_otsu = cv2.threshold(
        image_gray, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU
    )
    
    # Kapur (自定义实现)
    kapur_thresh = calculate_kapur_entropy_threshold(image_gray)
    _, binary_kapur = cv2.threshold(image_gray, kapur_thresh, 255, cv2.THRESH_BINARY)
    
    # Wang & Bai 二值化
    if wang_bai_thresh is not None:
        _, binary_wang_bai = cv2.threshold(image_gray, wang_bai_thresh, 255, cv2.THRESH_BINARY)
    else:
        # 如果方法失败，生成全黑图像
        binary_wang_bai = np.zeros_like(image_gray)

    # 5. 结果汇总
    thresholds = {
        'wang_bai': wang_bai_thresh,
        'otsu': otsu_thresh,
        'kapur': kapur_thresh
    }
    binaries = {
        'wang_bai': binary_wang_bai,
        'otsu': binary_otsu,
        'kapur': binary_kapur
    }
    
    print("\n  --- 阈值计算结果 ---")
    print(f"    Wang & Bai: {thresholds['wang_bai']:.2f} \t (论文值: {expected_thresholds['wang_bai']})")
    print(f"    Otsu:       {thresholds['otsu']:.2f} \t (论文值: {expected_thresholds['otsu']})")
    print(f"    Kapur:      {thresholds['kapur']:.2f} \t (论文值: {expected_thresholds['kapur']})")

    # 6. 生成图表
    print("\n  4. 正在生成对比图表...")
    generate_comparison_plots(
        image_name, image_gray, boundary_samples, thresholds, binaries, output_dir
    )
    
    # 7. 保存二值化结果
    cv2.imwrite(str(output_dir / f"{image_name}_02_otsu_binary.png"), binary_otsu)
    cv2.imwrite(str(output_dir / f"{image_name}_03_kapur_binary.png"), binary_kapur)
    cv2.imwrite(str(output_dir / f"{image_name}_04_wangbai_binary.png"), binary_wang_bai)

    print(f"  --- {image_name} 处理完成 ---")
    
    return {
        'image_name': image_name,
        'thresholds': thresholds,
        'expected': expected_thresholds,
        'boundary_points_found': len(boundary_samples),
        'output_dir': output_dir
    }

def main():
    """
    脚本主入口：运行 'girl' 图像的复现。
    """
    
    # --- 用户配置区 ---
    IMAGE_FILES = {
        'girl': Path("girl/girl.bmp"),     
    }

    # 论文中报告的阈值 [Wang&Bai, Otsu, Kapur]
    EXPECTED_THRESHOLDS = {
        'girl': {'wang_bai': 90, 'otsu': 101, 'kapur': 139},
    }
    # --- 结束配置区 ---

    all_results = []
    
    for image_name, image_path in IMAGE_FILES.items():
        if not image_path.exists():
            print(f"\n[跳过] 找不到图像文件: {image_path}")
            print(f"请将 {image_path.name} 放在脚本目录中。")
            continue
            
        if image_name not in EXPECTED_THRESHOLDS:
            print(f"\n[跳过] 找不到 {image_name} 的期望阈值数据。")
            continue
            
        result = process_image_and_compare_methods(
            image_name, 
            image_path, 
            EXPECTED_THRESHOLDS[image_name]
        )
        if result:
            all_results.append(result)
    
    # --- 打印最终总结报告 ---
    if all_results:
        print(f"\n\n{'='*70}")
        print("                 复 现 总 结 报 告")
        print(f"{'='*70}")
        
        for res in all_results:
            print(f"\n--- 图像: {res['image_name'].upper()} ---")
            print(f"  边界采样点: {res['boundary_points_found']} 个")
            print(f"  结果保存至: {res['output_dir']}/")
            print(f"  方法        |  复现值  |  论文值  |  差异")
            print(f"  -----------------------------------------------")
            
            # Wang&Bai
            wb_rep = res['thresholds']['wang_bai']
            wb_exp = res['expected']['wang_bai']
            if wb_rep is not None:
                wb_diff = wb_rep - wb_exp
                print(f"  Wang & Bai  |  {wb_rep: <7.2f} |  {wb_exp: <7.2f} |  {wb_diff: <+7.2f}")
            else:
                print(f"  Wang & Bai  |  失败    |  {wb_exp: <7.2f} |   ---")
                
            # Otsu
            ot_rep = res['thresholds']['otsu']
            ot_exp = res['expected']['otsu']
            ot_diff = ot_rep - ot_exp
            print(f"  Otsu        |  {ot_rep: <7.2f} |  {ot_exp: <7.2f} |  {ot_diff: <+7.2f}")
            
            # Kapur
            ka_rep = res['thresholds']['kapur']
            ka_exp = res['expected']['kapur']
            ka_diff = ka_rep - ka_exp
            print(f"  Kapur       |  {ka_rep: <7.2f} |  {ka_exp: <7.2f} |  {ka_diff: <+7.2f}")
            
    else:
        print("\n未处理任何图像。请检查 IMAGE_FILES 字典中的 'girl' 文件路径。")

if __name__ == "__main__":
    main()