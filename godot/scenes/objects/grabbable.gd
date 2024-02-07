class_name Grabbable
extends RigidBody3D

const SNAP_SPEED = 30.0

var _snap_target : Marker3D = null
var _previous_v_error := Vector3.ZERO
var _v_error_integral := Vector3.ZERO


func set_snap_target(snap_target):
	_snap_target = snap_target
	can_sleep = snap_target == null
	continuous_cd = snap_target != null
	gravity_scale = 0 if snap_target else 1


func _physics_process(delta):
	if _snap_target:
		var vec = _snap_target.global_position - global_position
		var v = vec * SNAP_SPEED # velocity
		var v_error = v - linear_velocity
		var error_derivative = (v_error - _previous_v_error) / delta
		_previous_v_error = v_error
		
		_v_error_integral += v_error * delta
		var impulse = v_error + error_derivative + (_v_error_integral * 1)
		
		apply_central_impulse(impulse * 0.01)
		#apply_central_force(impulse * 0.1)
		
		#add_constant_central_force(vec * delta)
		#apply_central_impulse(vec * 0.1)
		



#func _integrate_forces(state : PhysicsDirectBodyState3D):
	#if _snap_target:
		#var vec = _snap_target.global_position - global_position
		#state.linear_velocity = vec * SNAP_SPEED * state.step
