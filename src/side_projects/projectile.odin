package side_projects

import "core:fmt"
import "src:features"

Projectile :: struct {
	position: features.Tuple,
	velocity: features.Tuple,
}

Environment :: struct {
	gravity: features.Tuple,
	wind: features.Tuple,
}

tick :: proc(env: Environment, proj: Projectile) -> Projectile {
	new_position := features.add_tuples(proj.position, proj.velocity)
	new_velocity := features.add_tuples(proj.velocity, env.gravity)
	new_velocity = features.add_tuples(new_velocity, env.wind)
	return Projectile{new_position, new_velocity}
}

run :: proc() {
	position := features.point(0, 1, 0)
	velocity := features.vector(1, 1, 0)
	velocity = features.normalize(velocity)

	gravity := features.vector(0, -0.1, 0)
	wind := features.vector(-0.01, 0, 0)

	projectile := Projectile{position, velocity}
	environment := Environment{gravity, wind}

	tick_count := 0
	for projectile.position.y >= 0 {
		projectile = tick(environment, projectile)
		tick_count += 1
		fmt.printf("After %i ticks, projectile is at %f, %f, %f\n",
			tick_count,
			projectile.position.x,
			projectile.position.y,
			projectile.position.z)
	}
}

