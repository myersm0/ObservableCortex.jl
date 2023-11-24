
# helper function for Montage constructor below
function generate_axes(views::OrthographicLayout, grid::GridLayout)
	m, n = size(views)
	axes = Matrix{Axis3}(undef, m, n)
	for i in 1:m
		for j in 1:n
			which_hem = views[i, j].hemisphere
			direction = views[i, j].direction
			axes[i, j] = Axis3(
				grid[i, j],
				protrusions = (0, 0, 0, 0),
				azimuth = azimuth(views[i, j]),
				elevation = elevation(views[i, j]),
				viewmode = :fitzoom,
				aspect = :data,
			)
			hidespines!(axes[i, j])
			hidedecorations!(axes[i, j])
		end
	end
	return axes
end

@kwdef struct Montage
	views::OrthographicLayout
	grid::GridLayout
	surface::CorticalSurface
	meshes::Dict{BrainStructure, NamedTuple} =
		Dict(
			hem => @chain surface[hem] begin
				GeometryBasics.Mesh
				(coords = GeometryBasics.coordinates(_), faces = GeometryBasics.faces(_))
			end
			for hem in LR
		)
	axes::Matrix{Axis3} = generate_axes(views, grid)
end

function Makie.mesh!(
		montage::Montage, colors::Vector{T}; kwargs...
	) where T <: Union{AbstractFloat, Colorant}
	if length(colors) != size(montage.surface)
		length(colors) == size(montage.surface, Exclusive()) || error(DimensionMismatch)
		colors = pad(colors, montage.surface)
		# fill medial wall with NaN's if it's a numeric vector, or else with surf_color
		nan_val = eltype(colors) <: Colorant ? surf_color : NaN
		colors[medial_wall(montage.surface)] .= nan_val
	end
	for (i, ax) in enumerate(montage.axes)
		which_hem = montage.views[i].hemisphere
		verts = vertices(montage.surface[which_hem], Bilateral(), Inclusive())
		mesh!(
			ax, montage.meshes[which_hem]..., color = colors[verts]; 
			kwargs...
		)
	end
end

Makie.plot!(montage::Montage, args...; kwargs...) = mesh!(montage, args; kwargs...)



