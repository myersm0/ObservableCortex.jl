# ObservableCortex
This package aims to replicate many of the features and functionality of [Connectome Workbench](https://humanconnectome.org/software/connectome-workbench)'s GUI software `wb_view` for viewing 3d cortical surface meshes, but with the advantages of a programmatic interface and access to all of the [Makie.jl](https://docs.makie.org/stable/) and [Observables.jl](https://juliagizmos.github.io/Observables.jl/stable/) suite of functions for interactive 3d plotting and animations in Julia.

It builds on types and convenience functions from my other packages [CorticalSurfaces.jl](https://github.com/myersm0/CorticalSurfaces.jl) and [CorticalParcels.jl](https://github.com/myersm0/CorticalParcels.jl).

This is a work in progress. Basic functionality is available and usable right now. Much more is coming soon.

## Installation
This package is not yet available from the Julia General Registry. Until then, you can install from this GitHub repo. Within Julia (v1.9 or greater):
```
using Pkg
Pkg.add(url = "https://github.com/myersm0/ObservableCortex.jl")
```

## Usage
First, to bring in some related packages we'll need:
```
using JLD
using GLMakie
using CIFTI
using CorticalSurfaces
using Colors
```

Then a `CorticalSurface` struct must be created to supply the surface geometry, medial wall definition, etc. I omit this part for brevity here, but see `examples/surface_setup.jl` for details.

You can then define a `Montage` which is just a struct that contains all the things Makie will need to know in order to construct the plot:
- `views`: the set of brain views you want to visualize (here we'll just use `default_views` to get a four-panel arrangement of medial and lateral views)
- `grid`: the `Makie.GridLayout` that will be used to organize and render the surface views
- `surface`: the surface `c` that supplies the geometry for the surface mesh

`colors` can be any `Vector{T} where T <: Union{AbstractFloat, Colorant}`. You can also supply arbitrary additional keyword arguments that will simply be delegated to `Makie.mesh!`.
```
fig = Figure(; size = (800, 600))
montage = Montage(views = default_views, grid = fig.layout, surface = c)
colors = collect(1.0:size(c, Exclusive()))
colorrange = (minimum(colors), maximum(colors)) # to enforce consistency across panels
plot!(montage, colors; colormap = coolhot, colorrange = colorrange)
```
![demo1](https://github.com/myersm0/ObservableCortex.jl/blob/main/examples/demo1.png)

Or, instead of using the `default_views`, you can define a set of custom views in a specific arrangement that you want to plot by designing an `OrthographicLayout`, which is generated from `Matrix{OrthographicView}` like this:
```
custom_views = OrthographicLayout(
	[(L, Lateral) (L, Medial) (L, Dorsal) (L, Ventral)]
	[(R, Lateral) (R, Medial) (R, Ventral) (R, Dorsal)]
)
```

And then the custom views can be used for plotting:
```
fig = Figure(; size = (1200, 600))
montage = Montage(views = custom_views, grid = fig.layout, surface = c)
colors = [
	[HSV(0, 0, v) for v in range(0, 1; length = size(c[L], Exclusive()))];
	[HSV(0, 0, v) for v in range(1, 0; length = size(c[R], Exclusive()))];
]
plot!(montage, colors; colormap = coolhot)

# there's too much space between some of the panels; I aim to improve this in a future version,
# but for now you can do this:
colgap!(montage.grid, 2, -100)
colgap!(montage.grid, 3, -220)
```
![demo3](https://github.com/myersm0/ObservableCortex.jl/blob/main/examples/demo3.png)

## Acknowledgments
For testing and demonstration purposes, this package uses surface data from the MSC dataset (described in [Gordon et al 2017](https://www.cell.com/neuron/fulltext/S0896-6273(17)30613-X)). This data was obtained from the OpenfMRI database. Its accession number is ds000224.

[![Build Status](https://github.com/myersm0/ObservableCortex.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/myersm0/ObservableCortex.jl/actions/workflows/CI.yml?query=branch%3Amain)
