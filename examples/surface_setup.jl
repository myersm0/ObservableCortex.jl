
using Pkg.Artifacts

surface_dir = artifact"CIFTI_test_files"
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

