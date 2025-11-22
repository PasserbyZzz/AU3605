import cv2
import numpy as np
import matplotlib.pyplot as plt
from collections import deque
import os

plt.rcParams['font.sans-serif'] = ['SimHei']
plt.rcParams['axes.unicode_minus'] = False

class RegionGrower:
    def __init__(self, img_path, threshold=10):
        # 读取灰度图
        self.img_path = img_path
        self.img = cv2.imread(img_path, cv2.IMREAD_GRAYSCALE)
        
        self.h, self.w = self.img.shape
        self.threshold = threshold
        self.seeds = []
        self.output = np.zeros_like(self.img) # 分割结果图

    def get_8_neighbors(self, x, y):
        """获取 8 邻域坐标"""
        neighbors = []
        for dx in [-1, 0, 1]:
            for dy in [-1, 0, 1]:
                if dx == 0 and dy == 0: continue
                nx, ny = x + dx, y + dy
                if 0 <= nx < self.w and 0 <= ny < self.h:
                    neighbors.append((nx, ny))
        return neighbors

    def region_growing(self, seed):
        """执行区域生长算法 (BFS)"""
        seed_val = float(self.img[seed[1], seed[0]])
        q = deque([seed])
        
        count = 0
        while q:
            cx, cy = q.popleft()
            
            if self.output[cy, cx] == 255:
                continue
                
            # 标记为前景 (白色)
            self.output[cy, cx] = 255
            count += 1

            for nx, ny in self.get_8_neighbors(cx, cy):
                if self.output[ny, nx] == 255:
                    continue
                
                # 相似性准则: 灰度差 <= 阈值
                pixel_val = float(self.img[ny, nx])
                if abs(pixel_val - seed_val) <= self.threshold:
                    # 简单优化：如果尚未加入结果图，则入队
                    # (注：严格BFS需visited数组，此处简化利用output做标记)
                    q.append((nx, ny))
        
        return count

    def on_mouse(self, event, x, y, flags, param):
        """鼠标点击回调"""
        if event == cv2.EVENT_LBUTTONDOWN:
            print(f"捕获种子点: ({x}, {y}), 灰度值: {self.img[y, x]}")
            self.seeds.append((x, y))
            
            self.region_growing((x, y))
            
            result_win_name = "Segmented Result (Preview)"
            cv2.namedWindow(result_win_name, cv2.WINDOW_NORMAL)
            cv2.resizeWindow(result_win_name, 600, int(600 * self.h / self.w)) # 保持比例缩放
            cv2.imshow(result_win_name, self.output)

    def run_and_plot(self):
        """运行交互并在结束后绘制 1*2 对比图"""
        window_name = "Interactive Selection (Press 'q' to Finish)"
        cv2.namedWindow(window_name, cv2.WINDOW_NORMAL)
        display_width = 800
        display_height = int(display_width * self.h / self.w)
        cv2.resizeWindow(window_name, display_width, display_height)
        cv2.setMouseCallback(window_name, self.on_mouse)
        
        print("-" * 40)
        print("【操作步骤】")
        print("1. 鼠标左键点击图像中感兴趣的目标区域（作为种子）。")
        print("2. 支持点击多个点（生长区域会合并）。")
        print("3. 完成后，按键盘上的 'q' 或 'ESC' 键退出交互并生成最终对比图。")
        print("-" * 40)
        
        # 显示原图供点击
        cv2.imshow(window_name, self.img)
        
        # 等待直到用户按键退出
        while True:
            k = cv2.waitKey(1) & 0xFF
            if k == 27 or k == ord('q'): # ESC or 'q'
                break
        
        cv2.destroyAllWindows()

        plt.figure(figsize=(12, 6))
        
        plt.subplot(1, 2, 1)
        plt.suptitle(f"区域生长算法实现（简单图像）", fontsize=18)
        plt.imshow(self.img, cmap='gray')
        plt.title("原始图像")
        plt.axis('off')

        plt.subplot(1, 2, 2)
        plt.imshow(self.output, cmap='gray')
        plt.title(f"区域生长结果 (阈值 T={self.threshold})")
        plt.axis('off')

        plt.tight_layout()
        filename = os.path.basename(self.img_path)
        name_no_ext, _ = os.path.splitext(filename)
        plt.savefig(f"region_growing_test_images/results/{name_no_ext}_region_growing.png")

def main():
    simple_img_path = "region_growing_test_images/complex_image_3.jpg"
    app = RegionGrower(simple_img_path, threshold=15)
    app.run_and_plot()

if __name__ == "__main__":
    main() 