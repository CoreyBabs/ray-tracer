package shape

import "core:slice"
import "src:features/rays"
import "src:features/tuples"

Operation :: enum {
	Union,
	Intersection,
	Difference,
}

Csg :: struct {
	operation: Operation,
	left: ^Shape,
	right: ^Shape,
}

@(private)
csg :: proc(op: Operation, left, right: ^Shape) -> Csg {
	return Csg{ op, left, right }
}

new_csg_shape :: proc(op: Operation, left, right: ^Shape) -> ^Shape {
	s := new_shape()
	c := csg(op, left, right)
	set_shape(s, c)

	set_parent(left, s)
	set_parent(right, s)
	return s
}

@(private)
csg_equals :: proc(c1, c2: ^Csg) -> bool {
	return c1.operation == c2.operation &&
		shape_equals(c1.left, c2.left) &&
		shape_equals(c1.right, c2.right)
}

@(private)
csg_includes :: proc(c: ^Csg, s: ^Shape) -> bool {
	return shape_includes(c.left, s) || shape_includes(c.right, s)
}

@(private)
csg_intersect :: proc(s: ^Shape, r: ^rays.Ray) -> map[^Shape][]f64 {
	c := s.shape.(Csg)
	leftxs := intersect(c.left, r)
	defer delete(leftxs)
	rightxs := intersect(c.right, r)
	defer delete(rightxs)

	if leftxs == nil && rightxs == nil {
		return nil
	}

	m := make(map[^Shape][]f64)
	defer delete(m)
	
	if leftxs != nil {
		for key, value in leftxs {
			m[key] = value
		}
	}

	if rightxs != nil {
		for key, value in rightxs {
			m[key] = value
		}
	}
	
	filtered := filter_intersections(s, m)
	return filtered
}

@(private)
csg_normal_at :: proc(t: ^Csg, p: tuples.Tuple) -> tuples.Tuple {
	panic("Csg normal should never need to be calculated.")
}

intersection_allowed :: proc(op: Operation, lhit, inl, inr: bool) -> bool {
	switch op {
	case .Union: return (lhit && !inr) || (!lhit && !inl)
	case .Intersection: return (lhit && inr) || (!lhit && inl)
	case .Difference: return (lhit && !inr) || (!lhit && inl)
	case: return false
	}
}

filter_intersections :: proc(c: ^Shape, xs: map[^Shape][]f64) -> map[^Shape][]f64 {
	filtered := make(map[^Shape][]f64)
	csg := &c.shape.(Csg)

	inl := false
	inr := false

	for key, value in xs {
		lhit := shape_includes(csg.left, key)
		allowed := intersection_allowed(csg.operation, lhit, inl, inr)
		if allowed {
			filtered[key] = value
		}
		else {
			delete(value)
		}

		if lhit {
			inl = !inl
		}
		else {
			inr = !inr
		}
	}

	return filtered
}


