
using JLD
using GLMakie
using CIFTI
using CorticalSurfaces
using CorticalParcels
using Colors
using ObservableCortex
using Pkg.Artifacts

include("surface_setup.jl")

# ===== make a continuous-valued surface plot ==========================================

fig = Figure(; size = (600, 400))
montage = Montage(views = default_views, grid = fig.layout, surface = c)
colors = collect(1.0:size(c, Exclusive()))
colorrange = (minimum(colors), maximum(colors)) # to enforce consistency across panels
plot!(montage, colors; colormap = coolhot, colorrange = colorrange)
cbar = Colorbar(
	fig, bbox = BBox(240, 360, 200, 180), 
	limits = colorrange, 
	colormap = coolhot, 
	vertical = false, 
	width = 120, 
	height = 20, 
	ticks = ([colorrange[1], colorrange[2]], ["1", "59412"]),
	label = "Vertex",
)
save("demo1.png", fig)


# ===== as above but this time providing the colors directly ===========================

fig = Figure(; size = (800, 600))
montage = Montage(views = default_views, grid = fig.layout, surface = c)
colors = [RGB(α, α, α) for α in range(0, 1; length = size(c, Exclusive()))]
plot!(montage, colors; colormap = coolhot)
save("demo2.png", fig)


# ===== as above but this time with a custom arrangement of brain views ================

custom_views = PanelLayout(
	[
		[(L, Lateral) (L, Medial) (L, Dorsal) (L, Ventral)];
		[(R, Lateral) (R, Medial) (R, Ventral) (R, Dorsal)]
	]
)

fig = Figure(; size = (1200, 600))
montage = Montage(views = custom_views, grid = fig.layout, surface = c)
colors = [
	[HSV(0, 0, v) for v in range(0, 1; length = size(c[L], Exclusive()))];
	[HSV(0, 0, v) for v in range(1, 0; length = size(c[R], Exclusive()))];
]
plot!(montage, colors; colormap = coolhot)
colgap!(montage.grid, 2, -100)
colgap!(montage.grid, 3, -220)

ax = axis(montage, (R, Medial))
coord = coordinates(c[R])[:, 2099]
meshscatter!(ax, coord'; color = :yellow, markersize = 4)

save("demo3.png", fig)


# ===== plot discrete-valued data such as a parcellation ===============================

# no colors are provided in this case, so the parcel keys will be mapped to 
# `distinguishable_colors(nparcels)` from the Colors package by default

rootpath = artifact"CIFTI_test_files"
parcel_file = joinpath(rootpath, "test_parcels.dtseries.nii")
cifti_data = CIFTI.load(parcel_file)
px = BilateralParcellation{Int}(c, cifti_data)

fig = Figure(; size = (600, 400))
montage = Montage(views = default_views, grid = fig.layout, surface = c)
plot!(montage, px)
save("demo4.png", fig)


# ===== as above, but with a custom categorical colors =================================

# in order to supply the colormap yourself, you just need to make a dictionary
# that maps all parcel keys to a color value

# make them all blue:
colormap = Dict(k => RGB(0, 0.4, 1.0) for k in keys(px))

fig = Figure(; size = (600, 400))
custom_view = PanelLayout(reshape([(L, Medial)], (1, 1)))
montage = Montage(grid = fig.layout, surface = c, views = custom_view)
plot!(montage, px; colormap = colormap)

# we can also use meshscatter!() to plot "borders" on top of the parcels like this:

make_adjacency_list!(px.surface) # needed for finding borders below

ax = axes(montage, 1, 1)
ks = collect(keys(px[L]))
for k in ks
	p = px[L][k]
	border_vertices = borders(p)
	coords = coordinates(c[L])[:, border_vertices]
	meshscatter!(ax, coords'; color = :yellow, markersize = 0.8)
end


# ===== as above, but with custom color interpolation over a real-valued scale  ========

# if you have real-valued numbers associated with each parcel and, instead of using 
# a categorical colormap as before, you want to map those values to interpolated colors 
# from a certain colorscale (e.g., the `coolhot` scale supplied with this pkg) ...

# first, set up some values
vals = LinRange(0, 1, size(px)) |> collect

# keep in mind that parcels are not necessarily labeled consecutively from 1 to n,
# and that `keys(px)` returns elements from a dictionary in an undefined order;
# therefore to be sure we're going to map colors in the intended order we'll do this:
ks = keys(px) |> collect |> sort

# now make a dict that maps each parcel key to a interpolated color from `coolhot`:
colorrange = (minimum(vals), maximum(vals))
colormap = Dict(
	k => colorize(vals[i]; colormap = coolhot, colorrange = colorrange) 
	for (i, k) in enumerate(ks)
)

fig = Figure(; size = (600, 400))
montage = Montage(views = default_views, grid = fig.layout, surface = c)
plot!(montage, px; colormap = colormap)

save("demo5.png", fig)


