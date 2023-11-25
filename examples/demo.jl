
using JLD
using GLMakie
using CIFTI
using CorticalSurfaces
using Colors
using ObservableCortex

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
	[HSV(hue, 1, 1) for hue in range(1, 360; length = size(c[L], Exclusive()))];
	zeros(HSV, size(c[R], Exclusive()))
]
mesh!(montage, colors; colormap = coolhot)
colgap!(montage.grid, 2, -100)
colgap!(montage.grid, 3, -220)

save("demo3.png", fig)

