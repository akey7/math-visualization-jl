using Base64
using Gtk
using Plots
using Cairo

gr()

b_filename = joinpath("foxes_and_rabbits", "foxes_and_rabbits_ui.glade")
b = GtkBuilder(filename = b_filename)
win = b["window_01"]

showall(win)
# button_update_clicked(button_update)  # Get the initial default values from UI
if !isinteractive()
    c = Condition()
    signal_connect(win, :destroy) do widget
        notify(c)
    end
    wait(c)
end
