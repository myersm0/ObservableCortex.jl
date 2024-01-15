
@enum Orientation Lateral Medial Dorsal Ventral

struct OrthographicView
	hemisphere::BrainStructure
	orientation::Orientation
end

struct OrthographicLayout
	views::Matrix{OrthographicView}
	function OrthographicLayout(views::Matrix{OrthographicView})
		length(views[:]) == length(unique(views[:])) || error("Views must be unique")
		return new(views)
	end
end

function OrthographicLayout(mat::Matrix{Tuple{BrainStructure, Orientation}})
	OrthographicLayout([OrthographicView(x...) for x in mat])
end

Base.size(o::OrthographicLayout) = size(o.views)

Base.getindex(o::OrthographicLayout, args...) = getindex(o.views, args...)

const default_views = OrthographicLayout(
	[
		OrthographicView(L, Lateral) OrthographicView(R, Lateral);
		OrthographicView(L, Medial)  OrthographicView(R, Medial)
	]
)

# @match doesn't seem to be able to work with enum types within an OrthographicView,
# unfortunately; but this workaround with casting to a tuple of Ints is not too bad
function azimuth(v::OrthographicView)::Float64
	@match (Int(v.hemisphere), Int(v.orientation)) begin
		(0, 0) =>  π   # L, Lateral
		(0, 1) =>  0   # L, Medial
		(1, 0) =>  0   # R, Lateral
		(1, 1) =>  π   # R, Medial
		(_, 2) => -π/2 # _, Dorsal
		(_, 3) =>  π/2 # _, Ventral
	end
end

function elevation(v::OrthographicView)::Float64
	@match Int(v.orientation) begin
		0 =>  0   # Lateral
		1 =>  0   # Medial
		2 =>  π/2 # Dorsal
		3 => -π/2 # Ventral
	end
end

