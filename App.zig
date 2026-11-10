//! Hyprland's settings: every `hl.config` option of upstream Hyprland, grouped
//! and named like Hyprland's own options (`general.col.active_border`). Null options are not
//! written, so Hyprland's defaults apply. `target` picks who owns the values.

const App = @This();

const std = @import("std");
const kosm = @import("kosm");
const values = @import("values.zig");
const settings = @import("settings.zig");
const hyprland_adapter = @import("adapter.zig");

/// Where the options go: a Lua module kosm writes whole, or the user's own Lua files.
/// Default: `default_target`.
target: Target = default_target,
/// The file that gets a block reading the generated module, `hl.config(require("kosm"))`,
/// appended at its end so kosm's values win. Only with the `.generate` target, which
/// must then write `~/.config/hypr/kosm.lua`. A missing file is left for Hyprland to create,
/// with a warning. Null: no block. Default: `~/.config/hypr/hyprland.lua`.
include: ?[]const u8 = "~/.config/hypr/hyprland.lua",
/// How values are spelled, e.g. `.color = .hex_upper`. Default: `#rrggbbaa` colors, so
/// alpha is kept; null fields take the Lua adapter's, then kosm's.
format: kosm.Format = .{ .color = .hex8 },
/// Derives each inactive color from its active one when it is null and the active one is set
///, e.g. `general.col.inactive_border` from `general.col.active_border`. null: nothing
/// is derived. `from`: the theme's `state.inactive`.
inactive: ?kosm.Modifier = null,
/// The keyboard: its layouts, variants, model, options and rules, written as XKB's comma
/// separated lists to `input.kb_layout`, `kb_variant`, `kb_model`, `kb_options` and `kb_rules`
/// wherever those are null. null: nothing is derived. Default: null.
keyboard: ?kosm.Keyboard = null,
/// Environment variables for Hyprland and every program it starts, each one `hl.env` call in the
/// generated module, in this order: `.{ .name = "XDG_CURRENT_DESKTOP", .value = "Hyprland" }`.
/// A name given twice fails the apply. Only with the `.generate` target. Default: none.
env: []const values.Variable = &.{},
/// The pointer's cursor theme, written as `HYPRCURSOR_THEME` and `XCURSOR_THEME` unless `env`
/// sets them. null: neither is written. Default: null.
cursor_theme: ?[]const u8 = null,
/// The pointer's size in pixels, written as `HYPRCURSOR_SIZE` and `XCURSOR_SIZE` unless `env`
/// sets them. null: neither is written. Default: null.
cursor_size: ?u32 = null,
/// The GTK theme's name, written as `GTK_THEME` unless `env` sets it. null: not written.
/// Default: null.
gtk_theme: ?[]const u8 = null,
/// What themes Qt programs (`qt6ct`, `kde`, `hyprqt6engine`), written as
/// `QT_QPA_PLATFORMTHEME` unless `env` sets it. null: not written. Default: null.
qt_platform_theme: ?[]const u8 = null,
/// The curves animations can name, each one `hl.curve` call in the generated module:
/// `.{ .name = "expo_out", .curve = .ease_out_expo }`. Only with the `.generate` target.
/// Default: none.
curve: []const values.Curve = &.{},
/// How the parts of Hyprland's animation tree move, each one `hl.animation` call in the
/// generated module: `.{ .leaf = .windows, .speed = 3, .curve = "expo_out", .style = "slide" }`.
/// Only with the `.generate` target. Default: none, so Hyprland's own animations apply.
animation: []const values.Animation = &.{},
/// Settings the app doesn't cover, such as a plugin's, written after its own:
/// `.{ .path = "plugin.dynamic_cursors.length", .value = .{ .integer = 24 } }`. One that
/// overlaps a set option or another extra fails the apply. Default: none.
extra: []const kosm.Setting = &.{},

general: General = .{},
decoration: Decoration = .{},
animations: Animations = .{},
input: Input = .{},
gestures: Gestures = .{},
group: Group = .{},
misc: Misc = .{},
layers: Layers = .{},
binds: Binds = .{},
xwayland: Xwayland = .{},
opengl: Opengl = .{},
render: Render = .{},
cursor: Cursor = .{},
ecosystem: Ecosystem = .{},
debug: Debug = .{},
layout: Layout = .{},
dwindle: Dwindle = .{},
master: Master = .{},
scrolling: Scrolling = .{},
experimental: Experimental = .{},
input_capture: InputCapture = .{},
quirks: Quirks = .{},

/// Who owns Hyprland's values.
pub const Target = union(enum) {
    /// Writes every set option to this Lua module, `return { general = { ... } }`, so kosm is
    /// the source of truth. `hyprland.lua` reads it with `hl.config(require("kosm"))`.
    generate: []const u8,
    /// Sets each set option where the user's Lua files already hold it, so they stay
    /// the source of truth. An option they lack must be left null: kosm never inserts keys.
    edit: Files,
};

/// The user's Lua files an `edit` target changes.
pub const Files = @import("Files.zig");

/// The target every app starts with: kosm owns `~/.config/hypr/kosm.lua`. Change it here
/// to make editing the user's files the default.
pub const default_target: Target = .{ .generate = default_module };

/// Where `require("kosm")` in the include block finds the generated module.
const default_module = "~/.config/hypr/kosm.lua";

/// Hyprland's `general` options.
pub const General = @import("sections/General.zig");
/// Hyprland's `decoration` options.
pub const Decoration = @import("sections/Decoration.zig");
/// Hyprland's `animations` options.
pub const Animations = @import("sections/Animations.zig");
/// Hyprland's `input` options.
pub const Input = @import("sections/Input.zig");
/// Hyprland's `gestures` options.
pub const Gestures = @import("sections/Gestures.zig");
/// Hyprland's `group` options.
pub const Group = @import("sections/Group.zig");
/// Hyprland's `misc` options.
pub const Misc = @import("sections/Misc.zig");
/// Hyprland's `layers` options.
pub const Layers = @import("sections/Layers.zig");
/// Hyprland's `binds` options.
pub const Binds = @import("sections/Binds.zig");
/// Hyprland's `xwayland` options.
pub const Xwayland = @import("sections/Xwayland.zig");
/// Hyprland's `opengl` options.
pub const Opengl = @import("sections/Opengl.zig");
/// Hyprland's `render` options.
pub const Render = @import("sections/Render.zig");
/// Hyprland's `cursor` options.
pub const Cursor = @import("sections/Cursor.zig");
/// Hyprland's `ecosystem` options.
pub const Ecosystem = @import("sections/Ecosystem.zig");
/// Hyprland's `debug` options.
pub const Debug = @import("sections/Debug.zig");
/// Hyprland's `layout` options.
pub const Layout = @import("sections/Layout.zig");
/// Hyprland's `dwindle` options.
pub const Dwindle = @import("sections/Dwindle.zig");
/// Hyprland's `master` options.
pub const Master = @import("sections/Master.zig");
/// Hyprland's `scrolling` options.
pub const Scrolling = @import("sections/Scrolling.zig");
/// Hyprland's `experimental` options.
pub const Experimental = @import("sections/Experimental.zig");
/// Hyprland's `input_capture` options.
pub const InputCapture = @import("sections/InputCapture.zig");
/// Hyprland's `quirks` options.
pub const Quirks = @import("sections/Quirks.zig");

