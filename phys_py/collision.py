from my_types import *
from math import sqrt

# https://en.wikipedia.org/wiki/Collision_response


def when_does_collide(obj_a, obj_b):  # 1/2^13
    if obj_a.shape_type != 0 or obj_b.shape_type != 0:
        raise ValueError("Unsupported shape type")
    # circle-circle collision, uses sqrt
    r_sum = obj_a.size_1 + obj_b.size_1
    r_sum_sq = r_sum * r_sum
    df_x = obj_b.pos[0] - obj_a.pos[0]
    df_y = obj_b.pos[1] - obj_a.pos[1]
    df_sq = df_x * df_x + df_y * df_y

    rv_x = obj_a.vel[0] - obj_b.vel[0]
    rv_y = obj_a.vel[1] - obj_b.vel[1]
    rv_sq = rv_x * rv_x + rv_y * rv_y
    if -FLOAT_EPS < rv_x < FLOAT_EPS and -FLOAT_EPS < rv_y < FLOAT_EPS:
        return False, 1.0

    # distance to go in rv's direction: rv_dist = dot(rv, df) / |rv|
    # time to reach that distance: t = rv_dist / |rv| = dot(rv, df) / |rv|^2
    dot_rv_df = rv_x * df_x + rv_y * df_y
    min_dist_t = dot_rv_df / rv_sq  # INSTR: div
    if min_dist_t < 0:  # wrong direction
        return False, 1.0

    # distance between centers at that time: min_dist^2 = |df|^2 - |rv_dist|^2
    # do they overlap at that time: min_dist^2 <= r_sum^2
    min_dist_sq = df_sq - dot_rv_df * dot_rv_df / rv_sq  # INSTR: div
    if min_dist_sq > r_sum_sq + FLOAT_EPS:  # too far apart
        return False, 1.0

    # actual collision distance: dist = rv_dist - sqrt(r_sum^2 - min_dist^2)
    # time to reach that distance: t = dist / |rv| = dot(rv, df) / |rv|^2 - sqrt(r_sum^2 - |min_dist|^2)) / |rv| = min_dist_t - sqrt(r_sum^2 - |min_dist|^2) / |rv|
    col_t = min_dist_t - sqrt(
        r_sum_sq / rv_sq - min_dist_sq / rv_sq
    )  # INSTR: div, sqrt

    return True, col_t
