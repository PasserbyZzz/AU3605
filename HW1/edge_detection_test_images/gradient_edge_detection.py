import cv2
import numpy as np
import matplotlib.pyplot as plt
import os

plt.rcParams['font.sans-serif'] = ['SimHei']
plt.rcParams['axes.unicode_minus'] = False

def roberts_operator(img):
    # Roberts Gx
    kernel_x = np.array([[1, 0], [0, -1]], dtype=np.float64)
    # Roberts Gy
    kernel_y = np.array([[0, 1], [-1, 0]], dtype=np.float64)

    # 卷积运算
    Gx = cv2.filter2D(img, cv2.CV_64F, kernel_x)
    Gy = cv2.filter2D(img, cv2.CV_64F, kernel_y)

    # 计算幅值 M = sqrt(Gx^2 + Gy^2)
    magnitude = cv2.magnitude(Gx, Gy)
    return cv2.convertScaleAbs(magnitude)

def prewitt_operator(img):
    # Prewitt Gx
    kernel_x = np.array([[-1, 0, 1],
                         [-1, 0, 1],
                         [-1, 0, 1]], dtype=np.float64)
    # Prewitt Gy
    kernel_y = np.array([[-1, -1, -1],
                         [0,  0,  0],
                         [1,  1,  1]], dtype=np.float64)

    # 卷积运算
    Gx = cv2.filter2D(img, cv2.CV_64F, kernel_x)
    Gy = cv2.filter2D(img, cv2.CV_64F, kernel_y)

    # 计算幅值 M = sqrt(Gx^2 + Gy^2)
    magnitude = cv2.magnitude(Gx, Gy)
    return cv2.convertScaleAbs(magnitude)

def sobel_operator(img):
    # Sobel Gx
    Gx = cv2.Sobel(img, cv2.CV_64F, 1, 0, ksize=3)
    # Sobel Gy
    Gy = cv2.Sobel(img, cv2.CV_64F, 0, 1, ksize=3)

    # 计算幅值 M = sqrt(Gx^2 + Gy^2)
    magnitude = cv2.magnitude(Gx, Gy)
    return cv2.convertScaleAbs(magnitude)

def process_and_display(img_name, img_path):
    img = cv2.imread(img_path, cv2.IMREAD_GRAYSCALE)

    res_roberts = roberts_operator(img)
    res_prewitt = prewitt_operator(img)
    res_sobel = sobel_operator(img)

    plt.figure(figsize=(16, 5))
    plt.suptitle(f"一阶微分算子对比分析（{img_name}）", fontsize=16)

    titles = ["原图", "Roberts算子", "Prewitt算子", "Sobel算子"]
    images = [img, res_roberts, res_prewitt, res_sobel]

    for i in range(4):
        plt.subplot(1, 4, i+1)
        plt.imshow(images[i], cmap='gray')
        plt.title(titles[i], fontsize=12)
        plt.axis('off')

    plt.tight_layout()
    filename = os.path.basename(img_path)
    name_no_ext, _ = os.path.splitext(filename)
    plt.savefig(f"edge_detection_test_images/results/{name_no_ext}_first_comparison.png")

def main():
    test_images = [
        ("简单图像", "edge_detection_test_images/simple_image_1.bmp"), 
        ("简单图像", "edge_detection_test_images/simple_image_2.bmp"), 
        ("复杂图像", "edge_detection_test_images/complex_image_1.jpg"),
        ("复杂图像", "edge_detection_test_images/complex_image_2.jpg"),
        ("噪声图像", "edge_detection_test_images/image_with_noise.jpg"),
    ]

    for name, path in test_images:
        process_and_display(name, path)

if __name__ == "__main__":
    main()