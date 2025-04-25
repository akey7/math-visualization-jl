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
    layout = Layout(width = width, height = height)
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
println("Press enter to exit...")
readline()
