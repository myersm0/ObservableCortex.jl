
import GeometryBasics

function GeometryBasics.Mesh(hem::Hemisphere)
	!isnothing(hem.triangles) || error("triangle component must be defined")
	triangles = hem.triangles
	coords = coordinates(hem)
	pts = [GeometryBasics.Point{3, Float32}(coords[:, v]) for v in 1:size(hem)]
	triangles = [
		GeometryBasics.TriangleFace(triangles[:, v]) for v in 1:size(triangles, 2)
	]
	return GeometryBasics.Mesh(pts, triangles)
end


