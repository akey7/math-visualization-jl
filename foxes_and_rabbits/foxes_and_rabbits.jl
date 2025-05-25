using Base64
using Gtk
using Plots
using Cairo
using DifferentialEquations

gr()

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
    ps = [rabbit_pop_growth_rate, rabbit_eaten_rate, fox_pop_depletion_rate, fox_birth_rate]
    prob = ODEProblem(eqs!, u0, tspan, ps)
    sol = solve(prob, RK4(), dt = 1.0)
    return (sol.t, sol.u)
end

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
frame_timeseries = b["frame_timeseries"]
frame_phase_portrait = b["frame_phase_portrait"]
canvas_timeseries = GtkCanvas()
canvas_phase_portrait = GtkCanvas()
push!(frame_timeseries, canvas_timeseries)
push!(frame_phase_portrait, canvas_phase_portrait)

@guarded function button_update_clicked(widget, others...)
    initital_fox_pop = GAccessor.value(scale_initial_fox_pop)
    initial_rabbit_pop = GAccessor.value(scale_initial_rabbit_pop)
    rabbit_pop_growth_rate = GAccessor.value(scale_rabbit_pop_growth_rate)
    rabbit_eaten_rate = GAccessor.value(scale_rabbit_eaten_rate)
    fox_pop_depletion_rate = GAccessor.value(scale_fox_pop_depletion_rate)
    fox_birth_rate = GAccessor.value(scale_fox_birth_rate)
    x, y = calc_trajectories(
        initital_fox_pop,
        initial_rabbit_pop,
        rabbit_pop_growth_rate,
        rabbit_eaten_rate,
        fox_pop_depletion_rate,
        fox_birth_rate,
    )
end

signal_connect(button_update_clicked, button_update, "clicked")

showall(win)
# button_update_clicked(button_update)  # Get the initial default values from UI
if !isinteractive()
    c = Condition()
    signal_connect(win, :destroy) do widget
        notify(c)
    end
    wait(c)
end