/// App fields that are kosm's, not Hyprland options.
const own_fields = [_][]const u8{ "target", "include", "format", "inactive", "keyboard", "env", "cursor_theme", "cursor_size", "gtk_theme", "qt_platform_theme", "curve", "animation", "extra" };

/// Colors from the theme: the active border, glow and groupbar text from the accent
/// (cyan) and the foreground, groups in yellow (locked: orange), windows that can't be grouped in
/// magenta, the shadow from `surface.shadow`, the background behind windows. Inactive colors
/// derive through `inactive`; every other option is left to Hyprland.
pub fn from(theme: kosm.Theme) App {
    const palette = theme.palette;
    const variations = theme.variations;
    const foreground = if (theme.mode == .dark) palette.white else palette.black;
    const background = if (theme.mode == .dark) palette.black else palette.white;
    var app: App = .{ .inactive = variations.state.inactive };

    app.general.col.active_border = .solid(palette.cyan);
    app.general.col.nogroup_border_active = .solid(palette.magenta);
    app.decoration.shadow.color = .solid(variations.surface.shadow.apply(background));
    app.decoration.glow.color = .solid(palette.cyan);
    app.group.col.border_active = .solid(palette.yellow);
    app.group.col.border_locked_active = .solid(palette.orange);
    app.group.groupbar.col.active = .solid(palette.yellow);
    app.group.groupbar.col.locked_active = .solid(palette.orange);
    app.group.groupbar.text_color = foreground;
    app.group.groupbar.text_color_locked_active = foreground;
    app.misc.background_color = background;
    app.misc.col.splash = foreground;
    return app;
}

/// Makes Hyprland re-read its config. Without a running Hyprland, kosm only warns.
pub fn reload(self: App, reloader: *kosm.Reloader) !void {
    _ = self;
    try reloader.run(&.{ "hyprctl", "reload" });
}

/// Writes every set option to the target. An option Hyprland can't read (an empty gradient)
/// or a keyboard name XKB can't take fails the apply, naming it.
pub fn apply(self: App, output: *kosm.Output) !void {
    const file = switch (self.target) {
        .generate => |path| path,
        .edit => |files| files.files,
    };
    const app = try self.withKeyboard(output, file);
    // Checked before deriving, so a bad active color is named instead of the inactive copy.
    for (try settings.list(output.allocator, app, &own_fields)) |setting| {
        if (setting.problem) |message| return output.fail(file, "option '{s}': {s}", .{ setting.keyed.path, message });
    }
    const options = try settings.keyed(output.allocator, try settings.list(output.allocator, app.withDerived(), &own_fields));
    const set = try kosm.Setting.withExtras(output, file, options, self.extra, .{ .any_key = self.target == .edit });
    switch (self.target) {
        .generate => {
            if (self.include != null and !std.mem.eql(u8, file, default_module))
                return output.fail(self.include.?, "the include block reads require(\"kosm\"), which finds only {s}, not {s}; set include = null and read it yourself", .{ default_module, file });
            try output.generate(.{ .file = file, .lang = "hyprland", .format = self.format }, try self.module(output, file, try kosm.Setting.tree(output.allocator, set)));
            if (self.include) |include|
                try output.templateBlock(self, .{ .file = include, .id = "hyprland", .text = "hl.config(require(\"kosm\"))\n", .lang = "lua", .missing = .skip });
        },
        .edit => |files| {
            if (self.curve.len != 0 or self.animation.len != 0)
                return output.fail(file, "curves and animations are calls, which kosm writes only into a module it generates; leave curve and animation empty, or use the generate target", .{});
            if ((try self.variables(output, file)).len != 0)
                return output.fail(file, "environment variables are calls, which kosm writes only into a module it generates; leave env, cursor_theme, cursor_size, gtk_theme and qt_platform_theme unset, or use the generate target", .{});
            var selection = try output.edit(.{ .files = files.files, .exclude = files.exclude, .lang = "lua", .format = self.format });
            for (set) |setting| try selection.set(setting.path, setting.value);
        },
    }
}

/// Every environment variable to write, by name: the ones the app derives that `env` does not
/// set itself, then `env` in its order. A name `env` gives twice fails the apply.
fn variables(self: App, output: *kosm.Output, file: []const u8) ![]const kosm.Value.Entry {
    const allocator = output.allocator;
    for (self.env, 0..) |variable, index| {
        if (variable.name.len == 0) return output.fail(file, "environment variable {d} has no name", .{index + 1});
        if (std.mem.findScalar(u8, variable.name, '=') != null) return output.fail(file, "environment variable '{s}' holds a '=', which no name can; give the value as .value", .{variable.name});
        for (self.env[0..index]) |earlier| {
            if (std.mem.eql(u8, earlier.name, variable.name))
                return output.fail(file, "environment variable '{s}' is set twice, to '{s}' and to '{s}'", .{ variable.name, earlier.value, variable.value });
        }
    }
    var found: std.ArrayList(kosm.Value.Entry) = .empty;
    const size: ?[]const u8 = if (self.cursor_size) |pixels| try std.fmt.allocPrint(allocator, "{d}", .{pixels}) else null;
    const derived = [_]struct { []const u8, ?[]const u8 }{
        .{ "HYPRCURSOR_THEME", self.cursor_theme },
        .{ "XCURSOR_THEME", self.cursor_theme },
        .{ "HYPRCURSOR_SIZE", size },
        .{ "XCURSOR_SIZE", size },
        .{ "GTK_THEME", self.gtk_theme },
        .{ "QT_QPA_PLATFORMTHEME", self.qt_platform_theme },
    };
    for (derived) |variable| {
        const value = variable[1] orelse continue;
        const set = for (self.env) |own| {
            if (std.mem.eql(u8, own.name, variable[0])) break true;
        } else false;
        if (!set) try found.append(allocator, .{ .key = variable[0], .value = .{ .string = value } });
    }
    for (self.env) |variable| try found.append(allocator, .{ .key = variable.name, .value = .{ .string = variable.value } });
    return found.items;
}

