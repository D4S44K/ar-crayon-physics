from my_types import *


def draw_circle(canvas, center_x, center_y, r):
    rsq_down = r * r
    rsq_up = (r + 1) * (r + 1)
    for hcount in range(
        int(center_x - r - 10), int(center_x + r + 10)
    ):  # make this shorter
        for vcount in range(int(center_y - r - 10), int(center_y + r + 10)):
            if hcount < 0 or hcount >= WIDTH:
                continue
            if vcount < 0 or vcount >= HEIGHT:
                continue
            df_x = hcount - center_x
            df_y = vcount - center_y
            if rsq_down <= df_x * df_x + df_y * df_y <= rsq_up:
                canvas.set_pixel(hcount, vcount, 1)


def render_objects(objects):
    canvas = DrawFrame("test")
    for obj in objects:
        # print(f"Rendering object {obj.index}")
        if obj.shape_type == 0:
            draw_circle(canvas, obj.pos[0], obj.pos[1], obj.size_1)
        else:
            raise ValueError("Unsupported shape type")
    # print("Rendering done\n")
    return canvas
