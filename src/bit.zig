const std = @import("std");
const fmt = std.fmt;
const mem = std.mem;
const print = std.debug.print;
const assert = std.debug.assert;
const expect = std.testing.expect;

const CSYM = ";";
const CBEF = " " ++ CSYM ++ " ";

pub fn main() !void {
    // const v = 0b01011010;
    // print("{x}\n", .{v >> 4});
    // print("{d}\n", .{v});

    const stdout = std.io.getStdOut().writer();
    const show_comments = true;
    const pc = 0;
    const code = [_]u8{ 0x00, 0xD5 };

    const firstnib: u8 = code[0] >> 4;

    switch (firstnib) {
        0x00 => {
            switch (code[pc + 1] >> 4) {
                0xB => {
                    try stdout.print("{s: >7} 0x{X:0>1}        ", .{ "SCU", code[pc + 1] & 0x0f });
                    if (!show_comments) {
                        try stdout.print(CBEF ++ "Scroll up N pixels (N/2 pixels in low res mode)", .{});
                    }
                },
                0xC => {
                    try stdout.print("{s: >7} 0x{X:0>1}        ", .{ "SCD", code[pc + 1] & 0x0f });
                    if (!show_comments) {
                        try stdout.print(CBEF ++ "Scroll down N pixels (N/2 pixels in low res mode)", .{});
                    }
                },
                else => {},
            }
            switch (code[pc + 1]) {
                0xE0 => {
                    try stdout.print("{s: >7}         ", .{"CLS"});
                    if (!show_comments) {
                        try stdout.print(CBEF ++ "Clears the screen", .{});
                    }
                },
                0xEE => {
                    try stdout.print("{s: >7}         ", .{"RET"});
                    if (!show_comments) {
                        try stdout.print(CBEF ++ "Returns from a subroutine", .{});
                    }
                },
                0xFB => {
                    try stdout.print("{s: >7}         ", .{"SCR"});
                    if (!show_comments) {
                        try stdout.print(CBEF ++ "Scroll right 4 pixels (2 pixels in low res mode)", .{});
                    }
                },
                0xFC => {
                    try stdout.print("{s: >7}         ", .{"SCL"});
                    if (!show_comments) {
                        try stdout.print(CBEF ++ "Scroll left 4 pixels (2 pixels in low res mode)", .{});
                    }
                },
                0xFD => {
                    try stdout.print("{s: >7}         ", .{"EXIT"});
                    if (!show_comments) {
                        try stdout.print(CBEF ++ "Exit the interpreter; this causes the VM to infinite loop", .{});
                    }
                },
                0xFE => {
                    try stdout.print("{s: >7}         ", .{"LOW"});
                    if (!show_comments) {
                        try stdout.print(CBEF ++ "Enter low resolution (64x32) mode; this is the default mode", .{});
                    }
                },
                0xFF => {
                    try stdout.print("{s: >7}         ", .{"HIGH"});
                    if (!show_comments) {
                        try stdout.print(CBEF ++ "Enter high resolution (128x64) mode", .{});
                    }
                },
                else => {
                    std.debug.panic("unknown bytes: 0x{X:0>2}{X:0>2}", .{ code[pc], code[pc + 1] });
                },
            }
        },
        0x01 => try stdout.print("1 not handled yet", .{}),
        0x02 => try stdout.print("2 not handled yet", .{}),
        0x03 => try stdout.print("3 not handled yet", .{}),
        0x04 => try stdout.print("4 not handled yet", .{}),
        0x05 => try stdout.print("5 not handled yet", .{}),
        0x06 => {
            try stdout.print("{s: >7} V{X:0>1}, 0x{X:0>2}", .{ "MOV", code[pc] & 0x0f, code[pc + 1] });
            if (!show_comments) {
                try stdout.print(CBEF ++ "Sets V{X:0>1} to 0x{X:0>2}", .{ code[pc] & 0x0f, code[pc + 1] });
            }
        },
        0x07 => try stdout.print("7 not handled yet", .{}),
        0x08 => try stdout.print("8 not handled yet", .{}),
        0x09 => try stdout.print("9 not handled yet", .{}),
        0x0A => {
            try stdout.print("{s: >7} I, 0x{X:0>1}{X:0>2}", .{ "MOV", code[pc] & 0x0f, code[pc + 1] });
            if (!show_comments)
                try stdout.print(CBEF ++ "Sets I to 0x{X:0>1}{X:0>2}", .{ code[pc] & 0x0f, code[pc + 1] });
        },
        0x0B => try stdout.print("b not handled yet", .{}),
        0x0C => try stdout.print("c not handled yet", .{}),
        0x0D => try stdout.print("d not handled yet", .{}),
        0x0E => try stdout.print("e not handled yet", .{}),
        0x0F => try stdout.print("f not handled yet", .{}),
        else => unreachable,
    }
}
