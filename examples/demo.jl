
using JLD
using GLMakie
using CIFTI
using CorticalSurfaces
using Colors

include("surface_setup.jl")

fig = Figure(; size = (800, 600))
montage = Montage(views = default_layout, grid = fig.layout, surface = c)
colors = collect(1.0:size(c, Exclusive()))
mesh!(montage, colors; colormap = coolhot)
save("demo1.png", fig)

fig = Figure(; size = (800, 600))
montage = Montage(views = default_layout, grid = fig.layout, surface = c)
colors = [RGB(α, α, α) for α in range(0, 1; length = size(c, Exclusive()))]
mesh!(montage, colors; colormap = coolhot)
save("demo2.png", fig)

custom_layout = OrthographicLayout(
	[(L, Lateral) (L, Medial) (L, Dorsal) (L, Ventral)]
)

fig = Figure(; size = (1200, 300))
montage = Montage(views = custom_layout, grid = fig.layout, surface = c)
colors = [RGB(α, α, α) for α in range(0, 1; length = size(c, Exclusive()))]
mesh!(montage, colors; colormap = coolhot)
save("demo3.png", fig)


