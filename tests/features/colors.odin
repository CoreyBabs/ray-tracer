package test_features

import "core:math"
import "core:testing"
import "src:features/tuples"

@(test)
create_color :: proc(t: ^testing.T) {
	tuple := tuples.color(-0.5, 0.4, 1.7)
	result := tuple == [3]f64{-0.5, 0.4, 1.7} 
	testing.expect(t, result, "created color does not match expected value.")
}


@(test)
add_color_and_color :: proc(t: ^testing.T) {
	c1 := tuples.color(0.9, 0.6, 0.75)
	c2 := tuples.color(0.7, 0.1, 0.25)
	result := tuples.add_colors(c1, c2)
	testing.expectf(t, tuples.color_equals(result, [3]f64{1.6, 0.7, 1.0}), "color addition was not correct, got %f, %f, %f", result.r, result.g, result.b)
}

@(test)
subtract_color_and_color :: proc(t: ^testing.T) {
	c1 := tuples.color(0.9, 0.6, 0.75)
	c2 := tuples.color(0.7, 0.1, 0.25)
	result := tuples.subtract_colors(c1, c2)
	testing.expect(t, tuples.color_equals(result, [3]f64{0.2, 0.5, 0.5}), "color subtraction was not correct")
}

@(test)
multiply_color_by_scalar :: proc(t: ^testing.T) {
	c1 := tuples.color(0.2, 0.3, 0.4)
	expected := [3]f64{0.4, 0.6, 0.8}
	result := tuples.color_scalar_multiply(c1, 2)
	testing.expect(t,  tuples.color_equals(result, expected), "Scalar multiply failed")
}

@(test)
multiply_color_by_color :: proc(t: ^testing.T) {
	c1 := tuples.color(1, 0.2, 0.4)
	c2 := tuples.color(0.9, 1, 0.1)
	expected := [3]f64{0.9, 0.2, 0.04}
	result := tuples.color_multiply(c1, c2)
	testing.expect(t,  tuples.color_equals(result, expected), "Scalar multiply failed")
}

