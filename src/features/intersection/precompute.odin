package intersection

import "core:slice"
import "src:features/rays"
import "src:features/shape"
import "src:features/tuples"
import utils "src:utilities"

Precompute :: struct {
	t: f64,
	object: shape.Shape,
	point: tuples.Tuple,
	eyev: tuples.Tuple,
	normalv: tuples.Tuple,
	inside: bool,
	over_point: tuples.Tuple,
	under_point: tuples.Tuple,
	reflectv: tuples.Tuple,
	n1: f64, 
	n2: f64,
}

prepare_computation :: proc(intersection: ^Intersection, ray: ^rays.Ray, all_intersections: ^[dynamic]Intersection = nil) -> Precompute {
	point := rays.position(ray, intersection.t)
	eyev := -ray.direction
	inside, normalv := is_inside(shape.normal_at(&intersection.shape, point), eyev)
	over_point := point + tuples.scalar_multiply(normalv, utils.EPS)
	under_point := point - tuples.scalar_multiply(normalv, utils.EPS)
	reflectv := tuples.reflect(ray.direction, normalv)
	n1, n2 := calculate_refractions(intersection, all_intersections)
	return Precompute{
		intersection.t,
		intersection.shape,
		point,
		eyev,
		normalv,
		inside,
		over_point,
		under_point,
		reflectv,
		n1,
		n2,
	}
}

@(private)
is_inside :: proc(n, e: tuples.Tuple) -> (bool, tuples.Tuple) {
	dot := tuples.dot(n, e)
	if dot < 0 {
		return true, -n
	}

	return false, n
}

calculate_refractions :: proc(hit: ^Intersection, all_intersections: ^[dynamic]Intersection) -> (f64, f64) {
	intersection_slice: []Intersection
	if all_intersections == nil {
		intersection_slice = []Intersection{hit^}
	} 
	else {
		intersection_slice = all_intersections[:]
	}

	containers: [dynamic]^shape.Shape
	defer delete(containers)

	n1, n2: f64
	for &i in intersection_slice {
		if intersection_equals(&i, hit) {
			n1 = len(containers) == 0 ? 1.0 : containers[len(containers) - 1].material.refractive_index
		}
		
		index, found := shape.shape_search(&containers, &i.shape)
		if found && index > -1 {
			ordered_remove(&containers, index)
		}
		else {
			append(&containers, &i.shape)
		}

		if intersection_equals(&i, hit) {
			n2 = len(containers) == 0 ? 1.0 : containers[len(containers) - 1].material.refractive_index
			break
		}
	}

	return n1, n2
}