/// The generated module as the `hyprland` adapter takes it: the environment variables, the
/// curves and animations, then `config`, the options. A curve or animation Hyprland would refuse fails the apply.
fn module(self: App, output: *kosm.Output, file: []const u8, config: kosm.Value) !kosm.Value {
    const allocator = output.allocator;
    var parts: std.ArrayList(kosm.Value.Entry) = .empty;
    const environment = try self.variables(output, file);
    if (environment.len != 0) try parts.append(allocator, .{ .key = hyprland_adapter.env_part, .value = .{ .table = environment } });
    if (self.curve.len != 0) {
        const curves = try allocator.alloc(kosm.Value.Entry, self.curve.len);
        for (self.curve, curves, 0..) |named, *entry, index| {
            if (named.name.len == 0) return output.fail(file, "curve {d} has no name", .{index + 1});
            for (self.curve[0..index]) |earlier| {
                if (std.mem.eql(u8, earlier.name, named.name)) return output.fail(file, "curve '{s}' is defined twice", .{named.name});
            }
            entry.* = .{ .key = named.name, .value = try curveValue(output, file, named) };
        }
        try parts.append(allocator, .{ .key = hyprland_adapter.curve_part, .value = .{ .table = curves } });
    }
    if (self.animation.len != 0) {
        const animations = try allocator.alloc(kosm.Value, self.animation.len);
        for (self.animation, animations, 0..) |animation, *value, index| {
            for (self.animation[0..index]) |earlier| {
                if (earlier.leaf == animation.leaf) return output.fail(file, "animation '{s}' is set twice", .{animation.leaf.name()});
            }
            value.* = try self.animationValue(output, file, animation);
        }
        try parts.append(allocator, .{ .key = hyprland_adapter.animation_part, .value = .{ .list = animations } });
    }
    try parts.append(allocator, .{ .key = hyprland_adapter.config_part, .value = config });
    return .{ .table = parts.items };
}

/// Hyprland refuses a spring whose mass, stiffness or damping is below this.
const min_spring_value = 0.5;

/// The table `hl.curve` takes after the name.
fn curveValue(output: *kosm.Output, file: []const u8, named: values.Curve) !kosm.Value {
    const allocator = output.allocator;
    switch (named.curve) {
        .bezier => |bezier| {
            const points = try allocator.dupe(kosm.Value, &.{
                .{ .list = try allocator.dupe(kosm.Value, &.{ .{ .float = bezier.x1 }, .{ .float = bezier.y1 } }) },
                .{ .list = try allocator.dupe(kosm.Value, &.{ .{ .float = bezier.x2 }, .{ .float = bezier.y2 } }) },
            });
            return .{ .table = try allocator.dupe(kosm.Value.Entry, &.{
                .{ .key = "type", .value = .{ .string = "bezier" } },
                .{ .key = "points", .value = .{ .list = points } },
            }) };
        },
        .spring => |spring| {
            inline for (.{ "mass", "stiffness", "damping" }) |field| {
                if (@field(spring, field) < min_spring_value)
                    return output.fail(file, "curve '{s}': its spring's {s} is {d}, and Hyprland takes none below {d}", .{ named.name, field, @field(spring, field), min_spring_value });
            }
            return .{ .table = try allocator.dupe(kosm.Value.Entry, &.{
                .{ .key = "type", .value = .{ .string = "spring" } },
                .{ .key = "mass", .value = .{ .float = spring.mass } },
                .{ .key = "stiffness", .value = .{ .float = spring.stiffness } },
                .{ .key = "damping", .value = .{ .float = spring.damping } },
            }) };
        },
    }
}

/// The table `hl.animation` takes. Hyprland names an animation's curve under `bezier` or
/// `spring`, by what the curve is.
fn animationValue(self: App, output: *kosm.Output, file: []const u8, animation: values.Animation) !kosm.Value {
    const leaf = animation.leaf.name();
    var entries: std.ArrayList(kosm.Value.Entry) = .empty;
    try entries.append(output.allocator, .{ .key = "leaf", .value = .{ .string = leaf } });
    try entries.append(output.allocator, .{ .key = "enabled", .value = .{ .boolean = animation.enabled } });
    if (animation.speed) |speed| {
        if (!(speed > 0)) return output.fail(file, "animation '{s}': its speed is {d}, and Hyprland takes only speeds above 0", .{ leaf, speed });
        try entries.append(output.allocator, .{ .key = "speed", .value = .{ .float = speed } });
    } else if (animation.enabled) return output.fail(file, "animation '{s}' is enabled, so it needs a speed", .{leaf});
    if (animation.curve) |name| {
        try entries.append(output.allocator, .{ .key = try self.curveKind(output, file, leaf, name), .value = .{ .string = name } });
    } else if (animation.enabled) return output.fail(file, "animation '{s}' is enabled, so it needs a curve", .{leaf});
    if (animation.style) |style| try entries.append(output.allocator, .{ .key = "style", .value = .{ .string = style } });
    return .{ .table = entries.items };
}

/// "bezier" or "spring": what the curve `name` is. One the app does not define fails the
/// apply, naming the animation and the curves there are.
fn curveKind(self: App, output: *kosm.Output, file: []const u8, leaf: []const u8, name: []const u8) ![]const u8 {
    for (self.curve) |named| {
        if (std.mem.eql(u8, named.name, name)) return @tagName(named.curve);
    }
    if (std.mem.eql(u8, name, values.Animation.default_curve)) return "bezier";
    var defined: std.ArrayList(u8) = .empty;
    try defined.appendSlice(output.allocator, values.Animation.default_curve);
    for (self.curve) |named| {
        try defined.appendSlice(output.allocator, ", ");
        try defined.appendSlice(output.allocator, named.name);
    }
    return output.fail(file, "animation '{s}' names the curve '{s}', which is not defined; curves: {s}", .{ leaf, name, defined.items });
}

/// The app with every null `input.kb_*` option taken from `keyboard`.
fn withKeyboard(self: App, output: *kosm.Output, file: []const u8) !App {
    var app = self;
    const keyboard = self.keyboard orelse return app;
    if (keyboard.problem()) |found| return output.fail(file, "keyboard {s} '{s}' {s}", .{ found.kind, found.name, found.reason });
    const input = &app.input;
    if (input.kb_layout == null) input.kb_layout = try keyboard.layoutList(output.allocator);
    if (input.kb_variant == null) input.kb_variant = try keyboard.variantList(output.allocator);
    if (input.kb_options == null) input.kb_options = try keyboard.optionList(output.allocator);
    if (input.kb_model == null) input.kb_model = keyboard.model;
    if (input.kb_rules == null) input.kb_rules = keyboard.rules;
    return app;
}

