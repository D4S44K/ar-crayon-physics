from my_types import *
from math import sqrt

# https://en.wikipedia.org/wiki/Collision_response

from pandas import DataFrame

global_time = 0.0
global_i = 0
global_j = 0
debug_info_list = []


def my_sqrt(x):
    if x < 0:
        print(f"WARN: sqrt({x})")
        return 0
    return sqrt(x)


def merge_coll_info(c_list):
    does_col = False
    c_time = 1.0
    ap_idx = -1
    bp_idx = -1

    for hit, col_t, ai, bi in c_list:
        if hit and 0.0 <= col_t < c_time:
            does_col = True
            c_time = col_t
            ap_idx = ai
            bp_idx = bi

    return does_col, c_time, ap_idx, bp_idx


def debug_col_time_update(time_diff):
    global global_time
    global_time += time_diff.get_float()
    return global_time


def debug_set(obj_i, obj_j):
    global global_i
    global global_j
    global_i = obj_i.index
    global_j = obj_j.index
    df = DataFrame(debug_info_list)
    df.to_csv("result/debug_col.csv")


def get_earliest_collision(
    obj_a, obj_b
):  # return (does_collide, (time_to_collide, i_part, j_part))
    debug_set(obj_a, obj_b)
    if obj_a.static and obj_b.static:
        return False, (SFIX32(0.0), 0, 0)
    # always a.type <= b.type

    rv_x = obj_a.vel[0] - obj_b.vel[0]  # a goes to b
    rv_y = obj_a.vel[1] - obj_b.vel[1]

    a_parts = get_my_parts(obj_a)
    b_parts = get_my_parts(obj_b)

    col_info_list = []
    for ap_idx, a_part in enumerate(a_parts):
        for bp_idx, b_part in enumerate(b_parts):
            hit, col_t = get_collision(a_part, b_part, rv_x, rv_y)
            col_info_list.append((hit, col_t, ap_idx, bp_idx))
    does_collide, t, ap_idx, bp_idx = merge_coll_info(col_info_list)

    return does_collide, (t, ap_idx, bp_idx)


def get_collision(part_a, part_b, rv_x, rv_y):
    if part_a.t == 0:
        if part_b.t == 0:
            return circle_circle_collision(part_a, part_b, rv_x, rv_y)
        elif part_b.t == 1:
            raise ValueError("No point")
        elif part_b.t == 2:
            return circle_line_collision(part_a, part_b, rv_x, rv_y)
    elif part_a.t == 1:
        raise ValueError("No point")
    elif part_a.t == 2:
        if part_b.t == 0:
            return circle_line_collision(part_b, part_a, -rv_x, -rv_y)
        elif part_b.t == 2:
            return False, SFIX32(1.0)  # no line-line collision
        else:
            raise ValueError("No point")
    else:
        raise ValueError(f"Unsupported shape type {part_a.t} or {part_b.t}")


# def circle_point_collision(circle, point, rv_x, rv_y):
#     # circle-point collision, uses sqrt -> simplify?
#     r_sum = circle.r
#     r_sum_sq = r_sum * r_sum
#     df_x = point.x - circle.x
#     df_y = point.y - circle.y
#     df_sq = df_x * df_x + df_y * df_y

#     if -FLOAT_EPS < rv_x < FLOAT_EPS and -FLOAT_EPS < rv_y < FLOAT_EPS:
#         return False, 1.1
#     rv_sq = rv_x * rv_x + rv_y * rv_y

#     # distance to go in rv's direction: rv_dist = dot(rv, df) / |rv|
#     # time to reach that distance: t = rv_dist / |rv| = dot(rv, df) / |rv|^2
#     dot_rv_df = rv_x * df_x + rv_y * df_y
#     min_dist_t = dot_rv_df / rv_sq  # INSTR: div
#     if min_dist_t < 0:  # wrong direction
#         return False, 1.2

#     # distance between centers at that time: min_dist^2 = |df|^2 - |rv_dist|^2
#     # do they overlap at that time: min_dist^2 <= r_sum^2
#     min_dist_sq = df_sq - dot_rv_df * dot_rv_df / rv_sq  # INSTR: div
#     if min_dist_sq > r_sum_sq + FLOAT_EPS:  # too far apart
#         return False, 1.3

