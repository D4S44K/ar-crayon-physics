from my_types import *
from math import sqrt

# https://en.wikipedia.org/wiki/Collision_response

from pandas import DataFrame

global_time = 0.0
global_i = 0
global_j = 0
debug_info_list = []


def merge_coll_info(c_list):
    does_col = False
    c_time = 1.0
    c_idx = -1
    for i, c in enumerate(c_list):
        if c[0] and 0 <= c[1] < c_time:
            does_col = True
            c_time = c[1]
            c_idx = i
    return does_col, c_time, c_idx


def debug_col_time_update(time_diff):
    global global_time
    global_time += time_diff
    return global_time


def debug_set(obj_i, obj_j):
    global global_i
    global global_j
    global_i = obj_i.index
    global_j = obj_j.index
    df = DataFrame(debug_info_list)
    df.to_csv("result/debug_col.csv")


def when_does_collide(
    obj_i, obj_j
):  # return (does_collide, (time_to_collide, i_part, j_part))
    debug_set(obj_i, obj_j)
    if obj_i.static and obj_j.static:
        return False, (1.0, 0, 0)
    do_swap = obj_i.shape_type > obj_j.shape_type
    if do_swap:
        obj_a, obj_b = obj_j, obj_i
    else:
        obj_a, obj_b = obj_i, obj_j
    # always a.type <= b.type

    rv_x = obj_a.vel[0] - obj_b.vel[0]  # a goes to b
    rv_y = obj_a.vel[1] - obj_b.vel[1]

    if obj_a.shape_type == 0:
        (circle_a,) = get_my_parts(obj_a)
        if obj_b.shape_type == 0:
            (circle_b,) = get_my_parts(obj_b)
            does_collide, t = circle_circle_collision(circle_a, circle_b, rv_x, rv_y)
            return does_collide, (t, 0, 0)
        elif obj_b.shape_type == 1:
            pass
        elif obj_b.shape_type == 2:
            (point_b1, point_b2, line_b) = get_my_parts(obj_b)
            col0 = circle_point_collision(circle_a, point_b1, rv_x, rv_y)
            col1 = circle_point_collision(circle_a, point_b2, rv_x, rv_y)
            col2 = circle_line_collision(circle_a, line_b, rv_x, rv_y)
            does_collide, t, b_part = merge_coll_info([col0, col1, col2])
            if do_swap:
                return does_collide, (t, b_part, 0)
            else:
                return does_collide, (t, 0, b_part)
    elif obj_a.shape_type == 1:  # rectangle
        pass
    elif obj_a.shape_type == 2:  # line
        if obj_b.shape_type == 2:
            # return
            pass

    raise ValueError(f"Unsupported shape type {obj_a.shape_type} or {obj_b.shape_type}")


def circle_point_collision(circle, point, rv_x, rv_y):
    # circle-point collision, uses sqrt -> simplify?
    r_sum = circle.r
    r_sum_sq = r_sum * r_sum
    df_x = point.x - circle.x
    df_y = point.y - circle.y
    df_sq = df_x * df_x + df_y * df_y

    if -FLOAT_EPS < rv_x < FLOAT_EPS and -FLOAT_EPS < rv_y < FLOAT_EPS:
        return False, 1.1
    rv_sq = rv_x * rv_x + rv_y * rv_y

    # distance to go in rv's direction: rv_dist = dot(rv, df) / |rv|
    # time to reach that distance: t = rv_dist / |rv| = dot(rv, df) / |rv|^2
    dot_rv_df = rv_x * df_x + rv_y * df_y
    min_dist_t = dot_rv_df / rv_sq  # INSTR: div
    if min_dist_t < 0:  # wrong direction
        return False, 1.2

    # distance between centers at that time: min_dist^2 = |df|^2 - |rv_dist|^2
    # do they overlap at that time: min_dist^2 <= r_sum^2
    min_dist_sq = df_sq - dot_rv_df * dot_rv_df / rv_sq  # INSTR: div
    if min_dist_sq > r_sum_sq + FLOAT_EPS:  # too far apart
        return False, 1.3

    # actual collision distance: dist = rv_dist - sqrt(r_sum^2 - min_dist^2)
    # time to reach that distance: t = dist / |rv| = dot(rv, df) / |rv|^2 - sqrt(r_sum^2 - |min_dist|^2)) / |rv| = min_dist_t - sqrt(r_sum^2 - |min_dist|^2) / |rv|
    col_t = min_dist_t - sqrt(
        max(0, r_sum_sq / rv_sq - min_dist_sq / rv_sq)
    )  # INSTR: div, sqrt

    return True, col_t


