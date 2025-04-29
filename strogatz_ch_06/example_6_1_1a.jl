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

start_xs = collect(range(-1.5, 1.5, 10))
start_ys = collect(range(-1.5, 1.5, 10))
start_xys = Base.product(start_xs, start_ys)
scaler = 1 / length(start_xs)
end_xys = [
    (start_xy[1] + f(start_xy)*scaler, start_xy[2] + g(start_xy)*scaler) for
    start_xy ∈ start_xys
]

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
    showlegend = false,
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
    showlegend = false,
)
push!(traces, trace_gxy)
trace_fixed_points = scatter(
    x = [fixed_point[1]],
    y = [fixed_point[2]],
    mode = "markers",
    marker = attr(color = "firebrick", size = 10),
    name = "Fixed Point",
    showlegend = false,
)
push!(traces, trace_fixed_points)
for (start_xy, end_xy) ∈ zip(start_xys, end_xys)
    println("$start_xy to $end_xy")
    trace_slope = scatter(
        x = [start_xy[1], end_xy[1]],
        y = [start_xy[2], end_xy[2]],
        mode = "lines",
        line = attr(color = "green"),
        name = "slope",
        showlegend = false,
    )
    push!(traces, trace_slope)
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
