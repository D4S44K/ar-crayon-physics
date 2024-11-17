from my_types import *
from math import sqrt

from pandas import DataFrame

global_time = 0.0
global_i = 0
global_j = 0
debug_info_list = []


def debug_sim_time_update(time_diff):
    global global_time
    global_time += time_diff
    return global_time


def debug_set(obj_i, obj_j):
    global global_i
    global global_j
    global_i = obj_i.index
    global_j = obj_j.index
    df = DataFrame(debug_info_list)
    df.to_csv("result/debug_sim.csv")


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


def update_collision_vel(obj_a, obj_b, ap_idx, bp_idx):
    debug_set(obj_a, obj_b)

    rv_x = obj_a.vel[0] - obj_b.vel[0]  # a goes to b
    rv_y = obj_a.vel[1] - obj_b.vel[1]

    a_part_list = get_my_parts(obj_a)
    a_part = a_part_list[ap_idx]
    b_part_list = get_my_parts(obj_b)
    b_part = b_part_list[bp_idx]

    if a_part.t == 0:
        if b_part.t == 0:
            circle_circle_vel(obj_a, a_part, obj_b, b_part, rv_x, rv_y)
        elif b_part.t == 1:
            raise ValueError("No point")
        elif b_part.t == 2:
            circle_line_vel(obj_a, a_part, obj_b, b_part, rv_x, rv_y)
    elif a_part.t == 1:
        raise ValueError("No point")
    elif a_part.t == 2:
        if b_part.t == 0:
            circle_line_vel(obj_b, b_part, obj_a, a_part, -rv_x, -rv_y)
        elif b_part.t == 2:
            raise ValueError("No line-line collision")
        else:
            raise ValueError("No point")


def get_mass_coeff(obj_a, obj_b):
    m_scale_1 = 2 * obj_b.mass / (obj_a.mass + obj_b.mass)
    if obj_a.static:
        m_scale_1 = 0.0
    elif obj_b.static:
        m_scale_1 = 2.0
    m_scale_2 = 2.0 - m_scale_1
    return m_scale_1, m_scale_2


def circle_circle_vel(obj_a, a_part, obj_b, b_part, rv_x, rv_y):
    # circle-circle collision, uses sqrt and div
    # Assume they collided right now
    # df_x = obj_a.pos[0] - obj_b.pos[0]
    # df_y = obj_a.pos[1] - obj_b.pos[1]
    df_x = a_part.x - b_part.x
    df_y = a_part.y - b_part.y
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


# def circle_point_vel(obj_a, obj_b, point_b, rv_x, rv_y):
#     df_x = obj_a.pos[0] - point_b.x
#     df_y = obj_a.pos[1] - point_b.y
#     df_sq = df_x * df_x + df_y * df_y

#     dot_rv_df = rv_x * df_x + rv_y * df_y

#     unit_dist_x = ELAS * df_x * dot_rv_df / df_sq
#     unit_dist_y = ELAS * df_y * dot_rv_df / df_sq

#     m_scale_1, m_scale_2 = get_mass_coeff(obj_a, obj_b)

#     obj_a.vel = (
#         obj_a.vel[0] - m_scale_1 * unit_dist_x,
#         obj_a.vel[1] - m_scale_1 * unit_dist_y,
#     )

#     obj_b.vel = (
#         obj_b.vel[0] + m_scale_2 * unit_dist_x,
#         obj_b.vel[1] + m_scale_2 * unit_dist_y,
#     )


def circle_line_vel(obj_a, a_part, obj_b, line_b, rv_x, rv_y):
    ln_a = line_b.y2 - line_b.y1
    ln_b = line_b.x1 - line_b.x2  # always positive
    ln_sq = ln_a * ln_a + ln_b * ln_b
    ln_len = sqrt(ln_sq)
    # line: Ax + By = 0, normal vector is (-A, B)

    # sign = 1.0 if (df_x * ln_y - df_y * ln_x) > 0 else -1.0
    dot_rv_df = rv_x * ln_a + rv_y * ln_b  # sign??
    # dot_sign = 1.0 if dot_rv_df > 0 else -1.0

    unit_dist_x = ELAS * ln_a * dot_rv_df / ln_sq
    unit_dist_y = ELAS * ln_b * dot_rv_df / ln_sq

    m_scale_1, m_scale_2 = get_mass_coeff(obj_a, obj_b)

    obj_a.vel = (
        obj_a.vel[0] - m_scale_1 * unit_dist_x,
        obj_a.vel[1] - m_scale_1 * unit_dist_y,
    )

    obj_b.vel = (
        obj_b.vel[0] + m_scale_2 * unit_dist_x,
        obj_b.vel[1] + m_scale_2 * unit_dist_y,
    )
