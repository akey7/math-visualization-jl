using NonlinearSolve
using DifferentialEquations
using SciMLBase
using StaticArrays
using ForwardDiff
using PlotlyJS

########################################################
# FIND FIXED POINTS                                    #
########################################################

function find_fixed_points()
    system_of_eqs(u, p) = SA[-u[1]+u[1]^3, -2*u[2]]
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

########################################################
# MIN AND MAX X, Y FOR PLOTTING                        #
########################################################

min_x, max_x = -1.5, 1.5
min_y, max_y = -1.0, 1.0

########################################################
# SYSTEM OF EQUATIONS FOR NULLCLINES, SLOPE FIELD      #
########################################################

f(u::Union{Vector{Float64},Tuple{Float64,Float64}}) = -u[1] + u[1]^3
g(u::Union{Vector{Float64},Tuple{Float64,Float64}}) = -2*u[2]

########################################################
# CALCULATE CONTOURS TO DRAW NULLCLINES                #
########################################################

contour_xs = range(min_x, max_x, 100)
contour_ys = range(min_y, max_y, 100)
f_xy = [f([x, y]) for x ∈ contour_xs, y ∈ contour_ys]
g_xy = [g([x, y]) for x ∈ contour_xs, y ∈ contour_ys]

########################################################
# CALCULATE SLOPE FIELD                                #
########################################################

start_xs = collect(range(min_x, max_x, 10))
start_ys = collect(range(min_y, max_y, 10))
start_xys = Base.product(start_xs, start_ys)
scaler = 1 / length(start_xs)
end_xys = [
    (start_xy[1] + f(start_xy)*scaler, start_xy[2] + g(start_xy)*scaler) for
    start_xy ∈ start_xys
]

########################################################
# CALCUALTE A FEW TRAJECTORIES                         #
########################################################

function trajectory_eqs!(du, u, p, t)
    du[1] = -u[1] + u[1]^3
    du[2] = -2*u[2]
end

u0s = [
    [-0.833, -0.556],
    [-1.167, -0.556],
    [-1.167, 0.556],
    [-0.833, 0.556],
]
tspans = [
    (-0.5, 0.5),
    (-0.1, 0.2),
    (-0.1, 0.2),
    (-0.5, 0.5),
]
trajectories = []
for (u0, tspan) ∈ zip(u0s, tspans)
    trajectory_prob = ODEProblem(trajectory_eqs!, u0, tspan)
    trajectory_sol = solve(trajectory_prob, Tsit5())
    push!(trajectories, trajectory_sol.u) 
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
