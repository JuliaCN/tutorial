using Makie

p = Node(Point2f0.([1,2,3],[1,1,1]))
scatter(p, marker=:rect, markersize=1.5, limits=FRect(0, 0, 10,10))