/// The app with every null inactive color derived from its set active one.
fn withDerived(self: App) App {
    var app = self;
    const inactive = self.inactive orelse return app;
    derive(values.Gradient, &app.general.col.inactive_border, app.general.col.active_border, inactive);
    derive(values.Gradient, &app.general.col.nogroup_border, app.general.col.nogroup_border_active, inactive);
    derive(values.Gradient, &app.decoration.shadow.color_inactive, app.decoration.shadow.color, inactive);
    derive(values.Gradient, &app.decoration.glow.color_inactive, app.decoration.glow.color, inactive);
    derive(values.Gradient, &app.group.col.border_inactive, app.group.col.border_active, inactive);
    derive(values.Gradient, &app.group.col.border_locked_inactive, app.group.col.border_locked_active, inactive);
    derive(values.Gradient, &app.group.groupbar.col.inactive, app.group.groupbar.col.active, inactive);
    derive(values.Gradient, &app.group.groupbar.col.locked_inactive, app.group.groupbar.col.locked_active, inactive);
    derive(kosm.Color, &app.group.groupbar.text_color_inactive, app.group.groupbar.text_color, inactive);
    derive(kosm.Color, &app.group.groupbar.text_color_locked_inactive, app.group.groupbar.text_color_locked_active, inactive);
    return app;
}

fn derive(comptime T: type, inactive_slot: *?T, active: ?T, inactive: kosm.Modifier) void {
    if (inactive_slot.* != null) return;
    const color = active orelse return;
    inactive_slot.* = if (T == kosm.Color) inactive.apply(color) else color.modified(inactive);
}

const testing = std.testing;
const lua = @import("kosm_lua");

const Fixture = struct {
    tmp: testing.TmpDir,
    arena: std.heap.ArenaAllocator,
    plan: kosm.Plan,
    diagnostics: kosm.Diagnostics = .{},
    warnings: kosm.Warnings = undefined,
    home_buffer: [std.Io.Dir.max_path_bytes]u8 = undefined,
    output: kosm.Output = undefined,

    fn init(fixture: *Fixture, files: []const [2][]const u8) !void {
        fixture.* = .{ .tmp = testing.tmpDir(.{}), .arena = .init(testing.allocator), .plan = .init(testing.allocator, testing.io) };
        for (files) |file| {
            if (std.Io.Dir.path.dirname(file[0])) |parent| try fixture.tmp.dir.createDirPath(testing.io, parent);
            try fixture.tmp.dir.writeFile(testing.io, .{ .sub_path = file[0], .data = file[1] });
        }
        fixture.warnings = .init(fixture.arena.allocator());
        const length = try fixture.tmp.dir.realPath(testing.io, &fixture.home_buffer);
        fixture.output = .{
            .allocator = fixture.arena.allocator(),
            .home = fixture.home_buffer[0..length],
            .adapters = &.{ lua.adapter, hyprland_adapter.adapter },
            .plan = &fixture.plan,
            .diagnostics = &fixture.diagnostics,
            .warnings = &fixture.warnings,
            .app = "hyprland",
        };
    }

    fn deinit(fixture: *Fixture) void {
        fixture.plan.deinit();
        fixture.arena.deinit();
        fixture.tmp.cleanup();
    }

    fn planned(fixture: *Fixture, display_path: []const u8) []const u8 {
        for (fixture.plan.files.items) |file| {
            if (std.mem.eql(u8, file.display_path, display_path)) return file.new;
        }
        return "(not planned)";
    }
};

const test_palette: kosm.Palette = .{
    .black = kosm.hex("#041c26"),
    .white = kosm.hex("#dce9ee"),
    .cyan = kosm.hex("#2e8799"),
    .yellow = kosm.hex("#ebcb8b"),
    .orange = kosm.hex("#d08770"),
    .magenta = kosm.hex("#b48ead"),
};

/// An app with only the options a test sets, written as plain hex colors.
fn bareApp() App {
    return .{ .inactive = .{ .lightness = -0.1 }, .format = .{ .color = .hex }, .include = null };
}

