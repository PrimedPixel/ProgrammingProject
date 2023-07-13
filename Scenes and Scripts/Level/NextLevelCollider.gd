extends Area2D

@onready var animation = $AnimationPlayer
@onready var music = get_parent().get_node("Music")

# Sets up, in the Godot IDE, a space to select the levels
#export(PackedScene, FILE, "*.tscn") var target_level_path
@export var target_level_path: PackedScene

func _on_NextLevelCollider_body_entered(body):
	if body is Player:
		body.sprite.visible = false
		
		animation.play("End Level")
		
		music.fade_out()
		
		await animation.animation_finished
		
		GlobalVariables.checkpoint_pos = Vector2.ZERO
		
		Transition.exit_level_transition()
		await Transition.transition_completed

		var viewport = get_viewport()
		var viewport_child = viewport.get_child(viewport.get_child_count() - 1)
		viewport_child.queue_free()

		GlobalVariables.level_to = target_level_path
		var new_scene = target_level_path.instantiate()
		viewport.add_child(new_scene)

		Transition.enter_level_transition()
