const print = @import("std").debug.print;

pub const Color = enum {
    red,
    yellow,
};

pub const MoveError = error {
    IllegalMove,
};


pub const Position = struct {
    /// contains the bitboards for the two players
    board: [2]u42 = .{0, 0},
    stm: Color = .red,

    fn getBoard(self: *const Position, c: Color) u42 {
        return self.board[@intFromEnum(c)];
    }

    fn getOccupancy(self: *const Position) u42 {
        return self.board[0] | self.board[1];
    }

    fn cellColor(self: *const Position, cell: usize) ?Color {
        if ((self.getBoard(.red) & (@as(u42, 1) << @truncate(cell))) != 0) {
            return .red;
        }
        else if ((self.getBoard(.yellow) & (@as(u42, 1) << @truncate(cell))) != 0) {
            return .yellow;
        }
        else return null;
    }

    pub fn makeMove(self: *Position, move: u6) !void {
        // initialize the mask to the first space of the col
        var bit_mask: u42 = (@as(u42, 1) << @truncate(move)) << (5*7);
        for (0..6) |_| {
            // if the cell is empty make the move and return
            if ((bit_mask & self.getOccupancy()) == 0) {
                self.board[@intFromEnum(self.stm)] ^= bit_mask;
                self.stm = @enumFromInt(@intFromEnum(self.stm)^1);
                return;
            }
            // move the bit up 1 row
            bit_mask >>= 7;
        }
        return MoveError.IllegalMove;
    }

    pub fn generateMoves(self: *const Position, moveList: []u6) []u6 {
        var len: usize = 0;
        var bit_mask: u42 = 1;
        for (0..7) |move| {
            if ((bit_mask & self.getOccupancy()) == 0) {
                moveList[len] = @truncate(move);
                len += 1;
            }
            bit_mask <<= 1;
        }

        return moveList[0..len];
    }

    pub fn printBoard(self: *const Position) void {
        print("\x1b[34m+-+-+-+-+-+-+-+\n", .{});
        for (0..6) |row| {
            for (0..7) |col| {
                if (self.cellColor(row*7 + col)) |c| {
                    switch (c) {
                        .red => print("|\x1b[31m0\x1b[34m", .{}),
                        .yellow => print("|\x1b[33m0\x1b[34m", .{}),
                    }
                } else { print("| ", .{}); }
            }
            print("|\n", .{});
        }
        print("+-+-+-+-+-+-+-+\x1b[0m\n", .{});
    }
};


const std = @import("std");
const expectError = std.testing.expectError;
const expectEqual = std.testing.expectEqual;
const expectEqualSlices = std.testing.expectEqualSlices;

test "random tests" {
    print("Test print\n", .{});
    var position = Position{};
    print("Size of Position: {} B, {} bits\n", .{@sizeOf(Position), @sizeOf(Position)*8});
    var moves_buff: [7]u6 = undefined;
    try expectEqualSlices(u6, &.{0, 1, 2, 3, 4, 5, 6}, position.generateMoves(&moves_buff));
    position.printBoard();
    for (0..6) |_| {
        try position.makeMove(0);
        try position.makeMove(2);
        try position.makeMove(6);
    }
    try expectError(MoveError.IllegalMove, position.makeMove(0));
    try position.makeMove(4);
    try position.makeMove(4);
    position.printBoard();
    try expectEqualSlices(u6, &.{1, 3, 4, 5}, position.generateMoves(&moves_buff));
}
