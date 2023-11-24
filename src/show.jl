
function Base.show(io::IO, mime::MIME"text/plain", x::OrthographicLayout)
	println(io, "OrthographicLayout:")
	show(io, mime, x.views)
end


function Base.show(io::IO, mime::MIME"text/plain", m::Montage)
	print(io, "Montage:")
	println(io, "")
	print(io, "    ⊢ ")
	show(io, mime, m.views)
	println(io, "")
	print(io, "    ⊢ ")
	println(io, "Surface:")
	show(io, mime, m.surface)
end





