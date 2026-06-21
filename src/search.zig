const position = @import("position.zig");
const std = @import("std");


const MoveInfo = struct {
    total: u32 = 0,
    wins: f32 = 0,
    node: ?*Node = null,
};

const Node = struct {
    total: u32 = 0,
    moves: [7]u8 = undefined,
    infos: [7]MoveInfo = @splat(MoveInfo{}),
    n_moves: usize = 0,
    previous: ?*Node = null,
};
