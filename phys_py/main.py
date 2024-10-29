from my_types import *
from render import render_objects
from simulate import update_pos_vel, update_collision_vel
from collision import when_does_collide


def main():
    print("Hello, world!")

    video = ResultVideo("test")

    # circle at 30, 20 with radius 10
    obj0 = PhyiscalObject(
        0, 0.0, 10.0, 0.0, 1.0, (300.0, 60.0), (3.0, -2.0), (0.0, 1.0)
    )
    print(obj0)

    # circle at 100, 200 with radius 50
    obj1 = PhyiscalObject(
        1, 0.0, 50.0, 0.0, 10.0, (420.0, 200.0), (-2.0, -10.0), (0.0, 1.0)
    )
    print(obj1)

    obj2 = PhyiscalObject(
        2, 0.0, 30.0, 0.0, 1000.0, (320.0, 300.0), (0.0, 0.0), (0.0, 0.0), static=True
    )
    print(obj2)

    obj3 = PhyiscalObject(
        3, 0.0, 20.0, 0.0, 1000.0, (225.0, 200.0), (0.0, 0.0), (0.0, 0.0), static=True
    )
    print(obj2)

    obj_list = [obj0, obj1, obj2, obj3]

    for fr in range(100):
        if fr % 10 == 0:
            print(f"Frame {fr}")
        frame = render_objects(obj_list)
        video.add_frame(frame)

        left_time = 1.0
        while left_time > FLOAT_EPS:
            collide_pair = (-1, -1)
            time_step = left_time
            for i in range(len(obj_list)):
                for j in range(i + 1, len(obj_list)):
                    does_collide, t = when_does_collide(obj_list[i], obj_list[j])
                    if does_collide and 0 <= t < time_step:  # min time to collide
                        print(f"Collision between {i} and {j} in {t}, {does_collide}")
                        time_step = t
                        collide_pair = (i, j)
            if collide_pair[0] == -1:
                update_pos_vel(obj_list, time_step)
            else:
                update_pos_vel(obj_list, time_step)
                update_collision_vel(
                    obj_list[collide_pair[0]], obj_list[collide_pair[1]]
                )
                # print(f"left_time = {left_time}, wil do time_step = {time_step}")
            left_time -= time_step

    video.export_as_gif()


if __name__ == "__main__":
    main()
