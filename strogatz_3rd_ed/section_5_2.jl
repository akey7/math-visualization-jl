using LinearAlgebra
using PlotlyJS

A = [1.0 1.0; 4.0 -2.0]
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
