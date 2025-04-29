using NonlinearSolve
using DifferentialEquations
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

contour_xs = range(-4.0, 2.0, 100)
contour_ys = range(-2.0, 2.0, 100)
f_xy = [f([x, y]) for x ∈ contour_xs, y ∈ contour_ys]
g_xy = [g([x, y]) for x ∈ contour_xs, y ∈ contour_ys]

########################################################
# CALCULATE SLOPE FIELD                                #
########################################################

start_xs = collect(range(-4.0, 4.0, 20))
start_ys = collect(range(-1.5, 1.5, 10))
start_xys = Base.product(start_xs, start_ys)
scaler = 1 / length(start_xs)
end_xys = [
    (start_xy[1] + f(start_xy)*scaler, start_xy[2] + g(start_xy)*scaler) for
    start_xy ∈ start_xys
]

########################################################
# CALCUALTE A FEW TRAJECTORIES                         #
########################################################

function system_of_eqs_02!(dy, y, p, t)
    dy[1] = y[1] + exp(-y[2])
    dy[2] = -y[2]
end

# angles = [0.0, π/2, π, 3π/2]
# rs = [1.0]
# u0s = [[r * cos(θ), r * sin(θ)] for θ ∈ angles, r ∈ rs]
u0s = [
    [-1.5, 1.0],
    [-1.5, -1.0],
    [0.0, -1.0],
    [1.0, 0.0],
    [0.0, 1.0],
    [-0.83, 1.11],
    [0.722, 1.11],
    [-1.89, -0.105],
    [-1.90, -0.475]
]
tspan = (-0.5, 0.5)
dt = 0.01
trajectories = []
for u0 ∈ u0s
    prob02 = ODEProblem(system_of_eqs_02!, u0, tspan)
    sol02 = solve(prob02, RK4(), dt = dt)
    push!(trajectories, sol02.u)
end

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
    marker = attr(color = "firebrick", size = 15),
    name = "Fixed Point",
    showlegend = false,
)
push!(traces, trace_fixed_points)
for (start_xy, end_xy) ∈ zip(start_xys, end_xys)
    trace_slope = scatter(
        x = [start_xy[1], end_xy[1]],
        y = [start_xy[2], end_xy[2]],
        mode = "lines",
        line = attr(color = "lawngreen"),
        name = "slope",
        showlegend = false,
    )
    push!(traces, trace_slope)
end
for (i, trajectory) ∈ enumerate(trajectories)
    trace_start = scatter(
        x = [trajectory[1][1]],
        y = [trajectory[1][2]],
        mode = "markers",
        marker = attr(color = "blue", size = 10),
        name = "start $i",
        showlegend = false,
    )
    trace_trajectory = scatter(
        x = [x for (x, _) ∈ trajectory],
        y = [y for (_, y) ∈ trajectory],
        mode = "lines",
        line = attr(color = "black"),
        name = "trajectory $i",
        showlegend = false,
    )
    trace_end = scatter(
        x = [trajectory[end][1]],
        y = [trajectory[end][2]],
        mode = "markers",
        marker = attr(color = "red", size = 10),
        name = "end $i",
        showlegend = false,
    )
    push!(traces, trace_start)
    push!(traces, trace_trajectory)
    push!(traces, trace_end)
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