#     # actual collision distance: dist = rv_dist - sqrt(r_sum^2 - min_dist^2)
#     # time to reach that distance: t = dist / |rv| = dot(rv, df) / |rv|^2 - sqrt(r_sum^2 - |min_dist|^2)) / |rv| = min_dist_t - sqrt(r_sum^2 - |min_dist|^2) / |rv|
#     col_t = min_dist_t - sqrt(
#         max(0, r_sum_sq / rv_sq - min_dist_sq / rv_sq)
#     )  # INSTR: div, sqrt

#     return True, col_t


def circle_circle_collision(circle_a, circle_b, rv_x, rv_y):
    # circle-circle collision, uses sqrt
    r_sum = circle_a.r + circle_b.r
    r_sum_sq = (r_sum * r_sum).to_sfix32()
    df_x = circle_b.x - circle_a.x
    df_y = circle_b.y - circle_a.y
    df_sq = (df_x * df_x + df_y * df_y).to_sfix32()

    if rv_x == 0.0 and rv_y == 0.0:
        return False, SFIX32(1.1)
    rv_sq = (rv_x * rv_x + rv_y * rv_y).to_sfix32()

    # distance to go in rv's direction: rv_dist = dot(rv, df) / |rv|
    # time to reach that distance: t = rv_dist / |rv| = dot(rv, df) / |rv|^2
    dot_rv_df = (rv_x * df_x + rv_y * df_y).to_sfix32()
    min_dist_t = dot_rv_df / rv_sq  # INSTR: div
    if min_dist_t < 0.0:  # wrong direction
        return False, SFIX32(1.2)

    # distance between centers at that time: min_dist^2 = |df|^2 - |rv_dist|^2
    # do they overlap at that time: min_dist^2 <= r_sum^2
    # EWW....
    min_dist_sq = (
        df_sq
        - (
            dot_rv_df.convert(True, 13, 4) * (dot_rv_df / rv_sq).convert(True, 13, 4)
        ).to_sfix32()
    )  # INSTR: div
    if min_dist_sq > r_sum_sq:  # too far apart
        return False, SFIX32(1.3)

    # actual collision distance: dist = rv_dist - sqrt(r_sum^2 - min_dist^2)
    # time to reach that distance: t = dist / |rv| = dot(rv, df) / |rv|^2 - sqrt(r_sum^2 - |min_dist|^2)) / |rv| = min_dist_t - sqrt(r_sum^2 - |min_dist|^2) / |rv|
    col_t = min_dist_t - ((r_sum_sq - min_dist_sq) / rv_sq).sqrt()  # INSTR: div, sqrt

    return True, col_t


def circle_line_collision(circle, line, rv_x, rv_y):
    rad = circle.r.to_sfix32()
    df_x = circle.x - line.x1
    df_y = circle.y - line.y1

    ln_a = line.y2 - line.y1
    ln_b = line.x1 - line.x2  # always positive
    ln_sq = (ln_a * ln_a + ln_b * ln_b).to_sfix32()
    ln_len = (ln_sq).sqrt()
    # line: Ax + By = 0

    # TODO reduce div... and consider /0 error
    sdist_now = (ln_a * df_x + ln_b * df_y).to_sfix32() / ln_len
    sdist_1s = (
        ln_a * (df_x + rv_x) + ln_b * (df_y + rv_y)
    ).to_sfix32() / ln_len  # Can be skipped?

    neg_btw = (sdist_now < -rad) and (sdist_1s >= -rad)
    pos_btw = (sdist_now > rad) and (sdist_1s <= rad)
    if not neg_btw and not pos_btw:
        return False, SFIX32(1.0)

    rv_dot = -(rv_x * ln_a + rv_y * ln_b).to_sfix32()
    if neg_btw:
        col_t = (sdist_now + rad).to_sfix16() * (ln_len / rv_dot).to_sfix16()
    else:
        col_t = (sdist_now - rad).to_sfix16() * (ln_len / rv_dot).to_sfix16()
    col_t = col_t.to_sfix32()
    # check if collision is in range of segment
    # parallel vector: (-B, A)
    # ln_end_p = -(line.x2 - line.x1) * ln_b + (line.y2 - line.y1) * ln_a # is equal to ln_sq
    col_p = (
        -(df_x + rv_x) * ln_b + (df_y + rv_y) * ln_a
    ).to_sfix16() * col_t.to_sfix16()
    col_p = col_p.to_sfix32()

    if (col_p > 0.0) == (col_p > ln_sq):
        return False, SFIX32(1.0)

    return True, col_t
