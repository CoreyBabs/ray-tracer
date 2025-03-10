package intersection

import "core:math"
import "core:math/linalg"
import "core:slice"
import "src:features/rays"
import "src:features/shape"
import "src:features/tuples"
import utils "src:utilities"

Intersection :: struct {
	shape: shape.Shape,
	t: f64,
	u: f64,
	v: f64,
}

intersection :: proc(t: f64, shape: shape.Shape) -> Intersection {
	return Intersection{shape, t, 0, 0}
}

intersection_with_uv :: proc(t: f64, shape: shape.Shape, u, v: f64) -> Intersection {
	return Intersection{shape, t, u, v}
}

intersection_equals :: proc(i1, i2: ^Intersection) -> bool {
	return utils.fp_equals(i1.t, i2.t) && shape.shape_equals(&i1.shape, &i2.shape)
}

aggregate_intersections :: proc(intersections: ..Intersection) -> [dynamic]Intersection {
	aggregate: [dynamic]Intersection
	append(&aggregate, ..intersections)

	return aggregate
}

aggregate_ts :: proc(s: ^shape.Shape, ts: ..f64) -> [dynamic]Intersection {
	aggregate: [dynamic]Intersection
	for t in ts {
		append(&aggregate, intersection(t, s^))
	}

	return aggregate
}

aggregate_and_sort_ts :: proc(m: ^map[^shape.Shape][]f64, r: ^rays.Ray) -> [dynamic]Intersection {
	aggregate: [dynamic]Intersection

	for key, values in m {
		for t in values {
			#partial switch &s in key.shape {
			case shape.SmoothTriangle: 
				u, v := shape.smooth_triangle_get_uv(&key.shape.(shape.SmoothTriangle), r)
				append(&aggregate, intersection_with_uv(t, key^, u, v))
			case: append(&aggregate, intersection(t, key^))
			}
		}
	}

	slice.sort_by(aggregate[:], sort)
	return aggregate
}

intersect :: proc(s: ^shape.Shape, ray: ^rays.Ray) -> [dynamic]Intersection {
	ts := shape.intersect(s, ray)
	defer utils.free_map(&ts)
	defer delete(ts)

	if ts == nil {
		return nil
	}

	return aggregate_and_sort_ts(&ts, ray)
}

hit :: proc(intersections: [dynamic]Intersection) -> (Intersection, bool) {
	hit: Intersection
	found := false
	for i in intersections {
		if !found && i.t > 0 {
			hit = i
			found = true
		}
		else if i.t > 0 && i.t < hit.t {
			hit = i
			found = true
		}
	}

	return hit, found
}

sort :: proc(i1, i2: Intersection) -> bool {
	return i1.t < i2.t
}
