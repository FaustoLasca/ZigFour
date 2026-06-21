const position = @import("position.zig");
const print = @import("std").debug.print;

pub fn main() void {
    var pos = position.Position{};

    pos.printBoard();
}
