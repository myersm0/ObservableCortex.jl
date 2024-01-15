
struct Montage
	grid::GridLayout
	views::OrthographicLayout
	surface::CorticalSurface
	meshes::Dict{BrainStructure, NamedTuple}
	axes::Matrix{Axis3}
	_map1::Dict{BrainStructure, Vector{CartesianIndex}}
	_map2::Dict{OrthographicView, CartesianIndex}
end

"""
    Montage(; grid, surface, views = default_views)

Create a `Montage` representing a set of cortical surface views for plotting.
"""
function Montage(; 
		grid::GridLayout, surface::CorticalSurface, views::OrthographicLayout = default_views
	)
	meshes = Dict(
		hem => @chain surface[hem] begin
			GeometryBasics.Mesh
			(coords = GeometryBasics.coordinates(_), faces = GeometryBasics.faces(_))
		end
		for hem in LR
	)
	axes = generate_axes(views, grid)
	_map1, _map2 = generate_axis_maps(views)
	return Montage(grid, views, surface, meshes, axes, _map1, _map2)
end

# helper function for Montage constructor above
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

# another helper for Montage constructor
function generate_axis_maps(views::OrthographicLayout)
	map1 = Dict{BrainStructure, Vector{CartesianIndex}}()
	map2 = Dict{OrthographicView, CartesianIndex}()
	m, n = size(views)
	for i in 1:m
		for j in 1:m
			hem = views[i, j].hemisphere
			haskey(map1, hem) || setindex!(map1, Vector{CartesianIndex}(), hem)
			push!(map1[hem], CartesianIndex(i, j))
			map2[views[i, j]] = CartesianIndex(i, j)
		end
	end
	return (map1, map2)
end

"""
    axis(m, v)

Given a `Montage m`, get the `Axis3` for plotting that corresponds to the given 
`OrthographicView v`.
"""
axis(m::Montage, v::OrthographicView) = m.axes[m._map2[v]]

axis(m::Montage, b::BrainStructure, v::Orientation) = axis(m, OrthographicView(b, v))

axis(m::Montage, t::Tuple{BrainStructure, Orientation}) = axis(m, OrthographicView(t...))

axis(m::Montage, i::Integer, j::Integer) = getindex(m.axes, i, j)

"""
    axes(m, b)

Given a `Montage m`, get a `Vector{Axis3}` listing all axes in the montage that
correspond to the given hemisphere `b::BrainStructure` (should be either 
`CORTEX_LEFT`, `CORTEX_RIGHT`, or their abbreviations `L` and `R`)
"""
Base.axes(m::Montage, b::BrainStructure) = [m.axes[ind] for ind in m._map1[b]]

Base.axes(m::Montage, args...) = getindex(m.axes, args...)



