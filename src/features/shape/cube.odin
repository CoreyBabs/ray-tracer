package shape

import "core:math"
import "core:math/linalg"
import "src:features/rays"
import "src:features/tuples"
import utils "src:utilities"

Cube :: struct {}

cube :: proc() -> Cube {
	return Cube{}
}

cube_shape :: proc () -> Shape {
	c := cube()
	s := default_shape()
	set_shape(&s, c)
	return s
}

cube_equals :: proc(p1, p2: ^Cube) -> bool {
	return true
}


@(private)
cube_normal_at :: proc(s: ^Cube, p: tuples.Tuple) -> tuples.Tuple {
	maxc := max(abs(p.x), abs(p.y), abs(p.z))

	if maxc == abs(p.x) {
		return tuples.vector(p.x, 0, 0)
	}
	else if maxc == abs(p.y) {
		return tuples.vector(0, p.y, 0)
	}
	return tuples.vector(0, 0, p.z)
}

@(private)
cube_intersect :: proc(s: ^Cube, ray: ^rays.Ray) -> []f64 {
	xtmin, xtmax := check_axis(ray.origin.x, ray.direction.x)
	ytmin, ytmax := check_axis(ray.origin.y, ray.direction.y)
	ztmin, ztmax := check_axis(ray.origin.z, ray.direction.z)

	tmin := max(xtmin, ytmin, ztmin)
	tmax := min(xtmax, ytmax, ztmax)
	
	if tmin > tmax {
		return nil
	}

	ts := make([]f64, 2, context.allocator)
	ts[0] = tmin
	ts[1] = tmax
	return ts
}

@(private)
check_axis :: proc(origin, direction: f64) -> (f64, f64) {
	tmin_numerator := (-1 - origin)
	tmax_numerator := (1 - origin)

	tmin, tmax: f64
	if abs(direction) >= utils.EPS {
		tmin = tmin_numerator / direction
		tmax = tmax_numerator / direction
	}
	else {
		tmin = tmin_numerator * math.inf_f64(1)
		tmax = tmax_numerator * math.inf_f64(1)
	}

	if tmin > tmax {
		tmp := tmin
		tmin = tmax
		tmax = tmp
	}

	return tmin, tmax
}
