
function Base.show(io::IO, mime::MIME"text/plain", x::PanelLayout)
	println(io, "PanelLayout:")
	show(io, mime, x.panels)
end

# TODO: improve this with indentation for the component types
function Base.show(io::IO, mime::MIME"text/plain", m::Montage)
	print(io, "Montage:")
	println(io, "")
	print(io, "    ⊢ ")
	show(io, mime, m.panels)
	println(io, "")
	print(io, "    ⊢ ")
	println(io, "Surface:")
	show(io, mime, m.surface)
end





