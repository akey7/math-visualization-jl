using LinearAlgebra
using DifferentialEquations
using PlotlyJS

function solve_system(A::Matrix{Float64}, x0::Vector{Float64}, tspan::Tuple{Float64,Float64})
    f(x, p, t) = A * x
    prob = ODEProblem(f, x0, tspan)
    solve(prob, Tsit5())
end

function portrait(A::Matrix{Float64}, x0::Vector{Float64}, tspan::Tuple{Float64,Float64})
    sol = solve_system(A, x0, tspan)
    xs = sol[1, :]
    ys = sol[2, :]
    traces::Vector{GenericTrace} = []
    trace_path =
        scatter(x = xs, y = ys, mode = "lines", line = attr(color = "black"), name = "path")
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

display(portrait([0.0 1.0; -2.0 -1.0], [1.0, 0.0], (0.0, 1.0)))
println("Press enter to exit...")
readline()
