using NonlinearSolve
using DifferentialEquations
using SciMLBase
using StaticArrays
using ForwardDiff
using LinearAlgebra
using PlotlyJS

function find_fixed_points(
    system_of_eqs;
    guess_xs::AbstractRange,
    guess_ys::AbstractRange,
    ps::Vector{Float64},
)
    fixed_points = []
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
        else
            println("$u0 $(sol.retcode)")
        end
    end
    return fixed_points
end

function find_jacobians(system_of_eqs, fps, ps)
    jacobians = []
    for fp ∈ fps
        jacobian = ForwardDiff.jacobian(system_of_eqs, fp, ps)
        push!(jacobians, jacobian)
    end
    return jacobians
end

function classify_jacobian(A::Matrix{Float64})
    τ = tr(A)
    Δ = det(A)
    discriminant = tr(A)^2 - 4*det(A)
    if Δ < 0.0
        return "Saddle"
    else
        if isapprox(discriminant, 0.0)
            return "Star, Degenerate"
        elseif discriminant > 0.0
            if isapprox(τ, 0.0)
                return "Neutral Stable"
            elseif τ < 0.0
                return "Stable"
            else
                return "Unstable"
            end
        else
            return "Spiral"
        end
    end
    return "Unknown"
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
    As,
    contour_xs,
    contour_ys,
    contour_f_xy,
    contour_g_xy,
    slope_start_xys,
    slope_end_xys,
    trajectories,
)
    annotations = []
    for (fp, A) ∈ zip(fps, As)
        classification = classify_jacobian(A)
        annotation = attr(x = fp[1], y = fp[2], text = "<b>$classification</b>")
        push!(annotations, annotation)
    end
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
    for (i, (fp, A)) ∈ enumerate(zip(fps, As))
        classification = classify_jacobian(A)
        size = 15
        color = "darkorchid"
        symbol = classification == "Saddle" ? "circle-open" : "circle"
        showlegend = i == 1
        trace_fp = scatter(
            x = [fp[1]],
            y = [fp[2]],
            mode = "markers",
            marker = attr(color = color, symbol = symbol, size = size),
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
        annotations = annotations,
    )
    return plot(traces, layout)
end

#####################################################################
# MAKE THE PLOT                                                     #
#####################################################################
