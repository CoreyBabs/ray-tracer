package shape

import "core:math"
import "core:math/linalg"
import "src:features/rays"
import "src:features/tuples"
import utils "src:utilities"

Cylinder :: struct {
	min: f64,
	max: f64,
	closed: bool,
}

cylinder :: proc(min, max: f64, closed: bool = false) -> Cylinder {
	return Cylinder{min, max, closed}
}

default_cylinder :: proc() -> Cylinder {
	return Cylinder{math.inf_f64(-1), math.inf_f64(1), false}
}

cylinder_shape :: proc () -> Shape {
	c := default_cylinder()
	s := default_shape()
	set_shape(&s, c)
	return s
}

cylinder_equals :: proc(p1, p2: ^Cylinder) -> bool {
	return true
}


@(private)
cylinder_normal_at :: proc(s: ^Cylinder, p: tuples.Tuple) -> tuples.Tuple {
	dist := p.x * p.x + p.z * p.z
	if dist < 1 && p.y >= s.max - utils.EPS {
		return tuples.vector(0, 1, 0)
	}

	if dist < 1 && p.y <= s.min + utils.EPS {
		return tuples.vector(0, -1, 0)
	}

	return tuples.vector(p.x, 0, p.z)
}

@(private)
cylinder_intersect :: proc(s: ^Shape, ray: ^rays.Ray) -> map[^Shape][]f64 {
	a := ray.direction.x * ray.direction.x + ray.direction.z * ray.direction.z
	
	b := 2 * ray.origin.x * ray.direction.x + 2 * ray.origin.z * ray.direction.z
	c := ray.origin.x * ray.origin.x + ray.origin.z * ray.origin.z - 1

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

	cyl := s.shape.(Cylinder)	

	if !utils.fp_zero(a) {
		y0 := ray.origin.y + t0 * ray.direction.y
		if cyl.min < y0 && y0 < cyl.max {
			append(&ts, t0)
		}
		
		y1 := ray.origin.y + t1 * ray.direction.y
		if cyl.min < y1 && y1 < cyl.max {
			append(&ts, t1)
		}
	}

	intersect_caps(&cyl, ray, &ts)

	if len(ts) == 0 {
		return nil
	}

	m := make(map[^Shape][]f64)
	m[s] = ts[:]
	return m
}

@(private)
intersect_caps :: proc(cyl: ^Cylinder, r: ^rays.Ray, ts: ^[dynamic]f64) {
	if !cyl.closed || utils.fp_zero(r.direction.y) {
		return
	}

	t := (cyl.min - r.origin.y) / r.direction.y
	if check_cap(r, t) {
		append(ts, t)
	}

	t = (cyl.max - r.origin.y) / r.direction.y
	if check_cap(r, t) {
		append(ts, t)
	}
}  

@(private)
check_cap :: proc(r: ^rays.Ray, t: f64) -> bool {
	x := r.origin.x + t * r.direction.x
	z := r.origin.z + t * r.direction.z
	return (x*x + z*z) <= 1
}
