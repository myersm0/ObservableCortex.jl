
function Makie.mesh!(montage::Montage, values::AbstractVector; kwargs...)
	values_to_plot = @chain begin
		align_values(values, montage)
		compute_colors(_; kwargs...)
	end
	for (i, ax) in enumerate(montage.axes)
		which_hem = montage.panels[i].hemisphere
		verts = vertices(montage.surface[which_hem], Bilateral(), Inclusive())
		colors = values_to_plot[verts]
		montage.plots[i] = mesh!(
			ax, montage.meshes[which_hem]..., color = colors; 
			kwargs...
		)
	end
	return montage.plots
end

function Makie.mesh!(montage::Montage, values::Observable; kwargs...)
	values_to_plot = @lift begin
		@chain begin
			align_values($values, montage) 
			compute_colors(_; kwargs...)
		end
	end
	for (i, ax) in enumerate(montage.axes)
		which_hem = montage.panels[i].hemisphere
		verts = vertices(montage.surface[which_hem], Bilateral(), Inclusive())
		colors = @lift $values_to_plot[verts]
		montage.plots[i] = mesh!(
			ax, montage.meshes[which_hem]..., color = colors; 
			kwargs...
		)
	end
	return montage.plots
end

function Makie.mesh!(
		montage::Montage, px::BilateralParcellation; 
		colormap::Union{Nothing, AbstractDict} = nothing, nan_color = surf_color, kwargs...
	)
	ks = keys(px)
	if isnothing(colormap)
		temp = [nan_color; distinguishable_colors(size(px))]
		colormap = Dict(k => temp[i] for (i, k) in enumerate(ks))
		colormap[0] = nan_color
	else
		if !haskey(colormap, 0)
			colormap[0] = surf_color
		end
		all([k in keys(colormap) for k in ks]) || 
			throw(ArgumentError("colormap must have all keys from the parcellation"))
	end
	vals = vec(px)
	colors = [colormap[k] for k in vals]
	mesh!(montage, colors; nan_color = nan_color, kwargs...)
end

Makie.plot!(montage::Montage, args...; kwargs...) = mesh!(montage, args...; kwargs...)


## helpers for plotting:

import CorticalSurfaces: pad, default_with
default_with(::Colorant) = NaN
pad(x, montage::Montage) = pad(x, montage.surface)

function align_values(values::AbstractVector, montage::Montage; kwargs...)
	len = length(values)
	len == size(montage.surface, Inclusive()) && 
		return values
	len == size(montage.surface, Exclusive()) && 
		return pad(values, montage; kwargs...)
	return throw(
		DimensionMismatch(
			"""
			values of length $len not compatible with surface $(montage.surface)
			of size $(size(montage.surface, Inclusive())) (or 
			$size(montage.surface, Exclusive)) exclusive of medial wall
			"""
		)
	)
end

function colorize(
		val::Real; 
		colormap::Vector{<:Colorant}, colorrange, lowclip = colormap[1], highclip = colormap[end]
	)
	zmin, zmax = colorrange
	val <= zmin && return lowclip
	val >= zmax && return highclip
	scaled_val = (val - zmin) / (zmax - zmin) * (length(colormap) - 1)
	color1 = colormap[floor(Int, scaled_val) + 1]
	color2 = colormap[ceil(Int, scaled_val) + 1]
	t = scaled_val % 1
	grad = cgrad([color1, color2])
	return only(RGB{Float32}[grad[t]])
end

function compute_colors(values::AbstractVector; kwargs...)
	return values
end

function compute_colors(values::AbstractVector{<:Integer}; kwargs...)
	colormap = haskey(kwargs, :colormap) ? 
		kwargs[:colormap] : 
		distinguishable_colors(min(64, length(unique(values))))
	if typeof(colormap) <: AbstractVector
		colorrange = haskey(kwargs, :colorrange) ?
			kwargs[:colorrange] :
			(minimum(values), maximum(values))
		colors = colorize.(values; colormap = colormap, colorrange = colorrange)
	else # AbstractDict case
		colors = [colormap[v] for v in values]
	end
	colors[medial_wall(montage.surface)] .= surf_color
	return colors
end





