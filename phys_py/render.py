from my_types import *


def draw_circle(canvas, center_x, center_y, r, fill=False):
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
            if fill:
                if df_x * df_x + df_y * df_y <= rsq_up:
                    canvas.set_pixel(hcount, vcount, 1)
            else:
                if rsq_down <= df_x * df_x + df_y * df_y <= rsq_up:
                    canvas.set_pixel(hcount, vcount, 1)


def draw_line(canvas, start_x, start_y, end_x, end_y):
    for hcount in range(int(start_x), int(end_x)):
        y = start_y + (end_y - start_y) * (hcount - start_x) / (end_x - start_x)
        canvas.set_pixel(hcount, int(y), 1)
    sy = min(start_y, end_y)
    ey = max(start_y, end_y)
    for vcount in range(int(sy), int(ey)):
        x = start_x + (end_x - start_x) * (vcount - start_y) / (end_y - start_y)
        canvas.set_pixel(int(x), vcount, 1)


def render_objects(objects, frame_idx):
    canvas = DrawFrame(f"frame_{frame_idx}")
    canvas.write_text(10, 10, f"Frame {frame_idx}")
    for obj in objects:
        # print(f"Rendering object {obj.index}")
        if obj.shape_type == 0:
            draw_circle(canvas, obj.pos[0], obj.pos[1], obj.size_1, obj.static)
        elif obj.shape_type == 1:
            pass
        elif obj.shape_type == 2:
            start_x = obj.pos[0]
            start_y = obj.pos[1]
            end_x = obj.size_1
            end_y = obj.size_2
            draw_line(canvas, start_x, start_y, end_x, end_y)
        else:
            raise ValueError("Unsupported shape type")
    # print("Rendering done\n")
    return canvas
