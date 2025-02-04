package shape

import "core:math"
import "core:math/linalg"
import "src:features/rays"
import "src:features/tuples"
import utils "src:utilities"

Cone :: struct {
	min: f64,
	max: f64,
	closed: bool,
}

cone :: proc(min, max: f64, closed: bool = false) -> Cone {
	return Cone{min, max, closed}
}

default_cone :: proc() -> Cone {
	return Cone{math.inf_f64(-1), math.inf_f64(1), false}
}

cone_shape :: proc () -> Shape {
	c := default_cone()
	s := default_shape()
	set_shape(&s, c)
	return s
}

cone_equals :: proc(p1, p2: ^Cone) -> bool {
	return true
}


@(private)
cone_normal_at :: proc(s: ^Cone, p: tuples.Tuple) -> tuples.Tuple {
	dist := p.x * p.x + p.z * p.z
	if dist < 1 && p.y >= s.max - utils.EPS {
		return tuples.vector(0, 1, 0)
	}

	if dist < 1 && p.y <= s.min + utils.EPS {
		return tuples.vector(0, -1, 0)
	}

	y := math.sqrt_f64(dist)
	if p.y > 0 {
		y *= -1
	}

	return tuples.vector(p.x, y, p.z)
}

@(private)
cone_intersect :: proc(s: ^Cone, ray: ^rays.Ray) -> []f64 {
	a := ray.direction.x * ray.direction.x - ray.direction.y * ray.direction.y + ray.direction.z * ray.direction.z
	
	b := 2 * ray.origin.x * ray.direction.x - 2 * ray.origin.y * ray.direction.y + 2 * ray.origin.z * ray.direction.z
	c := ray.origin.x * ray.origin.x - ray.origin.y * ray.origin.y + ray.origin.z * ray.origin.z

	disc := b * b - 4 * a * c
	if disc < 0 {
		return nil
	}

	t0 := (-b - math.sqrt(disc)) / (2 * a)
	t1 := (-b + math.sqrt(disc)) / (2 * a)
	if t0 > t1 {
		tmp := t0
		t0 = t1
		t1 = tmp
	}

	ts : [dynamic]f64
	
	if !utils.fp_zero(a) {
		y0 := ray.origin.y + t0 * ray.direction.y
		if s.min < y0 && y0 < s.max {
			append(&ts, t0)
		}
		
		y1 := ray.origin.y + t1 * ray.direction.y
		if s.min < y1 && y1 < s.max {
			append(&ts, t1)
		}
	}
	else if !utils.fp_zero(b) {
		append(&ts, -c/(2 * b))
	}

	intersect_cone_caps(s, ray, &ts)

	return ts[:]
}

@(private)
intersect_cone_caps :: proc(cyl: ^Cone, r: ^rays.Ray, ts: ^[dynamic]f64) {
	if !cyl.closed || utils.fp_zero(r.direction.y) {
		return
	}

	t := (cyl.min - r.origin.y) / r.direction.y
	if check_cone_cap(r, t, cyl.min) {
		append(ts, t)
	}

	t = (cyl.max - r.origin.y) / r.direction.y
	if check_cone_cap(r, t, cyl.max) {
		append(ts, t)
	}
}  

@(private)
check_cone_cap :: proc(r: ^rays.Ray, t, y: f64,) -> bool {
	x := r.origin.x + t * r.direction.x
	z := r.origin.z + t * r.direction.z
	return (x*x + z*z) <= abs(y)
}
