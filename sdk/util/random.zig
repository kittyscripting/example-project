/// Uniform random value in `[lo, hi)` from the runtime RNG.
pub fn randomRange(lo: f32, hi: f32) f32 { _ = lo; _ = hi; return undefined; }

/// Standard normal sample (mean 0, variance 1).
pub fn normalSample() f32 { return undefined; }

/// Standard normal CDF Φ(x).
pub fn normalCdf(x: f32) f32 { _ = x; return undefined; }

/// Lognormal CDF `P(X ≤ t)` with shift `t0`, log-space mean `mu`, and
/// log-space standard deviation; 0 when `t ≤ t0`.
pub fn lognormalCdf(t: f32, t0: f32, mu: f32, sigma: f32) f32 { _ = t; _ = t0; _ = mu; _ = sigma; return undefined; }

/// Lognormal PDF at `t` with shift `t0`, log-space mean `mu`, and log-space
/// standard deviation; 0 when `t ≤ t0`.
pub fn lognormalPdf(t: f32, t0: f32, mu: f32, sigma: f32) f32 { _ = t; _ = t0; _ = mu; _ = sigma; return undefined; }
