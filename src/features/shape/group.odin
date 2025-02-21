package shape

import "src:features/rays"
import "src:features/tuples"
import utils "src:utilities"

Group :: struct {
	shapes: [dynamic]^Shape
}

group :: proc() -> Group {
	return Group{nil}
}

// TODO: Move this out of sphere and into a more generic shape constructor file
group_shape :: proc() -> Shape {
	s := default_shape()
	g := group()
	set_shape(&s, g)
	return s
}

free_group :: proc(g: ^Group) {
	delete(g.shapes)
} 


free_shape :: proc(s: ^Shape) {
	#partial switch &t in s.shape {
	case Group:
		for i := 0; i < len(t.shapes); i+= 1 {
			free_shape(t.shapes[i])
		}

		delete(t.shapes)
	case:
		free(&t)
	}
}

// TODO: Nested Groups are not working
add_shape_to_group :: proc(g, s: ^Shape) {
	gr := &g.shape.(Group)
	append(&gr.shapes, s)
	set_parent(s, g)
}

group_equals :: proc(g1, g2: ^Group) -> bool {
	if len(g1.shapes) != len(g2.shapes) {
		return false
	}

	for i := 0; i < len(g1.shapes); i+=1 {
		if !shape_equals(g1.shapes[i], g2.shapes[i]) {
			return false
		}
	}

	return true
}

group_intersect :: proc(s: ^Shape, r: ^rays.Ray) -> map[^Shape][]f64 {
	g := s.shape.(Group)
	if len(g.shapes) == 0 {
		return nil
	}

	b := group_bounds(&g)
	bi := bounds_intersect(&b, r)
	if !bi {
		return nil
	}

	m := make(map[^Shape][]f64)
	for &s in g.shapes {
		st : = intersect(s, r)
		defer delete(st)

		if st == nil || len(st[s]) == 0 {
			continue
		}

		m[s] = st[s]
	}

	return m
}

group_normal_at :: proc(g: ^Group, p: tuples.Tuple) -> tuples.Tuple {
	return tuples.vector(0, 0, 0)
}
