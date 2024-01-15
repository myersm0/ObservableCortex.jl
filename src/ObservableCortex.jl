
module ObservableCortex

using CIFTI
using CorticalSurfaces
using CorticalParcels
using Colors
using Chain
using Makie
using Match
import GeometryBasics

include("colors.jl")
export coolhot, videen_style, surf_color, power_colors, elabe_colors

include("layouts.jl")
export Orientation, Lateral, Medial, Dorsal, Ventral
export OrthographicView, OrthographicLayout, default_views

include("montage.jl")
export Montage, axes, axis

include("plot.jl")
export plot

include("show.jl")

end

