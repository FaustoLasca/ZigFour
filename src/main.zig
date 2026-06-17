const position = @import("position.zig");
const print = @import("std").debug.print;

pub fn main() void {
    var pos = position.Position{.board=.{0, 0b1000}};

    pos.printBoard();
}
