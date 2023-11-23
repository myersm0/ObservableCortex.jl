
module ObservableCortex

using CIFTI
using CorticalSurfaces
using CorticalParcels
using Colors
using Chain
using Observables
using GLMakie

include("layouts.jl")
export ViewDirection, Lateral, Medial, Dorsal, Ventral
export OrthoGraphicView, OrthographicLayout, default_layout

include("colors.jl")
export coolhot, videen_style

end

