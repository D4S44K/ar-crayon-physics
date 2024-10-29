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
    # circle-circle collision, uses sqrt and div
    # Assume they collided right now
    df_x = obj_a.pos[0] - obj_b.pos[0]
    df_y = obj_a.pos[1] - obj_b.pos[1]
    df_sq = df_x * df_x + df_y * df_y

    rv_x = obj_a.vel[0] - obj_b.vel[0]
    rv_y = obj_a.vel[1] - obj_b.vel[1]
    # rv_sq = rv_x * rv_x + rv_y * rv_y

    dot_rv_df = rv_x * df_x + rv_y * df_y

    unit_dist_x = ELAS * df_x * dot_rv_df / df_sq
    unit_dist_y = ELAS * df_y * dot_rv_df / df_sq

    m_scale_1 = 2 * obj_b.mass / (obj_a.mass + obj_b.mass)
    if obj_a.static:
        m_scale_1 = 0.0
    elif obj_b.static:
        m_scale_1 = 2.0
    m_scale_2 = 2.0 - m_scale_1

    obj_a.vel = (
        obj_a.vel[0] - m_scale_1 * unit_dist_x,
        obj_a.vel[1] - m_scale_1 * unit_dist_y,
    )

    obj_b.vel = (
        obj_b.vel[0] + m_scale_2 * unit_dist_x,
        obj_b.vel[1] + m_scale_2 * unit_dist_y,
    )
