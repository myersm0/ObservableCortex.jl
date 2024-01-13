
function colorize(val::Real; colormap::Vector{<:Colorant}, colorrange)
	scaled_val = (val - colorrange[1]) / (colorrange[2] - colorrange[1]) * (length(colormap) - 1)
	lower_ind = floor(Int, scaled_val) + 1
	upper_ind = ceil(Int, scaled_val) + 1
	t = scaled_val % 1
	grad = cgrad([colormap[lower_ind], colormap[upper_ind]])
	return only(RGB{Float32}[grad[t]])
end

const surf_color = RGB(0.78, 0.8, 0.8)

const videen_style = @chain begin
	[
		0xff 0x00 0x00; #red
		0xff 0x69 0x00; #orange
		0xff 0x99 0x00; #orange-yellow
		0xff 0xff 0x00; #yellow
		0x10 0xb0 0x10; #limegreen
		0x00 0xff 0x00; #green
		0x7f 0x7f 0xcc; #blue-videen7
		0x4c 0x4c 0x7f; #blue-videen9
		0x33 0x33 0x4c; #blue-videen11
		0x66 0x00 0x33; #purple2
		0x00 0x00 0x00; #black
		0x00 0xff 0xff; #cyan
		0x00 0xff 0x00; #green
		0xe2 0x51 0xe2; #violet
		0xff 0x38 0x8d; #hotpink
		0xff 0xff 0xff; #white
		0xdd 0xdd 0xdd; #gray-dd
		0xbb 0xbb 0xbb; #gray-bb
		0x00 0x00 0x00  #black
	]
	map(x -> RGB((x / 255)...), eachrow(_))
	vec
	reverse
end

hotmap = zeros(64, 3)
hotmap[:, 1] = [collect(range(0.0417, 1, 24)); fill(1, 40)]
hotmap[:, 2] = [fill(0, 24); range(0.0417, 1, 24); fill(1, 16)]
hotmap[:, 3] = [fill(0, 48); range(0.0625, 1, 16)]
coolmap = hotmap[:, 3:-1:1]
combined = vcat(coolmap[61:-1:1, :], zeros(10, 3), hotmap[1:61, :])
const coolhot = map(x -> RGB(x...), eachrow(combined))[:]

