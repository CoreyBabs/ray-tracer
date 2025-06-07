package test_features

import "core:testing"
import "src:features/intersection"
import "src:features/rays"
import "src:features/shape"
import "src:features/transforms"
import "src:features/tuples"
import utils "src:utilities"

@(test)
create_csg :: proc(t: ^testing.T) {
	s1 := shape.new_shape()
	s2 := shape.new_shape()

	cu := shape.cube()
	shape.set_shape(s2, cu)

	csg := shape.new_csg_shape(.Union, s1, s2)
	defer shape.free_shape(csg)
	c := csg.shape.(shape.Csg)

	testing.expectf(t, c.operation == shape.Operation.Union, "CSG operation is incorrect. Got: %v, Expected: %v", c.operation, shape.Operation.Union)
	testing.expect(t, shape.shape_equals(c.left, s1), "CSG left shape is not correct.")
	testing.expect(t, shape.shape_equals(c.right, s2), "CSG right shape is not correct.")
	testing.expectf(t, shape.shape_equals(s1.parent, csg), "Shape 1 parent is not CSG.")
	testing.expectf(t, shape.shape_equals(s2.parent, csg), "Shape 2 parent is not CSG.")
}

@(test)
csg_intersection_allowed_union :: proc(t: ^testing.T) {
	amount := 8
	lhits := [8]bool { true, true, true, true, false, false, false, false}
	inls := [8]bool { true, true, false, false, true, true, false, false}
	inrs := [8]bool { true, false, true, false, true, false, true, false}
	results := [8]bool { false, true, false, true, false, false, true, true}

	for i := 0; i < amount; i += 1 {
		result := shape.intersection_allowed(.Union, lhits[i], inls[i], inrs[i])
		testing.expectf(t, result == results[i], "Union intersection permission at index %v, lhit %v, inl %v, inr %v is not %v.", i, lhits[i], inls[i], inrs[i], results[i])
	}
}

@(test)
csg_intersection_allowed_intersection :: proc(t: ^testing.T) {
	amount := 8
	lhits := [8]bool { true, true, true, true, false, false, false, false}
	inls := [8]bool { true, true, false, false, true, true, false, false}
	inrs := [8]bool { true, false, true, false, true, false, true, false}
	results := [8]bool { true, false, true, false, true, true, false, false}

	for i := 0; i < amount; i += 1 {
		result := shape.intersection_allowed(.Intersection, lhits[i], inls[i], inrs[i])
		testing.expectf(t, result == results[i], "Intersection intersection permission at index %v, lhit %v, inl %v, inr %v is not %v.", i, lhits[i], inls[i], inrs[i], results[i])
	}
}

@(test)
csg_intersection_allowed_difference :: proc(t: ^testing.T) {
	amount := 8
	lhits := [8]bool { true, true, true, true, false, false, false, false}
	inls := [8]bool { true, true, false, false, true, true, false, false}
	inrs := [8]bool { true, false, true, false, true, false, true, false}
	results := [8]bool { false, true, false, true, true, true, false, false}

	for i := 0; i < amount; i += 1 {
		result := shape.intersection_allowed(.Difference, lhits[i], inls[i], inrs[i])
		testing.expectf(t, result == results[i], "Difference intersection permission at index %v, lhit %v, inl %v, inr %v is not %v.", i, lhits[i], inls[i], inrs[i], results[i])
	}
}

@(test)
csg_filtering_intersection :: proc(t: ^testing.T) {
	s1 := shape.new_shape()
	defer shape.free_shape(s1)
	s2 := shape.new_shape()
	defer shape.free_shape(s2)
	c := shape.cube()
	shape.set_shape(s2, c)

	ops := []shape.Operation { .Union, .Intersection, .Difference }
	x0s := []f64 { 0, 1, 0}
	x1s := []f64 { 3, 2 ,1}
	

	xs := make(map[^shape.Shape][]f64)
	xs[s1] = []f64{1, 3}
	xs[s2] = []f64{2, 4}
	defer delete(xs)

	// // i1 := intersection.intersection(1, s1)
	// // i2 := intersection.intersection(2, s2)
	// // i3 := intersection.intersection(3, s1)
	// // i4 := intersection.intersection(4, s2)
	// // xs := intersection.aggregate_intersections(i1, i2, i3, i4)
	for i := 0; i < len(ops); i += 1 {
		csg := shape.new_csg_shape(ops[i], s1, s2)
		defer free(csg)
		result := shape.filter_intersections(csg, xs)
		// defer delete(result)
		testing.expect(t, true, "failed")
		// testing.expectf(t, len(result) == 2, "CSG intersection filtering is incorrect. Got %v intersections, Expected 2.", len(result))
		// testing.expectf(t, utils.fp_equals(result[0][0], x0s[i]), "CSG intersection filtering is incorrect. Got: %v, Expected: %v.", result[0][0], x0s[i])
		// testing.expectf(t, utils.fp_equals(result[1][0], x1s[i]), "CSG intersection filtering is incorrect. Got: %v, Expected: %v.", result[1][1], x1s[i])
	}
}

@(test)
csg_ray_miss :: proc(t: ^testing.T) {
	s1 := shape.new_shape()
	s2 := shape.new_shape()
	c := shape.cube()
	shape.set_shape(s2, c)
	csg := shape.new_csg_shape(.Union, s1, s2)
	defer shape.free_shape(csg)

	r := rays.create_ray(tuples.point(0, 2, -5), tuples.vector(0, 0, 1))
	xs := shape.intersect(csg, &r)
	testing.expect(t, xs == nil, "CSG ray intersection is not nil when ray misses.")
}

// @(test)
csg_ray_intersection :: proc(t: ^testing.T) {
	s1 := shape.new_shape()
	s2 := shape.new_shape()
	shape.set_transform(s2, transforms.get_translation_matrix(0, 0, 0.5))
	csg := shape.new_csg_shape(.Union, s1, s2)
	defer shape.free_shape(csg)

	r := rays.create_ray(tuples.point(0, 0, -5), tuples.vector(0, 0, 1))
	xs := intersection.intersect(csg, &r)
	defer delete(xs)
	
	testing.expectf(t, len(xs) == 2, "CSG intersection is incorrect. Got %v intersections, Expected 2.", len(xs))
	testing.expectf(t, utils.fp_equals(xs[0].t, 4), "CSG intersection is incorrect. Got: %v, Expected: 4.", xs[0].t)
	testing.expectf(t, shape.shape_equals(&xs[0].shape, s1), "CSG intersection is incorrect. Got: %v, Expected: %v.", xs[0].shape, s1)
	testing.expectf(t, utils.fp_equals(xs[1].t, 6.5), "CSG intersection is incorrect. Got: %v, Expected: 6.5.", xs[1].t)
	testing.expectf(t, shape.shape_equals(&xs[0].shape, s1), "CSG intersection is incorrect. Got: %v, Expected: %v.", xs[1].shape, s2)
}


