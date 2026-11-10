//! Hyprland's Lua config as kosm generates it: environment variables, curves and animations as
//! the calls Hyprland takes them by (`hl.env`, `hl.curve`, `hl.animation`), each plugin's
//! settings inside a check that Hyprland has it loaded, then the options as the table
//! `hl.config` takes. The module still returns that table, so `hl.config(require("kosm"))` reads it.

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

/// A table of environment variables by name, each a string, for `hl.env`.
pub const env_part = "env";
/// A table of curves by name, each the table `hl.curve` takes after the name.
pub const curve_part = "curve";
/// A list of the tables `hl.animation` takes.
pub const animation_part = "animation";
/// A table of plugins by name, each the table of its settings. A plugin's settings reach
/// `hl.config` only while `hl.plugin.<name>` exists.
pub const plugin_part = "plugin";
/// The table `hl.config` takes, which the module returns.
pub const config_part = "config";

const part_list = env_part ++ ", " ++ curve_part ++ ", " ++ animation_part ++ ", " ++ plugin_part ++ ", " ++ config_part;

fn serialize(writer: *std.Io.Writer, root: kosm.Value, context: *kosm.Adapter.Context) kosm.Adapter.Error!void {
    if (root != .table) return context.unsupported("a Hyprland module is a table of parts ({s}), not a {s}", .{ part_list, @tagName(root) });
    // Both capabilities are part of the lua adapter kosm_lua declares.
    const format = lua.adapter.format.?;
    const serialize_table = lua.adapter.serialize.?;
    var config: kosm.Value = .{ .table = &.{} };
    for (root.table) |part| {
        if (std.mem.eql(u8, part.key, config_part)) {
            config = part.value;
        } else if (std.mem.eql(u8, part.key, env_part)) {
            if (part.value != .table) return context.unsupported("'{s}' is a table of variables by name, not a {s}", .{ env_part, @tagName(part.value) });
            for (part.value.table) |variable| {
                try writer.writeAll("hl.env(");
                try format(writer, .{ .string = variable.key }, context);
                try writer.writeAll(", ");
                try format(writer, variable.value, context);
                try writer.writeAll(")\n");
            }
            if (part.value.table.len != 0) try writer.writeByte('\n');
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
        } else if (std.mem.eql(u8, part.key, plugin_part)) {
            if (part.value != .table) return context.unsupported("'{s}' is a table of plugins by name, not a {s}", .{ plugin_part, @tagName(part.value) });
            for (part.value.table) |plugin| {
                try writer.print("if hl.plugin.{s} ~= nil then\n    hl.config(", .{plugin.key});
                const settings: kosm.Value = .{ .table = &.{.{ .key = plugin_part, .value = .{ .table = &.{plugin} } }} };
                try lua.writeBlock(writer, settings, 1, context);
                try writer.writeAll(")\nend\n\n");
            }
        } else return context.unsupported("a Hyprland module has no part '{s}'; its parts are {s}", .{ part.key, part_list });
    }
    try serialize_table(writer, config, context);
}
