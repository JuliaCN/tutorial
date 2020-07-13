#=

Julia的代码注释有两种，一种是在第一部分见过的那种，单行注释，字符 # 及后面的内容会被忽略，另一种是这里分别以 #= 和 =# 作为开头和结尾，中间的内容会被忽略，有别于第一种注释方式，该方式可以实现跨行注释和行内注释。

# 贪吃蛇游戏

          
      ❤  
          
   🐍🐍   
   🐍     
         

前面我们已经学习了矩阵相关的操作，接下来，我们可以学习使用矩阵来模拟游戏界面
=#

# 首先，定义游戏界面的高和宽
height = 6
width = 8

# 然后构造一个全0的矩阵，用0来表示地板
FLOOR = 0
board = fill(FLOOR, height, width)

# 用数字1来表示❤
FOOD = 1
board[2,6] = FOOD  # 将❤放在第二行，第六列的位置
board

# 用数字2来表示🐍
SNAKE = 2

# 假设🐍占了3个位置，分别是
snake = [CartesianIndex(4,5), CartesianIndex(4,4), CartesianIndex(5,4)]

board[snake] .= SNAKE  # 将相应位置标志为🐍
board

# !!! 注意，这里snake是有序的，
# 我们假设头部永远是第一个元素，即第4行第5列的位置 CartesianIndex(4,5)
# 而尾部则是最后一个元素，即CartesianIndex(5,4)

# 那如何实现🐍的移动呢？
# 回忆一下 CartesianIndex 的操作

snake[1] + CartesianIndex(0,1)  # 往右移动了一格

# 类似地，我们可以定义其它方向
UP = CartesianIndex(-1,0)
DOWN = CartesianIndex(1,0)
LEFT = CartesianIndex(0,-1)
RIGHT = CartesianIndex(0,1)

# 接下来，我们把🐍整体往右移动一格，
# 其实很简单，把移动后的头部插入到snake的最前面，然后把尾巴扔掉即可
pushfirst!(snake, snake[1]+RIGHT)
tail = pop!(snake)

board
snake
board[snake] .= SNAKE
board[tail] = FLOOR
board

#####
# 函数
#####

# 接下来介绍编程语言中最核心的概念之一：函数
# 前面已经使用了一些Julia语言内置的函数，
# 如：push!,pop!等
# 我们也可以通过function关键字来编写自定义函数

function step!(board, snake, direction)
    # 在这里实现具体的逻辑
end

# 这样，我们就完成了一个函数的定义
# function 是一个内置的关键字，表示我们接下来要定义一个函数了
# end表示一个函数定义的结束
# move 表示函数名，后面的括号里表示参数，分别我们要修改的界面,🐍和🐍的运行方向
# 虽然这个函数什么都没做，但是我们可以尝试调用它，看看会发生什么

step!(board, snake, UP)
board
snake

function step!(board, snake, direction)
    pushfirst!(snake, snake[1]+direction)
    tail = pop!(snake)
    board[tail] = FLOOR
    board[snake] .= SNAKE
    board
end

step!(board, snake, UP);board
step!(board, snake, LEFT);board
step!(board, snake, DOWN);board
step!(board, snake, RIGHT);board

# 问题来了
# Q1: 如果遇到了❤，🐍的长度应该+1
# Q2: 如果遇到了🐍自己的身体，那应该提示游戏结束
# Q3：如果🐍遇到了边界
#    a. 那么应该提示游戏结束
#    b. 一些其它的游戏变种中，遇到边界会允许穿过 (这里我们没有定义边界，暂时实现这一种)
# Q4: 吃掉❤之后，应该再随机生成一个

# 为了更好地解决上面这些问题，我们新增加几个函数，用于更好地描述运行逻辑

# 解决了Q1
function step!(board, snake, direction)
    if grow!(board, snake, direction)  # 长度+1成功
        if board[snake[1]] != FOOD     # 没有吃到❤
            board[snake[1]] = SNAKE
            board[snake[end]] = FLOOR
            pop!(snake)
            true
        else                          # 吃到了❤
            board[snake[1]] = SNAKE
            init_food!(board)         # 重新生成一个❤
        end
    else                              # 长度+1是非法操作
        false                         # 游戏结束
    end
end

# 解决Q2, Q3
function grow!(board, snake, direction)
    next_head = CartesianIndex(mod.((snake[1]+direction).I, axes(board)))
    if next_head in CartesianIndices(board) && board[next_head] != SNAKE
        pushfirst!(snake, next_head)
        true
    else
        false
    end
end

# 解决Q4
function init_food!(board)
    blank_positions = findall(==(FLOOR), board)  # TODO: cache
    if length(blank_positions) > 0
        board[rand(blank_positions)] = FOOD
        true
    else
        false
    end
end