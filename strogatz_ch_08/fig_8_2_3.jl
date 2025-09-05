using DifferentialEquations
using PlotlyJS

function calculate_trajectories(trajectory_eqs!, u0s, tspans, ps)
    trajectories = []
    for (u0, tspan) ∈ zip(u0s, tspans)
        trajectory_prob = ODEProblem(trajectory_eqs!, u0, tspan, ps)
        trajectory_sol = solve(trajectory_prob, RK4(), dt = 0.01)
        push!(trajectories, trajectory_sol.u)
    end
    return trajectories
end

function final_plot(;
    title,
    fps,
    contour_xs,
    contour_ys,
    contour_f_xy,
    contour_g_xy,
    slope_start_xys,
    slope_end_xys,
    trajectories,
)
    traces::Vector{GenericTrace} = []
    trace_fxy = contour(
        x = contour_xs,
        y = contour_ys,
        z = contour_f_xy',
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
        z = contour_g_xy',
        contours_start = 0,
        contours_end = 0,
        contours_coloring = "lines",
        colorscale = [[0, "darkorange"], [1.0, "white"]],
        line = attr(width = 2),
        name = "g(x,y)",
        showlegend = false,
    )
    push!(traces, trace_gxy)
    for (i, (start_xy, end_xy)) ∈ enumerate(zip(slope_start_xys, slope_end_xys))
        showlegend = i == 1
        trace_slope = scatter(
            x = [start_xy[1], end_xy[1]],
            y = [start_xy[2], end_xy[2]],
            mode = "lines",
            line = attr(color = "lawngreen"),
            name = "slope",
            showlegend = showlegend,
        )
        push!(traces, trace_slope)
    end
    for (i, trajectory) ∈ enumerate(trajectories)
        showlegend = i == 1
        trace_start = scatter(
            x = [trajectory[1][1]],
            y = [trajectory[1][2]],
            mode = "markers",
            marker = attr(color = "blue", size = 10),
            name = "start",
            showlegend = showlegend,
        )
        trace_trajectory = scatter(
            x = [x for (x, _) ∈ trajectory],
            y = [y for (_, y) ∈ trajectory],
            mode = "lines",
            line = attr(color = "black"),
            name = "trajectory",
            showlegend = showlegend,
        )
        trace_end = scatter(
            x = [trajectory[end][1]],
            y = [trajectory[end][2]],
            mode = "markers",
            marker = attr(color = "red", size = 10),
            name = "end",
            showlegend = showlegend,
        )
        push!(traces, trace_start)
        push!(traces, trace_trajectory)
        push!(traces, trace_end)
    end
    for (i, fp) ∈ enumerate(fps)
        size = 15
        color = "darkorchid"
        showlegend = i == 1
        trace_fp = scatter(
            x = [fp[1]],
            y = [fp[2]],
            mode = "markers",
            marker = attr(color = color, size = size),
            showlegend = showlegend,
            name = "Fixed Points",
        )
        push!(traces, trace_fp)
    end
    plot_bgcolor = "white"
    paper_bgcolor = "white"
    border_width = 1
    gridwidth = 1
    border_color = "black"
    gridcolor = "lightgray"
    layout = Layout(
        title = title,
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
    return plot(traces, layout)
end

function fig_8_2_3(μ, ω, b)
    ps = [μ, ω, b]

    # Compute trajectories
    function trajectory_eqs!(du, u, p, t)
        du[1] = p[1]*u[1] - u[1]^3
        du[2] = p[2] + p[3]*u[1]^2
    end

    u0s = [
        [1.0, 0.0],
        [-1.0, 0.0],
        [0.0, 1.0],
        [0.1, -1.0]
    ]
    tspans = [
        (0.0, 10.0),
        (0.0, 10.0),
        (0.0, 10.0),
    ]
    println("Computing trajectories...")
    trajectories = calculate_trajectories(trajectory_eqs!, u0s, tspans, ps)
    println("Done computing trajectories!")

    # Create final plot
    return final_plot(;
        title = "<b>μ=$μ, ω=$ω, b=$b</b>",
        fps = [],
        contour_xs = [],
        contour_ys = [],
        contour_f_xy = [],
        contour_g_xy = [],
        slope_start_xys = [],
        slope_end_xys = [],
        trajectories = trajectories,
    )
end

display(fig_8_2_3(1.0, 1.0, 1.0))
println("Press enter to exit")
readline()
