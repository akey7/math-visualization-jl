using PlotlyJS

x_eq(t, x0, a) = x0 * exp(a * t)
y_eq(t, y0) = y0 * exp(-t)

function portrait(a::Float64, r::Float64, angles::Vector{Float64})
    traces::Vector{GenericTrace} = []
    x0s = [r * cos(θ) for θ ∈ angles]
    y0s = [r * sin(θ) for θ ∈ angles]
    ts = range(0.0, 2.0, length = 10)
    for (x0, y0) ∈ zip(x0s, y0s)
        xs = x_eq.(ts, x0, a)
        ys = y_eq.(ts, y0)
        trace_line = scatter(
            x = xs,
            y = ys,
            mode = "lines",
            line = attr(color = "black"),
            showlegend = false,
        )
        trace_point = scatter(
            x = [x0],
            y = [y0],
            mode = "markers",
            marker = attr(color = "blue", size = 10),
            showlegend = false,
        )
        push!(traces, trace_line)
        push!(traces, trace_point)
    end
    layout = Layout(width = 500, height = 500)
    plot(traces, layout)
end

display(portrait(-2.0, 0.1, [0.0, π/4, π/2, π, 3π/4, 5π/4, 3π/2, 7π/4]))
# display(portrait(-1.0, 1.0, 6))
# display(portrait(0.0, 1.0, 6))
# display(portrait(1.0, 1.0, 6))
println("Press enter to continue")
readline()
