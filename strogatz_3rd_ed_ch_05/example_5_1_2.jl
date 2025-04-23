using PlotlyJS

x_eq(t, x0, a) = x0 * exp(a * t)
y_eq(t, y0) = y0 * exp(-t)

function portrait(a::Float64, r::Float64, width::Int64 = 500, height::Int64 = 500)
    traces::Vector{GenericTrace} = []
    angles = [0.0, π/4, π/2, π, 3π/4, 5π/4, 3π/2, 7π/4]
    x0s = [r * cos(θ) for θ ∈ angles]
    y0s = [r * sin(θ) for θ ∈ angles]
    ts = range(0.0, 2.0, length = 10)
    for (i, (x0, y0)) ∈ enumerate(zip(x0s, y0s))
        xs = x_eq.(ts, x0, a)
        ys = y_eq.(ts, y0)
        showlegend = i == 1
        trace_start = scatter(
            x = [x0],
            y = [y0],
            mode = "markers",
            marker = attr(color = "blue", size = 10),
            name = "start",
            showlegend = showlegend,
        )
        trace_line = scatter(
            x = xs,
            y = ys,
            mode = "lines",
            line = attr(color = "black"),
            name = "path",
            showlegend = showlegend,
        )
        trace_end = scatter(
            x = [xs[end]],
            y = [ys[end]],
            mode = "markers",
            marker = attr(color = "red", size = 10),
            name = "end",
            showlegend = showlegend,
        )
        push!(traces, trace_start)
        push!(traces, trace_line)
        push!(traces, trace_end)
    end
    title = "a = $a"
    plot_bgcolor = "white"
    paper_bgcolor = "white"
    border_width = 1
    gridwidth = 1
    border_color = "black"
    gridcolor = "lightgray"
    layout = Layout(
        plot_bgcolor = plot_bgcolor,
        paper_bgcolor = paper_bgcolor,
        title = title,
        xaxis = attr(
            showline = true,
            linewidth = border_width,
            linecolor = border_color,
            mirror = true,
            showgrid = true,
            gridcolor = gridcolor,
            gridwidth = gridwidth,
        ),
        yaxis = attr(
            showline = true,
            linewidth = border_width,
            linecolor = border_color,
            mirror = true,
            showgrid = true,
            gridcolor = gridcolor,
            gridwidth = gridwidth,
        ),
        width = width,
        height = height,
    )
    plot(traces, layout)
end

display(portrait(-2.0, 0.1))
display(portrait(-1.0, 1.0))
display(portrait(1.0, 1.0))
println("Press enter to continue")
readline()
