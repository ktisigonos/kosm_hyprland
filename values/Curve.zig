//! One `hl.curve` call: a curve under the name animations use it by.

const Curve = @This();

const kosm = @import("kosm");

/// What an animation's `curve` names: `expo_out`.
name: []const u8,
/// A bezier, a spring or a standard easing: `.ease_out_expo`,
/// `.{ .spring = .{ .stiffness = 50, .damping = 10 } }`. Hyprland takes no spring mass,
/// stiffness or damping below 0.5.
curve: kosm.Curve,
