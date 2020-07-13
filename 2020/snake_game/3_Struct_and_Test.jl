# 什么是struct呢？

# 简单来讲，就是把各种数据组织在一起，方便管理
# 比如，前面一节中，我们在全局定义了一些常量和变量

# width
# height
# board
# snake
# SNAKE
# food
# FOOD

# 思考
# 哪些数据是必须的呢？

# 抽象思维的第一步
# 运行逻辑与可视化分离

# width, height, snake, food
# board, SNAKE, FOOD

mutable struct SnakeGame
    height
    width
    snake
    food
end

# ? mutable

# 构造对象
game = SnakeGame(
    6,
    8, 
    [CartesianIndex(4,5), CartesianIndex(4,4), CartesianIndex(5,4)],
    CartesianIndex(2, 6)
    )

function SnakeGame(;height=6, width=8)
    snake = [rand(CartesianIndices((height, width)))]
    food = rand(CartesianIndices((height, width)))
    while food == snake[1]
        food = rand(CartesianIndices((height, width)))
    end
    SnakeGame(height, width, snake, food)
end

#####
# API 设计
#####

"""
    step!(game, direction)

把游戏中的🐍往指定方向移动一步，
如果碰到了🐍自己的身体，或者🐍占满了全部游戏界面，那就返回`false`，
否则返回`true`。如果刚好吃到了❤，那就在没有🐍的地方重新生成一个。
"""
function step!(game, direction) end

"""
    grow_snake!(snake, direction, bound)

把🐍朝指定方向移动一步，如果越界了，那么在对应的另一端出现。
如果遇到了🐍的身体，则返回`false`表示移动失败，否则返回`true`。
"""
function grow_snake!(snake, direction, bound) end

"把🐍的尾部拿掉，返回成功与否。"
function shrink_snake!(snake) end

"在没有🐍的地方重新生成一个❤，返回成功与否"
function init_food!(game) end

#####
# 实现
#####

function step!(game, direction)
    if grow_snake!(game.snake, direction, (game.height, game.width))
        if game.snake[1] == game.food
            init_food!(game)
        else
            shrink_snake!(game)
        end
    else
        false
    end
end

function grow_snake!(snake, direction, bound)
    next_head = snake[1] + direction
    if next_head in snake
        false
    else
        pushfirst!(snake, next_head)
        true
    end
end

function shrink_snake!(game)
    pop!(game.snake)
    true
end

function init_food!(game)
    if length(game.snake) <= game.height * game.width
        p = rand(CartesianIndices((game.height, game.width)))
        while p in game.snake
            p = rand(CartesianIndices((game.height, game.width)))
        end
        game.food = p
        true
    else
        false
    end
end

# 可视化？

#####
# 单元测试
#####

using Test

@test 1 == 1

@testset "测试示例" begin
    @testset "集合1" begin
        @test 1+1 == 2
    end
    # https://discourse.juliacn.com/t/topic/119
    @testset "集合2" begin
        @test 1.2 + 0.12 == 1.32
    end
end

@testset "grow_snake" begin
    snake = [CartesianIndex(2,2)]
    bound = (3,3)

    @test true == grow_snake!(snake, CartesianIndex(0, 1) #= right =#, bound)
    @test snake == [CartesianIndex(2,3), CartesianIndex(2,2)]

    @test true == grow_snake!(snake, CartesianIndex(0, 1) #= right =#, bound)
    @test snake == [CartesianIndex(2,1), CartesianIndex(2,3), CartesianIndex(2,2)]

    @test false == grow_snake!(snake, CartesianIndex(0, 1) #= right =#, bound)
    # make sure snake not affected
    @test snake == [CartesianIndex(2,1), CartesianIndex(2,3), CartesianIndex(2,2)]
end

function grow_snake!(snake, direction, bound)
    next_head = snake[1] + direction
    next_head = CartesianIndex(mod.(next_head.I, Base.OneTo.(bound)))
    if next_head in snake
        false
    else
        pushfirst!(snake, next_head)
        true
    end
end
