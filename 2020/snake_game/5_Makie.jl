# GUI in Julia
# https://github.com/barche/QML.jl
# https://github.com/Gnimuc/CImGui.jl
# https://github.com/JuliaGraphics/Tk.jl

# 但是，Makie.jl 毕竟是原生的嘛，全村人民的希望！！！
# https://github.com/JuliaPlots/Makie.jl

using Makie

# 这里只介绍几个和我们相关的函数
scatter(1:3, rand(3))
text("abc")
poly(FRect2D((2,2), (0.5,0.5)))

# 看起来平淡无奇，跟其它的画图的库似乎差不多？

# Observable

x = Node(0)
y = lift(x) do x
    "Score: $x"
end

x[] = 1
y
x[] = 2
y
x[] = 3
y

# 1. 设置分辨率
# 2. 设置像素视角
# 3. 禁用xy轴信息
scene = Scene(resolution = (1000, 1000), camera = campixel!, raw = true)


# ↑ y
# |
# |
# -----> x

text!(y, position = (500,1000), textsize = 50, align = (:center, :top))

x[] = 6
x[] = 66
x[] = 666

on(scene.events.keyboardbuttons) do but
    if ispressed(but, Keyboard.left)
        x[] = - abs(x[])
    elseif ispressed(but, Keyboard.up)
        x[] += 1
    elseif ispressed(but, Keyboard.down)
        x[] -= 1
    elseif ispressed(but, Keyboard.right)
        x[] = abs(x[])
    end
end

p = Node((0, 0))
box = lift(p) do p
    FRect2D(p, (100,100))
end
poly!(box)

on(scene.events.keyboardbuttons) do but
    if ispressed(but, Keyboard.left)
        p[] = p[] .+ (-100, 0)
    elseif ispressed(but, Keyboard.up)
        p[] = p[] .+ (0, 100)
    elseif ispressed(but, Keyboard.down)
        p[] = p[] .+ (0, -100)
    elseif ispressed(but, Keyboard.right)
        p[] = p[] .+ (100, 0)
    end
end

#####
# 绘制完整的界面
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

game = Node(SnakeGame())

scene = Scene(resolution = (900, 1200), raw = true, camera = campixel!)

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

