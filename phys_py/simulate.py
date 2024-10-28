from my_types import *


def update_pos_vel(objects, time_step):
    for obj in objects:
        obj.pos = (
            obj.pos[0] + obj.vel[0] * time_step,
            obj.pos[1] + obj.vel[1] * time_step,
        )
        obj.vel = (
            obj.vel[0] + obj.acc[0] * time_step,
            obj.vel[1] + obj.acc[1] * time_step,
        )


def update_collision_vel(obj_a, obj_b):
    if obj_a.shape_type != 0 or obj_b.shape_type != 0:
        raise ValueError("Unsupported shape type")
    # Assume they collided right now
