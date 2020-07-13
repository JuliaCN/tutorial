# 性能分析

function init_food!(game)
    if length(game.snake) <= game.height * game.width
        p = rand(CartesianIndices((game.height, game.width)))
        while p in game.snake  # !!! slow
            p = rand(CartesianIndices((game.height, game.width)))
        end
        game.food = p
        true
    else
        false
    end
end

using Random

game = SnakeGame(
    100,
    100,
    shuffle(CartesianIndices((100,100)))[1:5000],
    CartesianIndex(1,1)
    )

init_food!(game)

using BenchmarkTools

@benchmark init_food!(game)

game.snake = shuffle(CartesianIndices((100,100)))[1:8000]
@benchmark init_food!(game)

# ProfileView

using Profile
using ProfileView

Profile.clear()
@profile init_food!(game)
ProfileView.view()

Profile.clear()
@profile for _ in 1:1000
    init_food!(game)
end
ProfileView.view()