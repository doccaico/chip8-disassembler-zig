const std = @import("std");

const CSYM = ";";
const CBEF = " " ++ CSYM ++ " ";

fn disassembleCHIP8(stdout: anytype, code: []const u8, pc: u16, show_comment: bool) !void {
    try stdout.print("{X:0>4} {X:0>2} {X:0>2} ", .{ pc, code[pc], code[pc + 1] });

    switch (code[pc] >> 4) {
        0x0 => {
            switch (code[pc + 1] >> 4) {
                0xB => {
                    try stdout.print("{s: >7} 0x{X:0>1}", .{ "SCU", code[pc + 1] & 0x0F });
                    if (show_comment) {
                        try stdout.print("         " ++ CBEF ++ "Scroll up N pixels (N/2 pixels in low res mode)", .{});
                    }
                    return;
                },
                0xC => {
                    try stdout.print("{s: >7} 0x{X:0>1}", .{ "SCD", code[pc + 1] & 0x0F });
                    if (show_comment) {
                        try stdout.print("         " ++ CBEF ++ "Scroll down N pixels (N/2 pixels in low res mode)", .{});
                    }
                    return;
                },
                else => {},
            }
            switch (code[pc + 1]) {
                0xE0 => {
                    try stdout.print("{s: >7}", .{"CLS"});
                    if (show_comment) {
                        try stdout.print("             " ++ CBEF ++ "Clears the screen", .{});
                    }
                    return;
                },
                0xEE => {
                    try stdout.print("{s: >7}", .{"RET"});
                    if (show_comment) {
                        try stdout.print("             " ++ CBEF ++ "Returns from a subroutine", .{});
                    }
                    return;
                },
                0xFB => {
                    try stdout.print("{s: >7}", .{"SCR"});
                    if (show_comment) {
                        try stdout.print("             " ++ CBEF ++ "Scroll right 4 pixels (2 pixels in low res mode)", .{});
                    }
                    return;
                },
                0xFC => {
                    try stdout.print("{s: >7}", .{"SCL"});
                    if (show_comment) {
                        try stdout.print("             " ++ CBEF ++ "Scroll left 4 pixels (2 pixels in low res mode)", .{});
                    }
                    return;
                },
                0xFD => {
                    try stdout.print("{s: >8}", .{"EXIT"});
                    if (show_comment) {
                        try stdout.print("            " ++ CBEF ++ "Exit the interpreter; this causes the VM to infinite loop", .{});
                    }
                    return;
                },
                0xFE => {
                    try stdout.print("{s: >7}", .{"LOW"});
                    if (show_comment) {
                        try stdout.print("             " ++ CBEF ++ "Enter low resolution (64x32) mode; this is the default mode", .{});
                    }
                    return;
                },
                0xFF => {
                    try stdout.print("{s: >8}", .{"HIGH"});
                    if (show_comment) {
                        try stdout.print("            " ++ CBEF ++ "Enter high resolution (128x64) mode", .{});
                    }
                    return;
                },
                else => {},
            }

            try stdout.print("{s: >7} 0x{X:0>1}{X:0>2}", .{ "SYS", code[pc] & 0x0F, code[pc + 1] });
            if (show_comment) {
                try stdout.print("       " ++ CBEF ++ "Call CDP1802 code at 0x{X:0>1}{X:0>2}", .{ code[pc] & 0x0F, code[pc + 1] });
            }
        },
        0x1 => {
            try stdout.print("{s: >7} 0x{X:0>1}{X:0>2}", .{ "JMP", code[pc] & 0x0f, code[pc + 1] });
            if (show_comment) {
                try stdout.print("       " ++ CBEF ++ "Jumps to address 0x{X:0>1}{X:0>2}", .{ code[pc] & 0x0F, code[pc + 1] });
            }
            return;
        },
        0x2 => {
            try stdout.print("{s: >8} 0x{X:0>1}{X:0>2}", .{ "CALL", code[pc] & 0x0f, code[pc + 1] });
            if (show_comment) {
                try stdout.print("      " ++ CBEF ++ "Calls subroutine at 0x{X:0>1}{X:0>2}", .{ code[pc] & 0x0F, code[pc + 1] });
            }
            return;
        },
        0x3 => {
            try stdout.print("{s: >6} V{X:0>1} 0x{X:0>2}", .{ "JE", code[pc] & 0x0F, code[pc + 1] });
            if (show_comment) {
                try stdout.print("      " ++ CBEF ++ "Skips the next instruction if V{X:0>1} equals 0x{X:0>2}", .{ code[pc] & 0x0F, code[pc + 1] });
            }
            return;
        },
        0x4 => {
            try stdout.print("{s: >7} V{X:0>1} 0x{X:0>2}", .{ "JNE", code[pc] & 0x0F, code[pc + 1] });
            if (show_comment) {
                try stdout.print("     " ++ CBEF ++ "Skips the next instruction if V{X:0>1} doesn't equal 0x{X:0>2}", .{ code[pc] & 0x0F, code[pc + 1] });
            }
            return;
        },
        0x5 => {
            try stdout.print("{s: >6} V{X:0>1} V{X:0>1}", .{ "JE", code[pc] & 0x0F, code[pc + 1] >> 4 });
            if (show_comment) {
                try stdout.print("        " ++ CBEF ++ "Skips the next instruction if V{X:0>1} equals V{X:0>1}", .{ code[pc] & 0x0F, code[pc + 1] >> 4 });
            }
            return;
        },
        0x6 => {
            try stdout.print("{s: >7} V{X:0>1} 0x{X:0>2}", .{ "MOV", code[pc] & 0x0F, code[pc + 1] });
            if (show_comment) {
                try stdout.print("     " ++ CBEF ++ "Sets V{X:0>1} to 0x{X:0>2}", .{ code[pc] & 0x0F, code[pc + 1] });
            }
            return;
        },
        0x7 => {
            try stdout.print("{s: >7} V{X:0>1} 0x{X:0>2}", .{ "ADD", code[pc] & 0x0F, code[pc + 1] });
            if (show_comment) {
                try stdout.print("     " ++ CBEF ++ "Adds 0x{X:0>2} to V{X:0>1}", .{ code[pc + 1], code[pc] & 0x0F });
            }
            return;
        },
        0x8 => {
            switch (code[pc + 1] & 0x0F) {
                0x0 => {
                    try stdout.print("{s: >7} V{X:0>1} V{X:0>1}", .{ "MOV", code[pc] & 0x0F, code[pc + 1] >> 4 });
                    if (show_comment) {
                        try stdout.print("       " ++ CBEF ++ "Sets V{X:0>1} to the value of V{X:0>1}", .{ code[pc] & 0x0F, code[pc + 1] >> 4 });
                    }
                    return;
                },
                0x1 => {
                    try stdout.print("{s: >6} V{X:0>1} V{X:0>1}", .{ "OR", code[pc] & 0x0F, code[pc + 1] >> 4 });
                    if (show_comment) {
                        try stdout.print("        " ++ CBEF ++ "Sets V{X:0>1} to V{X:0>1} or V{X:0>1}", .{ code[pc] & 0x0F, code[pc] & 0x0F, code[pc + 1] >> 4 });
                    }
                    return;
                },
                0x2 => {
                    try stdout.print("{s: >7} V{X:0>1} V{X:0>1}", .{ "AND", code[pc] & 0x0F, code[pc + 1] >> 4 });
                    if (show_comment) {
                        try stdout.print("       " ++ CBEF ++ "Sets V{X:0>1} to V{X:0>1} and V{X:0>1}", .{ code[pc] & 0x0F, code[pc] & 0x0F, code[pc + 1] >> 4 });
                    }
                    return;
                },
                0x3 => {
                    try stdout.print("{s: >7} V{X:0>1} V{X:0>1}", .{ "XOR", code[pc] & 0x0F, code[pc + 1] >> 4 });
                    if (show_comment) {
                        try stdout.print("       " ++ CBEF ++ "Sets V{X:0>1} to V{X:0>1} xor V{X:0>1}", .{ code[pc] & 0x0F, code[pc] & 0x0F, code[pc + 1] >> 4 });
                    }
                    return;
                },
                0x4 => {
                    try stdout.print("{s: >7} V{X:0>1} V{X:0>1}", .{ "ADD", code[pc] & 0x0F, code[pc + 1] >> 4 });
                    if (show_comment) {
                        try stdout.print("       " ++ CBEF ++ "Adds V{X:0>1} to V{X:0>1}. VF is set to 1 when there's a carry, and to 0 when there isn't", .{ code[pc + 1] >> 4, code[pc] & 0x0F });
                    }
                    return;
                },
                0x5 => {
                    try stdout.print("{s: >7} V{X:0>1} V{X:0>1}", .{ "SUB", code[pc] & 0x0F, code[pc + 1] >> 4 });
                    if (show_comment) {
                        try stdout.print("       " ++ CBEF ++ "V{X:0>1} is subtracted from V{X:0>1}. VF is set to 0 when there's a borrow, and 1 when there isn't", .{ code[pc + 1] >> 4, code[pc] & 0x0F });
                    }
                    return;
                },
                0x6 => {
                    try stdout.print("{s: >10} V{X:0>1}", .{ "RSHIFT", code[pc] & 0x0F });
                    if (show_comment) {
                        try stdout.print("       " ++ CBEF ++ "Shifts V{X:0>1} right by one. VF is set to the value of the least significant bit of V{X:0>1}\n                               " ++ CBEF ++ "  before the shift", .{ code[pc] & 0x0F, code[pc] & 0x0F });
                    }
                    return;
                },
                0x7 => {
                    try stdout.print("{s: >10} V{X:0>1} V{X:0>1}", .{ "SUBREV", code[pc] & 0x0F, code[pc + 1] >> 4 });
                    if (show_comment) {
                        try stdout.print("    " ++ CBEF ++ "Sets V{X:0>1} to V{X:0>1} minus V{X:0>1}. VF is set to 0 when there's a borrow, and 1 when there isn't", .{ code[pc] & 0x0F, code[pc + 1] >> 4, code[pc] & 0x0F });
                    }
                    return;
                },
                0xE => {
                    try stdout.print("{s: >10} V{X:0>1}", .{ "LSHIFT", code[pc] & 0x0F });
                    if (show_comment) {
                        try stdout.print("       " ++ CBEF ++ "Shifts V{X:0>1} left by one. VF is set to the value of the most significant bit of V{X:0>1}\n                               " ++ CBEF ++ "  before the shift", .{ code[pc] & 0x0F, code[pc] & 0x0F });
                    }
                    return;
                },
                else => {},
            }
        },
        0x9 => {
            try stdout.print("{s: >7} V{X:0>1} V{X:0>1}", .{ "JNE", code[pc] & 0x0F, code[pc + 1] >> 4 });
            if (show_comment) {
                try stdout.print("       " ++ CBEF ++ "Skips the next instruction if V{X:0>1} doesn't equal V{X:0>1}", .{ code[pc] & 0x0F, code[pc + 1] >> 4 });
            }
            return;
        },
        0xA => {
            try stdout.print("{s: >7} I 0x{X:0>1}{X:0>2}", .{ "MOV", code[pc] & 0x0F, code[pc + 1] });
            if (show_comment) {
                try stdout.print("     " ++ CBEF ++ "Sets I to 0x{X:0>1}{X:0>2}", .{ code[pc] & 0x0F, code[pc + 1] });
            }
            return;
        },
        0xB => {
            try stdout.print("{s: >10} 0x{X:0>1}{X:0>2}", .{ "JMP V0", code[pc] & 0x0F, code[pc + 1] });
            if (show_comment) {
                try stdout.print("    " ++ CBEF ++ "Jumps to the address 0x{X:0>1}{X:0>2} plus V0", .{ code[pc] & 0x0F, code[pc + 1] });
            }
            return;
        },
        0xC => {
            try stdout.print("{s: >8} V{X:0>1} 0x{X:0>2}", .{ "RAND", code[pc] & 0x0F, code[pc + 1] });
            if (show_comment) {
                try stdout.print("    " ++ CBEF ++ "Sets V{X:0>1} to a random number and 0x{X:0>2}", .{ code[pc] & 0x0F, code[pc + 1] });
            }
            return;
        },
        0xD => {
            try stdout.print("{s: >10} V{X:0>1} V{X:0>1} 0x{X:0>1}", .{ "SPRITE", code[pc] & 0x0F, code[pc + 1] >> 4, code[pc + 1] & 0x0F });
            if (show_comment) {
                try stdout.print(CBEF ++ "Sprites stored in memory at location in index register (I), maximum 8bits wide.\n                               " ++ CBEF ++ "  Wraps around the screen. If when drawn, clears a pixel, register VF is set to 1\n                               " ++ CBEF ++ "  otherwise it is zero. All drawing is XOR drawing (i.e. it toggles the screen pixels)", .{});
            }
            return;
        },
        0xE => {
            switch (code[pc + 1]) {
                0x9E => {
                    try stdout.print("{s: >7} V{X:0>1}", .{ "SKP", code[pc] & 0x0F });
                    if (show_comment) {
                        try stdout.print("          " ++ CBEF ++ "Skips the next instruction if the key stored in V{X:0>1} is pressed", .{code[pc] & 0x0F});
                    }
                    return;
                },
                0xA1 => {
                    try stdout.print("{s: >8} V{X:0>1}", .{ "SKNP", code[pc] & 0x0F });
                    if (show_comment) {
                        try stdout.print("         " ++ CBEF ++ "Skips the next instruction if the key stored in V{X:0>1} isn't pressed", .{code[pc] & 0x0F});
                    }
                    return;
                },
                else => {
                    std.debug.panic("unknown bytes: 0x{X:0>2}{X:0>2}", .{ code[pc], code[pc + 1] });
                },
            }
        },
        0xF => {
            switch (code[pc + 1]) {
                0x07 => {
                    try stdout.print("{s: >7} V{X:0>1} DT", .{ "MOV", code[pc] & 0x0F });
                    if (show_comment) {
                        try stdout.print("       " ++ CBEF ++ "Sets V{X:0>1} to the value of the DT (delay timer)", .{code[pc] & 0x0F});
                    }
                    return;
                },
                0x0A => {
                    try stdout.print("{s: >11} V{X:0>1}", .{ "WAITKEY", code[pc] & 0x0F });
                    if (show_comment) {
                        try stdout.print("      " ++ CBEF ++ "A key press is awaited, and then stored in V{X:0>1}", .{code[pc] & 0x0F});
                    }
                    return;
                },
                0x15 => {
                    try stdout.print("{s: >10} V{X:0>1}", .{ "MOV DT", code[pc] & 0x0F });
                    if (show_comment) {
                        try stdout.print("       " ++ CBEF ++ "Sets the DT (delay timer) to V{X:0>1}", .{code[pc] & 0x0F});
                    }
                    return;
                },
                0x18 => {
                    try stdout.print("{s: >10} V{X:0>1}", .{ "MOV ST", code[pc] & 0x0F });
                    if (show_comment) {
                        try stdout.print("       " ++ CBEF ++ "Sets the ST (sound timer) to V{X:0>1}", .{code[pc] & 0x0F});
                    }
                    return;
                },
                0x1E => {
                    try stdout.print("{s: >9} V{X:0>1}", .{ "ADD I", code[pc] & 0x0F });
                    if (show_comment) {
                        try stdout.print("        " ++ CBEF ++ "Adds V{X:0>1} to I", .{code[pc] & 0x0F});
                    }
                    return;
                },
                0x29 => {
                    try stdout.print("{s: >12} V{X:0>1}", .{ "FONTLOAD", code[pc] & 0x0F });
                    if (show_comment) {
                        try stdout.print("     " ++ CBEF ++ "Sets I to the location of the sprite for the character in V{X:0>1}.\n                               " ++ CBEF ++ "  Characters 0-F (in hexadecimal) are represented by a 4x5 font", .{code[pc] & 0x0F});
                    }
                    return;
                },
                0x33 => {
                    try stdout.print("{s: >12} V{X:0>1}", .{ "STOBCD I", code[pc] & 0x0F });
                    if (show_comment) {
                        try stdout.print("     " ++ CBEF ++ "Stores the BCD (Binary-coded decimal) representation of V{X:0>1},\n                               " ++ CBEF ++ "  with the most significant of three digits at the address in I,\n                               " ++ CBEF ++ "  the middle digit at I plus 1, and the least significant digit at I plus 2.\n                               " ++ CBEF ++ "  (In other words, take the decimal representation of V{X:0>1},\n                               " ++ CBEF ++ "  place the hundreds digit in memory at location in I,\n                               " ++ CBEF ++ "  the tens digit at location I+1, and the ones digit at location I+2.)", .{ code[pc] & 0x0F, code[pc] & 0x0F });
                    }
                    return;
                },
                0x55 => {
                    try stdout.print("{s: >9} V{X:0>1}", .{ "STO I", code[pc] & 0x0F });
                    if (show_comment) {
                        try stdout.print("        " ++ CBEF ++ "Stores V0 to V{X:0>1} in memory starting at address I", .{code[pc] & 0x0F});
                    }
                    return;
                },
                0x65 => {
                    try stdout.print("{s: >8} V{X:0>1} I", .{ "LOAD", code[pc] & 0x0F });
                    if (show_comment) {
                        try stdout.print("       " ++ CBEF ++ "Fills V0 to V{X:0>1} with values from memory starting at address I", .{code[pc] & 0x0F});
                    }
                    return;
                },
                else => {
                    std.debug.panic("unknown bytes: 0x{X:0>2}{X:0>2}", .{ code[pc], code[pc + 1] });
                },
            }
            return;
        },
        else => unreachable,
    }
}

