import cv2
import matplotlib.pyplot as plt
import numpy as np
import os

plt.rcParams['font.sans-serif'] = ['SimHei']  
plt.rcParams['axes.unicode_minus'] = False  

img_path = "gaussian_multiscale_smoothing_test_images/gray_gaussian_noise_3.jpg"
img = cv2.imread(img_path, cv2.IMREAD_GRAYSCALE)

kernel_sizes = [
    (5, 5), 
    (7, 7), 
    (9, 9), 
    (11, 11), 
    (13, 13)
]

plt.figure(figsize=(15, 8))
plt.suptitle("不同高斯核的平滑效果比较（高斯噪声图像）", fontsize=20)

plt.subplot(2, 3, 1)
plt.imshow(img, cmap='gray')
plt.title("原始图像")
plt.axis('off')

for i, ksize in enumerate(kernel_sizes):
    blurred_img = cv2.GaussianBlur(img, ksize, sigmaX=0)

    plt.subplot(2, 3, i + 2)
    plt.imshow(blurred_img, cmap='gray')
    plt.title(f"高斯滤波 {ksize[0]}x{ksize[1]}")
    plt.axis('off')

plt.tight_layout()

output_path = "gaussian_multiscale_smoothing_test_images/results/gaussian_noise_3_gaussian_blur.png"
plt.savefig(output_path, dpi=300)
print(f"结果已显示并保存为 {output_path}")