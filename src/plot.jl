
function Makie.mesh!(
		montage::Montage, colors::Vector{T}; kwargs...
	) where T <: Union{AbstractFloat, Colorant}
	if length(colors) != size(montage.surface)
		length(colors) == size(montage.surface, Exclusive()) || error(DimensionMismatch)
		colors = pad(colors, montage.surface)
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

function Makie.mesh!(
		montage::Montage, px::BilateralParcellation; 
		colormap::Union{Nothing, AbstractDict} = nothing, nan_color = surf_color, kwargs...
	)
	ks = [collect(keys(px[L])); collect(keys(px[R]))]
	if isnothing(colormap)
		temp = [nan_color; distinguishable_colors(size(px))]
		colormap = Dict(k => temp[i] for (i, k) in enumerate(ks))
		colormap[0] = nan_color
	else
		all([k in keys(colormap) for k in ks]) || 
			error("colormap must have all keys from the parcellation, including zero")
	end
	vals = vec(px)
	colors = [colormap[k] for k in vals]
	mesh!(montage, colors; nan_color = nan_color, kwargs...)
end

Makie.plot!(montage::Montage, args...; kwargs...) = mesh!(montage, args...; kwargs...)



