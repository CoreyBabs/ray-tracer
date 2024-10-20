package intersection

import "core:math"
import "core:math/linalg"
import "src:features/rays"
import "src:features/sphere"
import "src:features/tuples"
import utils "src:utilities"

Intersection :: struct {
	t: f32,
	sphere: sphere.Sphere
}

intersection :: proc(t: f32, sphere: sphere.Sphere) -> Intersection {
	return Intersection{t, sphere}
}

intersection_equals :: proc(i1, i2: Intersection) -> bool {
	return utils.fp_equals(i1.t, i2.t) && sphere.sphere_equals(i1.sphere, i2.sphere)
}

aggregate_intersections :: proc(intersections: ..Intersection) -> [dynamic]Intersection {
	aggregate: [dynamic]Intersection
	append(&aggregate, ..intersections)

	return aggregate
}

intersect :: proc(sphere: ^sphere.Sphere, ray: ^rays.Ray) -> [dynamic]Intersection {
	transformed_ray := rays.transform(ray, linalg.inverse(sphere.transform))
	sphere_to_ray := tuples.subtract_tuples(transformed_ray.origin, sphere.center)

	a := tuples.dot(transformed_ray.direction, transformed_ray.direction)
	b := 2 * tuples.dot(transformed_ray.direction, sphere_to_ray)
	c := tuples.dot(sphere_to_ray, sphere_to_ray) - 1

	test := math.pow(b, 2)
	other := 4 * a * c
	discriminant := math.pow(b, 2) - (4 * a * c)

	if discriminant < 0 {
		return nil;
	}

	t1 := (-b - math.sqrt(discriminant)) / (2 * a)
	t2 := (-b + math.sqrt(discriminant)) / (2 * a)

	i1 := intersection(t1, sphere^)
	i2 := intersection(t2, sphere^)
	
	return aggregate_intersections(i1, i2)
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
