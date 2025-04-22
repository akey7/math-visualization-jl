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
    display(eig.values)
    println("Eigenvectors")
    display(eig.vectors)
end

solve_for_ic([1.0 1.0; 4.0 -2.0], [2.0; -3.0])
