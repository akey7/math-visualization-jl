using NonlinearSolve

function f(x, p)
    [
        x[1] + exp(-x[2]),
        -x[2]
    ]
end

initial_x = [0.5, 0.5]
prob = NonlinearProblem(f, initial_x)
sol = solve(prob, NewtonRaphson())
println("Solution: ", sol.u)
