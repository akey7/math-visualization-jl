using Base64
using Gtk
using Plots
using Cairo
using DifferentialEquations

gr()

######################################################################
# MODELING / ODE FUNCTION                                            #
######################################################################

function calc_trajectories(
    initital_fox_pop,
    initial_rabbit_pop,
    rabbit_pop_growth_rate,
    rabbit_eaten_rate,
    fox_pop_depletion_rate,
    fox_birth_rate,
)
    function eqs!(du, u, p, t)
        du[1] = p[1]*u[1] - p[2]*u[1]*u[2]
        du[2] = -p[3]*u[2] + p[4]*u[1]*u[2]
    end
    u0 = [initial_rabbit_pop, initital_fox_pop]
    tspan = (0.0, 1000.0)
    dt = 1.0
    ps = [rabbit_pop_growth_rate, rabbit_eaten_rate, fox_pop_depletion_rate, fox_birth_rate]
    prob = ODEProblem(eqs!, u0, tspan, ps)
    sol = solve(prob, RK4(), dt = dt, adaptive = false, save_everystep = true)
    return sol
end

######################################################################
# CONNECT WITH INTERFACE BUILDER FILE                                #
######################################################################

b_filename = joinpath("foxes_and_rabbits", "foxes_and_rabbits_ui.glade")
b = GtkBuilder(filename = b_filename)
win = b["window_01"]
button_update = b["button_update"]
button_reset = b["button_reset"]
scale_initial_fox_pop = b["scale_initial_fox_pop"]
scale_initial_rabbit_pop = b["scale_initial_rabbit_pop"]
scale_rabbit_pop_growth_rate = b["scale_rabbit_pop_growth_rate"]
scale_rabbit_eaten_rate = b["scale_rabbit_eaten_rate"]
scale_fox_pop_depletion_rate = b["scale_fox_pop_depletion_rate"]
scale_fox_birth_rate = b["scale_fox_birth_rate"]
adjustment_initial_fox_pop = b["adjustment_initial_fox_pop"]
adjustment_initial_rabbit_pop = b["adjustment_initial_rabbit_pop"]
adjustment_rabbit_pop_growth_rate = b["adjustment_rabbit_pop_growth_rate"]
adjustment_rabbit_eaten_rate = b["adjustment_rabbit_eaten_rate"]
adjustment_fox_pop_depletion_rate = b["adjustment_fox_pop_depletion_rate"]
adjustment_fox_birth_rate = b["adjustment_fox_birth_rate"]
frame_timeseries = b["frame_timeseries"]
frame_phase_portrait = b["frame_phase_portrait"]
canvas_timeseries = GtkCanvas()
canvas_phase_portrait = GtkCanvas()
push!(frame_timeseries, canvas_timeseries)
push!(frame_phase_portrait, canvas_phase_portrait)

######################################################################
# PLOTTING FUNCTIONS                                                 #
######################################################################

function plot_timeseries(sol)
    ts = sol.t
    rabbits = sol[1, :]
    foxes = sol[2, :]
    labels = ["Rabbits" "Foxes"]
    plt = plot(
        ts,
        [rabbits, foxes],
        lw = 3,
        labels = labels,
        xlabel = "Time",
        ylabel = "Population",
    )
    buf = IOBuffer()
    Plots.png(plt, buf)
    seekstart(buf)
    return Cairo.read_from_png(buf)
end

function plot_phase_portrait(sol)
    ts = sol.t
    rabbits = sol[1, :]
    foxes = sol[2, :]
    plt = plot(
        rabbits,
        foxes,
        line_z = ts,
        colormap = :plasma,
        lw = 3,
        xlabel = "Rabbits",
        ylabel = "Foxes",
        label = "",
        colorbar = true,
        colorbar_title = "Time",
    )
    buf = IOBuffer()
    Plots.png(plt, buf)
    seekstart(buf)
    return Cairo.read_from_png(buf)
end

######################################################################
# EVENT HANDLERS                                                     #
######################################################################

@guarded function button_update_clicked(widget, others...)
    initital_fox_pop = GAccessor.value(scale_initial_fox_pop)
    initial_rabbit_pop = GAccessor.value(scale_initial_rabbit_pop)
    rabbit_pop_growth_rate = GAccessor.value(scale_rabbit_pop_growth_rate)
    rabbit_eaten_rate = GAccessor.value(scale_rabbit_eaten_rate)
    fox_pop_depletion_rate = GAccessor.value(scale_fox_pop_depletion_rate)
    fox_birth_rate = GAccessor.value(scale_fox_birth_rate)
    sol = calc_trajectories(
        initital_fox_pop,
        initial_rabbit_pop,
        rabbit_pop_growth_rate,
        rabbit_eaten_rate,
        fox_pop_depletion_rate,
        fox_birth_rate,
    )
    timeseries_img = plot_timeseries(sol)
    timerseries_ctx = getgc(canvas_timeseries)
    set_source_surface(timerseries_ctx, timeseries_img)
    paint(timerseries_ctx)
    phase_portrait_img = plot_phase_portrait(sol)
    phase_portrait_ctx = getgc(canvas_phase_portrait)
    set_source_surface(phase_portrait_ctx, phase_portrait_img)
    paint(phase_portrait_ctx)
end

@guarded function button_reset_clicked(widget, others...)
    set_gtk_property!(adjustment_initial_fox_pop, :value, 10.0)
    set_gtk_property!(adjustment_initial_rabbit_pop, :value, 10.0)
    set_gtk_property!(adjustment_rabbit_pop_growth_rate, :value, 0.05)
    set_gtk_property!(adjustment_rabbit_eaten_rate, :value, 0.01)
    set_gtk_property!(adjustment_fox_pop_depletion_rate, :value, 0.01)
    set_gtk_property!(adjustment_fox_birth_rate, :value, 0.001)
end

signal_connect(button_update_clicked, button_update, :clicked)
signal_connect(button_reset_clicked, button_reset, :clicked)

showall(win)
button_update_clicked(button_update)  # Get the initial default values from UI and plot
if !isinteractive()
    c = Condition()
    signal_connect(win, :destroy) do widget
        notify(c)
    end
    wait(c)
end