fn usage(stdout: anytype) noreturn {
    stdout.writeAll(
        \\Usage: xxx [options] filepath
        \\
        \\Options:
        \\    -c, --comment     display comments
        \\
    ) catch {};
    std.process.exit(1);
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var arg_it = try std.process.argsWithAllocator(allocator);
    defer arg_it.deinit();

    _ = arg_it.skip();

    const stdout = std.io.getStdOut().writer();
    const stderr = std.io.getStdErr().writer();

    // default option
    var option_comment = false;
    var option_help = false;
    var file_path: []const u8 = "";

    while (arg_it.next()) |arg| {
        if (arg[0] == '-') {
            if (std.mem.eql(u8, arg, "-c") or std.mem.eql(u8, arg, "--comment")) {
                option_comment = true;
            } else if (std.mem.eql(u8, arg, "-h") or std.mem.eql(u8, arg, "--help")) {
                option_help = true;
                usage(stdout);
            } else {
                try stderr.print("unknown option: '{s}'\n", .{arg});
                usage(stdout);
            }
        } else {
            file_path = arg;
        }
    }

    if (file_path.len == 0)
        usage(stdout);

    var rom_file = try std.fs.cwd().openFile(file_path, .{ .mode = .read_only });

    // 0x1000(4096) - 0x200(512) = E00(3584)
    var buffer: [0x1000 - 0x200]u8 = undefined;

    const read_size = try rom_file.readAll(buffer[0x200..]);

    var pc: u16 = 0x200;
    while (pc < read_size + 0x200) : (pc += 2) {
        try disassembleCHIP8(stdout, &buffer, pc, option_comment);
        try stdout.writeByte('\n');
    }
}

