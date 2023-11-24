# ObservableCortex
This package aims to replicate many of the features and functionality of [Connectome Workbench](https://humanconnectome.org/software/connectome-workbench)'s GUI software `wb_view` for viewing 3d cortical surface meshes, but with the advantages of a programmatic interface and access to all of the [Makie.jl](https://docs.makie.org/stable/) and [Observables.jl](https://juliagizmos.github.io/Observables.jl/stable/) suite of functions for interactive graphics and animations in Julia.

It builds on types and convenience functions from my other packages [CorticalSurfaces.jl](https://github.com/myersm0/CorticalSurfaces.jl) and [CorticalParcels.jl](https://github.com/myersm0/CorticalParcels.jl).

This is a work in progress. Basic functionality as available and usable right now, but more is coming soon.

## Usage
First, to bring in some related packages we'll need:
```
using JLD
using GLMakie
using CIFTI
using CorticalSurfaces
using Colors
```

Then a `CorticalSurface` struct must be created to supply the surface geometry, medial wall definition, etc. I omit this part for brevity, but please see `examples/surface_setup.jl` for details.

Once you have a `CorticalSurface` struct setup (we'll call it `c` below), you can define a `Montage` that encapsulates the set of brain views you want to visualize, the `Makie.GridLayout` which we'll use for visualizing, and then the surface `c` that will supply the geometry for the surface mesh. `colors` can be any Vector{Union{AbstractFloat, Colorant}}.
```
fig = Figure(; size = (800, 600))
montage = Montage(views = default_views, grid = fig.layout, surface = c)
colors = collect(1.0:size(c, Exclusive()))
mesh!(montage, colors; colormap = coolhot)
```
[https://github.com/myersm0/ObservableCortex.jl/blob/main/examples/demo1.png]

Or, instead of using the `default_views`, you can define a set of custom views in a specific arrangement that you want to plot by designing an `OrthographicLayout`, which is generated from `Matrix{OrthographicView}` like this:
```
custom_views = OrthographicLayout(
	[(L, Lateral) (L, Medial) (L, Dorsal) (L, Ventral)]
)
```
[https://github.com/myersm0/ObservableCortex.jl/blob/main/examples/demo2.png]

And then the custom views can be used for plotting:
```
fig = Figure(; size = (1200, 300))
montage = Montage(views = custom_views, grid = fig.layout, surface = c)
colors = [RGB(α, α, α) for α in range(0, 1; length = size(c, Exclusive()))]
mesh!(montage, colors; colormap = coolhot)

# there's too much space between some of the panels; I aim to improve this in a future version,
# but for now you can do this:
colgap!(montage.grid, 2, -100)
colgap!(montage.grid, 3, -220)
```
[https://github.com/myersm0/ObservableCortex.jl/blob/main/examples/demo3.png]

[![Build Status](https://github.com/myersm0/ObservableCortex.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/myersm0/ObservableCortex.jl/actions/workflows/CI.yml?query=branch%3Amain)
