using LinearAlgebra
using PlotlyJS

function f(t::Float64, c1::Float64 = 1.0, c2::Float64 = 1.0)
    @. c1 * exp(t) * [cos(t); sin(t)] + c2 * exp(t) * [-sin(t); cos(t)] 
end

function portrait()
    ts = range(0.0, 1.0, 10)
    values = f.(ts)
    xs = [x for (x, _) ∈ values]
    ys = [y for (_, y) ∈ values]
    traces::Vector{GenericTrace} = []
    trace_path = scatter(
        x = xs,
        y = ys,
        mode = "lines",
        line = attr(color = "black"),
        name = "path",
    )
    trace_start = scatter(
        x = [xs[1]],
        y = [ys[1]],
        mode = "markers",
        line = attr(color = "blue"),
        name = "start",
    )
    trace_end = scatter(
        x = [xs[end]],
        y = [ys[end]],
        mode = "markers",
        line = attr(color = "red"),
        name = "end",
    )
    push!(traces, trace_path)
    push!(traces, trace_start)
    push!(traces, trace_end)
    layout = Layout(width = 550, height = 500)
    plot(traces, layout)
end

display(portrait())
println("Press enter to exit...")
readline()
