from PIL import Image


WIDTH = 640
HEIGHT = 360
PATH = "./result/"
ELAS = 0.7
FLOAT_EPS = 1 / 2**13


class PhyiscalObject:
    def shape_type_str(self):
        if self.shape_type == 0:
            return "circle"
        elif self.shape_type == 1:
            return "rectangle"
        else:
            print("Unknown shape type")
            return "unknown"

    def __init__(
        self,
        index,
        shape_type,
        size_1,
        size_2,
        mass,
        position,
        velocity,
        acceleration,
        static=False,
    ):
        # index: [4:0]
        # shape_type: [2:0]
        # size_1: [9:0]
        # size_2: [9:0]
        # mass: [7:0]

        # static: [0]
        # position: [31:0] (16bit float x2)
        # velocity: [31:0] (16bit float x2)
        # acceleration: [31:0] (16bit float x2)
        if index >= 32:
            print("Index out of range")
            return None
        self.index = index
        self.shape_type = shape_type
        self.size_1 = size_1
        self.size_2 = size_2

        self.static = static
        self.mass = mass
        self.pos = position
        self.vel = velocity
        self.acc = acceleration

    def __str__(self):
        res = f"Object {self.index:02d} : "
        if self.shape_type == 0:
            res += f"cicle, radius = {self.size_1}, "
        elif self.shape_type == 1:
            res += f"rectangle, size = {self.size_1}x{self.size_2}, "
        else:
            raise ValueError("Unknown shape type")
        res += f"mass = {self.mass}, "
        res += f"position = ({self.pos[0]:8.3f}, {self.pos[1]:8.3f}), "
        if self.static:
            res += "static"
        else:
            res += f"velocity = ({self.vel[0]:8.3f}, {self.vel[1]:8.3f}), "
            res += f"acceleration = ({self.acc[0]:8.3f}, {self.acc[1]:8.3f})"
        return res


class DrawFrame:
    def __init__(self, name):
        self.name = name
        self.image = Image.new("1", (WIDTH, HEIGHT), 0)

    def __str__(self):
        return f"DrawFrame {self.name}"

    def set_pixel(self, x, y, value):
        self.image.putpixel((x, y), value)

    def get_pixel(self, x, y):
        return self.image.getpixel((x, y))

    def export(self, filename="output.png"):
        self.image.save(PATH + filename)
        print(f"Exported {filename}")


class ResultVideo:
    def __init__(self, name):
        self.name = name
        self.frames = []

    def add_frame(self, frame):
        self.frames.append(frame)

    def export_as_gif(self, duration=100):
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
            loop=1,
        )
        print(f"Exported {filename}.gif")