def circle_circle_collision(circle_a, circle_b, rv_x, rv_y):
    # circle-circle collision, uses sqrt
    r_sum = circle_a.r + circle_b.r
    r_sum_sq = r_sum * r_sum
    df_x = circle_b.x - circle_a.x
    df_y = circle_b.y - circle_a.y
    df_sq = df_x * df_x + df_y * df_y

    if -FLOAT_EPS < rv_x < FLOAT_EPS and -FLOAT_EPS < rv_y < FLOAT_EPS:
        return False, 1.1
    rv_sq = rv_x * rv_x + rv_y * rv_y

    # distance to go in rv's direction: rv_dist = dot(rv, df) / |rv|
    # time to reach that distance: t = rv_dist / |rv| = dot(rv, df) / |rv|^2
    dot_rv_df = rv_x * df_x + rv_y * df_y
    min_dist_t = dot_rv_df / rv_sq  # INSTR: div
    if min_dist_t < 0:  # wrong direction
        return False, 1.2

    # distance between centers at that time: min_dist^2 = |df|^2 - |rv_dist|^2
    # do they overlap at that time: min_dist^2 <= r_sum^2
    min_dist_sq = df_sq - dot_rv_df * dot_rv_df / rv_sq  # INSTR: div
    if min_dist_sq > r_sum_sq + FLOAT_EPS:  # too far apart
        return False, 1.3

    # actual collision distance: dist = rv_dist - sqrt(r_sum^2 - min_dist^2)
    # time to reach that distance: t = dist / |rv| = dot(rv, df) / |rv|^2 - sqrt(r_sum^2 - |min_dist|^2)) / |rv| = min_dist_t - sqrt(r_sum^2 - |min_dist|^2) / |rv|
    col_t = min_dist_t - sqrt(
        r_sum_sq / rv_sq - min_dist_sq / rv_sq
    )  # INSTR: div, sqrt

    return True, col_t


def circle_line_collision(circle, line, rv_x, rv_y):
    df_x = circle.x - line.x1
    df_y = circle.y - line.y1

    ln_a = line.y2 - line.y1
    ln_b = line.x1 - line.x2  # always positive
    ln_sq = ln_a * ln_a + ln_b * ln_b
    ln_len = sqrt(ln_sq)
    # line: Ax + By = 0

    # TODO reduce div... and consider /0 error
    sdist_now = (ln_a * df_x + ln_b * df_y) / ln_len
    sdist_1s = (ln_a * (df_x + rv_x) + ln_b * (df_y + rv_y)) / ln_len

    neg_btw = (sdist_now < -circle.r) and (sdist_1s >= -circle.r)
    pos_btw = (sdist_now > circle.r) and (sdist_1s <= circle.r)
    if not neg_btw and not pos_btw:
        return False, 1.0

    rv_dot = -(rv_x * ln_a + rv_y * ln_b)
    if neg_btw:
        col_t = (sdist_now + circle.r) * ln_len / rv_dot
    else:
        col_t = (sdist_now - circle.r) * ln_len / rv_dot
    # check if collision is in range of segment
    # parallel vector: (-B, A)
    # ln_end_p = -(line.x2 - line.x1) * ln_b + (line.y2 - line.y1) * ln_a # is equal to ln_sq
    col_p = -(df_x + rv_x * col_t) * ln_b + (df_y + rv_y * col_t) * ln_a

    if (col_p > 0) == (col_p > ln_sq):
        return False, 1.0

    return True, col_t
