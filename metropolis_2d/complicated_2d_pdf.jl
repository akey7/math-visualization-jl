using Plots
using CairoMakie
using Random
using Distributions

#####################################################################
# SET RANDOM SEED                                                   #
#####################################################################

Random.seed!(1234)

#####################################################################
# SET THE DOMAIN OF THE 2D PDF                                      #
#####################################################################

domain_x_min = -4.0
domain_x_max = 4.0
domain_y_min = -3.0
domain_y_max = 4.0

#####################################################################
# CREATE A COMPLICATED 2D PDF f(x, y) THAT IS THE SUM OF 3 NORMAL   #
# DISTRIBUTIONS                                                     #
#####################################################################

μ1 = [0.0, 0.0]  # Means
Σ1 = [1.0 0.0; 0.0 1.0]  # Covariance matrix--off diagonal 0.0, directions uncorrelated.
mv1 = MvNormal(μ1, Σ1)

μ2 = [-2.0, 2.0]
Σ2 = [0.5 0.0; 0.0 0.5]
mv2 = MvNormal(μ2, Σ2)

μ3 = [2.0, 0.0]
Σ3 = [0.5 0.0; 0.0 0.5]
mv3 = MvNormal(μ3, Σ3)

# Compute the sum of PDFs
function f(v)
    (pdf(mv1, v) + pdf(mv2, v) + pdf(mv3, v))[1]
end

#####################################################################
# CREATE A CONTOUR PLOT OF THE 2D PDF                               #
#####################################################################

# Create a grid of points for the x and y axes
xs = range(start=domain_x_min, stop=domain_x_max, length=100)
ys = range(start=domain_y_min, stop=domain_y_max, length=100)

# Compute the PDF values over the grid
zs = [f([x, y]) for x in xs, y in ys]

fig = Figure(resolution = (750, 700))
ax = Axis(fig[1, 1], title="2D PDF for Sampling")
CairoMakie.xlims!(ax, minimum(xs), maximum(xs))
CairoMakie.ylims!(ax, minimum(ys), maximum(ys))
contour_plot = CairoMakie.contour!(ax, xs, ys, zs, levels=20, colormap=:viridis, linewidth = 3)
Colorbar(fig[1, 2], limits=(0, maximum(zs)), colormap=:viridis, flipaxis=false, size=25)
save("2d_pdf.png", fig)

#####################################################################
# SAMPLE FROM THE 2D PDF USING METROPOLIS ALGORITHM                 #
#####################################################################

num_steps = 1000000
Σ_step = [1.0 0.0; 0.0 1.0]

samples = zeros(Float64, 2, num_steps)
samples[1, 1] = rand(Uniform(domain_x_min, domain_x_max))
samples[2, 1] = rand(Uniform(domain_y_min, domain_y_max))

for i ∈ 2:num_steps
    μ_step = samples[:, i-1]
    proposal_dist = MvNormal(μ_step, Σ_step)
    proposal = rand(proposal_dist, 1)

    if min(1, f(proposal) / f(samples[:, i-1])) > rand()
        samples[:, i] = proposal
    else
        samples[:, i] = samples[:, i-1]
    end
end

#####################################################################
# 2D HISTOGRAM OF METROPOLIS SAMPLES                                #
#####################################################################

histogram2d(samples[1, :], samples[2, :], nbins=(100, 100), colormap=:viridis, normalize=false, size=(700, 600))
savefig("2d_pdf_samples.png")
