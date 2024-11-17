from my_types import *
from render import render_objects
from simulate import (
    update_pos_vel,
    update_collision_vel,
    update_acc,
    debug_sim_time_update,
)
from collision import get_earliest_collision, debug_col_time_update


def main():
    print("Hello, world!")

    video = ResultVideo("test")

    # circle at 30, 20 with radius 10
    obj0 = PhyiscalObject(0, 0, 10.0, 0.0, 1.0, (300.0, 60.0), (-3.2, -2.0))
    print(obj0)

    # circle at 100, 200 with radius 50
    obj1 = PhyiscalObject(1, 0, 50.0, 0.0, 10.0, (420.0, 200.0), (-2.0, -10.0))
    print(obj1)

    obj2 = PhyiscalObject(
        2, 0, 30.0, 0.0, 1000.0, (320.0, 300.0), (0.0, 0.0), static=True
    )
    print(obj2)

    obj3 = PhyiscalObject(
        3, 0, 20.0, 0.0, 1000.0, (225.0, 200.0), (0.0, 0.0), static=True
    )
    print(obj3)

    # line from 500, 320 to 620, 240
    obj4 = PhyiscalObject(
        4, 2, 120.0, -80.0, 1000.0, (450.0, 320.0), (0.0, 0.0), static=True
    )
    print(obj4)

    # line on left
    obj5 = PhyiscalObject(
        5, 2, 30.0, 30.0, 1000.0, (20.0, 250.0), (0.0, 0.0), static=True
    )
    print(obj5)

    # line from 100, 150 to 140, 100
    obj6 = PhyiscalObject(
        6, 2, 40.0, 50.0, 1000.0, (260.0, 100.0), (0.0, 0.0), static=True
    )
    print(obj6)

    # line on the right top
    obj7 = PhyiscalObject(
        7, 2, 120.0, 0.0, 1000.0, (500.0, 100.0), (0.0, 0.0), static=True
    )
    print(obj7)

    # rect
    obj8 = PhyiscalObject(
        8, 1, 100.0, 30.0, 50.0, (250.0, 100.0), (0.0, 0.0), static=False
    )
    print(obj8)

    # moving line
    obj9 = PhyiscalObject(
        9, 2, 50.0, 30.0, 0.5, (200.0, 40.0), (0.0, -10.0), static=False
    )
    print(obj9)

    obj_list = [obj0, obj1, obj2, obj3, obj4, obj5, obj7, obj8, obj9]

    for fr in range(120):
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