test "from writes Hyprland's own shape to the generated module, inactive colors derived" {
    var fixture: Fixture = undefined;
    try fixture.init(&.{});
    defer fixture.deinit();
    var app = from(kosm.Theme.from(test_palette, .dark));
    app.decoration.blur.size = 20;
    app.decoration.blur.variant = .frost;
    try app.apply(&fixture.output);
    const written = fixture.planned("~/.config/hypr/kosm.lua");
    try testing.expectStringStartsWith(written,
        \\return {
        \\    general = {
        \\        col = {
        \\            inactive_border = "#
    );
    for ([_][]const u8{
        "            active_border = \"#2e8799ff\",\n",
        "            nogroup_border_active = \"#b48eadff\",\n",
        "    decoration = {\n        shadow = {\n            color = \"#",
        "        glow = {\n            color = \"#2e8799ff\",\n            color_inactive = \"#",
        "        blur = {\n            variant = \"frost\",\n            size = 20,\n        },\n",
        "            border_locked_active = \"#d08770ff\",\n",
        "            text_color = \"#dce9eeff\",\n",
        "        background_color = \"#041c26ff\",\n",
        "        col = {\n            splash = \"#dce9eeff\",\n        },\n",
    }) |expected| {
        if (std.mem.indexOf(u8, written, expected) == null) {
            std.debug.print("missing:\n{s}\nin:\n{s}\n", .{ expected, written });
            return error.TestExpectedEqual;
        }
    }
    try testing.expect(std.mem.indexOf(u8, written, "input") == null);
}

test "hyprland.lua gets a block reading the generated module at its end, once" {
    const user_config = "hl.config({ general = { gaps_in = 5 } })\n";
    var fixture: Fixture = undefined;
    try fixture.init(&.{
        .{ ".config/hypr/hyprland.lua", user_config },
        .{ ".config/hypr/done.lua", user_config ++ "-- kosm:begin hyprland\nhl.config(require(\"kosm\"))\n-- kosm:end\n" },
    });
    defer fixture.deinit();
    var app = from(kosm.Theme.from(test_palette, .dark));
    try app.apply(&fixture.output);
    try testing.expectEqualStrings(user_config ++ "-- kosm:begin hyprland\nhl.config(require(\"kosm\"))\n-- kosm:end\n", fixture.planned("~/.config/hypr/hyprland.lua"));
    try testing.expectEqual(0, fixture.warnings.items.items.len);

    var second: Fixture = undefined;
    try second.init(&.{.{ ".config/hypr/done.lua", user_config ++ "-- kosm:begin hyprland\nhl.config(require(\"kosm\"))\n-- kosm:end\n" }});
    defer second.deinit();
    app.include = "~/.config/hypr/done.lua";
    try app.apply(&second.output);
    try testing.expectEqualStrings("~/.config/hypr/done.lua", second.plan.files.items[1].display_path);
    try testing.expect(!second.plan.files.items[1].changed());
}

test "a missing hyprland.lua is left for Hyprland to create, with a warning" {
    var fixture: Fixture = undefined;
    try fixture.init(&.{});
    defer fixture.deinit();
    const app = from(kosm.Theme.from(test_palette, .dark));
    try app.apply(&fixture.output);
    try testing.expectEqual(1, fixture.plan.files.items.len);
    try testing.expectEqualStrings("~/.config/hypr/kosm.lua", fixture.plan.files.items[0].display_path);
    const warnings = fixture.warnings.items.items;
    try testing.expectEqual(1, warnings.len);
    try testing.expectEqualStrings("~/.config/hypr/hyprland.lua", warnings[0].file);
    try testing.expectEqualStrings("does not exist, so block 'hyprland' is not written; apply again once it exists, or add the block's lines yourself:\nhl.config(require(\"kosm\"))", warnings[0].message);
}

test "the include block refuses a module require(\"kosm\") would not find" {
    var fixture: Fixture = undefined;
    try fixture.init(&.{});
    defer fixture.deinit();
    var app = from(kosm.Theme.from(test_palette, .dark));
    app.target = .{ .generate = "~/.config/hypr/theme.lua" };
    try testing.expectError(error.AppFailed, app.apply(&fixture.output));
    try testing.expectEqualStrings("the include block reads require(\"kosm\"), which finds only ~/.config/hypr/kosm.lua, not ~/.config/hypr/theme.lua; set include = null and read it yourself", fixture.diagnostics.message());
    try testing.expectEqual(0, fixture.plan.files.items.len);

    app.include = null;
    try app.apply(&fixture.output);
}

test "an inactive color follows its active one unless set, and a changed active one flows" {
    var app = bareApp();
    app.general.col.active_border = .solid(kosm.hex("#808080"));
    app.group.groupbar.text_color = kosm.hex("#808080");
    app.decoration.glow.color = .solid(kosm.hex("#808080"));
    app.decoration.glow.color_inactive = .solid(kosm.hex("#ff0000"));
    const derived = app.withDerived();
    const darker = app.inactive.?.apply(kosm.hex("#808080"));
    try testing.expectEqual(darker, derived.general.col.inactive_border.?.colors[0].?);
    try testing.expectEqual(darker, derived.group.groupbar.text_color_inactive.?);
    try testing.expectEqual(kosm.hex("#ff0000"), derived.decoration.glow.color_inactive.?.colors[0].?);
    try testing.expectEqual(null, derived.group.col.border_inactive);

    app.general.col.active_border = .solid(kosm.hex("#ffffff"));
    try testing.expectEqual(app.inactive.?.apply(kosm.hex("#ffffff")), app.withDerived().general.col.inactive_border.?.colors[0].?);
}

test "values are written the way Hyprland's Lua config reads them" {
    var fixture: Fixture = undefined;
    try fixture.init(&.{});
    defer fixture.deinit();
    var app = bareApp();
    app.target = .{ .generate = "~/kosm.lua" };
    app.general.col.active_border = .from(&.{ kosm.hex("#2e8799"), kosm.hex("#ffffff") });
    app.general.col.active_border.?.angle = 45;
    app.general.col.inactive_border = .solid(kosm.hex("#000000"));
    app.general.gaps_in = .all(5);
    app.general.gaps_out = .{ .top = 10, .right = 20, .bottom = 10, .left = 20 };
    app.general.resize_corner = .top_left;
    app.decoration.shadow.offset = .{ .x = 0, .y = 2.5 };
    app.group.groupbar.font_weight_active = .{ .name = .semibold };
    app.group.groupbar.font_weight_inactive = .{ .weight = 450 };
    app.cursor.no_hardware_cursors = .enabled;
    app.input.touchpad.drag_3fg = .@"3_finger";
    app.input.touchpad.tap_to_click = false;
    app.input_capture.capture_modifiers = true;
    app.master.orientation = .center;
    try app.apply(&fixture.output);
    try testing.expectEqualStrings(
        \\return {
        \\    general = {
        \\        gaps_in = 5,
        \\        gaps_out = {
        \\            top = 10,
        \\            right = 20,
        \\            bottom = 10,
        \\            left = 20,
        \\        },
        \\        col = {
        \\            inactive_border = "#000000",
        \\            active_border = {
        \\                colors = { "#2e8799", "#ffffff" },
        \\                angle = 45,
        \\            },
        \\        },
        \\        resize_corner = "top_left",
        \\    },
        \\    decoration = {
        \\        shadow = {
        \\            offset = { 0, 2.5 },
        \\        },
        \\    },
        \\    input = {
        \\        touchpad = {
        \\            tap_to_click = false,
        \\            drag_3fg = "3_finger",
        \\        },
        \\    },
        \\    group = {
        \\        groupbar = {
        \\            font_weight_active = "semibold",
        \\            font_weight_inactive = 450,
        \\        },
        \\    },
        \\    cursor = {
        \\        no_hardware_cursors = 1,
        \\    },
        \\    master = {
        \\        orientation = "center",
        \\    },
        \\    input_capture = {
        \\        capture_modifiers = true,
        \\    },
        \\}
        \\
    , fixture.planned("~/kosm.lua"));
}

const general_lua =
    \\local defs = require("defs")
    \\
    \\hl.config({
    \\    general = {
    \\        layout        = "scrolling",
    \\        allow_tearing = true,
    \\
    \\        -- Border
    \\        border_size             = defs.border.size,
    \\        resize_on_border        = true,
    \\
    \\        -- Border colors
    \\        col = {
    \\            inactive_border       = defs.border.inactive_col,
    \\            active_border         = { colors = { "#2E8799", "#2E8799" } },
    \\        },
    \\
    \\        snap = {
    \\            enabled      = true,
    \\            window_gap   = 10,
    \\        }
    \\    }
    \\})
    \\
;

const blur_lua =
    \\local defs = require("defs")
    \\
    \\hl.config({
    \\    decoration = {
    \\        blur = {
    \\            enabled = defs.blur.enabled,
    \\            size    = defs.blur.size,
    \\            variant = "frost",
    \\
    \\            aurora = {
    \\                color1 = "#2E8799AA",
    \\            },
    \\        },
    \\    }
    \\})
    \\
    \\hl.animation(defs.animations.windows)
    \\hl.bind("SUPER + Q", hl.dsp.window.close(), { description = "Close" })
    \\
;

test "the edit target sets options in the user's files, however they are split" {
    var fixture: Fixture = undefined;
    try fixture.init(&.{
        .{ ".config/hypr/hyprland/general.lua", general_lua },
        .{ ".config/hypr/hyprland/decoration/blur.lua", blur_lua },
        .{ ".config/hypr/hyprland.lua", "require(\"hyprland.general\")\nrequire(\"hyprland.decoration.blur\")\n" },
    });
    defer fixture.deinit();
    var app = bareApp();
    app.target = .{ .edit = .{} };
    app.general.col.active_border = .from(&.{ kosm.hex("#5e81ac"), kosm.hex("#88c0d0") });
    app.general.border_size = 2;
    app.general.snap.window_gap = 5;
    app.decoration.blur.size = 8;
    app.decoration.blur.variant = .aurora;
    app.decoration.blur.aurora.color1 = kosm.hex("#bf616a");
    try app.apply(&fixture.output);

    try testing.expectEqualStrings(
        \\local defs = require("defs")
        \\
        \\hl.config({
        \\    general = {
        \\        layout        = "scrolling",
        \\        allow_tearing = true,
        \\
        \\        -- Border
        \\        border_size             = 2,
        \\        resize_on_border        = true,
        \\
        \\        -- Border colors
        \\        col = {
        \\            inactive_border       = { colors = { "#42648d", "#69a0b0" } },
        \\            active_border         = { colors = { "#5e81ac", "#88c0d0" } },
        \\        },
        \\
        \\        snap = {
        \\            enabled      = true,
        \\            window_gap   = 5,
        \\        }
        \\    }
        \\})
        \\
    , fixture.planned("~/.config/hypr/hyprland/general.lua"));
    try testing.expectEqualStrings(
        \\local defs = require("defs")
        \\
        \\hl.config({
        \\    decoration = {
        \\        blur = {
        \\            enabled = defs.blur.enabled,
        \\            size    = 8,
        \\            variant = "aurora",
        \\
        \\            aurora = {
        \\                color1 = "#bf616a",
        \\            },
        \\        },
        \\    }
        \\})
        \\
        \\hl.animation(defs.animations.windows)
        \\hl.bind("SUPER + Q", hl.dsp.window.close(), { description = "Close" })
        \\
    , fixture.planned("~/.config/hypr/hyprland/decoration/blur.lua"));
}

test "the edit target refuses an option the user's files lack, or hold twice" {
    const files = [_][2][]const u8{
        .{ ".config/hypr/general.lua", general_lua },
        .{ ".config/hypr/override.lua", "hl.config({ general = { border_size = 3 } })\n" },
    };
    var app = bareApp();
    app.target = .{ .edit = .{} };
    app.general.allow_tearing = false;
    app.decoration.rounding = 10;
    {
        var fixture: Fixture = undefined;
        try fixture.init(&files);
        defer fixture.deinit();
        try testing.expectError(error.NoMatch, app.apply(&fixture.output));
        try testing.expectEqualStrings("path 'decoration.rounding' matches nothing; kosm never inserts keys", fixture.diagnostics.message());
    }
    app.decoration.rounding = null;
    app.general.border_size = 2;
    {
        var fixture: Fixture = undefined;
        try fixture.init(&files);
        defer fixture.deinit();
        try testing.expectError(error.TooManyMatches, app.apply(&fixture.output));
    }
    app.target = .{ .edit = .{ .exclude = &.{"~/.config/hypr/override.lua"} } };
    {
        var fixture: Fixture = undefined;
        try fixture.init(&files);
        defer fixture.deinit();
        try app.apply(&fixture.output);
        try testing.expect(std.mem.indexOf(u8, fixture.planned("~/.config/hypr/general.lua"), "border_size             = 2,") != null);
    }
}

test "choices Hyprland reads as numbers are enums, written as their number" {
    var fixture: Fixture = undefined;
    try fixture.init(&.{});
    defer fixture.deinit();
    var app = bareApp();
    app.target = .{ .generate = "~/kosm.lua" };
    app.general.layout = .{ .lua = "my_layout" };
    app.input.accel_profile = .{ .custom = .{ .step = 0.5, .points = &.{ 0, 0.25, 1.5 } } };
    app.input.scroll_points = .{ .step = 1, .points = &.{ 0, 2 } };
    app.input.float_switch_override_focus = .floating_too;
    app.input.tablet.transform = .flipped_90;
    app.misc.force_default_wallpaper = .random;
    app.scrolling.follow_focus = .soft;
    try app.apply(&fixture.output);
    const written = fixture.planned("~/kosm.lua");
    for ([_][]const u8{
        "        layout = \"lua:my_layout\",\n",
        "        accel_profile = \"custom 0.5 0 0.25 1.5\",\n",
        "        scroll_points = \"1 0 2\",\n",
        "        float_switch_override_focus = 2,\n",
        "        tablet = {\n            transform = 5,\n        },\n",
        "        force_default_wallpaper = -1,\n",
        "    scrolling = {\n        follow_focus = 2,\n    },\n",
    }) |expected| {
        if (std.mem.indexOf(u8, written, expected) == null) {
            std.debug.print("missing:\n{s}\nin:\n{s}\n", .{ expected, written });
            return error.TestExpectedEqual;
        }
    }

    var built_in = bareApp();
    built_in.target = app.target;
    built_in.general.layout = .scrolling;
    built_in.input.accel_profile = .flat;
    var second: Fixture = undefined;
    try second.init(&.{});
    defer second.deinit();
    try built_in.apply(&second.output);
    try testing.expectEqualStrings("return {\n    general = {\n        layout = \"scrolling\",\n    },\n    input = {\n        accel_profile = \"flat\",\n    },\n}\n", second.planned("~/kosm.lua"));
}

test "a gradient Hyprland can't draw fails the apply, naming the option" {
    const colors: [12]kosm.Color = @splat(kosm.hex("#2e8799"));
    var too_many = bareApp();
    too_many.general.col.active_border = .from(&colors);
    try testing.expectEqual(10, too_many.general.col.active_border.?.colors.len);
    var empty = bareApp();
    empty.target = .{ .edit = .{} };
    empty.decoration.glow.color = .{};

    var fixture: Fixture = undefined;
    try fixture.init(&.{});
    defer fixture.deinit();
    try testing.expectError(error.AppFailed, too_many.apply(&fixture.output));
    try testing.expectEqualStrings("option 'general.col.active_border': the gradient holds 12 colors; Hyprland draws at most 10", fixture.diagnostics.message());
    try testing.expectEqualStrings("~/.config/hypr/kosm.lua", fixture.diagnostics.file);
    try testing.expectError(error.AppFailed, empty.apply(&fixture.output));
    try testing.expectEqualStrings("option 'decoration.glow.color': the gradient has no colors; set at least one", fixture.diagnostics.message());
    try testing.expectEqualStrings("~/.config/hypr/**/*.lua", fixture.diagnostics.file);
    try testing.expectEqual(0, fixture.plan.files.items.len);
}

test "extras land in the generated module's tables beside the options, quoted keys too" {
    var fixture: Fixture = undefined;
    try fixture.init(&.{});
    defer fixture.deinit();
    var app = bareApp();
    app.target = .{ .generate = "~/kosm.lua" };
    app.general.border_size = 2;
    app.decoration.rounding = 10;
    app.extra = &.{
        .{ .path = "plugin.dynamic_cursors.length", .value = .{ .integer = 24 } },
        .{ .path = "general.future_option", .value = .{ .color = kosm.hex("#2e8799") } },
        .{ .path = "plugin.\"hy.prop\".enabled", .value = .{ .boolean = false } },
    };
    try app.apply(&fixture.output);
    try testing.expectEqualStrings(
        \\return {
        \\    general = {
        \\        border_size = 2,
        \\        future_option = "#2e8799",
        \\    },
        \\    decoration = {
        \\        rounding = 10,
        \\    },
        \\    plugin = {
        \\        dynamic_cursors = {
        \\            length = 24,
        \\        },
        \\        ["hy.prop"] = {
        \\            enabled = false,
        \\        },
        \\    },
        \\}
        \\
    , fixture.planned("~/kosm.lua"));
}

test "the edit target sets extras by path in the user's files" {
    var fixture: Fixture = undefined;
    try fixture.init(&.{.{ ".config/hypr/plugins.lua", "hl.config({ plugin = { dynamic_cursors = { length = 10 } } })\n" }});
    defer fixture.deinit();
    var app = bareApp();
    app.target = .{ .edit = .{} };
    app.extra = &.{.{ .path = "plugin.*.length", .value = .{ .integer = 24 } }};
    try app.apply(&fixture.output);
    try testing.expectEqualStrings("hl.config({ plugin = { dynamic_cursors = { length = 24 } } })\n", fixture.planned("~/.config/hypr/plugins.lua"));
}

test "an extra overlapping an option fails naming both, and '*' only edits" {
    const cases = [_]struct { extra: []const kosm.Setting, message: []const u8 }{
        .{ .extra = &.{.{ .path = "general.border_size", .value = .{ .integer = 3 } }}, .message = "extra 'general.border_size' and setting 'general.border_size' write the same key, or one inside the other; keep one" },
        .{ .extra = &.{.{ .path = "plugin.*.length", .value = .{ .integer = 1 } }}, .message = "extra 'plugin.*.length': '*' matches keys only in files kosm edits, not in one it generates" },
    };
    for (cases) |case| {
        var fixture: Fixture = undefined;
        try fixture.init(&.{});
        defer fixture.deinit();
        var app = bareApp();
        app.general.border_size = 2;
        app.extra = case.extra;
        try testing.expectError(error.AppFailed, app.apply(&fixture.output));
        try testing.expectEqualStrings(case.message, fixture.diagnostics.message());
        try testing.expectEqual(0, fixture.plan.files.items.len);
    }
}

test "App{} writes an empty module and its include block, and without inactive nothing derives" {
    var fixture: Fixture = undefined;
    try fixture.init(&.{.{ ".config/hypr/hyprland.lua", "hl.config({})\n" }});
    defer fixture.deinit();
    const empty: App = .{};
    try empty.apply(&fixture.output);
    try testing.expectEqualStrings("return {}\n", fixture.planned("~/.config/hypr/kosm.lua"));
    try testing.expectEqualStrings(
        "hl.config({})\n-- kosm:begin hyprland\nhl.config(require(\"kosm\"))\n-- kosm:end\n",
        fixture.planned("~/.config/hypr/hyprland.lua"),
    );

    var app: App = .{};
    app.general.col.active_border = .solid(kosm.hex("#808080"));
    try testing.expectEqual(null, app.withDerived().general.col.inactive_border);
}

test "a keyboard is written as XKB's comma lists, empty variants in position, and a set option wins" {
    var fixture: Fixture = undefined;
    try fixture.init(&.{});
    defer fixture.deinit();
    var app = bareApp();
    app.keyboard = .{
        .layouts = &.{ .{ .layout = "us" }, .{ .layout = "rs", .variant = "latin" }, .{ .layout = "rs" } },
        .options = &.{ "grp:alt_shift_toggle", "caps:escape" },
        .model = "pc105",
    };
    app.input.kb_options = "caps:swapescape";
    try app.apply(&fixture.output);
    try testing.expectEqualStrings(
        \\return {
        \\    input = {
        \\        kb_model = "pc105",
        \\        kb_layout = "us,rs,rs",
        \\        kb_variant = ",latin,",
        \\        kb_options = "caps:swapescape",
        \\    },
        \\}
        \\
    , fixture.planned("~/.config/hypr/kosm.lua"));
}

test "layouts without a variant write no kb_variant" {
    var fixture: Fixture = undefined;
    try fixture.init(&.{});
    defer fixture.deinit();
    var app = bareApp();
    app.keyboard = .{ .layouts = &.{ .{ .layout = "us" }, .{ .layout = "ru" } } };
    try app.apply(&fixture.output);
    try testing.expectEqualStrings("return {\n    input = {\n        kb_layout = \"us,ru\",\n    },\n}\n", fixture.planned("~/.config/hypr/kosm.lua"));
}

test "a keyboard name holding a comma fails the apply, naming the app and the name" {
    var fixture: Fixture = undefined;
    try fixture.init(&.{});
    defer fixture.deinit();
    var app = bareApp();
    app.keyboard = .{ .layouts = &.{ .{ .layout = "us" }, .{ .layout = "rs,ru" } } };
    try testing.expectError(error.AppFailed, app.apply(&fixture.output));
    try testing.expectEqualStrings("hyprland", fixture.diagnostics.app);
    try testing.expectEqualStrings("keyboard layout 'rs,ru' holds a comma, which separates entries; give each its own entry", fixture.diagnostics.message());
    try testing.expectEqual(0, fixture.plan.files.items.len);
}

test "curves and animations are calls before the returned table, each animation naming its curve by kind" {
    var fixture: Fixture = undefined;
    try fixture.init(&.{});
    defer fixture.deinit();
    var app = bareApp();
    app.animations.enabled = true;
    app.curve = &.{
        .{ .name = "expo_out", .curve = .ease_out_expo },
        .{ .name = "bounce", .curve = .{ .spring = .{ .stiffness = 50, .damping = 10 } } },
    };
    app.animation = &.{
        .{ .leaf = .windows, .speed = 3, .curve = "expo_out", .style = "slide bottom" },
        .{ .leaf = .windows_in, .speed = 4.5, .curve = "bounce" },
        .{ .leaf = .border_angle, .speed = 30, .curve = "default", .style = "loop" },
        .{ .leaf = .fade, .enabled = false },
    };
    try app.apply(&fixture.output);
    try testing.expectEqualStrings(
        \\hl.curve("expo_out", { type = "bezier", points = { { 0.16, 1 }, { 0.3, 1 } } })
        \\hl.curve("bounce", { type = "spring", mass = 1, stiffness = 50, damping = 10 })
        \\
        \\hl.animation({ leaf = "windows", enabled = true, speed = 3, bezier = "expo_out", style = "slide bottom" })
        \\hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.5, spring = "bounce" })
        \\hl.animation({ leaf = "borderangle", enabled = true, speed = 30, bezier = "default", style = "loop" })
        \\hl.animation({ leaf = "fade", enabled = false })
        \\
        \\return {
        \\    animations = {
        \\        enabled = true,
        \\    },
        \\}
        \\
    , fixture.planned("~/.config/hypr/kosm.lua"));
}

test "an animation naming a curve that is not defined fails the apply, naming both" {
    var fixture: Fixture = undefined;
    try fixture.init(&.{});
    defer fixture.deinit();
    var app = bareApp();
    app.curve = &.{.{ .name = "expo_out", .curve = .ease_out_expo }};
    app.animation = &.{.{ .leaf = .workspaces_in, .speed = 3, .curve = "quad_out" }};
    try testing.expectError(error.AppFailed, app.apply(&fixture.output));
    try testing.expectEqualStrings("animation 'workspacesIn' names the curve 'quad_out', which is not defined; curves: default, expo_out", fixture.diagnostics.message());
    try testing.expectEqualStrings("hyprland", fixture.diagnostics.app);
    try testing.expectEqual(0, fixture.plan.files.items.len);
}

test "curves and animations Hyprland would refuse fail the apply, each naming what is wrong" {
    const Case = struct { app: App, message: []const u8 };
    var weak_spring = bareApp();
    weak_spring.curve = &.{.{ .name = "soft", .curve = .{ .spring = .{ .stiffness = 0.2, .damping = 10 } } }};
    var twice = bareApp();
    twice.curve = &.{ .{ .name = "a", .curve = .linear }, .{ .name = "a", .curve = .ease } };
    var no_speed = bareApp();
    no_speed.animation = &.{.{ .leaf = .fade, .curve = "default" }};
    var no_curve = bareApp();
    no_curve.animation = &.{.{ .leaf = .fade, .speed = 3 }};
    var still = bareApp();
    still.animation = &.{.{ .leaf = .fade, .speed = 0, .curve = "default" }};
    var leaf_twice = bareApp();
    leaf_twice.animation = &.{ .{ .leaf = .fade, .enabled = false }, .{ .leaf = .fade, .speed = 3, .curve = "default" } };
    for ([_]Case{
        .{ .app = weak_spring, .message = "curve 'soft': its spring's stiffness is 0.2, and Hyprland takes none below 0.5" },
        .{ .app = twice, .message = "curve 'a' is defined twice" },
        .{ .app = no_speed, .message = "animation 'fade' is enabled, so it needs a speed" },
        .{ .app = no_curve, .message = "animation 'fade' is enabled, so it needs a curve" },
        .{ .app = still, .message = "animation 'fade': its speed is 0, and Hyprland takes only speeds above 0" },
        .{ .app = leaf_twice, .message = "animation 'fade' is set twice" },
    }) |case| {
        var fixture: Fixture = undefined;
        try fixture.init(&.{});
        defer fixture.deinit();
        try testing.expectError(error.AppFailed, case.app.apply(&fixture.output));
        try testing.expectEqualStrings(case.message, fixture.diagnostics.message());
    }
}

test "the edit target refuses curves and animations, which the user's files can't be given" {
    var fixture: Fixture = undefined;
    try fixture.init(&.{.{ ".config/hypr/hyprland.lua", "hl.config({ general = { gaps_in = 5 } })\n" }});
    defer fixture.deinit();
    var app = bareApp();
    app.target = .{ .edit = .{ .files = "~/.config/hypr/**/*.lua" } };
    app.curve = &.{.{ .name = "expo_out", .curve = .ease_out_expo }};
    try testing.expectError(error.AppFailed, app.apply(&fixture.output));
    try testing.expect(std.mem.find(u8, fixture.diagnostics.message(), "curves and animations are calls") != null);
}

test "environment variables are hl.env calls in order, derived ones first and yielding to set ones" {
    var fixture: Fixture = undefined;
    try fixture.init(&.{});
    defer fixture.deinit();
    var app = bareApp();
    app.cursor_theme = "Bibata";
    app.cursor_size = 24;
    app.gtk_theme = "Krystallos";
    app.qt_platform_theme = "qt6ct";
    app.env = &.{
        .{ .name = "XDG_CURRENT_DESKTOP", .value = "Hyprland" },
        .{ .name = "XCURSOR_SIZE", .value = "32" },
        .{ .name = "QT_QPA_PLATFORM", .value = "wayland;xcb" },
    };
    try app.apply(&fixture.output);
    try testing.expectEqualStrings(
        \\hl.env("HYPRCURSOR_THEME", "Bibata")
        \\hl.env("XCURSOR_THEME", "Bibata")
        \\hl.env("HYPRCURSOR_SIZE", "24")
        \\hl.env("GTK_THEME", "Krystallos")
        \\hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
        \\hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
        \\hl.env("XCURSOR_SIZE", "32")
        \\hl.env("QT_QPA_PLATFORM", "wayland;xcb")
        \\
        \\return {}
        \\
    , fixture.planned("~/.config/hypr/kosm.lua"));
}

test "an environment variable set twice fails the apply, naming it and both values" {
    var fixture: Fixture = undefined;
    try fixture.init(&.{});
    defer fixture.deinit();
    var app = bareApp();
    app.env = &.{ .{ .name = "GTK_THEME", .value = "a" }, .{ .name = "TERMINAL", .value = "kitty" }, .{ .name = "GTK_THEME", .value = "b" } };
    try testing.expectError(error.AppFailed, app.apply(&fixture.output));
    try testing.expectEqualStrings("environment variable 'GTK_THEME' is set twice, to 'a' and to 'b'", fixture.diagnostics.message());

    app.env = &.{.{ .name = "GTK_THEME=a", .value = "" }};
    try testing.expectError(error.AppFailed, app.apply(&fixture.output));
    try testing.expect(std.mem.find(u8, fixture.diagnostics.message(), "holds a '='") != null);
    try testing.expectEqual(0, fixture.plan.files.items.len);
}

test "the edit target refuses environment variables, set or derived" {
    var fixture: Fixture = undefined;
    try fixture.init(&.{.{ ".config/hypr/hyprland.lua", "hl.config({ general = { gaps_in = 5 } })\n" }});
    defer fixture.deinit();
    var app = bareApp();
    app.target = .{ .edit = .{ .files = "~/.config/hypr/**/*.lua" } };
    app.cursor_size = 24;
    try testing.expectError(error.AppFailed, app.apply(&fixture.output));
    try testing.expect(std.mem.find(u8, fixture.diagnostics.message(), "environment variables are calls") != null);
}
