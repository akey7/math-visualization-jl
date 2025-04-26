using LinearAlgebra
using DifferentialEquations
using PlotlyJS

function solve_system(
    A::Matrix{Float64},
    x0::Vector{Float64},
    tspan::Tuple{Float64,Float64},
)
    f(x, p, t) = A * x
    prob = ODEProblem(f, x0, tspan)
    solve(prob, Tsit5())
end

function portrait(
    A::Matrix{Float64},
    tspan::Tuple{Float64,Float64},
    rs::Vector{Float64},
    angles::Vector{Float64},
    width::Int64,
    height::Int64,
)
    x0s = [[r * cos(θ), r * sin(θ)] for θ ∈ angles, r ∈ rs]
    traces::Vector{GenericTrace} = []
    for (i, x0) ∈ enumerate(x0s)
        sol = solve_system(A, x0, tspan)
        xs = sol[1, :]
        ys = sol[2, :]
        showlegend = i == 1
        trace_path = scatter(
            x = xs,
            y = ys,
            mode = "lines",
            line = attr(color = "black"),
            name = "path",
            showlegend = showlegend,
        )
        trace_start = scatter(
            x = [xs[1]],
            y = [ys[1]],
            mode = "markers",
            line = attr(color = "blue"),
            name = "start",
            showlegend = showlegend,
        )
        trace_end = scatter(
            x = [xs[end]],
            y = [ys[end]],
            mode = "markers",
            line = attr(color = "red"),
            name = "end",
            showlegend = showlegend,
        )
        push!(traces, trace_path)
        push!(traces, trace_start)
        push!(traces, trace_end)
    end
    title = "<b>A = $A</b>"
    plot_bgcolor = "white"
    paper_bgcolor = "white"
    border_width = 1
    gridwidth = 1
    border_color = "black"
    gridcolor = "lightgray"
    layout = Layout(
        title = title,
        plot_bgcolor = plot_bgcolor,
        paper_bgcolor = paper_bgcolor,
        width = width,
        height = height,
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
        )
    )
    plot(traces, layout)
end

display(
    portrait(
        [1.0 -1.0; 1.0 1.0],
        (0.0, 2.0),
        [0.5],
        [0.0, π/4, π/2, π, 3π/4, 5π/4, 3π/2, 7π/4],
        550,
        500,
    ),
)
display(
    portrait(
        [3.0 -3.0; 2.0 2.0],
        (0.0, 2.0),
        [0.5],
        [0.0, π/4, π/2, π, 3π/4, 5π/4, 3π/2, 7π/4],
        550,
        500,
    ),
)
println("Press enter to exit...")
readline()
