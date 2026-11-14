extends GutTest

const TEST_SCENE: PackedScene = preload("uid://u4eb1lfdhgph")

const ANIM: StringName = &"anim"
const ANIM_DIRECTIONAL: StringName = &"animd"
const ANIM_CARRY: StringName = &"animc"
const ANIM_STRICT_CARRY: StringName = &"animsc"
const ANIM_CARRY_DIRECTIONAL: StringName = &"animcd"

var test_case: AnimationHandler

var direction: Direction


func before_each() -> void:
    test_case = add_child_autoqfree(TEST_SCENE.instantiate())
    direction = autoqfree(Direction.new())


func test_animation_name() -> void:
    test_case.switch_anim_string(ANIM)
    assert_eq(test_case.current_animation, ANIM)
    assert_eq(test_case.animation, ANIM)


func test_animation_name_direction() -> void:
    test_case.switch_anim_string(ANIM_DIRECTIONAL)
    assert_push_error_count(1)

    test_case.direction = direction
    var test_dir: Direction.Dir = Direction.Dir.values().pick_random()
    direction.face_direction = test_dir
    test_case.switch_anim_string(ANIM_DIRECTIONAL)
    assert_eq(test_case.current_animation, ANIM_DIRECTIONAL)
    assert_eq(test_case.animation, ANIM_DIRECTIONAL + "_" + Direction.Dir.find_key(test_dir).to_lower())


func test_animation_name_carry() -> void:
    test_case._carry_state = CarryHandler.CarryState.FREE
    test_case.switch_anim_string(ANIM_CARRY)
    assert_eq(test_case.current_animation, ANIM_CARRY)
    assert_eq(test_case.animation, ANIM_CARRY)

    test_case._carry_state = CarryHandler.CarryState.CARRY
    test_case.switch_anim_string(ANIM_CARRY)
    assert_eq(test_case.current_animation, ANIM_CARRY)
    assert_eq(test_case.animation, ANIM_CARRY + "_carry")


func test_animation_name_strict_carry() -> void:
    test_case._carry_state = CarryHandler.CarryState.FREE
    test_case.switch_anim_string(ANIM_STRICT_CARRY)
    assert_push_error_count(1)

    test_case._carry_state = CarryHandler.CarryState.CARRY
    test_case.switch_anim_string(ANIM_STRICT_CARRY)
    assert_eq(test_case.current_animation, ANIM_STRICT_CARRY)
    assert_eq(test_case.animation, ANIM_STRICT_CARRY + "_carry")


func test_animation_name_direction_carry() -> void:
    test_case.direction = direction
    test_case._carry_state = CarryHandler.CarryState.FREE
    test_case.switch_anim_string(ANIM_CARRY_DIRECTIONAL)
    assert_eq(test_case.current_animation, ANIM_CARRY_DIRECTIONAL)
    assert_eq(test_case.animation, ANIM_CARRY_DIRECTIONAL + "_" + Direction.Dir.find_key(direction.face_direction).to_lower())
    test_case._carry_state = CarryHandler.CarryState.CARRY
    test_case.switch_anim_string(ANIM_CARRY_DIRECTIONAL)
    assert_eq(test_case.current_animation, ANIM_CARRY_DIRECTIONAL)
    assert_eq(test_case.animation, ANIM_CARRY_DIRECTIONAL + "_" + Direction.Dir.find_key(direction.face_direction).to_lower() + "_carry")


func test_animation_updates_on_direction_change() -> void:
    test_case.direction = direction
    direction.face_direction = Direction.Dir.RIGHT
    test_case.switch_anim_string(ANIM_DIRECTIONAL)
    assert_eq(test_case.animation, ANIM_DIRECTIONAL + "_right")
    direction.face_direction = Direction.Dir.LEFT
    simulate(test_case, 1, 1)
    assert_eq(test_case.animation, ANIM_DIRECTIONAL + "_left")


func test_animation_updates_on_carry_state_change() -> void:
    test_case._carry_state = CarryHandler.CarryState.FREE
    test_case.switch_anim_string(ANIM_CARRY)
    assert_eq(test_case.animation, ANIM_CARRY)
    test_case._carry_state = CarryHandler.CarryState.CARRY
    simulate(test_case, 1, 1)
    assert_eq(test_case.animation, ANIM_CARRY + "_carry")

signal cont

func test_flicker_works() -> void:
    var vis: bool = test_case.visible
    test_case.flicker = true
    assert_false(test_case.timer.is_stopped())
    
    test_case.timer.timeout.connect(cont.emit, CONNECT_DEFERRED | CONNECT_ONE_SHOT)
    await cont
    assert_ne(test_case.visible, vis)
    test_case.timer.timeout.connect(cont.emit, CONNECT_DEFERRED | CONNECT_ONE_SHOT)
    await cont
    assert_eq(test_case.visible, vis)
    test_case.flicker = false
    assert_true(test_case.timer.is_stopped())
    assert_eq(test_case.visible, true)
    
func test_animation_from_state() -> void:
    var state: Player.State = Player.State.values().pick_random()
    test_case.switch_anim(state)
    assert_eq(test_case.animation, test_case.animations[state])
