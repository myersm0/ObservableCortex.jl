
using ObservableCortex
using Test
using JLD
using CIFTI
using CorticalSurfaces
using Colors
using CairoMakie
using Pkg.Artifacts

# first we need to setup the surface
surface_dir = artifact"CIFTI_test_files"
temp = load(joinpath(surface_dir, "MSC01.jld"))

surfL = temp["pointsets"]["midthickness"][L]
mwL = temp["medial wall"][L]
triangleL = temp["triangle"][L]
hemL = Hemisphere(L, surfL, mwL; triangles = triangleL)

surfR = temp["pointsets"]["midthickness"][R]
mwR = temp["medial wall"][R]
triangleR = temp["triangle"][R]
hemR = Hemisphere(R, surfR, mwR; triangles = triangleR)

c = CorticalSurface(hemL, hemR)

@testset "ObservableCortex.jl" begin
	custom_views = OrthographicLayout(
		[(L, Lateral) (L, Medial) (L, Dorsal) (L, Ventral)]
	)
	@test size(custom_views) == (1, 4)

	fig = Figure(; size = (800, 600))
	montage = Montage(views = default_views, grid = fig.layout, surface = c)
	m, n = size(default_views)
	for i in 1:m
		for j in 1:n
			ax = montage.axes[i, j]
			@test axis(montage, i, j) === ax
			@test ax in axes(montage, i, :)
			@test length(axes(montage, i, :)) == 2
			@test ax in axes(montage, :, j)
			@test length(axes(montage, :, j)) == 2

			which_view = montage.views[i, j]
			@test axis(montage, which_view) === ax
			@test axis(montage, which_view.hemisphere, which_view.orientation) === ax
			@test axis(montage, (which_view.hemisphere, which_view.orientation)) === ax

			which_hem = montage.views[i, j].hemisphere
			@test length(axes(montage, which_hem)) == 2
			@test ax in axes(montage, which_hem)
		end
	end
end

