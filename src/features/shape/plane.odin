package shape

import "core:math"
import "core:math/linalg"
import "src:features/rays"
import "src:features/tuples"
import utils "src:utilities"

Plane :: struct {}

plane :: proc() -> Plane {
	return Plane{}
}

plane_shape :: proc () -> Shape {
	p := plane()
	s := default_shape()
	set_shape(&s, p)
	return s
}

plane_equals :: proc(p1, p2: ^Plane) -> bool {
	return true
}


@(private)
plane_normal_at :: proc(s: ^Plane, p: tuples.Tuple) -> tuples.Tuple {
	return tuples.vector(0, 1, 0)
}

@(private)
plane_intersect :: proc(s: ^Shape, ray: ^rays.Ray) -> map[^Shape][]f64 {
	if math.abs(ray.direction.y) < utils.EPS {
		return nil
	}

	t := -ray.origin.y / ray.direction.y
	ts := make([]f64, 1, context.allocator)
	ts[0] = t
	

	m := make(map[^Shape][]f64)
	m[s] = ts
	return m
}
