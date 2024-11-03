from my_types import *
from math import sqrt

# https://en.wikipedia.org/wiki/Collision_response


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


def when_does_collide(
    obj_i, obj_j
):  # return (does_collide, (time_to_collide, i_part, j_part))
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
            # does_collide3, t3 = circle_line
            does_collide, t, b_part = merge_coll_info([col0, col1])
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
    # circle-circle collision, uses sqrt
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
        r_sum_sq / rv_sq - min_dist_sq / rv_sq
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
