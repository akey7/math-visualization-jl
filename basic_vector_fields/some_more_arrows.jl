using PlotlyJS

function f_xv(x::Float64, v::Float64, ω::Float64 = 1.0)
    (v, -ω^2*x)
end

annotations = []
xs = [-1.0, 1.0, 0.0, 0.0]
ys = [0.0, 0.0, -1.0, 1.0]
for (x, y) ∈ zip(xs, ys)
    (ẋ, ẏ) = f_xv(x, y)
    annotation = attr(
        ax = x,
        ay = y,
        x = x + ẋ,
        y = y + ẏ,
        axref = "x",
        ayref = "y",
        showarrow = true,
        arrowcolor = "black",
        arrowhead = 2,
        arrowsize = 2,
        text = "",
    )
    push!(annotations, annotation)
end
trace1 = scatter(
    x = xs,
    y = ys,
    mode = "markers",
    marker = attr(color = "blue", size = 10),
)
layout = Layout(annotations = annotations, width = 500, height = 500)
p = plot([trace1], layout)
display(p)
println("Press enter to exit.")
readline()
