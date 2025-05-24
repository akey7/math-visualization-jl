using Base64
using Gtk
using Plots
using Cairo

gr()

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

showall(win)
# button_update_clicked(button_update)  # Get the initial default values from UI
if !isinteractive()
    c = Condition()
    signal_connect(win, :destroy) do widget
        notify(c)
    end
    wait(c)
end
