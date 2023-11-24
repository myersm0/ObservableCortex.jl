
# helper function for Montage constructor below
function generate_axes(views::OrthographicLayout, grid::GridLayout)
	m, n = size(views)
	axes = Matrix{Axis3}(undef, m, n)
	for i in 1:m
		for j in 1:n
			which_hem = views[i, j].hemisphere
			direction = views[i, j].direction
			left = (j - 1) * panelwidth
			right = left + panelwidth - 1
			top = (i - 1) * panelheight
			bottom = top + panelheight - 1
			axes[i, j] = Axis3(
				grid[i, j],
				bbox = BBox(left, right, top, bottom)
				protrusions = (0, 0, 0, 0),
				aziumuth = azimuth(views[i, j]),
				elevation = elevation(views[i, j]),
				viewmode = :fitzoom,
				aspect = :data
			)
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

function Makie.plot!(montage::Montage, colors::Vector{RGB})
	if length(colors) != size(montage.surface)
		length(colors) == size(montage.surface, Exclusive()) || error(DimensionMismatch)
		colors = pad(colors, montage.surface)
	end
	for (i, ax) in enumerate(montage.axes)
		which_hem = montage.views[i].hemisphere
		verts = vertices(montage.surface[which_hem], Bilateral(), Inclusive())
		mesh!(ax, montage.meshes[which_hem]..., color = colors[verts])
	end
end

function Makie.plot!(montage::Montage, p::Parcel)
	colors = fill(surf_color, size(p.surface))
	colors[vertices(p)] .= :blue
	for (i, ax) in enumerate(montage.axes)
		which_hem = montage.views[i].hemisphere
		p.surface == surace[which_hem] || continue
		mesh!(ax, montage.meshes[which_hem]..., color = colors)
	end
end







