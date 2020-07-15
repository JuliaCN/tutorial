# 性能分析

# Why?
# 就这么简单的游戏还需要啥性能？

using Random

create_test_game(n) = SnakeGame(
    100,
    100,
    shuffle(CartesianIndices((100,100)))[1:n],
    CartesianIndex(1,1)
    )

init_food!(create_test_game(1000))

using BenchmarkTools

@benchmark init_food!($(create_test_game(1000)))
@benchmark init_food!($(create_test_game(8000)))

directions = (CartesianIndex(-1,0), CartesianIndex(0,1), CartesianIndex(0,-1), CartesianIndex(1,0))
@benchmark step!($(create_test_game(1000)), $(rand(directions)))
@benchmark step!($(create_test_game(8000)), $(rand(directions)))
@benchmark step!($(create_test_game(rand(2:5000))), $(rand(directions)))

# ProfileView

using Profile
using ProfileView

game = create_test_game(8000)

Profile.clear()
@profile step!(game, rand(directions))
ProfileView.view()

Profile.clear()
@profile for _ in 1:1000
    step!(game, rand(directions))
end
ProfileView.view()

# Multiple Dispatch

struct Snake <: AbstractArray{CartesianIndex{2}, 1}
    positions::Vector{CartesianIndex{2}}
    cache::Set{CartesianIndex{2}}
end

Snake() = Snake(CartesianIndex{2}[])
Snake(positions) = Snake(positions, Set(positions))

Base.size(s::Snake) = size(s.positions)
Base.getindex(s::Snake, i...) = getindex(s.positions, i...)

function Base.push!(s::Snake, x)
    push!(s.positions, x)
    push!(s.cache, x)
end

function Base.pushfirst!(s::Snake, x)
    pushfirst!(s.positions, x)
    push!(s.cache, x)
end

function Base.pop!(s::Snake)
    x = pop!(s.positions)
    pop!(s.cache, x)
end

Base.in(x, s::Snake) = x in s.cache

create_test_game(n) = SnakeGame(
    100,
    100,
    Snake((CartesianIndices((100,100)))[1:n]),
    CartesianIndex(1,1)
    )

game = create_test_game(8000)

Profile.clear()
@profile for _ in 1:1000
    step!(game, rand(directions))
end
ProfileView.view()

@benchmark step!($(create_test_game(1000)), $(rand(directions)))
@benchmark step!($(create_test_game(8000)), $(rand(directions)))
@benchmark step!($(create_test_game(rand(2:5000))), $(rand(directions)))

function step!(game, direction)
    next_head = game.snake[1] + direction
    next_head = CartesianIndex(mod(next_head[1], 1:game.height), mod(next_head[2], 1:game.width))  # 允许跨越边界
    if is_valid(game, next_head)
        pushfirst!(game.snake, next_head)
        if next_head == game.food
            length(game.snake) < game.height * game.width && init_food!(game)
        else
            pop!(game.snake)
        end
        true
    else
        false
    end
end

# 还可以更快么？

function init_food!(game)
    p = rand(CartesianIndices((game.height, game.width)))
    while !is_valid(game, p)
        p = rand(CartesianIndices((game.height, game.width)))
    end
    game.food = p
end

# 几何分布求期望

# 我们真的需要吗？

# NO FREE LUNCH

#####
# !!! 懂得适可而止
#####

# 增加 cache 导致的性能下降
# MCTS 中，copy game