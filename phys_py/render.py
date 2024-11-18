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
    sx = int(start_x)
    sy = int(start_y)
    ex = int(end_x)
    ey = int(end_y)
    if sx != ex:
        if sx > ex:
            sx, ex = ex, sx
            sy, ey = ey, sy
        for hcount in range(sx, ex + 1):
            y = sy + (ey - sy) * (hcount - sx) / (ex - sx)
            if sy <= y <= ey or ey <= y <= sy:
                canvas.set_pixel(hcount, int(y), 1)
    if sy != ey:
        if sy > ey:
            sy, ey = ey, sy
            sx, ex = ex, sx
        for vcount in range(sy, ey + 1):
            x = sx + (ex - sx) * (vcount - sy) / (ey - sy)
            if sx <= x <= ex or ex <= x <= sx:
                canvas.set_pixel(int(x), vcount, 1)


def render_objects(objects, frame_idx):
    canvas = DrawFrame(f"frame_{frame_idx}")
    canvas.write_text(10, 10, f"Frame {frame_idx}")
    for obj in objects:
        # print(f"Rendering object {obj.index}")
        if obj.shape_type == 0:
            draw_circle(canvas, obj.pos[0], obj.pos[1], obj.params[0], obj.static)
        elif obj.shape_type == 1:
            sx = obj.pos[0]
            sy = obj.pos[1]
            ex = obj.pos[0] + obj.params[0]
            ey = obj.pos[1] + obj.params[1]
            draw_line(canvas, sx, sy, ex, sy)
            draw_line(canvas, ex, sy, ex, ey)
            draw_line(canvas, sx, ey, ex, ey)
            draw_line(canvas, sx, ey, sx, sy)
        elif obj.shape_type == 2:
            start_x = obj.pos[0]
            start_y = obj.pos[1]
            end_x = obj.pos[0] + obj.params[0]
            end_y = obj.pos[1] + obj.params[1]
            draw_line(canvas, start_x, start_y, end_x, end_y)
        else:
            raise ValueError("Unsupported shape type")
    # print("Rendering done\n")
    return canvas
