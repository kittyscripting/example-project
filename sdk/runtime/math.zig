/// Sine of `x` radians.
pub fn sinf(x: f32) f32 { _ = x; return undefined; }

/// Cosine of `x` radians.
pub fn cosf(x: f32) f32 { _ = x; return undefined; }

/// Tangent of `x` radians.
pub fn tanf(x: f32) f32 { _ = x; return undefined; }

/// Arcsine of `x`, result in radians.
pub fn asinf(x: f32) f32 { _ = x; return undefined; }

/// Arccosine of `x`, result in radians.
pub fn acosf(x: f32) f32 { _ = x; return undefined; }

/// Two-argument arctangent of `y`/`x` in radians, honoring signs.
pub fn atan2f(y: f32, x: f32) f32 { _ = y; _ = x; return undefined; }

/// `base` raised to the power `exp`.
pub fn powf(base: f32, exp: f32) f32 { _ = base; _ = exp; return undefined; }

/// Uniform random value in `[min, max)` from the runtime RNG.
pub fn random(min: f32, max: f32) f32 { _ = min; _ = max; return undefined; }

/// Seed the runtime RNG; deterministic sequences follow for `random`.
pub fn seedRandom(seed: i32) void { _ = seed; }

/// Clamp `val` into the inclusive range `[lo, hi]`.
pub fn clampf(val: f32, lo: f32, hi: f32) f32 { _ = val; _ = lo; _ = hi; return undefined; }

/// Linear interpolation from `a` to `b` by fraction `t`. `t` is unclamped.
pub fn lerpf(a: f32, b: f32, t: f32) f32 { _ = a; _ = b; _ = t; return undefined; }

/// Euclidean distance between points `(x1, y1)` and `(x2, y2)`.
pub fn distance(x1: f32, y1: f32, x2: f32, y2: f32) f32 { _ = x1; _ = y1; _ = x2; _ = y2; return undefined; }

/// Wrap `radians` into the range `[-π, π]`.
pub fn normalizeAngle(radians: f32) f32 { _ = radians; return undefined; }

/// 2-component vector. Methods are pure: operands in, results out.
pub const Vec2 = extern struct {
    x: f32,
    y: f32,
    pub fn init(x: f32, y: f32) Vec2 { _ = x; _ = y; return undefined; }
    pub fn add(a: Vec2, b: Vec2) Vec2 { _ = a; _ = b; return undefined; }
    pub fn sub(a: Vec2, b: Vec2) Vec2 { _ = a; _ = b; return undefined; }
    pub fn scale(a: Vec2, s: f32) Vec2 { _ = a; _ = s; return undefined; }
    pub fn dot(a: Vec2, b: Vec2) f32 { _ = a; _ = b; return undefined; }
    pub fn lengthSq(a: Vec2) f32 { _ = a; return undefined; }
    pub fn length(a: Vec2) f32 { _ = a; return undefined; }
    pub fn normalized(a: Vec2) Vec2 { _ = a; return undefined; }
    pub fn negate(a: Vec2) Vec2 { _ = a; return undefined; }
    pub fn lerp(a: Vec2, b: Vec2, t: f32) Vec2 { _ = a; _ = b; _ = t; return undefined; }
    pub fn dist(a: Vec2, b: Vec2) f32 { _ = a; _ = b; return undefined; }
    pub fn angle(a: Vec2) f32 { _ = a; return undefined; }
    pub fn rotate(a: Vec2, rad: f32) Vec2 { _ = a; _ = rad; return undefined; }
};

/// 3-component vector. Components are meters for SDK world-space positions
/// and geometry; direction vectors are dimensionless. Methods are pure:
/// operands in, results out.
pub const Vec3 = extern struct {
    x: f32 = 0,
    y: f32 = 0,
    z: f32 = 0,
    pub fn init(x: f32, y: f32, z: f32) Vec3 { _ = x; _ = y; _ = z; return undefined; }
    pub fn add(a: Vec3, b: Vec3) Vec3 { _ = a; _ = b; return undefined; }
    pub fn sub(a: Vec3, b: Vec3) Vec3 { _ = a; _ = b; return undefined; }
    pub fn mul(a: Vec3, b: Vec3) Vec3 { _ = a; _ = b; return undefined; }
    pub fn scale(a: Vec3, s: f32) Vec3 { _ = a; _ = s; return undefined; }
    pub fn dot(a: Vec3, b: Vec3) f32 { _ = a; _ = b; return undefined; }
    pub fn lengthSq(a: Vec3) f32 { _ = a; return undefined; }
    pub fn length(a: Vec3) f32 { _ = a; return undefined; }
    pub fn normalized(a: Vec3) Vec3 { _ = a; return undefined; }
    pub fn negate(a: Vec3) Vec3 { _ = a; return undefined; }
    pub fn cross(a: Vec3, b: Vec3) Vec3 { _ = a; _ = b; return undefined; }
    pub fn reflect(v: Vec3, n: Vec3) Vec3 { _ = v; _ = n; return undefined; }
    pub fn lerp(a: Vec3, b: Vec3, t: f32) Vec3 { _ = a; _ = b; _ = t; return undefined; }
    pub fn dist(a: Vec3, b: Vec3) f32 { _ = a; _ = b; return undefined; }
};

