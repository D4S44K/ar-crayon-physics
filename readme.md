## Run python physics

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r req.txt
cd phys_py
python main.py
```

Open result/test.gif for test result.

## Basic conventions

We separate the objects into primitive components: circle, line segment and point.
Point is just a circle with radius 0, so we just need to solve dynamics for circle and line segment.

## Collision detection

0. Let's say we're checking collision between `obj_a` and `obj_b`.
1. Get the relative velocity of `obj_a`. i.e. `obj_a` is moving towards stationary `obj_b` with velocity (`rv_x`, `rv_y`)

### Circle-Circle

2. Get the displacement vector (`df_x`, `df_y`) from `obj_a` to `obj_b`. i.e. if we move the center of `obj_a` by this vector, it will be at the center of `obj_b`.
3. Considering `rv` and `df`, calculate the minimum possible distance `min_dist` and its corresponding time of collision.
4. If it's going in the opposite direction, or the min distance is greater than the sum of the radii, return no collision.
5. If not, calculate the collision point and return its time of collision.

### Circle-Line

2. Consider left endpoint of line segment as a origin. Get the (translated) position of the circle, (`df_x`, `df_y`)
3. Calculate the line's normal vector, `ln` = (`ln_a`, `ln_b`) (signs?). Since the left endpoint is (0,0), the line is `ln_a * x + ln_b * y = 0`.
4. Calculate the current distance from the center to the line, and check which side of the line the circle is on.
5. Calculate the time to reach the +-radius range of the line.
6. Check if that point is within the line segment. If so, return the time of collision.

### Line-Line

Line-Line collision is hard to describe and safe to ignore, since the endpoints will be first to hit any other object.
Therefore, we always return no collision for line-line.

## Collision Response

After detecting the collision and proceeding all objects to that collision time, we need to update the velocities of two collied objects.
We set the [CoR](https://en.wikipedia.org/wiki/Coefficient_of_restitution) as `ELAS` constant in `my_types.py` for now.

1. Get the relative velocity of `obj_a` and `obj_b`.
2. Get the masses and coefficients (`m_scale_a`, `m_scale_b`) of `obj_a` and `obj_b`.
3. Get the normal vector of contact point, `n` = (`n_x`, `n_y`). (`unit_dist` in the code)
4. Decompose the relative velocity into normal and tangential components.
5. Invert the normal component and multiply by `ELAS` to get the normal component of the new velocity.
6. Add the tangential component to the new velocity.
7. Update the velocities of `obj_a` and `obj_b`.

Note that if the object is static, its corresponding mass is infinite, so its `m_scale` is 0.

This process is same for both circle-circle and circle-line collision.
The way of calculating normal vector is different, but the rest is same.

---

## Tentative object representation

[127:126] : obj type
[125:125] : is obj static
[124:32] : params
[31:16] : pos y
[15:0] : pos x

each of pos x,y is 10+6 fixed decimal

circle:
type: 2'b00
pos x,y is center
param: [47:32] is radius, 10+6 fixed decimal

rect:
type 2'b01
pos x,y is left endpoint (if duplicate, choose top)
param: (width, height, angle in some way)

line:
type: 2'b10
pos x,y is left endpoint (if duplicate, choose top)
param: [47:32] is y and [63:48] is x of the other endpoint

deactivated objects:
type: 2'b11
e.g. objects fallen too far off screen (note that pos is never negative)
e.g. deleted objects, empty objects
