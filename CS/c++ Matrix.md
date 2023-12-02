# Matrix

## 基础概念

### 矩阵满秩

![image-20231130013655127](src/image-20231130013655127.png)

### 正交矩阵

正交矩阵的行列式为**正负1**

![image-20231130013822961](src/image-20231130013822961.png)



## svd分解

奇异值分解（Singular Value Decomposition，简称SVD）是一种线性代数的技术，用于将一个矩阵分解为三个矩阵的乘积。这种分解在许多领域，特别是在数值分析和机器学习中，都有广泛的应用。

给定一个实数或复数的矩阵A，其SVD分解可以表示为：
$$
A=U\sum V^T
$$
![image-20231130011116276](src/image-20231130011116276.png)

# c++ Eigen

## 列向量

```
#include <iostream>
#include <Eigen/Dense>

int main() {
    // 创建一个固定大小的列向量 (例如，这里是3维向量)
    Eigen::Vector3d fixedVector;

    // 向固定列向量赋值
    fixedVector << 1, 2, 3;

    std::cout << "Fixed Size Vector:\n" << fixedVector << std::endl;

    return 0;
}

```

## 矩阵

```
#include <iostream>
#include <Eigen/Dense>

int main() {
    // 创建一个3x3的矩阵
    Eigen::Matrix3d matrix3x3;

    // 向矩阵赋值
    matrix3x3 << 1, 2, 3,
                 4, 5, 6,
                 7, 8, 9;

    std::cout << "3x3 Matrix:\n" << matrix3x3 << std::endl;

    return 0;
}

```

