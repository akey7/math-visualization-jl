using PlotlyJS

function f(t::Float64, a::Float64, x0::Float64 = 1.0, y0::Float64 = 1.0)
    x = x0 * exp(a*t)
    y = y0 * exp(-t)
    (x, y)
end

points = [f(t, 0.0) for t ∈ range(0.0, 1.0, 10)]
xs = [x for (x, _) ∈ points]
ys = [y for (_, y) ∈ points]
trace1 = scatter(x = xs, y = ys, mode = "lines")
layout = Layout(width = 500, height = 500)
p = plot([trace1], layout)
display(p)
println("Press enter to exit")
readline()
