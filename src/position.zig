const print = @import("std").debug.print;

pub const Color = enum {
    red,
    yellow,
};


pub const Position = struct {
    /// contains the bitboards for the two players
    board: [2]u42 = .{0, 0},
    stm: ?Color = null,

    pub fn printBoard(self: *const Position, c : Color) void {
        print("Method print: {b}\n", .{self.board[@intFromEnum(c)]});
    }
};


test "random tests" {
    print("Test print\n", .{});
    const position = Position{.board=.{0b11, 0b100}};
    position.printBoard(.red);
}
