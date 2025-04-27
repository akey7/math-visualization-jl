using NonlinearSolve
using PlotlyJS

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
# CALCULATE CONTOURS TO FIND NULLCLINES                #
########################################################

xs = range(-2.0, 2.0, 100)
ys = range(-2.0, 2.0, 100)
f_xy = [f([x, y]) for x ∈ xs, y ∈ ys]
g_xy = [g([x, y]) for x ∈ xs, y ∈ ys]

########################################################
# ASSEMBLE FINAL PLOT                                  #
########################################################

trace_f = contour(
    x = xs,
    y = ys,
    z = f_xy',
    contours_start = 0,
    contours_end = 0,
    contours_coloring = "lines"
)
trace_g = contour(
    x = xs,
    y = ys,
    z = g_xy',
    contours_start = 0,
    contours_end = 0,
    contours_coloring = "lines"
)
plot_bgcolor = "white"
paper_bgcolor = "white"
border_width = 1
gridwidth = 1
border_color = "black"
gridcolor = "lightgray"
layout = Layout(
    width = 550, 
    height = 550
)
display(plot([trace_f, trace_g], layout))

########################################################
# PROMPT TO EXIT                                       #
########################################################

println("Press enter to exit...")
readline()
