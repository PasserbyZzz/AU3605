import cv2
import numpy as np
import matplotlib.pyplot as plt
import os

plt.rcParams['font.sans-serif'] = ['SimHei']
plt.rcParams['axes.unicode_minus'] = False

class QuadTreeSplitter:
    def __init__(self, img, std_thresh=10.0, min_size=4):
        self.img = img
        self.h, self.w = img.shape
        self.std_thresh = std_thresh  # 均匀性阈值
        self.min_size = min_size      # 最小区域尺寸
        
        # 用于可视化的结果图
        self.result_image = np.zeros_like(img)
        # 用于绘制分割线的画布
        self.draw_lines = cv2.cvtColor(img, cv2.COLOR_GRAY2BGR)

    def split(self, x, y, w, h):
        # 递归分裂函数
        # 获取当前区域 (ROI)
        roi = self.img[y:y+h, x:x+w]
        
        # 计算均值和标准差
        mean, std = cv2.meanStdDev(roi)
        mean = mean[0][0]
        std = std[0][0]

        # 判定准则: 
        # 1. 区域足够均匀 (std < T_split) 
        # 2. 区域已经太小 (size <= MinSize)
        if std <= self.std_thresh or w <= self.min_size or h <= self.min_size:
            # -> 停止分裂，作为叶子节点
            # 用区域均值填充结果图
            self.result_image[y:y+h, x:x+w] = int(mean)
        else:
            # -> 继续分裂 (递归)
            # 计算分裂点 (中心)
            half_w = int(w / 2)
            half_h = int(h / 2)
            
            # 绘制分割线 (为了可视化递归过程)
            cv2.line(self.draw_lines, (x, y + half_h), (x + w, y + half_h), (0, 0, 255), 1)
            cv2.line(self.draw_lines, (x + half_w, y), (x + half_w, y + h), (0, 0, 255), 1)

            # 递归调用四个子象限
            # 左上
            self.split(x, y, half_w, half_h)
            # 右上
            self.split(x + half_w, y, w - half_w, half_h)
            # 左下
            self.split(x, y + half_h, half_w, h - half_h)
            # 右下
            self.split(x + half_w, y + half_h, w - half_w, h - half_h)

    def run(self):
        print("正在执行四叉树递归分裂...")
        # 从整张图开始分裂
        self.split(0, 0, self.w, self.h)
        return self.result_image, self.draw_lines

def main():
    # 建议路径
    path = "region_splitting_merging_test_images/complex_image_2.bmp"
    img = cv2.imread(path, cv2.IMREAD_GRAYSCALE)

    # 初始化算法
    # std_thresh 越大，容忍度越高，块越大；越小，分得越细
    splitter = QuadTreeSplitter(img, std_thresh=15.0, min_size=4)
    
    res_segment, res_grid = splitter.run()

    plt.figure(figsize=(15, 5))
    plt.suptitle("区域分裂与合并算法实现（复杂图像）", fontsize=16)

    plt.subplot(1, 3, 1)
    plt.imshow(img, cmap='gray')
    plt.title("原图")
    plt.axis('off')

    plt.subplot(1, 3, 2)
    plt.imshow(cv2.cvtColor(res_grid, cv2.COLOR_BGR2RGB))
    plt.title("分裂过程")
    plt.axis('off')

    plt.subplot(1, 3, 3)
    plt.imshow(res_segment, cmap='gray')
    plt.title("分割结果")
    plt.axis('off')

    plt.tight_layout()
    filename = os.path.basename(path)
    name_no_ext, _ = os.path.splitext(filename)
    plt.savefig(f"region_splitting_merging_test_images/results/{name_no_ext}_quadtree_split.png")

if __name__ == "__main__":
    main()