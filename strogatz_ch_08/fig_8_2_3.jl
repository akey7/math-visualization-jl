using NonlinearSolve
using DifferentialEquations
using SciMLBase
using StaticArrays
using ForwardDiff
using LinearAlgebra
using Suppressor
using PlotlyJS

function find_fixed_points(
    system_of_eqs;
    guess_xs::AbstractRange,
    guess_ys::AbstractRange,
    ps::Vector{Float64},
)
    fixed_points = []
    @suppress begin
        for (guess_x, guess_y) ∈ Base.product(guess_xs, guess_ys)
            u0 = [guess_x, guess_y]
            prob = NonlinearProblem(system_of_eqs, u0, ps)
            sol = solve(prob, TrustRegion(), maxiters = 1_000_000)
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
                # else
                #     println("$u0 $(sol.retcode)")
            end
        end
    end
    return fixed_points
end

function nullcline_contours(f, g, xs, ys)
    f_xy = [f([x, y]) for x ∈ xs, y ∈ ys]
    g_xy = [g([x, y]) for x ∈ xs, y ∈ ys]
    return f_xy, g_xy
end

function slope_field(f, g, xs, ys)
    scaler = 1 / length(xs)
    start_xys = Base.product(xs, ys)
    end_xys = [
        (start_xy[1] + f(start_xy)*scaler, start_xy[2] + g(start_xy)*scaler) for
        start_xy ∈ start_xys
    ]
    return start_xys, end_xys
end

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

function circle_of_u0s(r, tspan_min, tspan_max)
    angles = [0.0, π/4, π/2, π, 3π/4, 5π/4, 3π/2, 7π/4]
    u0s = [[r*cos(θ), r*sin(θ)] for θ ∈ angles]
    tspans = [(tspan_min, tspan_max) for _ ∈ eachindex(u0s)]
    return u0s, tspans
end

function fig_8_2_3(μ, ω)
    ps = [μ, ω]

    # Min, max of calculations
    min_x, max_x = -0.1, 0.1
    min_y, max_y = -0.1, 0.1

    # Compute fixed points
    fp_eqs(u, p) = SA[p[1]*u[1]-p[2]*u[2], p[2]*u[1]+p[1]*u[2]]
    fps = find_fixed_points(
        fp_eqs,
        guess_xs = range(min_x, max_x, 5),
        guess_ys = range(min_y, max_y, 5),
        ps = ps,
    )

    # Find contours to plot nullclines
    f(u) = μ*u[1]-ω*u[2]
    g(u) = ω*u[1]+μ*u[2]
    contour_xs = range(min_x, max_x, 100)
    contour_ys = range(min_y, max_y, 100)
    contour_f_xy, contour_g_xy = nullcline_contours(f, g, contour_xs, contour_ys)

    # Find slope field
    slope_start_xys, slope_end_xys = slope_field(f, g, range(min_x, max_x, 10), range(min_y, max_y, 10))

    # Compute trajectories
    function trajectory_eqs!(du, u, p, t)
        du[1] = p[1]*u[1] - p[2]*u[2]
        du[2] = p[2]*u[1] + p[1]*u[2]
    end

    u0s, tspans = circle_of_u0s(0.01, 0.0, 2.5)
    println("Computing trajectories...")
    trajectories = calculate_trajectories(trajectory_eqs!, u0s, tspans, ps)
    println("Done computing trajectories!")

    # Create final plot
    return final_plot(;
        title = "<b>μ=$μ, ω=$ω</b>",
        fps = fps,
        contour_xs = contour_xs,
        contour_ys = contour_ys,
        contour_f_xy = contour_f_xy,
        contour_g_xy = contour_g_xy,
        slope_start_xys = slope_start_xys,
        slope_end_xys = slope_end_xys,
        trajectories = trajectories,
    )
end

display(fig_8_2_3(1.0, 1.0))
println("Press enter to exit")
readline()
