import cv2
import numpy as np
import matplotlib.pyplot as plt
import os


plt.rcParams['font.sans-serif'] = ['SimHei']
plt.rcParams['axes.unicode_minus'] = False

def laplacian_abs(img):
    # 标准 Laplacian
    dst = cv2.Laplacian(img, cv2.CV_64F, ksize=3)
    return cv2.convertScaleAbs(dst)

def log_zero_crossing(img, sigma, threshold=0.0):
    # 高斯平滑
    blurred = cv2.GaussianBlur(img, (0, 0), sigma)
    
    # Laplacian
    log_response = cv2.Laplacian(blurred, cv2.CV_64F, ksize=3)
    
    # 零交叉检测
    rows, cols = log_response.shape
    zc_img = np.zeros((rows, cols), dtype=np.uint8)
    
    # 设定阈值约束
    for r in range(rows - 1):
        for c in range(cols - 1):
            curr = log_response[r, c]
            
            # 检查右侧
            right = log_response[r, c+1]
            if curr * right < 0: # 符号相反
                if np.abs(curr - right) > threshold:
                    zc_img[r, c] = 255
                    continue # 找到一个方向即可标记为边缘
            
            # 检查下侧
            bottom = log_response[r+1, c]
            if curr * bottom < 0:
                if np.abs(curr - bottom) > threshold:
                    zc_img[r, c] = 255

    return zc_img

def process_comprehensive(img_name, img_path):
    img = cv2.imread(img_path, cv2.IMREAD_GRAYSCALE)

    sigma_small = 1.0
    sigma_medium = 2.0
    sigma_large = 4.0
    
    high_thresh = 5.0 

    img1 = img
    img2 = laplacian_abs(img)
    img3 = log_zero_crossing(img, sigma_small, threshold=2.0) 
    img4 = log_zero_crossing(img, sigma_medium, threshold=2.0)
    img5 = log_zero_crossing(img, sigma_large, threshold=2.0)
    img6 = log_zero_crossing(img, sigma_small, threshold=high_thresh)
    img7 = log_zero_crossing(img, sigma_medium, threshold=high_thresh)
    img8 = log_zero_crossing(img, sigma_large, threshold=high_thresh)

    plt.figure(figsize=(20, 10))
    plt.suptitle(f"二阶微分算子对比分析（{img_name}）", fontsize=18)

    images = [img1, img2, img3, img4, img5, img6, img7, img8]
    titles = [
        "原图", 
        "Laplacian 算子", 
        f"LoG (小尺度 $\sigma={sigma_small}$)", 
        f"LoG (中尺度 $\sigma={sigma_medium}$)", 
        f"LoG (大尺度 $\sigma={sigma_large}$)", 
        f"LoG (小尺度) + 高梯度阈值", 
        f"LoG (中尺度) + 高梯度阈值", 
        f"LoG (大尺度) + 高梯度阈值"
    ]

    for i in range(8):
        plt.subplot(2, 4, i+1)
        plt.imshow(images[i], cmap='gray')
        plt.title(titles[i], fontsize=12)
        plt.axis('off')

    plt.tight_layout()
    filename = os.path.basename(img_path)
    name_no_ext, _ = os.path.splitext(filename)
    plt.savefig(f"edge_detection_test_images/results/{name_no_ext}_second_comparison.png")

def main():
    path = "edge_detection_test_images/image_with_noise.jpg"

    if os.path.exists(path):
        process_comprehensive("噪声图像", path)
    else:
        print(f"请准备测试图像: {path}")

if __name__ == "__main__":
    main()