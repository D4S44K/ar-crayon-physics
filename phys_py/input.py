import json
from my_types import *

TEST_PATH = "./test/"


def get_type_int(type_str):
    if type_str == "circle":
        return 0
    elif type_str == "rect":
        return 1
    elif type_str == "line":
        return 2
    else:
        raise ValueError(f"Unsupported shape type {type_str}")


def load_obj_file(file_path):
    obj_list = []
    info = {}
    with open(file_path, "r") as file:
        data = json.load(file)
        info["name"] = data["name"]
        info["CoR"] = data["CoR"]
        info["gravity"] = data["gravity"]
        info["frame_count"] = data["frame_count"]
        print(f"Loaded simulation {info}")

        for obj in data["objects"]:
            if obj["skip"]:
                continue
            type_int = get_type_int(obj["shape_type"])
            mass = obj["mass"]
            pos = tuple(obj["position"])
            vel = tuple(obj["velocity"])
            static = obj["static"]
            params = tuple(obj["params"])
            cur_obj = PhyiscalObject(
                len(obj_list), type_int, mass, pos, vel, static, params
            )
            print(f"Loaded {cur_obj}")
            obj_list.append(cur_obj)

    return info, obj_list
