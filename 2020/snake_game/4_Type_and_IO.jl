#####
# 回顾
#####

mutable struct SnakeGame
    height
    width
    snake
    food
end

function SnakeGame(;height=6, width=8)
    snake = [rand(CartesianIndices((height, width)))]
    food = rand(CartesianIndices((height, width)))
    while food == snake[1]
        food = rand(CartesianIndices((height, width)))
    end
    SnakeGame(height, width, snake, food)
end

game = SnakeGame()

typeof(game)
typeof(game.height)
typeof(game.snake)

print(game)
print(stdout, game)

#####
# 如何个性化定义 SnakeGame 的显示呢？
# https://pretalx.com/juliacon2020/talk/KZK93G/
#####
Base.show(io::IO, ::MIME"text/plain", game::SnakeGame) = "A SnakeGame"

function Base.show(io::IO, game::SnakeGame)
    println(io, "board size: $(game.height) * $(game.width), score: $(length(game.snake))")
    for i in 1:game.height
        for j in 1:game.width
            if CartesianIndex(i,j) == game.food
                print(io, '♡')
            elseif CartesianIndex(i,j) in game.snake
                print(io, '⧇')
            else
                print(io, '∘')
            end
        end
        println(io)
    end
end

game

Base.show(io::IO, ::MIME"text/plain", game::SnakeGame) = show(io, game)

#####
# API
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
    next_head = CartesianIndex(mod.(next_head.I, Base.OneTo.(bound)))
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

UP = CartesianIndex(-1,0)
DOWN = CartesianIndex(1,0)
LEFT = CartesianIndex(0,-1)
RIGHT = CartesianIndex(0,1)

step!(game, UP);game
step!(game, DOWN);game
step!(game, LEFT);game
step!(game, RIGHT);game

#####
# 读取键盘输入
#####

text = readline()

# 这里我们用 wasd 按键来表示 上左下右

function play()
    game = SnakeGame()
    dir = nothing
    println(game)
    while true
        x = readline()
        dir = if x == "w"
            UP
        elseif x == "s"
            DOWN
        elseif x == "a"
            LEFT
        elseif x == "d"
            RIGHT
        else
            dir
        end

        is_succeed = step!(game, dir)
        println(game)
        is_succeed || break
    end
end