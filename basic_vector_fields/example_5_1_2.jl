using PlotlyJS

function f(t::Float64; a::Float64, x0::Float64 = 1.0, y0::Float64 = 1.0)
    x = x0 * exp(a*t)
    y = y0 * exp(-t)
    (x, y)
end

a = -2.0
traces::Vector{AbstractTrace} = []
for x0 ∈ range(-1.0, 1.0, 5)
    xs::Vector{Float64} = []
    ys::Vector{Float64} = []
    for t ∈ range(-1.0, 1.0, 100)
        (x, y) = f(t; a = a, x0 = x0)
        push!(xs, x)
        push!(ys, y)
    end
    trace = scatter(
        x = xs,
        y = ys,
        mode = "lines",
    )
    push!(traces, trace)
end
layout = Layout(width = 500, height = 500)
p = plot(traces, layout)
display(p)
println("Press enter to exit")
readline()
