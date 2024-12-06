from my_types import *
from math import sqrt

from pandas import DataFrame

global_time = 0.0
global_i = 0
global_j = 0
debug_info_list = []

CoR = SFIX16(ELAS)
ZERO = SFIX16(0.0)


def debug_sim_time_update(time_diff):
    global global_time
    global_time += time_diff.get_float()
    return global_time


def debug_set(obj_i, obj_j):
    global global_i
    global global_j
    global_i = obj_i.index
    global_j = obj_j.index
    df = DataFrame(debug_info_list)
    df.to_csv("result/debug_sim.csv")


def update_pos_vel(pos, vel, acc_y, time_step):
    ts = time_step.to_sfix32()  # this should have 12bit decimal
    pos_x = pos[0].add_wrap((vel[0].to_sfix32() * ts).to_sfix16())
    pos_y = pos[1].add_wrap((vel[1].to_sfix32() * ts).to_sfix16())

    vel_x = vel[0]
    vel_y = vel[1].add_wrap((acc_y.to_sfix32() * ts).to_sfix16())
    return (pos_x, pos_y), (vel_x, vel_y)


def update_all_pos_vel(objects, time_step):
    # ts should have 12bit decimal
    for obj in objects:
        new_pos, new_vel = update_pos_vel(obj.pos, obj.vel, obj.acc[1], time_step)
        obj.pos = new_pos
        obj.vel = new_vel


def check_inactive(objects):
    for obj in objects:
        if obj.active:
            vert_out = obj.pos[1] >= ZERO.max_rep() or obj.pos[1] <= ZERO.min_rep()
            horz_out = obj.pos[0] >= ZERO.max_rep() or obj.pos[0] <= ZERO.min_rep()
            if vert_out or horz_out:
                print(f"Object {obj.index} is out of bounds")
                obj.active = False


def update_acc(objects):
    for obj in objects:
        obj.acc = (ZERO, ZERO)
        if not obj.static:
            obj.acc = (ZERO, SFIX16(GRAVITY))


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
    m_scale_1 = SFIX16(0.0)
    if obj_a.static:
        m_scale_1 = SFIX16(0.0)
    elif obj_b.static:
        m_scale_1 = SFIX16(2.0)
    else:
        m_scale_1 = (SFIX16(2.0) * obj_b.mass).to_sfix16() / (obj_a.mass + obj_b.mass)
    m_scale_2 = SFIX16(2.0) - m_scale_1
    return m_scale_1, m_scale_2


def circle_circle_vel(obj_a, a_part, obj_b, b_part, rv_x, rv_y):
    # circle-circle collision, uses sqrt and div
    # Assume they collided right now
    # df_x = obj_a.pos[0] - obj_b.pos[0]
    # df_y = obj_a.pos[1] - obj_b.pos[1]
    df_x = a_part.x - b_part.x
    df_y = a_part.y - b_part.y
    df_sq = (df_x * df_x + df_y * df_y).to_sfix32()

    dot_rv_df = (rv_x * df_x + rv_y * df_y).to_sfix32()

    unit_dist_x = (
        (CoR * df_x).to_sfix16() * (dot_rv_df / df_sq).to_sfix16()
    ).to_sfix16()
    unit_dist_y = (
        (CoR * df_y).to_sfix16() * (dot_rv_df / df_sq).to_sfix16()
    ).to_sfix16()

    m_scale_1, m_scale_2 = get_mass_coeff(obj_a, obj_b)

    obj_a.vel = (
        obj_a.vel[0] - (m_scale_1 * unit_dist_x).to_sfix16(),
        obj_a.vel[1] - (m_scale_1 * unit_dist_y).to_sfix16(),
    )

    obj_b.vel = (
        obj_b.vel[0] + (m_scale_2 * unit_dist_x).to_sfix16(),
        obj_b.vel[1] + (m_scale_2 * unit_dist_y).to_sfix16(),
    )


def circle_line_vel(obj_a, a_part, obj_b, line_b, rv_x, rv_y):
    ln_a = line_b.y2 - line_b.y1
    ln_b = line_b.x1 - line_b.x2  # always positive
    ln_sq = (ln_a * ln_a + ln_b * ln_b).to_sfix32()
    # line: Ax + By = 0, normal vector is (-A, B)

    # sign = 1.0 if (df_x * ln_y - df_y * ln_x) > 0 else -1.0
    dot_rv_df = (rv_x * ln_a + rv_y * ln_b).to_sfix32()  # sign??
    # dot_sign = 1.0 if dot_rv_df > 0 else -1.0

    unit_dist_x = (
        (((CoR * ln_a).to_sfix32() * dot_rv_df).to_sfix32() / ln_sq).to_sfix16()
    ).to_sfix32()
    unit_dist_y = (
        (((CoR * ln_b).to_sfix32() * dot_rv_df).to_sfix32() / ln_sq).to_sfix16()
    ).to_sfix32()

    m_scale_1, m_scale_2 = get_mass_coeff(obj_a, obj_b)
    m_scale_1 = m_scale_1.to_sfix32()
    m_scale_2 = m_scale_2.to_sfix32()

    obj_a.vel = (
        obj_a.vel[0] - (m_scale_1 * unit_dist_x).to_sfix16(),  # 32bit * 32bit -> 16bit
        obj_a.vel[1] - (m_scale_1 * unit_dist_y).to_sfix16(),
    )

    obj_b.vel = (
        obj_b.vel[0] + (m_scale_2 * unit_dist_x).to_sfix16(),
        obj_b.vel[1] + (m_scale_2 * unit_dist_y).to_sfix16(),
    )