/// 4-component vector. Methods are pure: operands in, results out.
pub const Vec4 = extern struct {
    x: f32 = 0,
    y: f32 = 0,
    z: f32 = 0,
    w: f32 = 0,
    pub fn init(x: f32, y: f32, z: f32, w: f32) Vec4 { _ = x; _ = y; _ = z; _ = w; return undefined; }
    pub fn add(a: Vec4, b: Vec4) Vec4 { _ = a; _ = b; return undefined; }
    pub fn sub(a: Vec4, b: Vec4) Vec4 { _ = a; _ = b; return undefined; }
    pub fn mul(a: Vec4, b: Vec4) Vec4 { _ = a; _ = b; return undefined; }
    pub fn scale(a: Vec4, s: f32) Vec4 { _ = a; _ = s; return undefined; }
    pub fn dot(a: Vec4, b: Vec4) f32 { _ = a; _ = b; return undefined; }
    pub fn lengthSq(a: Vec4) f32 { _ = a; return undefined; }
    pub fn length(a: Vec4) f32 { _ = a; return undefined; }
    pub fn normalized(a: Vec4) Vec4 { _ = a; return undefined; }
    pub fn negate(a: Vec4) Vec4 { _ = a; return undefined; }
    pub fn lerp(a: Vec4, b: Vec4, t: f32) Vec4 { _ = a; _ = b; _ = t; return undefined; }
};

/// Quaternion: `x`, `y`, `z` vector part and scalar `w` (identity has
/// `w = 1`). Methods are pure: operands in, results out.
pub const Quat = extern struct {
    x: f32 = 0,
    y: f32 = 0,
    z: f32 = 0,
    w: f32 = 1,
    pub fn identity() Quat { return undefined; }
    pub fn fromAxisAngle(axis: Vec3, angle_rad: f32) Quat { _ = axis; _ = angle_rad; return undefined; }
    pub fn fromEuler(pitch: f32, yaw: f32, roll: f32) Quat { _ = pitch; _ = yaw; _ = roll; return undefined; }
    pub fn mul(a: Quat, b: Quat) Quat { _ = a; _ = b; return undefined; }
    pub fn dot(a: Quat, b: Quat) f32 { _ = a; _ = b; return undefined; }
    pub fn length(q: Quat) f32 { _ = q; return undefined; }
    pub fn normalized(q: Quat) Quat { _ = q; return undefined; }
    pub fn conjugate(q: Quat) Quat { _ = q; return undefined; }
    pub fn inverse(q: Quat) Quat { _ = q; return undefined; }
    pub fn rotateVec3(q: Quat, v: Vec3) Vec3 { _ = q; _ = v; return undefined; }
    pub fn slerp(a: Quat, b: Quat, t: f32) Quat { _ = a; _ = b; _ = t; return undefined; }
    /// Create the rotation that takes the default forward axis `(0, 0, 1)`
    /// to `dir`.
    pub fn fromDirection(dir: Vec3) Quat { _ = dir; return undefined; }
    /// The default forward axis `(0, 0, 1)` rotated by `q`.
    pub fn toDirection(q: Quat) Vec3 { _ = q; return undefined; }
    /// Shortest angle in radians between two quaternions.
    pub fn angleBetween(a: Quat, b: Quat) f32 { _ = a; _ = b; return undefined; }
};

/// 4x4 matrix, column-major in `m` (`m[col * 4 + row]`). Constructors build
/// transforms; `mulVec4`, `transformPoint`, and `transformDir` apply them.
/// World-space transforms take SDK meters; angles are radians.
pub const Mat4 = struct {
    m: [16]f32,
    pub fn identity() Mat4 { return undefined; }
    pub fn mul(a: Mat4, b: Mat4) Mat4 { _ = a; _ = b; return undefined; }
    pub fn transpose(a: Mat4) Mat4 { _ = a; return undefined; }
    pub fn mulVec4(a: Mat4, v: Vec4) Vec4 { _ = a; _ = v; return undefined; }
    pub fn translation(x: f32, y: f32, z: f32) Mat4 { _ = x; _ = y; _ = z; return undefined; }
    pub fn scaling(x: f32, y: f32, z: f32) Mat4 { _ = x; _ = y; _ = z; return undefined; }
    pub fn rotationX(rad: f32) Mat4 { _ = rad; return undefined; }
    pub fn rotationY(rad: f32) Mat4 { _ = rad; return undefined; }
    pub fn rotationZ(rad: f32) Mat4 { _ = rad; return undefined; }
    pub fn perspective(fovy: f32, aspect: f32, near: f32, far: f32) Mat4 { _ = fovy; _ = aspect; _ = near; _ = far; return undefined; }
    pub fn ortho(left: f32, right: f32, bottom: f32, top: f32, near: f32, far: f32) Mat4 { _ = left; _ = right; _ = bottom; _ = top; _ = near; _ = far; return undefined; }
    pub fn lookAt(eye: Vec3, center: Vec3, up: Vec3) Mat4 { _ = eye; _ = center; _ = up; return undefined; }
    pub fn fromQuat(q: Quat) Mat4 { _ = q; return undefined; }
    pub fn transformPoint(a: Mat4, v: Vec3) Vec3 { _ = a; _ = v; return undefined; }
    pub fn transformDir(a: Mat4, v: Vec3) Vec3 { _ = a; _ = v; return undefined; }
};
