//! One `hl.animation` call: how one part of Hyprland's animation tree moves.

const Animation = @This();

const std = @import("std");

/// The part of the animation tree this sets. A leaf left out follows its parent:
/// `windows_in` follows `windows`, and everything follows `global`.
leaf: Leaf,
/// Whether the leaf animates at all. Default: true.
enabled: bool = true,
/// How long the animation takes, in tenths of a second; above 0. Required while enabled.
speed: ?f64 = null,
/// The name of a curve in the app's `curve`, or `default`, Hyprland's own bezier. Required
/// while enabled.
curve: ?[]const u8 = null,
/// The style as Hyprland spells it for the leaf: `slide bottom`, `popin 80%`, `slidevert`,
/// `loop`. null: the leaf's default.
style: ?[]const u8 = null,

/// The bezier every Hyprland has without defining it.
pub const default_curve = "default";

/// Hyprland's animation tree, in Zig spelling.
pub const Leaf = enum {
    global,
    windows,
    windows_in,
    windows_out,
    windows_move,
    layers,
    layers_in,
    layers_out,
    fade,
    fade_in,
    fade_out,
    fade_switch,
    fade_shadow,
    fade_glow,
    fade_dim,
    fade_layers,
    fade_layers_in,
    fade_layers_out,
    fade_popups,
    fade_popups_in,
    fade_popups_out,
    fade_dpms,
    border,
    border_angle,
    workspaces,
    workspaces_in,
    workspaces_out,
    special_workspace,
    special_workspace_in,
    special_workspace_out,
    zoom_factor,
    monitor_added,

    /// The leaf as Hyprland spells it: `windowsIn`, `zoomFactor`, and `borderangle`.
    pub fn name(leaf: Leaf) []const u8 {
        return switch (leaf) {
            // The one leaf Hyprland does not spell in camel case.
            .border_angle => "borderangle",
            inline else => |tag| comptime camelCase(@tagName(tag)),
        };
    }
};

fn camelCase(comptime snake: []const u8) []const u8 {
    comptime var camel: []const u8 = "";
    comptime var upper = false;
    inline for (snake) |character| {
        if (character == '_') {
            upper = true;
            continue;
        }
        camel = camel ++ &[_]u8{if (upper) std.ascii.toUpper(character) else character};
        upper = false;
    }
    return camel;
}

test "every leaf is spelled as Hyprland's animation tree spells it" {
    var names: std.ArrayList(u8) = .empty;
    defer names.deinit(std.testing.allocator);
    for (std.enums.values(Leaf)) |leaf| {
        try names.appendSlice(std.testing.allocator, leaf.name());
        try names.append(std.testing.allocator, ' ');
    }
    try std.testing.expectEqualStrings("global windows windowsIn windowsOut windowsMove layers layersIn layersOut fade fadeIn fadeOut fadeSwitch " ++
        "fadeShadow fadeGlow fadeDim fadeLayers fadeLayersIn fadeLayersOut fadePopups fadePopupsIn fadePopupsOut fadeDpms border borderangle " ++
        "workspaces workspacesIn workspacesOut specialWorkspace specialWorkspaceIn specialWorkspaceOut zoomFactor monitorAdded ", names.items);
}
