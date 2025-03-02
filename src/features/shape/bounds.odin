package shape

import "core:math"
import "core:math/linalg"
import "src:features/rays"
import "src:features/tuples"
import utils "src:utilities"

Bounds :: struct {
	min: tuples.Tuple,
	max: tuples.Tuple,
}

default_bounds :: proc() -> Bounds {
	return Bounds{lower_bounds_limit(), upper_bounds_limit()}
}

bounds :: proc(min, max: tuples.Tuple) -> Bounds {
	return Bounds{min, max}
}

lower_bounds_limit :: proc() -> tuples.Tuple {
	return tuples.point(math.inf_f64(-1), math.inf_f64(-1), math.inf_f64(-1))
}

upper_bounds_limit :: proc() -> tuples.Tuple {
	return tuples.point(math.inf_f64(1), math.inf_f64(1), math.inf_f64(1))
}

shape_bounds :: proc(s: ^Shape) -> Bounds {
	switch &t in &s.shape {
	case Sphere:
		return bounds(tuples.point(-1, -1, -1), tuples.point(1, 1, 1))
	case Plane:
		return bounds(tuples.point(math.inf_f64(-1), 0, math.inf_f64(-1)), tuples.point(math.inf_f64(1), 0, math.inf_f64(1)))
	case Cube:
		return bounds(tuples.point(-1, -1, -1), tuples.point(1, 1, 1))
	case Cylinder:
		return bounds(tuples.point(-1, t.min, -1), tuples.point(1, t.max, 1))
	case Cone:
		return bounds(tuples.point(-1, t.min, -1), tuples.point(1, t.max, 1))
	case Group:
		return group_bounds(&t)
	case Triangle:
		return triangle_bounds(&t)
	case:
		panic("Unknown shape type.")
	}
}

group_bounds :: proc(g: ^Group) -> Bounds {
	minx, miny, minz := math.inf_f64(1), math.inf_f64(1), math.inf_f64(1)
	maxx, maxy, maxz := math.inf_f64(-1), math.inf_f64(-1), math.inf_f64(-1)

	points := make([]tuples.Tuple, 8, context.allocator)
	defer delete(points)

	for i := 0; i < len(g.shapes); i+=1 {
		s := g.shapes[i]
		b := shape_bounds(s)
		points[0] = s.transform * b.min
		points[1] = s.transform * tuples.point(b.min.x, b.min.y, b.max.z)
		points[2] = s.transform * tuples.point(b.min.x, b.max.y, b.min.z)
		points[3] = s.transform * tuples.point(b.min.x, b.max.y, b.max.z)
		points[4] = s.transform * tuples.point(b.max.x, b.min.y, b.min.z)
		points[5] = s.transform * tuples.point(b.max.x, b.min.y, b.max.z)
		points[6] = s.transform * tuples.point(b.max.x, b.max.y, b.min.z)
		points[7] = s.transform * b.max

		for p in points {
			minx = min(minx, p.x)
			miny = min(miny, p.y)
			minz = min(minz, p.z)
			maxx = max(maxx, p.x)
			maxy = max(maxy, p.y)
			maxz = max(maxz, p.z)
		}
	}

	return Bounds{tuples.point(minx, miny, minz), tuples.point(maxx, maxy, maxz)}
}

@(private)
bounds_intersect :: proc(b: ^Bounds, ray: ^rays.Ray) -> bool {
	xtmin, xtmax := check_axis(ray.origin.x, ray.direction.x, b.min.x, b.max.x)
	ytmin, ytmax := check_axis(ray.origin.y, ray.direction.y, b.min.y, b.max.y)
	ztmin, ztmax := check_axis(ray.origin.z, ray.direction.z, b.min.z, b.max.z)

	tmin := max(xtmin, ytmin, ztmin)
	tmax := min(xtmax, ytmax, ztmax)
	
	return tmin <= tmax
}

@(private)
triangle_bounds :: proc(t: ^Triangle) -> Bounds {
	minx := min(t.p1.x, t.p2.x, t.p3.x)
	miny := min(t.p1.y, t.p2.y, t.p3.y)
	minz := min(t.p1.z, t.p2.z, t.p3.z)

	maxx := max(t.p1.x, t.p2.x, t.p3.x)
	maxy := max(t.p1.y, t.p2.y, t.p3.y)
	maxz := max(t.p1.z, t.p2.z, t.p3.z)

	return Bounds{tuples.point(minx, miny, minz), tuples.point(maxx, maxy, maxz)}
}
