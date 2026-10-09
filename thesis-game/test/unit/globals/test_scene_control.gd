extends GutTest


func test_begin_game()->void:
    SceneControl.begin_game(0)
    assert_true(SceneControl.current_scene.is_queued_for_deletion())
    await wait_idle_frames(1)
    assert_eq(SceneControl.loaded_scene_path, SceneControl.GAME)
    assert_true(SceneControl.current_scene is GameScene)
    
    
func test_back_to_menu()->void:
    SceneControl.back_to_menu()
    assert_true(SceneControl.current_scene.is_queued_for_deletion())
    await wait_idle_frames(1)
    assert_eq(SceneControl.loaded_scene_path, SceneControl.MENU)
    assert_true(SceneControl.current_scene is MenuScene)
