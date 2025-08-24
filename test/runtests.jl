using ObservableCortex
using Test
using JLD
using CIFTI
using CorticalSurfaces
using CorticalParcels
using Colors
using CairoMakie
using Pkg.Artifacts

# setup surface for testing
surface_dir = artifact"CIFTI_test_files"
temp = load(joinpath(surface_dir, "MSC01.jld"))

surfL = temp["pointsets"]["midthickness"][L]
mwL = temp["medial wall"][L]
triangleL = temp["triangle"][L]
hemL = Hemisphere(L, surfL, mwL; triangles = triangleL)

surfR = temp["pointsets"]["midthickness"][R]
mwR = temp["medial wall"][R]
triangleR = temp["triangle"][R]
hemR = Hemisphere(R, surfR, mwR; triangles = triangleR)

c = CorticalSurface(hemL, hemR)

@testset "ObservableCortex.jl" begin
	
	@testset "Panel and PanelLayout" begin
		panel = Panel(L, Lateral)
		@test panel.hemisphere == L
		@test panel.orientation == Lateral
		
		custom_views = PanelLayout(
			[(L, Lateral) (L, Medial) (L, Dorsal) (L, Ventral)]
		)
		@test size(custom_views) == (1, 4)
		
		@test size(default_views) == (2, 2)
		@test default_views[1, 1] == Panel(L, Lateral)
		@test default_views[2, 2] == Panel(R, Medial)
	end
	
	@testset "Montage creation and structure" begin
		fig = Figure(; size = (800, 600))
		montage = Montage(panels = default_views, grid = fig.layout, surface = c)
		@test montage.surface === c
		@test size(montage.axes) == size(default_views)
		@test size(montage.plots) == size(default_views)
		
		@test all(ax isa Axis3 for ax in montage.axes)
		
		@test haskey(montage._map1, L)
		@test haskey(montage._map1, R)
		@test length(montage._map1[L]) == 2  # two left panels in default_views
		@test length(montage._map1[R]) == 2  # two right panels
		
		@test haskey(montage._map2, Panel(L, Lateral))
		@test haskey(montage._map2, Panel(R, Medial))
	end
	
	@testset "Axis accessors" begin
		fig = Figure(; size = (800, 600))
		montage = Montage(panels = default_views, grid = fig.layout, surface = c)
		
		m, n = size(default_views)
		for i in 1:m
			for j in 1:n
				ax = montage.axes[i, j]
				
				# Test grid-based access
				@test axis(montage, i, j) === ax
				
				# Test row/column access
				@test ax in axes(montage, i, :)
				@test length(axes(montage, i, :)) == n
				@test ax in axes(montage, :, j)
				@test length(axes(montage, :, j)) == m
				
				# Test panel-based access
				which_view = montage.panels[i, j]
				@test axis(montage, which_view) === ax
				@test axis(montage, which_view.hemisphere, which_view.orientation) === ax
				@test axis(montage, (which_view.hemisphere, which_view.orientation)) === ax
				
				# Test hemisphere-based access
				which_hem = montage.panels[i, j].hemisphere
				@test length(axes(montage, which_hem)) == 2
				@test ax in axes(montage, which_hem)
			end
		end
	end
	
	@testset "Basic plotting" begin
		fig = Figure(; size = (800, 600))
		montage = Montage(panels = default_views, grid = fig.layout, surface = c)
		
		# Test with continuous values
		values = randn(size(c, Exclusive()))
		plots = plot!(montage, values; colormap = coolhot)
		
		@test size(plots) == size(montage.axes)
		@test all(p isa Makie.Mesh for p in plots)
		@test montage.plots == plots
		
		# Test that plot! delegates to mesh!
		values2 = randn(size(c, Exclusive()))
		plots2 = mesh!(montage, values2; colormap = videen_style)
		@test size(plots2) == size(montage.axes)
	end
	
	@testset "Plot accessors (getindex)" begin
		fig = Figure(; size = (800, 600))
		montage = Montage(panels = default_views, grid = fig.layout, surface = c)
		values = randn(size(c, Exclusive()))
		plot!(montage, values)
		
		# Test panel-based access
		@test montage[Panel(L, Lateral)] isa Makie.Mesh
		@test montage[(L, Lateral)] isa Makie.Mesh
		@test montage[L, Lateral] isa Makie.Mesh
		
		# Test grid-based access
		@test montage[1, 1] isa Makie.Mesh
		@test montage[2, 2] isa Makie.Mesh
		
		# Test hemisphere-based access (returns array)
		left_plots = montage[L]
		@test length(left_plots) == 2
		@test all(p isa Makie.Mesh for p in left_plots)
		
		right_plots = montage[R]
		@test length(right_plots) == 2
		@test all(p isa Makie.Mesh for p in right_plots)
	end
	
	@testset "Value alignment and padding" begin
		fig = Figure(; size = (800, 600))
		montage = Montage(panels = default_views, grid = fig.layout, surface = c)
		
		# Test with values excluding medial wall
		values_exclusive = randn(size(c, Exclusive()))
		plots = plot!(montage, values_exclusive)
		@test !isnothing(plots)
		
		# test with values including medial wall
		values_inclusive = randn(size(c, Inclusive()))
		plots = plot!(montage, values_inclusive)
		@test !isnothing(plots)
		
		wrong_size = randn(100)
		@test_throws DimensionMismatch plot!(montage, wrong_size)
	end
	
	@testset "Color computation" begin
		fig = Figure(; size = (800, 600))
		montage = Montage(panels = default_views, grid = fig.layout, surface = c)
		
		# Test with Colorant values
		colors = [RGB(rand(), rand(), rand()) for _ in 1:size(c, Exclusive())]
		plots = plot!(montage, colors)
		@test !isnothing(plots)
		
		# Test colorize function
		val = 0.5
		colormap = coolhot
		colorrange = (0.0, 1.0)
		color = ObservableCortex.colorize(val; colormap = colormap, colorrange = colorrange)
		@test color isa RGB{Float32}
		
		# Test edge cases
		color_low = ObservableCortex.colorize(-1.0; colormap = colormap, colorrange = colorrange)
		@test color_low == colormap[1]
		
		color_high = ObservableCortex.colorize(2.0; colormap = colormap, colorrange = colorrange)
		@test color_high == colormap[end]
	end
	
	@testset "Parcellation plotting" begin
		fig = Figure(; size = (800, 600))
		montage = Montage(panels = default_views, grid = fig.layout, surface = c)
		
		# Load parcellation
		parcel_file = joinpath(surface_dir, "test_parcels.dtseries.nii")
		cifti_data = CIFTI.load(parcel_file)
		px = BilateralParcellation{Int}(c, cifti_data)
		
		# test with default colormap
		plots = plot!(montage, px)
		@test !isnothing(plots)
		
		# test with custom colormap
		custom_colormap = Dict(k => RGB(0.5, 0.5, 0.5) for k in keys(px))
		custom_colormap[0] = surf_color
		plots = plot!(montage, px; colormap = custom_colormap)
		@test !isnothing(plots)
	end
	
	@testset "Observable support" begin
		fig = Figure(; size = (800, 600))
		montage = Montage(panels = default_views, grid = fig.layout, surface = c)
		
		# Create Observable data
		obs_values = Observable(randn(size(c, Exclusive())))
		
		# Test that Observable can be passed
		plots = plot!(montage, obs_values; colormap = coolhot)
		@test !isnothing(plots)
		
		# update Observable (just checking it doesn't error)
		obs_values[] = randn(size(c, Exclusive()))
		
		# test with Observable of colors
		obs_colors = Observable([RGB(rand(), rand(), rand()) for _ in 1:size(c, Exclusive())])
		plots = plot!(montage, obs_colors)
		@test !isnothing(plots)
	end
	
	@testset "Camera angles" begin
		# Test azimuth calculations
		@test ObservableCortex.azimuth(Panel(L, Lateral)) ≈ π
		@test ObservableCortex.azimuth(Panel(L, Medial)) ≈ 0
		@test ObservableCortex.azimuth(Panel(R, Lateral)) ≈ 0
		@test ObservableCortex.azimuth(Panel(R, Medial)) ≈ π
		@test ObservableCortex.azimuth(Panel(L, Dorsal)) ≈ -π/2
		@test ObservableCortex.azimuth(Panel(L, Ventral)) ≈ π/2
		
		# Test elevation calculations
		@test ObservableCortex.elevation(Panel(L, Lateral)) ≈ 0
		@test ObservableCortex.elevation(Panel(L, Medial)) ≈ 0
		@test ObservableCortex.elevation(Panel(L, Dorsal)) ≈ π/2
		@test ObservableCortex.elevation(Panel(L, Ventral)) ≈ -π/2
	end
	
	@testset "Custom panel layouts" begin
		fig = Figure(; size = (1200, 400))
		
		# Test single hemisphere layout
		left_only = PanelLayout([(L, Lateral) (L, Medial)])
		montage = Montage(panels = left_only, grid = fig.layout, surface = c)
		@test size(montage.axes) == (1, 2)
		
		values = randn(size(c, Exclusive()))
		plots = plot!(montage, values)
		@test size(plots) == (1, 2)
		
		# Test vertical layout
		fig2 = Figure(; size = (400, 800))
		vertical_layout = PanelLayout(
			reshape([(L, Lateral); (L, Medial); (R, Lateral); (R, Medial)], :, 1)
		)
		montage2 = Montage(panels = vertical_layout, grid = fig2.layout, surface = c)
		@test size(montage2.axes) == (4, 1)
	end
	
	@testset "Edge cases and error handling" begin
		fig = Figure(; size = (800, 600))
		montage = Montage(panels = default_views, grid = fig.layout, surface = c)
		
		# Empty vector should error
		@test_throws DimensionMismatch plot!(montage, Float64[])
		
		# Vector with NaNs should work
		values_with_nans = randn(size(c, Exclusive()))
		values_with_nans[1:100] .= NaN
		plots = plot!(montage, values_with_nans)
		@test !isnothing(plots)
		
		# Test with single-color input
		single_color = fill(0.5, size(c, Exclusive()))
		plots = plot!(montage, single_color)
		@test !isnothing(plots)
	end
	
end
