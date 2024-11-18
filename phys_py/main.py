from my_types import *
from input import load_obj_file
from render import render_objects
from simulate import (
    update_pos_vel,
    update_collision_vel,
    update_acc,
    debug_sim_time_update,
)
from collision import get_earliest_collision, debug_col_time_update


def main():
    info, obj_list = load_obj_file("test/sandbox.json")
    video = ResultVideo(info["name"])

    for fr in range(info["frame_count"]):
        if fr % 10 == 0:
            print(f"Frame {fr}")
        frame = render_objects(obj_list, fr)
        video.add_frame(frame)

        left_time = 1.0
        iterations = 0
        while left_time > FLOAT_EPS and iterations < MAX_COL_ITER:
            collide_pair = (-1, -1)
            collide_parts = (-1, -1)
            time_step = left_time
            if iterations < MAX_COL_ITER - 1:
                for i in range(len(obj_list)):
                    for j in range(i + 1, len(obj_list)):
                        does_collide, (t, i_part, j_part) = get_earliest_collision(
                            obj_list[i], obj_list[j]
                        )
                        if does_collide and 0 <= t < time_step:  # min time to collide
                            print(
                                f"Collision between {i}({i_part}) and {j}({j_part}) in {t} after {debug_col_time_update(0)}, {does_collide}"
                            )
                            time_step = t
                            collide_pair = (i, j)
                            collide_parts = (i_part, j_part)
            if collide_pair[0] == -1:
                update_pos_vel(obj_list, time_step)
            else:
                update_pos_vel(obj_list, time_step)
                update_collision_vel(
                    obj_list[collide_pair[0]],
                    obj_list[collide_pair[1]],
                    collide_parts[0],
                    collide_parts[1],
                )
                # print(f"left_time = {left_time}, wil do time_step = {time_step}")
            left_time -= time_step
            debug_col_time_update(time_step)
            debug_sim_time_update(time_step)
            iterations += 1

        update_acc(obj_list)
        # video.export_as_gif()

    video.export_as_gif()


if __name__ == "__main__":
    main()
