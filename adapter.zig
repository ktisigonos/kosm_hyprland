//! Hyprland's Lua config as kosm generates it: curves and animations as the calls Hyprland
//! takes them by (`hl.curve`, `hl.animation`), then the options as the table `hl.config`
//! takes. The module still returns that table, so `hl.config(require("kosm"))` reads it.

const std = @import("std");
const kosm = @import("kosm");
const lua = @import("kosm_lua");

/// Writes a Hyprland module through `output.generate` with `.lang = "hyprland"`. The root is a
/// table of the parts below, each written when present; anything else in it is refused. Values
/// are spelled as the `lua` adapter spells them.
pub const adapter: kosm.Adapter = .{
    .name = "hyprland",
    .default_format = lua.adapter.default_format,
    .comment = lua.adapter.comment,
    .serialize = serialize,
};

/// A table of curves by name, each the table `hl.curve` takes after the name.
pub const curve_part = "curve";
/// A list of the tables `hl.animation` takes.
pub const animation_part = "animation";
/// The table `hl.config` takes, which the module returns.
pub const config_part = "config";

fn serialize(writer: *std.Io.Writer, root: kosm.Value, context: *kosm.Adapter.Context) kosm.Adapter.Error!void {
    if (root != .table) return context.unsupported("a Hyprland module is a table of parts ({s}, {s}, {s}), not a {s}", .{ curve_part, animation_part, config_part, @tagName(root) });
    // Both capabilities are part of the lua adapter kosm_lua declares.
    const format = lua.adapter.format.?;
    const serialize_table = lua.adapter.serialize.?;
    var config: kosm.Value = .{ .table = &.{} };
    for (root.table) |part| {
        if (std.mem.eql(u8, part.key, config_part)) {
            config = part.value;
        } else if (std.mem.eql(u8, part.key, curve_part)) {
            if (part.value != .table) return context.unsupported("'{s}' is a table of curves by name, not a {s}", .{ curve_part, @tagName(part.value) });
            for (part.value.table) |curve| {
                try writer.writeAll("hl.curve(");
                try format(writer, .{ .string = curve.key }, context);
                try writer.writeAll(", ");
                try format(writer, curve.value, context);
                try writer.writeAll(")\n");
            }
            if (part.value.table.len != 0) try writer.writeByte('\n');
        } else if (std.mem.eql(u8, part.key, animation_part)) {
            if (part.value != .list) return context.unsupported("'{s}' is a list of animations, not a {s}", .{ animation_part, @tagName(part.value) });
            for (part.value.list) |animation| {
                try writer.writeAll("hl.animation(");
                try format(writer, animation, context);
                try writer.writeAll(")\n");
            }
            if (part.value.list.len != 0) try writer.writeByte('\n');
        } else return context.unsupported("a Hyprland module has no part '{s}'; its parts are {s}, {s} and {s}", .{ part.key, curve_part, animation_part, config_part });
    }
    try serialize_table(writer, config, context);
}
