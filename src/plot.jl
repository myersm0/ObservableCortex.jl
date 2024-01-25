
function Makie.mesh!(
		montage::Montage, values::Vector{T}; kwargs...
	) where T <: Union{AbstractFloat, Colorant}
	if length(values) != size(montage.surface)
		length(values) == size(montage.surface, Exclusive()) || error(DimensionMismatch)
		pad_with = T <: Colorant ? surf_color : NaN
		values = pad(values, montage.surface; sentinel = pad_with)
	end
	for (i, ax) in enumerate(montage.axes)
		which_hem = montage.views[i].hemisphere
		verts = vertices(montage.surface[which_hem], Bilateral(), Inclusive())
		mesh!(
			ax, montage.meshes[which_hem]..., color = values[verts]; 
			kwargs...
		)
	end
end

function Makie.mesh!(
		montage::Montage, values::Vector{<:Integer}; pad_with = 0, kwargs...
	)
	if length(values) != size(montage.surface)
		length(values) == size(montage.surface, Exclusive()) || error(DimensionMismatch)
		values = pad(values, montage.surface; sentinel = pad_with)
	end

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

	for (i, ax) in enumerate(montage.axes)
		which_hem = montage.views[i].hemisphere
		verts = vertices(montage.surface[which_hem], Bilateral(), Inclusive())
		mesh!(
			ax, montage.meshes[which_hem]..., color = colors[verts]; 
			kwargs...
		)
	end
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
			error("colormap must have all keys from the parcellation")
	end
	vals = vec(px)
	colors = [colormap[k] for k in vals]
	mesh!(montage, colors; nan_color = nan_color, kwargs...)
end

Makie.plot!(montage::Montage, args...; kwargs...) = mesh!(montage, args...; kwargs...)


## helpers for plotting:

function colorize(
		val::Real; 
		colormap::Vector{<:Colorant}, 
		colorrange,
		lowclip = colormap[1], 
		highclip = colormap[end]
	)
	zmin, zmax = colorrange

	if val <= zmin
		return lowclip
	elseif val >= zmax
		return highclip
	end

	scaled_val = (val - zmin) / (zmax - zmin) * (length(colormap) - 1)
	color1 = colormap[floor(Int, scaled_val) + 1]
	color2 = colormap[ceil(Int, scaled_val) + 1]
	t = scaled_val % 1
	grad = cgrad([color1, color2])
	return only(RGB{Float32}[grad[t]])
end

