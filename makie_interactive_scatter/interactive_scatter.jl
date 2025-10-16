using GLMakie
using Random, Statistics

# --- sample data -------------------------------------------------------------
Random.seed!(42)
N  = 400
x  = randn(N)
y  = 0.6 .* x .+ 0.7 .* randn(N)
grp = rand(1:3, N)                     # 3 groups

# --- figure & axis -----------------------------------------------------------
f = Figure(resolution = (900, 540))
ax = Axis(f[1, 1],
    title = "Interactive Scatter (GLMakie)",
    xlabel = "x",
    ylabel = "y"
)

# Widgets: x-range sliders + group dropdown + reset button
xmin, xmax = extrema(x)
smin = Slider(f[2, 1], range = LinRange(xmin, xmax, 200), startvalue = xmin)
smax = Slider(f[3, 1], range = LinRange(xmin, xmax, 200), startvalue = xmax)
menug = Menu(f[2, 2], options = ["All", "1", "2", "3"], default = "All")
reset_btn = Button(f[3, 2], label = "Reset")

# --- reactive filtering ------------------------------------------------------
mask = @lift begin
    lo = $smin.value
    hi = $smax.value
    gsel = $menug.selection
    inx = (x .>= lo) .& (x .<= hi)
    gsel == "All" ? inx : (inx .& (string.(grp) .== gsel))
end

fx = @lift x[$mask]
fy = @lift y[$mask]
fc = @lift grp[$mask]

plt = scatter!(ax, fx, fy;
    color = fc,
    colormap = :Set2,
    markersize = 8,
    strokewidth = 0.5,
    strokecolor = :black
)

Colorbar(f[1, 2], plt, label = "Group")

# --- FIXED: listen to slider values, not sliders ------------------------------
onany(smin.value, smax.value) do lo, hi
    xlims!(ax, lo, hi)
end

# Reset button logic
on(reset_btn.clicks) do _
    smin.value[] = xmin
    smax.value[] = xmax
    menug.selection[] = "All"
    xlims!(ax, xmin, xmax)
end

# --- Interactivity ------------------------------------------------------------
DataInspector(f)  # Press 'i' in the GL window to toggle hover tooltips

f
