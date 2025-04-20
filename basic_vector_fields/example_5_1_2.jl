using PlotlyJS

x_eq(t, x0, a) = x0 * exp(a * t)
y_eq(t, y0) = y0 * exp(-t)

x0s = [cos(θ) for θ ∈ range(0.0, 2π, 9)]
y0s = [sin(θ) for θ ∈ range(0.0, 2π, 9)]

function portrait(a::Float64)
    ts = range(-1.0, 1.0, length=10)
    traces::Vector{GenericTrace} = []
    for (x0, y0) ∈ zip(x0s, y0s)
        xs = x_eq.(ts, x0, a)
        ys = y_eq.(ts, y0)
        trace = scatter(x = xs, y = ys, mode = "lines", showlegend = false)
        push!(traces, trace)
    end
    layout = Layout(width = 500, height = 500)
    plot(traces, layout)
end

display(portrait(-2.0))
println("Press enter to continue")
readline()
