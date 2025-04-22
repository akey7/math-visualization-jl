using LinearAlgebra
using PlotlyJS

#####################################################
# DEFINE A MATRIX AND INITIAL CONDITIONS            #
#####################################################

A = [1.0 1.0; 4.0 -2.0]
initial_conditions = [2.0; -3.0]

#####################################################
# SOLVE AND CHECK EIGENSOLUTIONS                    #
#####################################################

eig = eigen(A)
println("Eigenvalues")
display(eig.values)
println("Eigenvectors")
display(eig.vectors)

for i ∈ 1:2
    v = eig.vectors[:, i]
    λ = eig.values[i]
    lhs = A * v
    rhs = λ * v 
    println(lhs ≈ rhs)
end

#####################################################
# SOLVE FOR C1, C2                                  #
#####################################################

c1_c2 = eig.vectors \ initial_conditions
println(c1_c2)

#####################################################
# FINALIZE THE SOLUTION                             #
#####################################################

x_eq(t) = c1_c2[1] * eig.vectors[1, 1] * exp(eig.values[1] * t) + c1_c2[2] * eig.vectors[1, 2] * exp(eig.values[2] * t)
y_eq(t) = c1_c2[1] * eig.vectors[2, 1] * exp(eig.values[1] * t) + c1_c2[2] * eig.vectors[2, 2] * exp(eig.values[2] * t)

#####################################################
# PLOTTING FUNCTION                                 #
#####################################################

function portrait(r::Float64)
    traces::Vector{GenericTrace} = []
    angles = [0.0, π/4, π/2, π, 3π/4, 5π/4, 3π/2, 7π/4]
    x0s = [r * cos(θ) for θ ∈ angles]
    y0s = [r * sin(θ) for θ ∈ angles]
    ts = range(0.0, 2.0, length = 10)
    for (i, (x0, y0)) ∈ enumerate(zip(x0s, y0s))
        xs = x_eq.(ts)
        ys = y_eq.(ts)
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
    layout = Layout(width = 500, height = 500)
    plot(traces, layout)
end
