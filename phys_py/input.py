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


def load_object(obj, index):
    if obj.get("skip", False):
        return
    type_int = get_type_int(obj["shape_type"])
    mass = obj.get("mass", 1.0)
    pos = tuple(obj["position"])
    vel = tuple(obj["velocity"])
    static = obj["static"]
    params = tuple(obj["params"])
    cur_obj = PhyiscalObject(index, type_int, mass, pos, vel, static, params)
    return cur_obj


def get_object(cur_obj):
    # if cur_obj.active == False: # TODO
    #     return {}
    obj = {}
    obj["static"] = cur_obj.static
    obj["shape_type"] = ["circle", "rect", "line"][cur_obj.shape_type]
    # obj["mass"] = cur_obj
    obj["position"] = [cur_obj.pos[0].get_float(), cur_obj.pos[1].get_float()]
    obj["velocity"] = [cur_obj.vel[0].get_float(), cur_obj.vel[1].get_float()]
    obj["params"] = [x.get_float() for x in cur_obj.params]
    return obj


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
            cur_obj = load_object(obj, len(obj_list))
            print(f"Loaded {cur_obj}")
            obj_list.append(cur_obj)

    return info, obj_list
