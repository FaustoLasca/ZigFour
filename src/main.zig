const position = @import("position.zig");
const print = @import("std").debug.print;

pub fn main() void {
    var pos = position.Position{.board=.{0, 0b1000}};
    print ("aaaaaaaaa, {b}\n", .{pos.board[@intFromEnum(position.Color.yellow)]});

    pos.printBoard(position.Color.yellow);
}
