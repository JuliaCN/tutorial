####################
#                  #
#             ❤   #
#                  #
#        🐍🐍🐍   #
#                  #
#                  #
#                  #
#                  #
####################

#=

Julia的代码注释有两种，一种是上面的那种，单行注释，字符 # 及后面的内容会被忽略，另一种是这里分别以 #= 和 =# 作为开头和结尾，中间的内容会被忽略，有别于第一种注释方式，该方式可以实现跨行注释和行内注释。

# 贪吃蛇游戏

1. 如何表示游戏界面？
    1. 如何表示🐍？
    2. 如何表示❤？
    3. 如何表示围墙？

2. 定义游戏规则
    1. 🐍根据用户输入，每次往前行进1步
    2. 如果遇到❤，那么长度+1
    3. 如果遇到墙或者是自己的身体，则游戏失败。游戏得分即为🐍的长度。

=#

height = 6
width = 8



board = fill(0, height, width)
board[1,1]

# 用数字1来表示❤
board[1,1] = 1
board

# 用数字2来表示🐍
board[2,2] = 2
board

#####
# 定义游戏界面的长和宽
#####

const WIDTH, HEIGHT = 10, 8

# const WIDTH = 10
# const HEIGHT = 10

# 为什么要用const?  https://docs.julialang.org/en/v1/base/base/#const
# 为什么要用大写？  https://github.com/invenia/BlueStyle#global-variables

#####
# 定义游戏界面
#####

const WALL = '◼'
const SNAKE = '⊡'
const TARGET = '♡'
const FLOOR = ' '

# 注意，这里都是用的单引号

const BOARD = Matrix{Char}(undef, HEIGHT, WIDTH)

# 什么是Matrix?
# 这里的花括号是什么意思？
# 为什么HEIGHT在前，WIDTH在后？  https://docs.julialang.org/en/v1/manual/performance-tips/#man-performance-column-major-1

length(BOARD)
size(BOARD)

# 接下来，开始刷墙啦~
BOARD[1]
BOARD[1] = WALL
BOARD[2] = WALL

BOARD[1:2]
BOARD

# 一次刷多个
BOARD[3:4] = [WALL, WALL]

BOARD[1:HEIGHT]

# 一次刷很多个，怎么办呢？总不能手动写那么多个 WALL 吧......
BOARD[1:HEIGHT] .= WALL

# 先猜猜下面会把哪些元素刷成墙
BOARD[HEIGHT*(WIDTH-1)+1:HEIGHT] .= WALL

# 目前为止，左右两面墙都刷好了, 那上下两面墙呢？
BOARD[HEIGHT+1] = WALL
BOARD[HEIGHT*2] = WALL
BOARD[HEIGHT*2+1] = WALL
BOARD[HEIGHT*3] = WALL

# 咦，等等，这要刷到哪辈子去......
# 按行取元素
BOARD[1,1:WIDTH]

BOARD[1,1:WIDTH] .= WALL
BOARD[HEIGHT,1:WIDTH] .= WALL

# 当然，这里有一些语法层面的简写，比如
# BOARD[1,:] .= WALL
# BOARD[end,:] .= WALL

# 除了按行、列取元素之外，也可以按区块取元素
BOARD[2:end-1, 2:end-1] .= FLOOR

# 然后，随便选一个空白的地方，把❤和🐍放上去

BOARD[WIDTH ÷ 2, HEIGHT ÷ 2] = TARGET
BOARD[WIDTH ÷ 2 - 1, HEIGHT ÷ 2 + 1] = SNAKE
BOARD

# 到这里，便完成了游戏界面的初始化

#####
# 进阶
# 思考这样一个问题，如何随机初始化❤和🐍的位置呢？
#####

# 首先重置游戏界面
fill!(BOARD, WALL)
BOARD[2:HEIGHT, 2:WIDTH-1] .= FLOOR

x, y = rand(2:HEIGHT-1), rand(2:WEIGHT-1)
# 可以输入 ?rand 查看该函数的更多用法
# 这里 rand(2:HEIGHT-1) 就是生成一个 2 到 HEIGHT-1 之间的随机整数

# 然后把🐍放上去
BOARD[x,y] = SNAKE

# 接下来，把❤也放上去
# 显然，和上面一样，我们可以这么做
# x, y = rand(2:HEIGHT-1), rand(2:WEIGHT-1)
# BOARD[x,y] = TARGET

# 等等，万一，这个位置上本来就有🐍了呢？那岂不是被覆盖了
# 所以，放置之前，先检查一下这个位置上是不是已经有🐍了
# 如果没有，直接放上去，否则，就重新选一对随机数，
# 如果重新选出来的位置上还是有🐍的，那就一直重新选......

while true
    x, y = rand(2:HEIGHT-1), rand(2:WEIGHT-1)
    if BOARD[x,y] == SNAKE
        continue
    else
        BOARD[x,y] = TARGET
        break
    end
end

# 不过，这样有个小小的问题，游戏进行到后期，满屏到处都是🐍只有一小部分地方可以放❤，
# 这时候会导致多次生成无效的随机数，咋办呢？

# 问题:
# 假设屏幕上可以放❤的格子占比为 p , 那么请问，上面的循环里，生成随机数的次数的期望是多少呢？
# 嗯？不知道？小朋友，要不要回去先补一补怎么算几何分布的期望了再来听课？

# 另外一种做法是，先将所有可以放❤的格子缓存起来，然后每次随机从中选一个出来即可

# 先重置下界面
fill!(BOARD, WALL)
BOARD[2:HEIGHT, 2:WIDTH-1] .= FLOOR

# 先放置🐍
x, y = rand(2:HEIGHT-1), rand(2:WEIGHT-1)
BOARD[x,y] = SNAKE

# 然后找出所有空白地方
empty_positions = findall(==(FLOOR), BOARD)

# 这里 ==(FLOOR) 是一个partial函数，用来判断一个元素是否等于FLOOR

# 再随机选一个出来并将其对应的位置设置为❤
BOARD[rand(empty_positions)] = TARGET

# 需要注意的是，这里findall返回的值是一个向量，其中每一个元素都是CartesianIndex类型
# 在Julia中，除了可以通过手动指定各个维度的下标之外，也可以通过CartesianIndex对象来访问元素

BOARD[CartesianIndex(x,y)] == SNAKE

# 类似地，可以用CartesianIndices类型来访问某一区块内的数据
BOARD[CartesianIndices((2:HEIGHT-1, 2:WEIGHT-1))]
BOARD[CartesianIndices((2:HEIGHT-1, 2:WEIGHT-1))]