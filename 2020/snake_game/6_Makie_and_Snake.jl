# 真！100行Julia代码实现带GUI的贪吃蛇
using Makie

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

function step!(game, direction)
    next_head = game.snake[1] + direction
    next_head = CartesianIndex(mod.(next_head.I, Base.OneTo.((game.height, game.width))))  # 允许跨越边界
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

is_valid(game, position) = position ∉ game.snake

function init_food!(game)
    p = rand(CartesianIndices((game.height, game.width)))
    while !is_valid(game, p)
        p = rand(CartesianIndices((game.height, game.width)))
    end
    game.food = p
end

function play(;n=10,t=0.5)
    game = Node(SnakeGame(;width=n,height=n))
    scene = Scene(resolution = (1000, 1000), raw = true, camera = campixel!)
    display(scene)

    area = scene.px_area
    poly!(scene, area)

    grid_size = @lift((widths($area)[1] / $game.height, widths($area)[2] / $game.width))

    snake_boxes = @lift([FRect2D((p.I .- (1,1)) .* $grid_size , $grid_size) for p in $game.snake])
    poly!(scene, snake_boxes, color=:blue, strokewidth = 5, strokecolor = :black)

    snake_head_box = @lift(FRect2D(($game.snake[1].I .- (1,1)) .* $grid_size , $grid_size))
    poly!(scene, snake_head_box, color=:black)
    snake_head = @lift((($game.snake[1].I .- 0.5) .* $grid_size))
    scatter!(scene, snake_head, marker='◉', color=:blue, markersize=@lift(minimum($grid_size)))

    food_position = @lift(($game.food.I .- (0.5,0.5)) .* $grid_size)
    scatter!(scene, food_position, color=:red, marker='♥', markersize=@lift(minimum($grid_size)))

    score_text = @lift("Score: $(length($game.snake)-1)")
    text!(scene, score_text, color=:gray, position = @lift((widths($area)[1]/2, widths($area)[2])), textsize = 50, align = (:center, :top))

    direction = Ref{Any}(nothing)

    on(scene.events.keyboardbuttons) do but
        if ispressed(but, Keyboard.left)
            direction[] = CartesianIndex(-1,0)
        elseif ispressed(but, Keyboard.up)
            direction[] = CartesianIndex(0,1)
        elseif ispressed(but, Keyboard.down)
            direction[] = CartesianIndex(0,-1)
        elseif ispressed(but, Keyboard.right)
            direction[] = CartesianIndex(1,0)
        end
    end

    last_dir = nothing
    while true
        # 避免掉头就直接挂了
        if !isnothing(direction[]) && (isnothing(last_dir) || direction[] != -last_dir)
            last_dir = direction[]
        end
        if !isnothing(last_dir)
            if step!(game[], last_dir)
                game[] = game[]
            else
                break
            end
        end
        sleep(t)
    end
end

# TODO: Recording
