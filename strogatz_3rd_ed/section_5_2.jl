using LinearAlgebra
using PlotlyJS

#####################################################
# DEFINE A MATRIX AND INITIAL CONDITIONS            #
#####################################################

# A = [1.0 1.0; 4.0 -2.0]
A = [1.0 -2.0; -3.0 4.0]
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

x_eq(t) =
    c1_c2[1] * eig.vectors[1, 1] * exp(eig.values[1] * t) +
    c1_c2[2] * eig.vectors[1, 2] * exp(eig.values[2] * t)
y_eq(t) =
    c1_c2[1] * eig.vectors[2, 1] * exp(eig.values[1] * t) +
    c1_c2[2] * eig.vectors[2, 2] * exp(eig.values[2] * t)

#####################################################
# DISPALY A PLOT                                    #
#####################################################

cs = range(-10.0, 10.0, 100)
xs1 = cs .* eig.vectors[1, 1]
ys1 = cs .* eig.vectors[2, 1]
xs2 = cs .* eig.vectors[1, 2]
ys2 = cs .* eig.vectors[2, 2]
traces = [
    scatter(x = xs1, y = ys1, mode = "lines", line = attr(color = "black")),
    scatter(
        x = [xs1[1]],
        y = [ys1[1]],
        model = "markers",
        marker = attr(color = "blue", size = 10),
    ),
    scatter(
        x = [xs1[end]],
        y = [ys1[end]],
        model = "markers",
        marker = attr(color = "red", size = 10),
    ),
    scatter(x = xs2, y = ys2, mode = "lines", line = attr(color = "black")),
    scatter(
        x = [xs2[1]],
        y = [ys2[1]],
        model = "markers",
        marker = attr(color = "blue", size = 10),
    ),
    scatter(
        x = [xs2[end]],
        y = [ys2[end]],
        model = "markers",
        marker = attr(color = "red", size = 10),
    ),
]
layout = Layout(width = 500, height = 500, legend = false)
p = plot(traces, layout)
PlotlyJS.display(p)
println("Press enter to exit")
readline()
