using ObservableCortex
using Test
using JLD
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
end

