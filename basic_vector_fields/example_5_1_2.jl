using PlotlyJS

function f(t::Float64, a::Float64; x0::Float64 = 1.0, y0::Float64 = 1.0)
    x = x0 * exp(a*t)
    y = y0 * exp(-t)
    (x, y)
end

a = 0.0
traces::Vector{AbstractTrace} = []
for x0 in range(0.0, 1.0, 10)
    points = [f(t, a; x0 = x0) for t ∈ range(0.0, 1.0, 10)]
    xs = [x for (x, _) ∈ points]
    ys = [y for (_, y) ∈ points]
    trace = scatter(x = xs, y = ys, mode = "lines")
    push!(traces, trace)
end
layout = Layout(width = 500, height = 500)
p = plot(traces, layout)
display(p)
println("Press enter to exit")
readline()
