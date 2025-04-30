using NonlinearSolve
using DifferentialEquations
using SciMLBase
using StaticArrays
using ForwardDiff
using PlotlyJS

########################################################
# SYSTEM OF EQUATIONS                                  #
########################################################

f(x) = -x[1] + x[1]^3
g(x) = -2*x[2]

########################################################
# FIND FIXED POINTS                                    #
########################################################

function find_fixed_points()
    system_of_eqs(u, p) = SA[-u[1] + u[1]^3, -2*u[2]]
    guess_xs = range(-2.0, 2.0, 10)
    guess_ys = range(-2.0, 2.0, 10)
    fixed_points = []
    for (guess_x, guess_y) ∈ Base.product(guess_xs, guess_ys)
        u0 = SA[guess_x, guess_y]
        prob = NonlinearProblem(system_of_eqs, u0)
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
    fixed_points
end
fps = find_fixed_points()
println(fps)

########################################################
# COMPUTE JACOBIANS AT FIXED POINTS                    #
########################################################

function find_jacobians()
    jacobians = []
    for fp ∈ fps
        jacobian = ForwardDiff.jacobian(fp) do u
            [-u[1] + u[1]^3, -2*u[2]]
        end
        push!(jacobians, jacobian)
    end
    jacobians
end
println(find_jacobians())
