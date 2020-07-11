# 组合类型

# 前面一个部分中，我们定义了许多常量，使用各种不同的数据来表示游戏中的组件
# 在Julia中，可以用struct关键字将这些数据组织在一起，方便统一地管理和操作

# 抽象

# 这里，我们重新审视《贪食蛇》这个游戏，本质上，我们就是在构造一个二维的界面，
# 其中，每个元素有4中可能
# 1. 墙
# 2. 空白地板
# 3. 🐍
# 4. ❤

using Random

struct Snake end
const SNAKE = Snake()
Base.show(io::IO, ::Snake) = print(io, '⊡')

struct Wall end
const WALL = Wall()
Base.show(io::IO, ::Wall) = print(io, '◼')

struct Target end
const TARGET = Target()
Base.show(io::IO, ::Target) = print(io, '♡')

struct Floor end
const FLOOR = Floor()
Base.show(io::IO, ::Floor) = print(io, ' ')

"""
    SnakeBoard

这里定义了四个字段：

- `wall`, 所有墙的位置信息
- `floor`, 空白地板的位置
- `snake_body`, 🐍除了头部以外的位置信息
- `snake_head`, 🐍头部的位置信息
- `target`, ❤的位置信息
"""
mutable struct SnakeBoard{R} <: AbstractMatrix{Union{Wall, Floor, Snake, Target}}
    height::Int
    width::Int
    wall::Set{CartesianIndex{2}}
    floor::Set{CartesianIndex{2}}
    snake::Vector{CartesianIndex{2}}  # TODO: use Datastructures.Deque instead
    target::CartesianIndex{2}
    rng::R
end

Base.size(board::SnakeBoard) = (board.height, board.width)

function Base.getindex(board::SnakeBoard, i::Int, j::Int)
    id = CartesianIndex(i, j)
    if id in board.wall WALL
    elseif id == board.target TARGET
    elseif id in board.floor FLOOR
    else SNAKE
    end
end

Base.show(io::IO, ::MIME{Symbol("text/plain")}, board::SnakeBoard) = show(io, board)

function Base.show(io::IO, board::SnakeBoard)
    println(io, "size: $(size(board)), score: $(length(board.snake))")
    for i in 1:size(board, 1)
        for j in 1:size(board, 2)
            print(io, board[i, j], " ")
        end
        println(io)
    end
end

default_wall(height, width) = Set([
    CartesianIndex.(1:height, 1)...,      # 左边的墙
    CartesianIndex.(1:height, width)...,  # 右边的墙
    CartesianIndex.(1, 2:width-1)...,     # 上面的墙
    CartesianIndex.(height, 2:width-1)... # 下面的墙
    ])

function SnakeBoard(;height=8,width=10,wall=default_wall(height, width),rng=Random.GLOBAL_RNG)
    floor = Set(CartesianIndices((1:height, 1:width)))
    setdiff!(floor, wall)

    snake = rand(rng, floor)  # 随机初始化一个🐍的位置
    pop!(floor, snake)
    target = rand(rng, floor)  # 随机初始化一个❤

    SnakeBoard(height, width, wall, floor, CartesianIndex{2}[snake], target, rng)
end

abstract type AbstractMove end

struct Left <: AbstractMove end
const LEFT = Left()
(m::Left)(x::CartesianIndex{2},h,w) =  CartesianIndex(x[1], x[2] == 1 ? w : x[2]-1)

struct Right <: AbstractMove end
const RIGHT = Right()
(m::Right)(x::CartesianIndex{2},h,w) = CartesianIndex(x[1], x[2] == w ? 1 : x[2]+1)

struct Up <: AbstractMove end
const UP = Up()
(m::Up)(x::CartesianIndex{2},h,w) = CartesianIndex(x[1] == 1 ? h : x[1]-1, x[2])

struct Down <: AbstractMove end
const DOWN = Down()
(m::Down)(x::CartesianIndex{2},h,w) = CartesianIndex(x[1] == h ? 1 : x[1]+1, x[2])

"执行动作，返回布尔值表示游戏是否结束"
function (board::SnakeBoard)(move::AbstractMove)
    head′ = move(board.snake[1], size(board)...)
    if head′ in board.floor
        pop!(board.floor, head′)
        pushfirst!(board.snake, head′)
        if head′ == board.target
            if isempty(board.floor)
                return true  # 没有空余地板了，游戏结束
            else
                board.target = rand(board.rng, board.floor)
                return false  # 吃掉❤，游戏继续
            end
        else
            tail = pop!(board.snake)
            push!(board.floor, tail)
            return false  # 向前移动一步，游戏继续
        end
    else
        return true  # 遇到非法单位，游戏结束
    end
end

function play(s=SnakeBoard())
    a = nothing
    while true
        println("\33[2J")
        println(s)
        x = readline()
        a = if x == "w"
            UP
        elseif x == "s"
            DOWN
        elseif x == "a"
            LEFT
        elseif x == "d"
            RIGHT
        else
            a
        end
        s(a) && break
    end
end