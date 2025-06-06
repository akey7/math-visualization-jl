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
    # annotations = []
    # for (fp, A) ∈ zip(fps, As)
    #     classification = classify_jacobian(A)
    #     annotation = attr(x = fp[1], y = fp[2], text = "<b>$classification</b>")
    #     push!(annotations, annotation)
    # end
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
        # annotations = annotations,
    )
    return plot(traces, layout)
end

#####################################################################
# MAKE FIGURES 7.3.7 AND 7.3.8                                      #
#####################################################################

function fig_7_3_7(a_vals)
    b2_plus = 0.5 .* (1 .- 2 .* a_vals .+ sqrt.(max.(0.0, 1 .- 8 .* a_vals)))
    b2_minus = 0.5 .* (1 .- 2 .* a_vals .- sqrt.(max.(0.0, 1 .- 8 .* a_vals)))
    traces::Vector{GenericTrace} = []
    trace1 = scatter(
        x = a_vals,
        y = b2_plus,
        mode = "lines",
        name = "b<sup>2</sup> + branch",
        fill = "none",
        line = attr(color = "purple"),
        showlegend = false,
    )
    push!(traces, trace1)
    trace2 = scatter(
        x = a_vals,
        y = b2_minus,
        mode = "lines",
        name = "b<sup>2</sup> - branch",
        fill = "tonexty",
        line = attr(color = "purple"),
        showlegend = false,
    )
    push!(traces, trace2)
    annotation_bgcolor = "white"
    annotation_bordercolor = "black"
    annotation_font = attr(size = 18)
    annotation_borderwidth = 1
    annotations = [
        attr(
            x = 0.06,
            y = 0.5,
            text = "<b>stable limit cycle</b>",
            bgcolor = annotation_bgcolor,
            bordercolor = annotation_bordercolor,
            borderwidth = annotation_borderwidth,
            font = annotation_font,
            showarrow = false,
        ),
        attr(
            x = 0.09,
            y = 0.0,
            text = "<b>stable fixed point</b>",
            bgcolor = annotation_bgcolor,
            bordercolor = annotation_bordercolor,
            borderwidth = annotation_borderwidth,
            font = annotation_font,
            showarrow = false,
        ),
        attr(
            x = 0.09,
            y = 0.9,
            text = "<b>stable fixed point</b>",
            bgcolor = annotation_bgcolor,
            bordercolor = annotation_bordercolor,
            borderwidth = annotation_borderwidth,
            font = annotation_font,
            showarrow = false,
        ),
    ]
    plot_bgcolor = "white"
    paper_bgcolor = "white"
    border_width = 1
    gridwidth = 1
    border_color = "black"
    gridcolor = "lightgray"
    layout = Layout(
        width = 500,
        height = 500,
        annotations = annotations,
        plot_bgcolor = plot_bgcolor,
        paper_bgcolor = paper_bgcolor,
        xaxis = attr(
            title = "a",
            showline = true,
            linewidth = border_width,
            linecolor = border_color,
            mirror = true,
            showgrid = true,
            gridcolor = gridcolor,
            gridwidth = gridwidth,
        ),
        yaxis = attr(
            title = "b<sup>2</sup>",
            showline = true,
            linewidth = border_width,
            linecolor = border_color,
            mirror = true,
            showgrid = true,
            gridcolor = gridcolor,
            gridwidth = gridwidth,
        ),
    )
    plot(traces, layout)
end

function fig_7_3_8(a, b)
    # Define parameters of functions
    ps = [a, b]

    # Min, max of calculations
    min_x, max_x = 0.0, 3.0
    min_y, max_y = 0.0, 4.0

    # Find fixed points
    eqs_01(u, p) = SA[-u[1]+p[1]*u[2]+u[1]^2*u[2], p[2]-p[1]*u[2]-u[1]^2*u[2]]
    fps = find_fixed_points(
        eqs_01;
        guess_xs = range(min_x, max_x, 5),
        guess_ys = range(min_y, max_y, 5),
        ps = ps,
    )
    println(fps)

    # Find Jacobians
    eqs_02(u, p) = [-u[1]+p[1]*u[2]+u[1]^2*u[2], p[2]-p[1]*u[2]-u[1]^2*u[2]]
    As = find_jacobians(eqs_02, fps, ps)
    println(As)

    # Find contours to plot nullclines and slope field
    f(u::Union{Vector{Float64},Tuple{Float64,Float64}}) = -u[1]+ps[1]*u[2]+u[1]^2*u[2]
    g(u::Union{Vector{Float64},Tuple{Float64,Float64}}) = ps[2]-ps[1]*u[2]-u[1]^2*u[2]
    contour_xs = range(min_x, max_x, 100)
    contour_ys = range(min_y, max_y, 100)
    contour_f_xy, contour_g_xy = nullcline_contours(f, g, contour_xs, contour_ys)
    start_xys, end_xys = slope_field(f, g, range(min_x, max_x, 10), range(min_y, max_y, 10))

    # Compute trajectories
    function trajectory_eqs!(du, u, p, t)
        du[1] = -u[1]+p[1]*u[2]+u[1]^2*u[2]
        du[2] = p[2]-p[1]*u[2]-u[1]^2*u[2]
    end

    u0s = [[0.333, 0.889], [0.667, 2.667], [0.0, 0.222]]
    tspans = [(0.0, 20.0), (0.0, 20.0), (0.0, 20.0)]

    trajectories = calculate_trajectories(trajectory_eqs!, u0s, tspans, ps)

    # Create final plot
    return final_plot(;
        title = "<b>a=$(ps[1]), b=$(ps[2])</b>",
        fps = fps,
        As = As,
        contour_xs = contour_xs,
        contour_ys = contour_ys,
        contour_f_xy = contour_f_xy,
        contour_g_xy = contour_g_xy,
        slope_start_xys = start_xys,
        slope_end_xys = end_xys,
        trajectories = trajectories,
    )
end

display(fig_7_3_8(0.08, 0.6))
display(fig_7_3_8(0.12, 0.2))
display(fig_7_3_7(range(0.0, 0.12537, 200)))
println("Press enter to exit")
readline()
