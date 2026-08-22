class_name TurnState
extends EnemyState


func init_state(_enemy: Enemy) -> void: pass


func enter_state(enemy: Enemy) -> void:
    enemy.direction.set_dir_from_vector(-enemy.direction.get_vector())


func exit_state(enemy: Enemy) -> void:
    enemy.velocity = enemy.direction.get_vector()
    enemy.move_and_slide()


func check_switch(_enemy: Enemy) -> void: pass


func process_enemy(_enemy: Enemy, _delta: float) -> void: pass
