using LinearAlgebra
using PlotlyJS

function solve_for_ic(A::Matrix{Float64}, ics::Vector{Float64})
    println("#####################################################")
    println("# BEGIN SOLVE                                       #")
    println("#####################################################")
    println("A:")
    display(A)
    println("Initial conditions:")
    display(ics)
    eig = eigen(A)
    println("Eigenvalues")
    λ = eig.values
    display(λ)
    println("Normalized eigenvectors")
    v = eig.vectors
    display(v)
    c = eig.vectors \ ics
    println("c1 and c2")
    display(c)
    x_eq(t::Float64) = c[1]*v[1, 1]*exp(λ[1]*t) + c[2]*v[1, 2]*exp(λ[2]*t)
    y_eq(t::Float64) = c[1]*v[1, 2]*exp(λ[1]*t) + c[2]*v[2, 2]*exp(λ[2]*t)
    x_eq, y_eq
end

A = [1.0 1.0; 4.0 -2.0]
ts = range(-1.0, 1.0, 100)
traces::Vector{GenericTrace} = []
for x ∈ [2.0]
    for y ∈ [-3.0]
        x_eq, y_eq = solve_for_ic(A, [x, y])
        xs = x_eq.(ts)
        ys = y_eq.(ts)
        trace_line = scatter(x = xs, y = ys, mode = "lines", marker = attr(color = "black"))
        trace_start = scatter(
            x = [xs[1]],
            y = [ys[1]],
            mode = "markers",
            marker = attr(color = "blue", size = 10),
        )
        trace_end = scatter(
            x = [xs[end]],
            y = [ys[end]],
            mode = "markers",
            marker = attr(color = "red", size = 10),
        )
        push!(traces, trace_start)
        push!(traces, trace_line)
        push!(traces, trace_end)
    end
end
layout = Layout(width = 500, height = 500)
p = plot(traces, layout)
display(p)
println("Press enter to exit...")
readline()
