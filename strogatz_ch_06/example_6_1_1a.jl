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
fixed_point = sol.u
println("Fixed point: ", fixed_point)

########################################################
# CALCULATE CONTOURS TO DRAW NULLCLINES                #
########################################################

contour_xs = range(-2.0, 2.0, 100)
contour_ys = range(-2.0, 2.0, 100)
f_xy = [f([x, y]) for x ∈ contour_xs, y ∈ contour_ys]
g_xy = [g([x, y]) for x ∈ contour_xs, y ∈ contour_ys]

########################################################
# CALCULATE SLOPE FIELD                                #
########################################################

start_xs = range(-2.0, 2.0, 10)
start_ys = range(-2.0, 2.0, 10)
end_xs = [x + f([x, y]) for x ∈ start_xs, y ∈ start_ys]
end_ys = [y + g([x, y]) for x ∈ start_xs, y ∈ start_ys]

########################################################
# ASSEMBLE FINAL PLOT                                  #
########################################################

traces::Vector{GenericTrace} = []
trace_fxy = contour(
    x = contour_xs,
    y = contour_ys,
    z = f_xy',
    contours_start = 0,
    contours_end = 0,
    contours_coloring = "lines",
    colorscale = [[0, "gold"], [1.0, "white"]],
    line = attr(width = 2),
    name = "f(x,y)",
)
push!(traces, trace_fxy)
trace_gxy = contour(
    x = contour_xs,
    y = contour_ys,
    z = g_xy',
    contours_start = 0,
    contours_end = 0,
    contours_coloring = "lines",
    colorscale = [[0, "darkorange"], [1.0, "white"]],
    line = attr(width = 2),
    name = "g(x,y)",
)
push!(traces, trace_gxy)
trace_fixed_points = scatter(
    x = [fixed_point[1]],
    y = [fixed_point[2]],
    mode = "markers",
    marker = attr(color = "firebrick", size = 10),
)
push!(traces, trace_fixed_points)
println(length(end_xs))
for ((start_x, start_y), (end_x, end_y)) ∈ zip(zip(start_xs, start_ys), (end_xs, end_ys))
    println("($start_x, $start_y) to ($end_x, $end_y)")
end
plot_bgcolor = "white"
paper_bgcolor = "white"
border_width = 1
gridwidth = 1
border_color = "black"
gridcolor = "lightgray"
layout = Layout(
    width = 550,
    height = 500,
    plot_bgcolor = plot_bgcolor,
    paper_bgcolor = paper_bgcolor,
    xaxis = attr(
        showline = true,
        linewidth = border_width,
        linecolor = border_color,
        mirror = true,
        showgrid = true,
        gridcolor = gridcolor,
        gridwidth = gridwidth,
    ),
    yaxis = attr(
        showline = true,
        linewidth = border_width,
        linecolor = border_color,
        mirror = true,
        showgrid = true,
        gridcolor = gridcolor,
        gridwidth = gridwidth,
    ),
)
display(plot(traces, layout))

########################################################
# PROMPT TO EXIT                                       #
########################################################

println("Press enter to exit...")
readline()
