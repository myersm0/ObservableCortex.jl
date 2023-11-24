
module ObservableCortex

using CIFTI
using CorticalSurfaces
using Colors
using Chain
using Makie
using Match
import GeometryBasics

include("layouts.jl")
export ViewDirection, Lateral, Medial, Dorsal, Ventral
export OrthoGraphicView, OrthographicLayout, default_views

include("colors.jl")
export coolhot, videen_style

include("plot.jl")
export Montage, plot

end

