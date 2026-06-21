const print = @import("std").debug.print;

pub const Color = enum {
    red,
    yellow,
    no_color,
};

pub const MoveError = error {
    IllegalMove,
};


pub const Position = struct {
    /// contains the bitboards for the two players
    board: [6][7]Color = @splat(@splat(Color.no_color)),
    stm: Color = .red,
    winner: Color = .no_color,

    pub fn is_winning_cell(self: *const Position, row: u8, col: u8) bool {
        const color = self.board[row][col];
        // check below, only need to check for row 3 or lower
        if (row <= 3) {
            var r = row + 1;
            var count: u8 = 1;
            while (r < 6 and self.board[r][col] == color) : (r += 1) {
                count += 1;
                if (count == 4) {
                    return true;
                }
            }
        }
        // check the other three directions, horizontal and 2 diagonals
        const row_deltas = [3]i8{1, 0, -1};
        const col_delta = 1;
        for (row_deltas) |row_delta| {
            var count: u8 = 1;
            // check positive direction first
            var r: i8 = @as(i8, @intCast(row)) + row_delta;
            var c: i8 = @as(i8, @intCast(col)) + col_delta;
            while (r>=0 and r<6 and c<7 and self.board[@intCast(r)][@intCast(c)] == color) {
                count += 1;
                if (count == 4) {
                    return true;
                }
                r += row_delta;
                c += col_delta;
            }
            // then check negative direction
            r = @as(i8, @intCast(row)) - row_delta;
            c = @as(i8, @intCast(col)) - col_delta;
            while (r>=0 and r<6 and c>=0 and self.board[@intCast(r)][@intCast(c)] == color) {
                count += 1;
                if (count == 4) {
                    return true;
                }
                r -= row_delta;
                c -= col_delta;
            }
        }
        return false;
    }

    pub fn makeMove(self: *Position, move: u8) !void {
        for (1..7) |i| {
            const row = 6 - i;
            if (self.board[row][move] == Color.no_color) {
                self.board[row][move] = self.stm;
                if (self.is_winning_cell(@truncate(row), @truncate(move))) {
                    self.winner = self.stm;
                }
                self.stm = @enumFromInt(@intFromEnum(self.stm)^1);
                return;
            }
        }
        // if the column is full, the move is illegal
        return MoveError.IllegalMove;
    }

    pub fn generateMoves(self: *const Position, moveList: []u8) []u8 {
        var len: usize = 0;
        for (0..7) |move| {
            if (self.board[0][move] == Color.no_color) {
                moveList[len] = @truncate(move);
                len += 1;
            }
        }
        return moveList[0..len];
    }

    pub fn printBoard(self: *const Position) void {
        print("\x1b[34m+-+-+-+-+-+-+-+\n", .{});
        for (0..6) |row| {
            for (0..7) |col| {
                switch (self.board[row][col]) {
                    .red => print("|\x1b[31m0\x1b[34m", .{}),
                    .yellow => print("|\x1b[33m0\x1b[34m", .{}),
                    .no_color => print("| ", .{}),
                }
            }
            print("|\n", .{});
        }
        print("+-+-+-+-+-+-+-+\x1b[0m\n", .{});
    }
};


const std = @import("std");
const expect = std.testing.expect;
const expectError = std.testing.expectError;
const expectEqual = std.testing.expectEqual;
const expectEqualSlices = std.testing.expectEqualSlices;

test "random tests" {
    var position = Position{};
    print("Size of Position: {} B, {} bits\n", .{@sizeOf(Position), @sizeOf(Position)*8});
    var moves_buff: [7]u8 = undefined;
    try expectEqualSlices(u8, &.{0, 1, 2, 3, 4, 5, 6}, position.generateMoves(&moves_buff));
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
    try expectEqualSlices(u8, &.{1, 3, 4, 5}, position.generateMoves(&moves_buff));
}

test "winning move" {
    var position = Position{};
    for (0..3) |_| {
        try position.makeMove(0);
        try position.makeMove(1);
    }
    try expectEqual(Color.no_color, position.winner);
    try position.makeMove(0);
    position.printBoard();
    try expectEqual(Color.red, position.winner);

    position = Position{};
    for (0..3) |i| {
        try position.makeMove(@intCast(i));
        try position.makeMove(@intCast(i));
    }
    try expectEqual(.no_color, position.winner);
    try position.makeMove(3);
    position.printBoard();
    try expectEqual(.red, position.winner);

    position = Position{};
    for (0..4) |_| { try position.makeMove(5); }
    for (0..2) |_| { try position.makeMove(3); }
    try position.makeMove(4);
    try position.makeMove(2);
    try position.makeMove(4);
    try expectEqual(Color.no_color, position.winner);
    try position.makeMove(4);
    position.printBoard();
    try expectEqual(.yellow, position.winner);

    position = Position{};
    for (0..4) |_| { try position.makeMove(0); }
    for (0..2) |_| { try position.makeMove(2); }
    try position.makeMove(1);
    try position.makeMove(3);
    try position.makeMove(1);
    try expectEqual(Color.no_color, position.winner);
    try position.makeMove(1);
    position.printBoard();
    try expectEqual(.yellow, position.winner);
}