test "test_display" {
    const S = struct {
        const show_comment = true;
        // const show_comment = false;

        pub fn cm(comment: []const u8) []const u8 {
            if (show_comment) {
                return comment;
            } else {
                return "";
            }
        }
    };

    var list = std.ArrayList(u8).init(std.testing.allocator);
    defer list.deinit();

    var string_list: std.ArrayList([]const u8) = undefined;
    if (S.show_comment) {
        string_list = std.ArrayList([]const u8).init(std.testing.allocator);
    }

    const Test = struct {
        []const u8,
        []const u8,
    };
    const tests = [_]Test{
        .{ &[_]u8{ 0x00, 0xBF }, "0000 00 BF     " ++ "SCU 0xF" ++ comptime b: {
            break :b S.cm("         " ++ CBEF ++ "Scroll up N pixels (N/2 pixels in low res mode)");
        } },
        .{ &[_]u8{ 0x00, 0xC5 }, "0000 00 C5     " ++ "SCD 0x5" ++ comptime b: {
            break :b S.cm("         " ++ CBEF ++ "Scroll down N pixels (N/2 pixels in low res mode)");
        } },
        .{ &[_]u8{ 0x00, 0xE0 }, "0000 00 E0     " ++ "CLS" ++ comptime b: {
            break :b S.cm("             " ++ CBEF ++ "Clears the screen");
        } },
        .{ &[_]u8{ 0x00, 0xEE }, "0000 00 EE     " ++ "RET" ++ comptime b: {
            break :b S.cm("             " ++ CBEF ++ "Returns from a subroutine");
        } },
        .{ &[_]u8{ 0x00, 0xFB }, "0000 00 FB     " ++ "SCR" ++ comptime b: {
            break :b S.cm("             " ++ CBEF ++ "Scroll right 4 pixels (2 pixels in low res mode)");
        } },
        .{ &[_]u8{ 0x00, 0xFC }, "0000 00 FC     " ++ "SCL" ++ comptime b: {
            break :b S.cm("             " ++ CBEF ++ "Scroll left 4 pixels (2 pixels in low res mode)");
        } },
        .{ &[_]u8{ 0x00, 0xFD }, "0000 00 FD     " ++ "EXIT" ++ comptime b: {
            break :b S.cm("            " ++ CBEF ++ "Exit the interpreter; this causes the VM to infinite loop");
        } },
        .{ &[_]u8{ 0x00, 0xFE }, "0000 00 FE     " ++ "LOW" ++ comptime b: {
            break :b S.cm("             " ++ CBEF ++ "Enter low resolution (64x32) mode; this is the default mode");
        } },
        .{ &[_]u8{ 0x00, 0xFF }, "0000 00 FF     " ++ "HIGH" ++ comptime b: {
            break :b S.cm("            " ++ CBEF ++ "Enter high resolution (128x64) mode");
        } },
        .{ &[_]u8{ 0x01, 0x23 }, "0000 01 23     " ++ "SYS 0x123" ++ comptime b: {
            break :b S.cm("       " ++ CBEF ++ "Call CDP1802 code at 0x123");
        } },
        .{ &[_]u8{ 0x1A, 0xBC }, "0000 1A BC     " ++ "JMP 0xABC" ++ comptime b: {
            break :b S.cm("       " ++ CBEF ++ "Jumps to address 0xABC");
        } },
        .{ &[_]u8{ 0x2A, 0xBC }, "0000 2A BC     " ++ "CALL 0xABC" ++ comptime b: {
            break :b S.cm("      " ++ CBEF ++ "Calls subroutine at 0xABC");
        } },
        .{ &[_]u8{ 0x3A, 0xBC }, "0000 3A BC     " ++ "JE VA 0xBC" ++ comptime b: {
            break :b S.cm("      " ++ CBEF ++ "Skips the next instruction if VA equals 0xBC");
        } },
        .{ &[_]u8{ 0x4A, 0xBC }, "0000 4A BC     " ++ "JNE VA 0xBC" ++ comptime b: {
            break :b S.cm("     " ++ CBEF ++ "Skips the next instruction if VA doesn't equal 0xBC");
        } },
        .{ &[_]u8{ 0x5A, 0xB0 }, "0000 5A B0     " ++ "JE VA VB" ++ comptime b: {
            break :b S.cm("        " ++ CBEF ++ "Skips the next instruction if VA equals VB");
        } },
        .{ &[_]u8{ 0x6A, 0xBC }, "0000 6A BC     " ++ "MOV VA 0xBC" ++ comptime b: {
            break :b S.cm("     " ++ CBEF ++ "Sets VA to 0xBC");
        } },
        .{ &[_]u8{ 0x7A, 0xBC }, "0000 7A BC     " ++ "ADD VA 0xBC" ++ comptime b: {
            break :b S.cm("     " ++ CBEF ++ "Adds 0xBC to VA");
        } },
        .{ &[_]u8{ 0x8A, 0xB0 }, "0000 8A B0     " ++ "MOV VA VB" ++ comptime b: {
            break :b S.cm("       " ++ CBEF ++ "Sets VA to the value of VB");
        } },
        .{ &[_]u8{ 0x8A, 0xB1 }, "0000 8A B1     " ++ "OR VA VB" ++ comptime b: {
            break :b S.cm("        " ++ CBEF ++ "Sets VA to VA or VB");
        } },
        .{ &[_]u8{ 0x8A, 0xB2 }, "0000 8A B2     " ++ "AND VA VB" ++ comptime b: {
            break :b S.cm("       " ++ CBEF ++ "Sets VA to VA and VB");
        } },
        .{ &[_]u8{ 0x8A, 0xB3 }, "0000 8A B3     " ++ "XOR VA VB" ++ comptime b: {
            break :b S.cm("       " ++ CBEF ++ "Sets VA to VA xor VB");
        } },
        .{ &[_]u8{ 0x8A, 0xB4 }, "0000 8A B4     " ++ "ADD VA VB" ++ comptime b: {
            break :b S.cm("       " ++ CBEF ++ "Adds VB to VA. VF is set to 1 when there's a carry, and to 0 when there isn't");
        } },
        .{ &[_]u8{ 0x8A, 0xB5 }, "0000 8A B5     " ++ "SUB VA VB" ++ comptime b: {
            break :b S.cm("       " ++ CBEF ++ "VB is subtracted from VA. VF is set to 0 when there's a borrow, and 1 when there isn't");
        } },
        .{ &[_]u8{ 0x8A, 0x06 }, "0000 8A 06     " ++ "RSHIFT VA" ++ comptime b: {
            break :b S.cm("       " ++ CBEF ++ "Shifts VA right by one. VF is set to the value of the least significant bit of VA\n                               " ++ CBEF ++ "  before the shift");
        } },
        .{ &[_]u8{ 0x8A, 0xB7 }, "0000 8A B7     " ++ "SUBREV VA VB" ++ comptime b: {
            break :b S.cm("    " ++ CBEF ++ "Sets VA to VB minus VA. VF is set to 0 when there's a borrow, and 1 when there isn't");
        } },
        .{ &[_]u8{ 0x8A, 0x0E }, "0000 8A 0E     " ++ "LSHIFT VA" ++ comptime b: {
            break :b S.cm("       " ++ CBEF ++ "Shifts VA left by one. VF is set to the value of the most significant bit of VA\n                               " ++ CBEF ++ "  before the shift");
        } },
        .{ &[_]u8{ 0x9A, 0xB0 }, "0000 9A B0     " ++ "JNE VA VB" ++ comptime b: {
            break :b S.cm("       " ++ CBEF ++ "Skips the next instruction if VA doesn't equal VB");
        } },
        .{ &[_]u8{ 0xA1, 0x23 }, "0000 A1 23     " ++ "MOV I 0x123" ++ comptime b: {
            break :b S.cm("     " ++ CBEF ++ "Sets I to 0x123");
        } },
        .{ &[_]u8{ 0xB1, 0x23 }, "0000 B1 23     " ++ "JMP V0 0x123" ++ comptime b: {
            break :b S.cm("    " ++ CBEF ++ "Jumps to the address 0x123 plus V0");
        } },
        .{ &[_]u8{ 0xCA, 0x12 }, "0000 CA 12     " ++ "RAND VA 0x12" ++ comptime b: {
            break :b S.cm("    " ++ CBEF ++ "Sets VA to a random number and 0x12");
        } },
        .{ &[_]u8{ 0xDA, 0xBC }, "0000 DA BC     " ++ "SPRITE VA VB 0xC" ++ comptime b: {
            break :b S.cm(CBEF ++ "Sprites stored in memory at location in index register (I), maximum 8bits wide.\n                               " ++ CBEF ++ "  Wraps around the screen. If when drawn, clears a pixel, register VF is set to 1\n                               " ++ CBEF ++ "  otherwise it is zero. All drawing is XOR drawing (i.e. it toggles the screen pixels)");
        } },
        .{ &[_]u8{ 0xEA, 0x9E }, "0000 EA 9E     " ++ "SKP VA" ++ comptime b: {
            break :b S.cm("          " ++ CBEF ++ "Skips the next instruction if the key stored in VA is pressed");
        } },
        .{ &[_]u8{ 0xEA, 0xA1 }, "0000 EA A1     " ++ "SKNP VA" ++ comptime b: {
            break :b S.cm("         " ++ CBEF ++ "Skips the next instruction if the key stored in VA isn't pressed");
        } },
        .{ &[_]u8{ 0xFA, 0x07 }, "0000 FA 07     " ++ "MOV VA DT" ++ comptime b: {
            break :b S.cm("       " ++ CBEF ++ "Sets VA to the value of the DT (delay timer)");
        } },
        .{ &[_]u8{ 0xFA, 0x0A }, "0000 FA 0A     " ++ "WAITKEY VA" ++ comptime b: {
            break :b S.cm("      " ++ CBEF ++ "A key press is awaited, and then stored in VA");
        } },
        .{ &[_]u8{ 0xFA, 0x15 }, "0000 FA 15     " ++ "MOV DT VA" ++ comptime b: {
            break :b S.cm("       " ++ CBEF ++ "Sets the DT (delay timer) to VA");
        } },
        .{ &[_]u8{ 0xFA, 0x18 }, "0000 FA 18     " ++ "MOV ST VA" ++ comptime b: {
            break :b S.cm("       " ++ CBEF ++ "Sets the ST (sound timer) to VA");
        } },
        .{ &[_]u8{ 0xFA, 0x1E }, "0000 FA 1E     " ++ "ADD I VA" ++ comptime b: {
            break :b S.cm("        " ++ CBEF ++ "Adds VA to I");
        } },
        .{ &[_]u8{ 0xFA, 0x29 }, "0000 FA 29     " ++ "FONTLOAD VA" ++ comptime b: {
            break :b S.cm("     " ++ CBEF ++ "Sets I to the location of the sprite for the character in VA.\n                               " ++ CBEF ++ "  Characters 0-F (in hexadecimal) are represented by a 4x5 font");
        } },
        .{ &[_]u8{ 0xFA, 0x33 }, "0000 FA 33     " ++ "STOBCD I VA" ++ comptime b: {
            break :b S.cm("     " ++ CBEF ++ "Stores the BCD (Binary-coded decimal) representation of VA,\n                               " ++ CBEF ++ "  with the most significant of three digits at the address in I,\n                               " ++ CBEF ++ "  the middle digit at I plus 1, and the least significant digit at I plus 2.\n                               " ++ CBEF ++ "  (In other words, take the decimal representation of VA,\n                               " ++ CBEF ++ "  place the hundreds digit in memory at location in I,\n                               " ++ CBEF ++ "  the tens digit at location I+1, and the ones digit at location I+2.)");
        } },
        .{ &[_]u8{ 0xFA, 0x55 }, "0000 FA 55     " ++ "STO I VA" ++ comptime b: {
            break :b S.cm("        " ++ CBEF ++ "Stores V0 to VA in memory starting at address I");
        } },
        .{ &[_]u8{ 0xFA, 0x65 }, "0000 FA 65     " ++ "LOAD VA I" ++ comptime b: {
            break :b S.cm("       " ++ CBEF ++ "Fills V0 to VA with values from memory starting at address I");
        } },
    };

    for (tests) |t| {
        try disassembleCHIP8(list.writer().any(), t[0], 0, S.show_comment);
        const actual = list.items;
        const expected = t[1];
        if (S.show_comment) {
            try string_list.append(expected);
        }
        try std.testing.expectEqualStrings(expected, actual);
        list.clearRetainingCapacity();
    }

    if (S.show_comment) {
        std.debug.print("\n", .{});
        for (string_list.items) |s| {
            std.debug.print("{s}\n", .{s});
        }
        string_list.deinit();
    }
}
