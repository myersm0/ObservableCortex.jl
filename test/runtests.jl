using ObservableCortex
using Test
using JLD
using GLMakie
using CIFTI
using CorticalSurfaces
using Colors

# first we need to setup the surface
surface_dir = joinpath(dirname(@__FILE__), "..", "data")
temp = load(joinpath(surface_dir, "MSC01.jld"))

surfL = temp["pointsets"]["midthickness"][L]
mwL = temp["medial wall"][L]
triangleL = temp["triangle"][L]
hemL = Hemisphere(surfL, mwL; triangles = triangleL)

surfR = temp["pointsets"]["midthickness"][R]
mwR = temp["medial wall"][R]
triangleR = temp["triangle"][R]
hemR = Hemisphere(surfR, mwR; triangles = triangleR)

c = CorticalSurface(hemL, hemR)

@testset "ObservableCortex.jl" begin
	custom_views = OrthographicLayout(
		[(L, Lateral) (L, Medial) (L, Dorsal) (L, Ventral)]
	)
	@test size(custom_views) == (1, 4)

	fig = Figure(; size = (800, 600))
	montage = Montage(views = default_views, grid = fig.layout, surface = c)
	colors = collect(1.0:size(c, Exclusive()))
	mesh!(montage, colors; colormap = coolhot)

	fig = Figure(; size = (800, 600))
	montage = Montage(views = default_views, grid = fig.layout, surface = c)
	colors = [RGB(α, α, α) for α in range(0, 1; length = size(c, Exclusive()))]
	mesh!(montage, colors; colormap = coolhot)

	fig = Figure(; size = (1200, 300))
	montage = Montage(views = custom_views, grid = fig.layout, surface = c)
	colors = [RGB(α, α, α) for α in range(0, 1; length = size(c, Exclusive()))]
	mesh!(montage, colors; colormap = coolhot)
	colgap!(montage.grid, 2, -100)
	colgap!(montage.grid, 3, -220)
end


