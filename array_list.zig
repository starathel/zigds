const std = @import("std");

fn ArrayList(comptime T: type) type {
    return struct {
        const Self = @This();

        cap: usize,
        items: []T,
        alloc: std.mem.Allocator,

        fn init(alloc: std.mem.Allocator) Self {
            return Self{
                .cap = 0,
                .items = &[_]T{},
                .alloc = alloc,
            };
        }

        fn append(self: *Self, val: T) !void {
            if (self.items.len == self.cap) {
                try self.grow();
            }
            self.items.len += 1;
            self.items[self.items.len - 1] = val;
        }

        fn grow(self: *Self) !void {
            if (self.cap == 0) {
                self.cap = 1;
                self.items = try self.alloc.alloc(T, 1);
                self.items.len = 0;
                return;
            }

            const old_cap = self.cap;
            self.cap *= 2;
            const new_slice = try self.alloc.alloc(T, self.cap);

            for (0..self.items.len) |i| {
                new_slice[i] = self.items[i];
            }

            self.alloc.free(self.items.ptr[0..old_cap]);
            self.items.ptr = new_slice.ptr;
        }

        fn deinit(self: *Self) void {
            self.alloc.free(self.items.ptr[0..self.cap]);

            self.cap = 0;
            self.items = &[_]T{};
        }
    };
}

test ArrayList {
    var list = ArrayList(i32).init(std.testing.allocator);

    try list.append(1);
    try std.testing.expect(list.cap == 1);
    try std.testing.expectEqualSlices(i32, &[_]i32{1}, list.items);

    try list.append(2);
    try std.testing.expect(list.cap == 2);
    try std.testing.expectEqualSlices(i32, &[_]i32{1, 2}, list.items);

    try list.append(3);
    try std.testing.expect(list.cap == 4);
    try std.testing.expectEqualSlices(i32, &[_]i32{1, 2, 3}, list.items);

    try list.grow();
    try std.testing.expect(list.cap == 8);
    try std.testing.expectEqualSlices(i32, &[_]i32{1, 2, 3}, list.items);

    list.deinit();
}
