using NonlinearSolve
using DifferentialEquations
using SciMLBase
using PlotlyJS

########################################################
# SYSTEM OF EQUATIONS                                  #
########################################################

f(x) = -x[1] + x[1]^3
g(x) = -2*x[2]

########################################################
# FIND FIXED POINTS                                    #
########################################################

nls_system_of_eqs(x, p) = [f(x), g(x)]
guess_xs = range(-2.0, 2.0, 10)
guess_ys = range(-2.0, 2.0, 10)
fixed_points = []
for (guess_x, guess_y) ∈ Base.product(guess_xs, guess_ys)
    prob = NonlinearProblem(nls_system_of_eqs, [guess_x, guess_y])
    sol = solve(prob, NewtonRaphson())
    if SciMLBase.successful_retcode(sol)
        found = false
        for fixed_point ∈ fixed_points
            if isapprox(fixed_point[1], sol.u[1], atol = 1e-3) &&
               isapprox(fixed_point[2], sol.u[2], atol = 1e-3)
                found = true
                break
            end
        end
        if !found
            push!(fixed_points, sol.u)
        end
    end
end
println(fixed_points)
