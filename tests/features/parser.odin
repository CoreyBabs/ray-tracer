package test_features

import "core:testing"
import "src:features/parser"
import "src:features/shape"
import "src:features/tuples"

@(test)
ignoring_lines :: proc(t: ^testing.T) {
	path := "./test_files/ignore.obj"

	p := parser.parse_obj_file(path)
	defer parser.free_parser(&p)

	testing.expectf(t, p.ignored == 5, "Parser ignored an incorrect number of lines. Expected: 5, Got: %v", p.ignored)
}

@(test)
parse_vertices :: proc(t: ^testing.T) {
	path := "./test_files/vertex.obj"

	p := parser.parse_obj_file(path)
	defer parser.free_parser(&p)

	v1 := tuples.point(-1, 1, 0)
	v2 := tuples.point(-1, 0.5, 0)
	v3 := tuples.point(1, 0, 0)
	v4 := tuples.point(1, 1, 0)

	testing.expectf(t, tuples.tuple_equals(p.vertices[1], v1), "Parser vertex is incorrect at index 1, Expected: %v, Got: %v", v1, p.vertices[1])
	testing.expectf(t, tuples.tuple_equals(p.vertices[2], v2), "Parser vertex is incorrect at index 2, Expected: %v, Got: %v", v2, p.vertices[2])
	testing.expectf(t, tuples.tuple_equals(p.vertices[3], v3), "Parser vertex is incorrect at index 3, Expected: %v, Got: %v", v3, p.vertices[3])
	testing.expectf(t, tuples.tuple_equals(p.vertices[4], v4), "Parser vertex is incorrect at index 4, Expected: %v, Got: %v", v4, p.vertices[4])
}

@(test)
parse_faces :: proc(t: ^testing.T) {
	path := "./test_files/faces.obj"

	p := parser.parse_obj_file(path)
	defer parser.free_parser(&p)

	g := &p.default_group.shape.(shape.Group)
	t1 := &g.shapes[0].shape.(shape.Triangle)
	t2 := &g.shapes[1].shape.(shape.Triangle)

	testing.expectf(t, tuples.tuple_equals(t1.p1, p.vertices[1]), "Parser face does not match vertex. Face: %v, Vertex: %v", t1.p1, p.vertices[1])
	testing.expectf(t, tuples.tuple_equals(t1.p2, p.vertices[2]), "Parser face does not match vertex. Face: %v, Vertex: %v", t1.p2, p.vertices[2])
	testing.expectf(t, tuples.tuple_equals(t1.p3, p.vertices[3]), "Parser face does not match vertex. Face: %v, Vertex: %v", t1.p3, p.vertices[3])
	testing.expectf(t, tuples.tuple_equals(t2.p1, p.vertices[1]), "Parser face does not match vertex. Face: %v, Vertex: %v", t2.p1, p.vertices[1])
	testing.expectf(t, tuples.tuple_equals(t2.p2, p.vertices[3]), "Parser face does not match vertex. Face: %v, Vertex: %v", t2.p2, p.vertices[3])
	testing.expectf(t, tuples.tuple_equals(t2.p3, p.vertices[4]), "Parser face does not match vertex. Face: %v, Vertex: %v", t2.p3, p.vertices[4])
}

@(test)
parse_polygon :: proc(t: ^testing.T) {
	path := "./test_files/polygon.obj"

	p := parser.parse_obj_file(path)
	defer parser.free_parser(&p)

	g := &p.default_group.shape.(shape.Group)
	t1 := &g.shapes[0].shape.(shape.Triangle)
	t2 := &g.shapes[1].shape.(shape.Triangle)
	t3 := &g.shapes[2].shape.(shape.Triangle)

	testing.expectf(t, tuples.tuple_equals(t1.p1, p.vertices[1]), "Parser face does not match vertex. Face: %v, Vertex: %v", t1.p1, p.vertices[1])
	testing.expectf(t, tuples.tuple_equals(t1.p2, p.vertices[2]), "Parser face does not match vertex. Face: %v, Vertex: %v", t1.p2, p.vertices[2])
	testing.expectf(t, tuples.tuple_equals(t1.p3, p.vertices[3]), "Parser face does not match vertex. Face: %v, Vertex: %v", t1.p3, p.vertices[3])
	testing.expectf(t, tuples.tuple_equals(t2.p1, p.vertices[1]), "Parser face does not match vertex. Face: %v, Vertex: %v", t2.p1, p.vertices[1])
	testing.expectf(t, tuples.tuple_equals(t2.p2, p.vertices[3]), "Parser face does not match vertex. Face: %v, Vertex: %v", t2.p2, p.vertices[3])
	testing.expectf(t, tuples.tuple_equals(t2.p3, p.vertices[4]), "Parser face does not match vertex. Face: %v, Vertex: %v", t2.p3, p.vertices[4])
	testing.expectf(t, tuples.tuple_equals(t3.p1, p.vertices[1]), "Parser face does not match vertex. Face: %v, Vertex: %v", t3.p1, p.vertices[1])
	testing.expectf(t, tuples.tuple_equals(t3.p2, p.vertices[4]), "Parser face does not match vertex. Face: %v, Vertex: %v", t3.p2, p.vertices[4])
	testing.expectf(t, tuples.tuple_equals(t3.p3, p.vertices[5]), "Parser face does not match vertex. Face: %v, Vertex: %v", t3.p3, p.vertices[5])
}

@(test)
parse_groups :: proc(t: ^testing.T) {
	path := "./test_files/triangles.obj"

	p := parser.parse_obj_file(path)
	defer parser.free_parser(&p)

	g1 := &p.groups["FirstGroup"].shape.(shape.Group)
	g2 := &p.groups["SecondGroup"].shape.(shape.Group)
	t1 := &g1.shapes[0].shape.(shape.Triangle)
	t2 := &g2.shapes[0].shape.(shape.Triangle)

	testing.expectf(t, tuples.tuple_equals(t1.p1, p.vertices[1]), "Parser face does not match vertex. Face: %v, Vertex: %v", t1.p1, p.vertices[1])
	testing.expectf(t, tuples.tuple_equals(t1.p2, p.vertices[2]), "Parser face does not match vertex. Face: %v, Vertex: %v", t1.p2, p.vertices[2])
	testing.expectf(t, tuples.tuple_equals(t1.p3, p.vertices[3]), "Parser face does not match vertex. Face: %v, Vertex: %v", t1.p3, p.vertices[3])
	testing.expectf(t, tuples.tuple_equals(t2.p1, p.vertices[1]), "Parser face does not match vertex. Face: %v, Vertex: %v", t2.p1, p.vertices[1])
	testing.expectf(t, tuples.tuple_equals(t2.p2, p.vertices[3]), "Parser face does not match vertex. Face: %v, Vertex: %v", t2.p2, p.vertices[3])
	testing.expectf(t, tuples.tuple_equals(t2.p3, p.vertices[4]), "Parser face does not match vertex. Face: %v, Vertex: %v", t2.p3, p.vertices[4])
}

@(test)
obj_to_groups :: proc(t: ^testing.T) {
	path := "./test_files/triangles.obj"

	p := parser.parse_obj_file(path)
	defer parser.free_parser(&p)

	groups := parser.parser_to_groups(&p)
	delete(groups)

	for &g in groups {
		testing.expect(t, shape.shape_equals(g, p.groups["FirstGroup"]) || shape.shape_equals(g, p.groups["SecondGroup"]), "Group in parser was not in group list.")
	}
}
