
using JLD
using GLMakie
using CIFTI
using CorticalSurfaces
using ObservableCortex
using Colors

include("surface_setup.jl")

fig = Figure(; size = (600, 400))
montage = Montage(views = default_views, grid = fig.layout, surface = c)
colors = collect(1.0:size(c, Exclusive()))
colorrange = (minimum(colors), maximum(colors)) # to enforce consistency across panels
mesh!(montage, colors; colormap = coolhot, colorrange = colorrange)
save("demo1.png", fig)

fig = Figure(; size = (800, 600))
montage = Montage(views = default_views, grid = fig.layout, surface = c)
colors = [RGB(α, α, α) for α in range(0, 1; length = size(c, Exclusive()))]
mesh!(montage, colors; colormap = coolhot)
save("demo2.png", fig)

custom_views = OrthographicLayout(
	[(L, Lateral) (L, Medial) (L, Dorsal) (L, Ventral)]
)

fig = Figure(; size = (1200, 300))
montage = Montage(views = custom_views, grid = fig.layout, surface = c)
colors = [
	[RGB(α, α, α) for α in range(0, 1; length = size(c[L], Exclusive()))];
	zeros(RGB, size(c[R], Exclusive()))
]
mesh!(montage, colors; colormap = coolhot)
colgap!(montage.grid, 2, -100)
colgap!(montage.grid, 3, -220)
save("demo3.png", fig)


