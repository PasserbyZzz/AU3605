import cv2
import numpy as np
import matplotlib.pyplot as plt
import os

plt.rcParams['font.sans-serif'] = ['SimHei']
plt.rcParams['axes.unicode_minus'] = False

def non_max_suppression(magnitude, angle_deg):
    # 非极大值抑制 (NMS)
    M, N = magnitude.shape
    nms_img = np.zeros((M, N), dtype=np.float32)
    
    # 将角度归一化到 0-180
    angle_deg[angle_deg < 0] += 180

    for i in range(1, M-1):
        for j in range(1, N-1):
            try:
                q = 255
                r = 255
                
                # 梯度方向 0度 (左右邻居)
                if (0 <= angle_deg[i,j] < 22.5) or (157.5 <= angle_deg[i,j] <= 180):
                    q = magnitude[i, j+1]
                    r = magnitude[i, j-1]
                # 梯度方向 45度 (右上/左下)
                elif (22.5 <= angle_deg[i,j] < 67.5):
                    q = magnitude[i+1, j-1]
                    r = magnitude[i-1, j+1]
                # 梯度方向 90度 (上下)
                elif (67.5 <= angle_deg[i,j] < 112.5):
                    q = magnitude[i+1, j]
                    r = magnitude[i-1, j]
                # 梯度方向 135度 (左上/右下)
                elif (112.5 <= angle_deg[i,j] < 157.5):
                    q = magnitude[i-1, j-1]
                    r = magnitude[i+1, j+1]

                # 只有当当前像素大于沿梯度方向的两个邻居时，才保留
                if (magnitude[i,j] >= q) and (magnitude[i,j] >= r):
                    nms_img[i,j] = magnitude[i,j]
                else:
                    nms_img[i,j] = 0

            except IndexError as e:
                pass
                
    # 归一化以便显示
    return cv2.convertScaleAbs(nms_img)

def analyze_canny_internals(img_name, img_path):
    # canny 内部实现
    img = cv2.imread(img_path, cv2.IMREAD_GRAYSCALE)

    # 高斯平滑
    blurred = cv2.GaussianBlur(img, (3, 3), .5)

    # 计算梯度幅值和方向
    gx = cv2.Sobel(blurred, cv2.CV_64F, 1, 0, ksize=3)
    gy = cv2.Sobel(blurred, cv2.CV_64F, 0, 1, ksize=3)
    magnitude = cv2.magnitude(gx, gy)
    angle = cv2.phase(gx, gy, angleInDegrees=True)

    # 非极大值抑制
    nms_result = non_max_suppression(magnitude, angle)

    # 阈值设定
    high_thresh = np.max(nms_result) * 0.15
    low_thresh = high_thresh * 0.4
    
    # 模拟单一阈值效果
    _, single_low = cv2.threshold(nms_result, low_thresh, 255, cv2.THRESH_BINARY)
    _, single_high = cv2.threshold(nms_result, high_thresh, 255, cv2.THRESH_BINARY)

    # 完整的 Canny
    canny_final = cv2.Canny(blurred, 100, 250)

    plt.figure(figsize=(20, 8))
    plt.suptitle(f"Canny 算法NMS实现与单双阈值分析（{img_name}）", fontsize=18)

    plt.subplot(1, 5, 1)
    plt.imshow(cv2.convertScaleAbs(magnitude), cmap='gray')
    plt.title("梯度幅值 (Sobel)")
    plt.axis('off')

    plt.subplot(1, 5, 2)
    plt.imshow(nms_result, cmap='gray')
    plt.title("非极大值抑制 (NMS)")
    plt.axis('off')

    plt.subplot(1, 5, 3)
    plt.imshow(single_low, cmap='gray')
    plt.title(f"单一低阈值 (T={int(low_thresh)})")
    plt.axis('off')

    plt.subplot(1, 5, 4)
    plt.imshow(single_high, cmap='gray')
    plt.title(f"单一高阈值 (T={int(high_thresh)})")
    plt.axis('off')

    plt.subplot(1, 5, 5)
    plt.imshow(canny_final, cmap='gray')
    plt.title("滞后双阈值 (Canny)")
    plt.axis('off')

    plt.tight_layout()
    filename = os.path.basename(img_path)
    name_no_ext, _ = os.path.splitext(filename)
    plt.savefig(f"edge_detection_test_images/results/{name_no_ext}_canny_analysis.png")

def analyze_canny_scales(img_name, img_path):
    # 多尺度 Canny 检测
    img = cv2.imread(img_path, cv2.IMREAD_GRAYSCALE)

    # 设置阈值
    T_low = 50
    T_high = 150

    # 小尺度 (Sigma 小 -> 模糊核小)
    blur_small = cv2.GaussianBlur(img, (3, 3), 0.5)
    canny_small = cv2.Canny(blur_small, T_low, T_high)

    # 中尺度
    blur_med = cv2.GaussianBlur(img, (7, 7), 1.5)
    canny_med = cv2.Canny(blur_med, T_low, T_high)

    # 大尺度 (Sigma 大 -> 模糊核大)
    blur_large = cv2.GaussianBlur(img, (13, 13), 3.0)
    canny_large = cv2.Canny(blur_large, T_low, T_high)

    plt.figure(figsize=(16, 6))
    plt.suptitle(f"Canny 算法多尺度分析（{img_name}）", fontsize=18)

    plt.subplot(1, 4, 1)
    plt.imshow(img, cmap='gray')
    plt.title("原图")
    plt.axis('off')

    plt.subplot(1, 4, 2)
    plt.imshow(canny_small, cmap='gray')
    plt.title("小尺度 ($\sigma=0.5$)")
    plt.axis('off')

    plt.subplot(1, 4, 3)
    plt.imshow(canny_med, cmap='gray')
    plt.title("中尺度 ($\sigma=1.5$)")
    plt.axis('off')

    plt.subplot(1, 4, 4)
    plt.imshow(canny_large, cmap='gray')
    plt.title("大尺度 ($\sigma=3.0$)")
    plt.axis('off')

    plt.tight_layout()
    filename = os.path.basename(img_path)
    name_no_ext, _ = os.path.splitext(filename)
    plt.savefig(f"edge_detection_test_images/results/{name_no_ext}_canny_comparison.png")

def main():
    path_simple = "edge_detection_test_images/simple_image_1.bmp"
    path_complex = "edge_detection_test_images/complex_image_2.jpg"
    path_noise = "edge_detection_test_images/image_with_noise.jpg"
    path_multiscale = "edge_detection_test_images/multiscale_image_1.jpg"

    # 原理拆解
    # analyze_canny_internals("简单图像", path_simple)
    # analyze_canny_internals("复杂图像", path_complex)
    # analyze_canny_internals("噪声图像", path_noise)
    analyze_canny_internals("多尺度图像", path_multiscale)
    
    # 多尺度分析
    # analyze_canny_scales("简单图像", path_simple)
    # analyze_canny_scales("复杂图像", path_complex)
    # analyze_canny_scales("噪声图像", path_noise)

if __name__ == "__main__":
    main()