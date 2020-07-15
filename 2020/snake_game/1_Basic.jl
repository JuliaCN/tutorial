#####
# 熟悉 REPL
#####

# Julia中最核心的概念

# ?
Array

#####
# 向量
#####

# 一维数组有一个别名
# ?
Vector

v = [1,2,3]

# 添加和删除向量中的元素
# 这里 ! 是什么意思？
push!(v, 4)
push!(v, 5)
push!(v, 6)

length(v)

pop!(v)

length(v)
v

pushfirst!(v, 0)
popfirst!(v)
v

6 ∈ v
1 ∈ v

# 访问和修改向量中的元素
v[1]
v[1] = 3
v

# 批量操作
v[1:3]
v[1:3] = [0,0,0]  # 注意这里要等长
v[1:3] = [-1, -1]
v

# 广播操作
v[1:3] .= 1
v

#####
# 矩阵
#####
# ?
Matrix

m = [1 2 3; 4 5 6;]

# 往矩阵添加/删除元素？
push!(m, 1)
push!(m, [4,8])
hcat(m, [4,8])

# 访问和修改矩阵中的元素
m[1]
m[2]

# column-major
# ↓↓↓↓
# ↓↓↓↓

m[3]
m[4]
m[5]
m[6]

m[6] = 0
m

# 笛卡尔坐标系
# ?
CartesianIndex
i = CartesianIndex(2,3)
m[i]
m
m[2,3]
m[i[1], i[2]]

# 看起来，CartesianIndex似乎并没有什么特殊的地方，
# 不过 CartesianIndex 可以很方便地做坐标转换

i + CartesianIndex(-1,-1)  # 把i分别向左和向上移动单位长
m[i + CartesianIndex(-1,-1)]

# 访问矩阵中的一块区域

m[1,1:2]
m[1:2, 3]

i = CartesianIndices((1, 1:2))
m[i]
i = CartesianIndices((1:2, 3))
m[i]

# 批量操作
m[i] .= 1

#####
# 其它
#####

# 初始化指定长度的向量/矩阵

# 构造指定长度的向量
v = Vector(undef, 5)

v = fill(0, 2)
m = fill(0, 2, 3)
