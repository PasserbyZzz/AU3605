import cv2
import matplotlib.pyplot as plt
import os
import numpy as np

plt.rcParams['font.sans-serif'] = ['SimHei']
plt.rcParams['axes.unicode_minus'] = False

img_path = "threshold_segmentation_test_images/simple_image_1.bmp"

img = cv2.imread(img_path, cv2.IMREAD_GRAYSCALE)

best_threshold, otsu_img = cv2.threshold(img, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)

print(f"Otsu 算法计算出的最佳阈值: {best_threshold}")

plt.figure(figsize=(12, 6))
plt.suptitle("Otsu's 分割结果（简单图像）", fontsize=20)

plt.subplot(1, 2, 1)
plt.imshow(img, cmap='gray')
plt.title("原图 (Original)")
plt.axis('off')

plt.subplot(1, 2, 2)
plt.imshow(otsu_img, cmap='gray')
plt.title(f"Otsu 阈值分割 (T={best_threshold})")
plt.axis('off')

plt.tight_layout()

output_path = "threshold_segmentation_test_images/results/simple_image_1_otsu.png"
plt.savefig(output_path, dpi=300)
print(f"结果已保存为 {output_path}")