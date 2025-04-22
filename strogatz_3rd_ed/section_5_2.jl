using LinearAlgebra
using PlotlyJS

A = [1.0 1.0; 4.0 -2.0]
eig = eigen(A)
println("Eigenvalues")
println(eig.values)
println("Eigenvectors")
println(eig.vectors)
