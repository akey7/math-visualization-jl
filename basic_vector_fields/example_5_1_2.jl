using PlotlyJS

function f(t::Float64, a::Float64; x0::Float64 = 1.0, y0::Float64 = 1.0)
    x = x0 * exp(a*t)
    y = y0 * exp(-t)
    (x, y)
end

a = -2.0
traces::Vector{AbstractTrace} = []
xs::Vector{Float64} = []
ys::Vector{Float64} = []
for t ∈ range(-1.0, 1.0, 100)
    (x, y) = f(t, a)
    push!(xs, x)
    push!(ys, y)
end
trace1 = scatter(
    x = xs,
    y = ys,
    mode = "lines",
)
layout = Layout(width = 500, height = 500)
p = plot([trace1], layout)
display(p)
println("Press enter to exit")
readline()
