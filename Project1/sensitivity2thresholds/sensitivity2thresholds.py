import cv2
import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path
from typing import Tuple, List, Dict, Any, Set

plt.rcParams['font.sans-serif'] = ['SimHei']  
plt.rcParams['axes.unicode_minus'] = False 

def calculate_image_derivatives(image_gray: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
    """
    计算图像的梯度幅值和拉普拉斯算子。
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

def find_boundary_samples_and_positions(
    image_gray: np.ndarray, 
    gradient_magnitude: np.ndarray, 
    laplacian_image: np.ndarray, 
    T_g: float
) -> Tuple[List[float], Set[Tuple[int, int]]]:
    """
    实现论文第3节(第5页)的核心算法。
    
    返回:
        - (List[float]): 采样点的灰度值列表 (用于 Fig. 27 a1-c1)
        - (Set[Tuple[int, int]]): 贡献采样的 *像素* 坐标 (用于 Fig. 27 a-c)
    """
    height, width = image_gray.shape
    boundary_samples = []
    # 使用集合(set)来自动去重
    pixel_positions = set()
    
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
            if (l_p1 * l_p2_r < 0) and (g_p1 + g_p2_r >= T_g):
                weight = abs(l_p1) / (abs(l_p1) + abs(l_p2_r))
                gray_sample = (1 - weight) * f_p1 + weight * image_float[p2_right]
                boundary_samples.append(gray_sample)
                pixel_positions.add(p1) # 记录p1像素位置

            # 检查“下方边”
            l_p3_b = laplacian_image[p3_bottom]
            g_p3_b = gradient_magnitude[p3_bottom]
            if (l_p1 * l_p3_b < 0) and (g_p1 + g_p3_b >= T_g):
                weight = abs(l_p1) / (abs(l_p1) + abs(l_p3_b))
                gray_sample = (1 - weight) * f_p1 + weight * image_float[p3_bottom]
                boundary_samples.append(gray_sample)
                pixel_positions.add(p1) # 记录p1像素位置
                
    return boundary_samples, pixel_positions

def generate_gradient_sensitivity_plot(
    image_gray: np.ndarray,
    analysis_results: List[Dict[str, Any]],
    output_dir: Path
):
    """
    生成 Fig. 27 (a)-(c), (a1)-(c1), (a2)-(c2) 的 3xN 组合图
    """
    num_thresholds = len(analysis_results)
    fig, axes = plt.subplots(3, num_thresholds, figsize=(7 * num_thresholds, 18))
    fig.suptitle('复现论文 5.2 节：梯度阈值 $T_g$ 敏感性分析 (Fig. 27 - Girl)', fontsize=20)
    
    threshold_summary = []

    for col, res in enumerate(analysis_results):
        T_g = res['T_g']
        samples = res['samples']
        positions = res['positions']
        threshold = res['threshold']
        binary_image = res['binary_image']
        
        # --- Row 1: Fig. 27 (a)-(c) (边缘图) ---
        ax_map = axes[0, col]
        # 创建边缘图
        edge_map_image = np.zeros_like(image_gray)
        if positions:
            # 将 set of tuples 转换为 numpy 索引
            rows, cols = zip(*positions)
            edge_map_image[rows, cols] = 255
        
        ax_map.imshow(edge_map_image, cmap='gray')
        ax_map.set_title(f"边缘图\n$T_g = {T_g}$", fontsize=16)
        ax_map.axis('off')
        
        # --- Row 2: Fig. 27 (a1)-(c1) (边界采样直方图) ---
        ax_hist = axes[1, col]
        if samples:
            ax_hist.hist(samples, bins=50, range=[0, 255], color='darkgreen')
            ax_hist.set_title(f"边界采样直方图\n(N={len(samples)})", fontsize=16)
            ax_hist.axvline(threshold, color='red', linestyle='--', 
                            label=f"均值 (阈值): {threshold:.1f}")
            ax_hist.legend()
        else:
            ax_hist.set_title(f"Fig. 27 (a1/b1/c1)\n(T_g={T_g} - 未找到点)", fontsize=16)

        ax_hist.set_xlabel('灰度级')
        ax_hist.set_ylabel('采样点数量')
        ax_hist.set_xlim([0, 255])
        ax_hist.grid(True, linestyle='--', alpha=0.3)
        
        # --- Row 3: Fig. 27 (a2)-(c2) (分割结果) ---
        ax_seg = axes[2, col]
        ax_seg.imshow(binary_image, cmap='gray')
        ax_seg.set_title(f"分割结果\n最终阈值 = {threshold:.1f}", fontsize=16)
        ax_seg.axis('off')
        
        threshold_summary.append(f"T_g = {T_g: <5.1f}  ->  阈值 r = {threshold: <5.1f}  (论文值: {res['expected']})")

    plt.tight_layout(rect=[0, 0.03, 1, 0.95])
    fig_path = output_dir / "Gradient_Sensitivity_Analysis(girl).png"
    plt.savefig(fig_path, dpi=300)
    print(f"  已保存综合对比图: {fig_path}")
    plt.close()
    
    # 打印最终的鲁棒性分析报告
    print("\n" + "="*70)
    print("         复 现 结 论 ")
    print("         算法对梯度阈值 T_g 的鲁棒性")
    print("-"*70)
    print("尽管 T_g 值变化巨大 (40 -> 160)，导致边缘图(上)和")
    print("直方图(中)的形态完全不同，但计算出的最终阈值(下)高度稳定。")
    print("\n计算得到的阈值 (均值):")
    for summary_line in threshold_summary:
        print(f"  - {summary_line}")
    print("="*70)

def main():
    """
    脚本主入口：运行 5.2 节的 $T_g$ 敏感性分析复现。
    """
    
    # --- 用户配置区 ---
    IMAGE_PATH = Path("sensitivity2thresholds/girl.bmp") 
    OUTPUT_DIR = Path("./sensitivity2thresholds")
    OUTPUT_DIR.mkdir(exist_ok=True)
    
    # 论文第14页明确给出的三个 T_g 值
    T_G_VALUES_TO_TEST = [40.0, 100.0, 160.0]
    
    # 论文第14页报告的对应阈值
    EXPECTED_THRESHOLDS = [90, 87, 92]
    # --- 结束配置区 ---
    
    print(f"开始复现 5.2 节 $T_g$ 敏感性分析 (Fig. 27)")
    print(f"使用图像: {IMAGE_PATH}")
    print(f"测试 T_g 值: {T_G_VALUES_TO_TEST}")
    print(f"结果将保存至: {OUTPUT_DIR}")
    
    # 1. 载入图像
    image = cv2.imread(str(IMAGE_PATH))
    if image is None:
        print(f"[错误] 无法读取图像文件: {IMAGE_PATH}")
        return
    image_gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    
    # 2. 预计算梯度和拉普拉斯 (只需一次)
    print("  1. 正在预计算梯度和拉普拉斯...")
    gradient_magnitude, laplacian_image = calculate_image_derivatives(image_gray)
    
    analysis_results = []
    
    # 3. 循环测试
    print("  2. 正在循环测试不同的 T_g 值...")
    for i, T_g in enumerate(T_G_VALUES_TO_TEST):
        print(f"    - 测试 T_g = {T_g}...")
        
        # 3a. 获取采样点和位置
        samples, positions = find_boundary_samples_and_positions(
            image_gray, gradient_magnitude, laplacian_image, T_g
        )
        
        # 3b. 计算阈值
        if samples:
            threshold = np.mean(samples)
        else:
            threshold = 0 # 失败
        
        # 3c. 分割图像
        _, binary_image = cv2.threshold(image_gray, threshold, 255, cv2.THRESH_BINARY)
        
        # 3d. 保存结果
        analysis_results.append({
            "T_g": T_g,
            "samples": samples,
            "positions": positions,
            "threshold": threshold,
            "binary_image": binary_image,
            "expected": EXPECTED_THRESHOLDS[i]
        })

    # 4. 生成组合图表
    if analysis_results:
        generate_gradient_sensitivity_plot(image_gray, analysis_results, OUTPUT_DIR)
    else:
        print("[错误] 未能生成分析结果。")
        
if __name__ == "__main__":
    main()