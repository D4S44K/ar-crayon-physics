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


def update_acc(objects):
    for obj in objects:
        obj.acc = (0.0, 0.0)
        if not obj.static:
            obj.acc = (0.0, GRAVITY)


def update_collision_vel(obj_i, obj_j, ip_idx, jp_idx):
    do_swap = obj_i.shape_type > obj_j.shape_type
    if do_swap:
        obj_a, obj_b = obj_j, obj_i
        ap_idx, bp_idx = jp_idx, ip_idx
    else:
        obj_a, obj_b = obj_i, obj_j
        ap_idx, bp_idx = ip_idx, jp_idx
    # always a.type <= b.type
    rv_x = obj_a.vel[0] - obj_b.vel[0]  # a goes to b
    rv_y = obj_a.vel[1] - obj_b.vel[1]

    if obj_a.shape_type == 0:
        if obj_b.shape_type == 0:
            circle_circle_vel(obj_a, obj_b, rv_x, rv_y)
        elif obj_b.shape_type == 1:
            pass
        elif obj_b.shape_type == 2:
            b_part_list = get_my_parts(obj_b)
            b_part = b_part_list[bp_idx]
            if b_part.t != 1:
                pass
            else:
                circle_point_vel(obj_a, obj_b, b_part, rv_x, rv_y)
    elif obj_a.shape_type == 1:
        pass
    elif obj_a.shape_type == 2:
        pass


def circle_circle_vel(obj_a, obj_b, rv_x, rv_y):
    # circle-circle collision, uses sqrt and div
    # Assume they collided right now
    df_x = obj_a.pos[0] - obj_b.pos[0]
    df_y = obj_a.pos[1] - obj_b.pos[1]
    df_sq = df_x * df_x + df_y * df_y

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


def circle_point_vel(obj_a, obj_b, point_b, rv_x, rv_y):
    df_x = obj_a.pos[0] - point_b.x
    df_y = obj_a.pos[1] - point_b.y
    df_sq = df_x * df_x + df_y * df_y

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
