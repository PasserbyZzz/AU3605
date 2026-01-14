# AU3605

## 简介

本仓库为 上海交通大学 **数字图像处理与模式识别(AU3605)** 课程大作业，完成于2025年秋季学期，任务要求详见 [大作业 1](https://github.com/PasserbyZzz/AU3605/blob/main/Project1/report/课程大作业1.pdf) 和 [平时作业](https://github.com/PasserbyZzz/AU3605/blob/main/HW1/report/平时作业.pdf)。

欢迎任何的 **`Issues`** 以及 **`Pull requests`**!

## 总体流程

### 大作业 1

1. **预处理**：使用非线性扩散方法对图像去噪平滑，以优化后续采样质量。
2. **边界点检测**：遍历图像网格寻找“边缘单元”，判断标准为单元边的两个顶点满足：
     1. **过零点**：拉普拉斯值符号相反（$l(p_1) \cdot l(p_2) < 0$）。
     2. **高梯度**：梯度幅值之和大于设定阈值 $T$。
3. **灰度采样计算**：在边缘单元内利用线性插值，计算拉普拉斯值为 0 的位置及其对应的**灰度值**。
4. **阈值选择**：构建边界采样点的灰度直方图，呈现单峰或多峰。
    - **单阈值**：取所有采样点灰度值的**均值**或直方图**峰值** 。
    - **多阈值**：识别直方图中的聚类，取各聚类的**均值**作为对应物体的阈值 。

### 平时作业

- **题目一**：高斯滤波
- **题目二**：阈值分割
- **题目三**：边缘检测
- **题目四**：区域生长、区域分裂与合并

## 具体实现

详见 [大作业 1 实验报告](https://github.com/PasserbyZzz/AU3605/blob/main/Project1/report/report.pdf) 和 [平时作业实验报告](https://github.com/PasserbyZzz/AU3605/blob/main/HW1/report/report.pdf)。

## 效果展示

### 大作业 1

腿部 CT 图像多阈值分割结果：

<div align="center">
  <img src="Project1\leg\leg_00_multilevel_kmeans_comparison.png" 
       alt="腿部 CT 图像多阈值分割" 
       style="width: 70%; max-width: 800px;">
</div>

头部 CT 图像多阈值分割结果：

<div align="center">
  <img src="Project1\head\head_00_multilevel_kmeans_comparison.png" 
       alt="头部 CT 图像多阈值分割" 
       style="width: 70%; max-width: 800px;">
</div>

### 平时作业

略。

## 文件目录

- **AU3605**
  - **HW1**：平时作业
    - **edge_detection_test_images**：边缘检测测试图像
    - **gaussian_multiscale_smoothing_test_images**：高斯多尺度平滑测试图像
    - **region_growing_test_images**：区域生长测试图像
    - **region_splitting_merging_test_images**：区域分裂与合并测试图像
    - **threshold_segmentation_test_images**：阈值分割测试图像
    - **report**：平时作业要求与实验报告
  - **Project1**：大作业 1
    - **baboon**：斑马猴图像
    - **characters**：字符图像
    - **fingerprint**：指纹图像
    - **girls**：女孩图像
    - **head**：头部 CT 图像
    - **leg**：腿部 CT 图像
    - **rice**：大米图像
    - **sensitivity2noise**：噪声敏感性测试图像
    - **sensitivity2thresholds**：阈值敏感性测试图像
    - **report**：大作业 1 要求与实验报告

*注意：* 请以 `HW1` 或 `Project1` 为根目录运行！

## 邮箱

任何疑问，欢迎邮件交流：**`passerby_zzz@sjtu.edu.cn`** !

## **Wish for your Star⭐!**