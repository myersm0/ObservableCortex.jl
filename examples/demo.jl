
include("surface_setup.jl")

using GLMakie

fig = Figure(; size = (800, 600))
montage = Montage(views = default_layout, grid = fig.layout, surface = c)
colors = collect(1.0:size(c, Exclusive()))
mesh!(montage, colors; colormap = coolhot)

fig = Figure(; size = (800, 600))
montage = Montage(views = default_layout, grid = fig.layout, surface = c)
colors = [RGB(α, α, α) for α in range(0, 1; length = size(c, Exclusive()))]
mesh!(montage, colors; colormap = coolhot)

custom_layout = OrthographicLayout(
	[(L, Lateral) (L, Medial) (L, Dorsal) (L, Ventral)]
)

fig = Figure(; size = (1200, 300))
montage = Montage(views = custom_layout, grid = fig.layout, surface = c)
colors = [RGB(α, α, α) for α in range(0, 1; length = size(c, Exclusive()))]
mesh!(montage, colors; colormap = coolhot)


