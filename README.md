# ObservableCortex
This package aims to replicate much of the functionality of [Connectome Workbench](https://humanconnectome.org/software/connectome-workbench)'s GUI software `wb_view` for viewing 3d cortical surface meshes, but with the advantages of a programmatic interface and access to all of the [Makie.jl](https://docs.makie.org/stable/) and [Observables.jl](https://juliagizmos.github.io/Observables.jl/stable/) functions for interactive 3d plotting and animations in Julia.

To do this, this package transparently manages a few things that make it easier for you (in the context of surface space fMRI) to take full advantage of Makie and Observables:
- Convert your surface into a format required by Makie's `mesh` plotting function
- Split your `color` vector (the colors to be plotted on the brain) into left and right hemispheres, if necessary
- Pad the `color` vector to account for medial wall, if necessary, in order to match the underlying surface geometry
- Arrange the visualization into a customary 4-panel layout showing lateral and medial views of the left and right hemispheres (or allow you the flexibility to specify a custom arrangement)
- Provide some commonly used color schemes from the literature
- Enable easy access to more complex visualizations requiring graph traversal-based operations, such as plotting region borders
- Support reactive data updates through Observables for interactive visualizations

## Installation
Within Julia (version 1.9 or greater):
```julia
using Pkg
Pkg.add("ObservableCortex")
```

## Usage
First, to bring in some related packages we'll need:
```julia
using JLD
using GLMakie
using CIFTI
using CorticalSurfaces
using Colors
using ObservableCortex
```

Then a `CorticalSurface` struct must be created to supply the surface geometry, medial wall definition, etc. I omit this part for brevity here, but see `examples/surface_setup.jl` for details. We'll call the resulting struct `c` in the code examples below.

You can then define a `Montage` which is just a struct that contains several of the things Makie will need to know in order to construct the plot:
- **panels**: a `PanelLayout` defining the set of brain views you want to visualize (here we'll just use `default_views` to get a four-panel arrangement of medial and lateral views)
- **grid**: a `Makie.GridLayout` that will be used to organize and render the surface views
- **surface**: a `CorticalSurface` that supplies the geometry for the surface mesh (see [CorticalSurfaces.jl](https://github.com/myersm0/CorticalSurfaces.jl))
- **plots**: a matrix of plots objects from Makie, once plotting has occurred (initially they're undefined, when the Montage is first constructed)

Then, in the call to `plot!` below, the argument `colors` can be any `Vector{T} where T <: Union{Number, Colorant}` _or_ it can be an `Observable`. Its length should be equal to the total number of vertices in the surface `c`, with or without medial wall. A common use case will be working with data from a [CIFTI](https://github.com/myersm0/CIFTI.jl) file, which typically will include both hemispheres in a single matrix and will omit the medial wall. The `Montage` struct from this package will know how to handle these cases, because it knows from its component `c::CorticalSurface` about properties of the surface like medial wall location and the number of vertices in each hemisphere. This implies the additional expectation that your `color` vector must be from data in the same space as that of the surface that you provided, which will be the case if you consistently work with a certain surface space representation such as the so-called fsLR_32k space.

You can also supply arbitrary additional keyword arguments that will simply be delegated to `Makie.mesh!`. (To generate the below image, I also added a `Colorbar` but I omit that step here for brevity; see `examples/demo.jl`.)
```julia
fig = Figure(; size = (800, 600))
montage = Montage(grid = fig.layout, surface = c)
colors = collect(1.0:size(c, Exclusive()))
colorrange = (minimum(colors), maximum(colors)) # to enforce consistency across panels
plot!(montage, colors; colormap = coolhot, colorrange = colorrange)
```
![demo1](https://github.com/myersm0/ObservableCortex.jl/blob/main/examples/demo1.png)

Or, instead of using the `default_views`, you can define a set of custom views in a specific arrangement that you want to plot by designing a `PanelLayout` like this:
```julia
custom_views = PanelLayout(
	[
		(L, Lateral) (L, Medial) (L, Dorsal) (L, Ventral);
		(R, Lateral) (R, Medial) (R, Ventral) (R, Dorsal)
	]
)
```

And then the custom views can be used for plotting:
```julia
fig = Figure(; size = (1200, 600))
montage = Montage(grid = fig.layout, surface = c, panels = custom_views)
colors = [
	[HSV(0, 0, v) for v in range(0, 1; length = size(c[L], Exclusive()))];
	[HSV(0, 0, v) for v in range(1, 0; length = size(c[R], Exclusive()))];
]
plot!(montage, colors)
```
![demo3](https://github.com/myersm0/ObservableCortex.jl/blob/main/examples/demo3.png)

## Accessing plots and axes
You can access plots and axes through the montage using the same indexing syntax:

```julia
# access plots by panel specification  
montage[(L, Medial)].colorrange = (0, 1)  # Adjust colorrange for left medial view

# access all plots for a hemisphere
for plot in montage[L]
	plot.visible = false  # hide all left hemisphere views
end

# access axes for additional plotting
ax = axis(montage, (R, Medial))  # Get the axis for right medial view
coord = coordinates(c[R])[:, 2099]  # Get coordinates of a specific vertex
meshscatter!(ax, coord'; color = :yellow, markersize = 4)  # Add a marker
```

## Interactive visualizations with Observables
The package supports Observables for animated and interactive visualizations:

```julia
# create Observable data
random_data = Observable(randn(size(c, Exclusive())))

# plot with Observable - automatically updates when data changes
plot!(montage, random_data; colormap = coolhot)

# add interactive controls
slider = Slider(fig[2, 1:2], range = 0:0.1:3, startvalue = 0)
on(slider.value) do threshold
	random_data[] = randn(size(c, Exclusive())) .* (abs.(brain_data[]) .> threshold)
end
```

See `examples/extended_demo.jl` for more advanced interactive examples including time series animations, vertex picking, and synchronized visualizations.

## Plotting parcellations

Plotting discrete-valued data such as parcels (see [CorticalParcels.jl](https://github.com/myersm0/CorticalParcels.jl)) is supported. You can supply a `colormap` dictionary that maps all parcel keys (as well as zero) to a `Colorant`, or you can omit this and use the default set of `distinguishable_colors` from the `Colors` package. If `parcel_file` is the path to a CIFTI file containing a set of parcels you want to visualize:

```julia
using CorticalParcels

cifti_data = CIFTI.load(parcel_file)
px = BilateralParcellation{Int}(c, cifti_data)
fig = Figure(; size = (600, 400))
montage = Montage(grid = fig.layout, surface = c)
plot!(montage, px)
```
![demo4](https://github.com/myersm0/ObservableCortex.jl/blob/main/examples/demo4.png)

See the `examples/demo.jl` file for additional examples including custom color mappings and plotting parcel borders.

## Acknowledgments
For testing and demonstration purposes, this package uses surface data from the MSC dataset (described in [Gordon et al 2017](https://www.cell.com/neuron/fulltext/S0896-6273(17)30613-X)). This data was obtained from the OpenfMRI database. Its accession number is ds000224.

[![Build Status](https://github.com/myersm0/ObservableCortex.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/myersm0/ObservableCortex.jl/actions/workflows/CI.yml?query=branch%3Amain)
