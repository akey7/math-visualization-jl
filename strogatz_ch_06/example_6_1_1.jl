using NonlinearSolve

########################################################
# SYSTEM OF EQUATIONS                                  #
########################################################

f(x) = x[1] + exp(-x[2])
g(x) = -x[2]

########################################################
# FIND FIXED POINT                                     #
########################################################

function system_of_eqs(x, p)
    [f(x), g(x)]
end

initial_x = [0.5, 0.5]
prob = NonlinearProblem(system_of_eqs, initial_x)
sol = solve(prob, NewtonRaphson())
println("Fixed point: ", sol.u)

########################################################
# FIND NULLCLINES GRAPHICALLY                          #
########################################################

x_vals = range(-10.0, 10.0, 100)
y_vals = range(-10.0, 10.0, 100)
contour = []
