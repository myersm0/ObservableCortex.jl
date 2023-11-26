
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

Makie.plot!(montage::Montage, args...; kwargs...) = mesh!(montage, args...; kwargs...)


