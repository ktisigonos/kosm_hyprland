//! One Hyprland plugin's settings, written only while Hyprland has the plugin loaded: it
//! refuses the settings of a plugin it does not know.

const kosm = @import("kosm");

/// The plugin's name in `hl.plugin` and under `plugin` in `hl.config`: `dynamic_cursors`.
name: []const u8,
/// Its settings by path below the plugin, each a `kosm.Value`:
/// `.{ .path = "rotate.length", .value = .{ .integer = 24 } }` is
/// `plugin.dynamic_cursors.rotate.length`. Default: none.
settings: []const kosm.Setting = &.{},
