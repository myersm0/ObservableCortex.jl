
@enum Orientation Lateral Medial Dorsal Ventral

struct Panel
	hemisphere::BrainStructure
	orientation::Orientation
end

struct PanelLayout
	panels::Matrix{Panel}
	function PanelLayout(panels::Matrix{Panel})
		length(panels[:]) == length(unique(panels[:])) || throw(ArgumentError("Views must be unique"))
		return new(panels)
	end
end

function PanelLayout(mat::Matrix{Tuple{BrainStructure, Orientation}})
	PanelLayout([Panel(x...) for x in mat])
end

Base.size(o::PanelLayout) = size(o.panels)

Base.getindex(o::PanelLayout, args...) = getindex(o.panels, args...)

const default_views = PanelLayout(
	[
		Panel(L, Lateral) Panel(R, Lateral);
		Panel(L, Medial)  Panel(R, Medial)
	]
)

# @match doesn't seem to be able to work with enum types within an Panel,
# unfortunately; but this workaround with casting to a tuple of Ints is not too bad
function azimuth(v::Panel)::Float64
	@match (Int(v.hemisphere), Int(v.orientation)) begin
		(0, 0) =>  π   # L, Lateral
		(0, 1) =>  0   # L, Medial
		(1, 0) =>  0   # R, Lateral
		(1, 1) =>  π   # R, Medial
		(_, 2) => -π/2 # _, Dorsal
		(_, 3) =>  π/2 # _, Ventral
	end
end

function elevation(v::Panel)::Float64
	@match Int(v.orientation) begin
		0 =>  0   # Lateral
		1 =>  0   # Medial
		2 =>  π/2 # Dorsal
		3 => -π/2 # Ventral
	end
end

