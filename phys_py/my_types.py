from PIL import Image, ImageDraw
from primitives import SFIX16, SFIX32


WIDTH = 640
HEIGHT = 360
PATH = "./result/"
ELAS = 0.7
FLOAT_EPS = 1 / 2**13
GRAVITY = 1.0
MAX_COL_ITER = 64


class PhyiscalObject:
    def shape_type_str(self):
        if self.shape_type == 0:
            return "circle"
        elif self.shape_type == 1:
            return "rectangle"
        elif self.shape_type == 2:
            return "line"
        else:
            print("Unknown shape type")
            return "unknown"

    def __init__(
        self,
        index,
        shape_type,
        mass,
        position,
        velocity,
        static=False,
        params=(),
    ):
        # index: [4:0]
        # shape_type: [2:0]
        # params: [47:0] (16bit float x3, max)
        # mass: [7:0]

        # static: [0]
        # position: [31:0] (16bit float x2)
        # velocity: [31:0] (16bit float x2)
        if index >= 32:
            print("Index out of range")
            return None
        self.active = True
        self.index = index
        self.shape_type = shape_type
        self.params = [SFIX16(p) for p in params]

        self.static = static
        self.mass = SFIX16(mass)
        self.pos = (SFIX16(position[0]), SFIX16(position[1]))
        self.vel = (SFIX16(velocity[0]), SFIX16(velocity[1]))
        if self.static:
            self.acc = (SFIX16(0.0), SFIX16(0.0))
        else:
            self.acc = (SFIX16(0.0), SFIX16(GRAVITY))

    def __str__(self):
        res = f"Object {self.index:02d} : "
        if self.shape_type == 0:
            res += f"cicle, radius = {self.params[0]}, "
        elif self.shape_type == 1:
            res += f"rectangle, vector = ({self.params[0]}, {self.params[1]}),  (?, {self.params[2]}), "
        elif self.shape_type == 2:
            res += f"line, vector = ({self.params[0]}, {self.params[1]}), "
        else:
            raise ValueError("Unknown shape type")
        res += f"mass = {self.mass}, "
        res += f"position = ({self.pos[0]}, {self.pos[1]}), "
        if self.static:
            res += "static"
        else:
            res += f"velocity = ({self.vel[0]}, {self.vel[1]}), "
            res += f"acceleration = ({self.acc[0]}, {self.acc[1]})"
        return res


class circle:
    def __init__(self, x, y, r):
        self.t = 0
        self.x = x
        self.y = y
        self.r = r

    def __str__(self):
        return f"circle at ({self.x}, {self.y}) with radius {self.r}"


# class point:
#     def __init__(self, x, y):
#         self.t = 1
#         self.x = x
#         self.y = y

#     def __str__(self):
#         return f"point at ({self.x}, {self.y})"


class line:
    def __init__(self, x1, y1, x2, y2):
        self.t = 2
        self.x1 = x1
        self.y1 = y1
        self.x2 = x2
        self.y2 = y2

    def __str__(self):
        return f"line from ({self.x1}, {self.y1}) to ({self.x2}, {self.y2})"


def get_my_parts(obj):  # return tuple
    if obj.shape_type == 0:
        return (circle(obj.pos[0], obj.pos[1], obj.params[0]),)
    elif obj.shape_type == 1:
        # point_1 = point(obj.pos[0], obj.pos[1])
        px, py = obj.pos[0], obj.pos[1]
        dx1, dy1 = obj.params[0], obj.params[1]
        dy2 = obj.params[2]
        dx2 = (-dy1 / dx1 * dy2).to_sfix16()
        point_1 = circle(px, py, SFIX16(0.0))
        point_2 = circle(px + dx1, py + dy1, SFIX16(0.0))
        point_3 = circle(px + dx1 + dx2, py + dy1 + dy2, SFIX16(0.0))
        point_4 = circle(px + dx2, py + dy2, SFIX16(0.0))
        line_1 = line(point_1.x, point_1.y, point_2.x, point_2.y)
        line_2 = line(point_2.x, point_2.y, point_3.x, point_3.y)
        line_3 = line(point_3.x, point_3.y, point_4.x, point_4.y)
        line_4 = line(point_4.x, point_4.y, point_1.x, point_1.y)
        return (point_1, point_2, point_3, point_4, line_1, line_2, line_3, line_4)
    elif obj.shape_type == 2:
        point_1 = circle(obj.pos[0], obj.pos[1], SFIX16(0.0))
        point_2 = circle(
            obj.pos[0] + obj.params[0], obj.pos[1] + obj.params[1], SFIX16(0.0)
        )
        line_ = line(point_1.x, point_1.y, point_2.x, point_2.y)
        return (point_1, point_2, line_)
    else:
        raise ValueError("Unsupported shape type")


class DrawFrame:
    def __init__(self, name):
        self.name = name
        self.image = Image.new("1", (WIDTH, HEIGHT), 0)
        self.draw = ImageDraw.Draw(self.image)

    def __str__(self):
        return f"DrawFrame {self.name}"

    def set_pixel(self, x, y, value, check=True):
        if check:
            if x < 0 or x >= WIDTH:
                return
            if y < 0 or y >= HEIGHT:
                return
        self.image.putpixel((x, y), value)

    def get_pixel(self, x, y):
        return self.image.getpixel((x, y))

    def write_text(self, x, y, text):
        self.draw.text((x, y), text, fill=1)

    def export(self, filename="output.png"):
        self.image.save(PATH + filename)
        print(f"Exported {filename}")


class ResultVideo:
    def __init__(self, name):
        self.name = name
        self.frames = []

    def add_frame(self, frame):
        self.frames.append(frame)

    def export_as_gif(self, duration=50):
        if not self.frames:
            print("No frames to export")
            return

        filename = PATH + self.name

        # Convert frames to PIL Images
        pil_frames = [
            frame.image for frame in self.frames if isinstance(frame.image, Image.Image)
        ]

        # Save as GIF
        pil_frames[0].save(
            f"{filename}.gif",
            save_all=True,
            append_images=pil_frames[1:],
            duration=duration,
            loop=0,
        )
        print(f"Exported {filename}.gif")
