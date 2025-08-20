
# ObservableCortex
This package aims to replicate much of the functionality of [Connectome Workbench](https://humanconnectome.org/software/connectome-workbench)'s GUI software `wb_view` for viewing 3d cortical surface meshes, but with the advantages of a programmatic interface and access to all of the [Makie.jl](https://docs.makie.org/stable/) and [Observables.jl](https://juliagizmos.github.io/Observables.jl/stable/) functions for interactive 3d plotting and animations in Julia.

To do this, this package just transparently manages a few things that make it easier for you (in the context of surface space fMRI) to take full advantage of Makie and Observables:
- Convert your surface into a format required by Makie's `mesh` plotting function
- Split your `color` vector (the colors to be plotted on the brain) into left and right hemispheres, if necessary
- Pad the `color` vector to account for medial wall, if necessary, in order to match the underlying surface geometry
- Arrange the visualization into a customary 4-panel layout showing lateral and medial views of the left and right hemispheres (or allow you the flexibility to specify a custom arrangement)
- Provide some commonly used color schemes from the literature
- Enable easy access to more complex visualizations requiring graph traversal-based operations, such as plotting region borders (_not yet implemented_)

This is a work in progress. Basic functionality is available and usable right now. Much more is coming soon.

## Installation
Within Julia (version 1.9 or greater):
```
using Pkg
Pkg.add("ObservableCortex")
```

## Usage
First, to bring in some related packages we'll need:
```
using JLD
using GLMakie
using CIFTI
using CorticalSurfaces
using Colors
using ObservableCortex
```

Then a `CorticalSurface` struct must be created to supply the surface geometry, medial wall definition, etc. I omit this part for brevity here, but see `examples/surface_setup.jl` for details. We'll call the resulting struct `c` in the code examples below.

You can then define a `Montage` which is just a struct that contains several of the things Makie will need to know in order to construct the plot:
- **views**: an `PanelLayout` defining the set of brain views you want to visualize (here we'll just use `default_views` to get a four-panel arrangement of medial and lateral views)
- **grid**: a `Makie.GridLayout` that will be used to organize and render the surface views
- **surface**: a `CorticalSurface` that supplies the geometry for the surface mesh (see [CorticalSurfaces.jl](https://github.com/myersm0/CorticalSurfaces.jl))

Then, in the call to `plot!` below, the argument `colors` can be any `Vector{T} where T <: Union{AbstractFloat, Colorant}`. Its length should be equal to the total number of vertices in the surface `c`, with or without medial wall. A common use case will be working with data from a [CIFTI](https://github.com/myersm0/CIFTI.jl) file, which typically will include both hemispheres in a single matrix and will omit the medial wall. The `Montage` struct from this package will know how to handle these cases, because it knows from its component `c::CorticalSurface` about properties of the surface like medial wall location and the number of vertices in each hemisphere. This implies the additional expectation that your `color` vector must be from data in the same space as that of the surface that you provided, which will be the case if you consistently work with a certain surface space representation such as the so-called fsLR_32k space.

You can also supply arbitrary additional keyword arguments that will simply be delegated to `Makie.mesh!`. (To generate the below image, I also added a `Colorbar` but I omit that step here for brevity; see `examples/demo.jl`.)
```
fig = Figure(; size = (800, 600))
montage = Montage(grid = fig.layout, surface = c)
colors = collect(1.0:size(c, Exclusive()))
colorrange = (minimum(colors), maximum(colors)) # to enforce consistency across panels
plot!(montage, colors; colormap = coolhot, colorrange = colorrange)
```
![demo1](https://github.com/myersm0/ObservableCortex.jl/blob/main/examples/demo1.png)

Or, instead of using the `default_views`, you can define a set of custom views in a specific arrangement that you want to plot by designing an `PanelLayout` like this:
```
custom_views = PanelLayout(
	[
		[(L, Lateral) (L, Medial) (L, Dorsal) (L, Ventral)];
		[(R, Lateral) (R, Medial) (R, Ventral) (R, Dorsal)]
	]
)
```

And then the custom views can be used for plotting:
```
fig = Figure(; size = (1200, 600))
montage = Montage(grid = fig.layout, surface = c, views = custom_views)
colors = [
	[HSV(0, 0, v) for v in range(0, 1; length = size(c[L], Exclusive()))];
	[HSV(0, 0, v) for v in range(1, 0; length = size(c[R], Exclusive()))];
]
plot!(montage, colors; colormap = coolhot)
```
![demo3](https://github.com/myersm0/ObservableCortex.jl/blob/main/examples/demo3.png)

Once you have the mesh plot initialized as above, you can then do arbitrary additional plotting in each of the panels. To do so, first of all you need to be able to access the `Axis3` object that corresponds to the specific panel(s) that you want to work with. Several ways to do this are provided. Note the pluralization of the function name in the third line:
```
ax = axis(montage, 2, 3)         # get the axis in row 2, column 3
ax = axis(montage, (L, Medial))  # get the left medial axis
axs = axes(montage, L)           # get all the left hemisphere axes
```

You can then plot any additional graphical elements that you want to that axis. For example, we could call Makie's `meshscatter!` to plot a yellow sphere marking a particular point on the brain:
```
ax = axis(montage, (R, Medial))
vert = 2099 # pick a vertex, let's say from the 2099th one
coord = coordinates(c[R])[:, vert] # get the x, y, z coordinates of that vertex
meshscatter!(ax, coord'; color = :yellow, markersize = 4)
```

As of version 0.3, plotting discrete-valued data such as parcels (see [CorticalParcels.jl](https://github.com/myersm0/CorticalParcels.jl)) is now supported. You can supply a `colormap` dictionary that maps all parcel keys (as well as zero) to a `Colorant`, or you can omit this and use the default set of `distinguishable_colors` from the `Colors` package. If `parcel_file` is the path to a CIFTI file containing a set of parcels you want to visualize:

```
using CorticalParcels

cifti_data = CIFTI.load(parcel_file)
px = BilateralParcellation{Int}(c, cifti_data)
fig = Figure(; size = (600, 400))
montage = Montage(grid = fig.layout, surface = c)
plot!(montage, px)
```
![demo4](https://github.com/myersm0/ObservableCortex.jl/blob/main/examples/demo4.png)

One last example is given in the `examples/demo.jl` file for plotting parcel or region "borders." This is usually useful if you have continuous-valued statistics or activation to plot on the brain, and you want to see region boundaries overlaid on top of that.

## Acknowledgments
For testing and demonstration purposes, this package uses surface data from the MSC dataset (described in [Gordon et al 2017](https://www.cell.com/neuron/fulltext/S0896-6273(17)30613-X)). This data was obtained from the OpenfMRI database. Its accession number is ds000224.

[![Build Status](https://github.com/myersm0/ObservableCortex.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/myersm0/ObservableCortex.jl/actions/workflows/CI.yml?query=branch%3Amain)
