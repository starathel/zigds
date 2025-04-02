const std = @import("std");

fn LinkedList(comptime T: type) type {
    return struct {
        const Self = @This();

        const Node = struct {
            data: T,
            next: ?*Node = null,
            prev: ?*Node = null,

            fn create(alloc: std.mem.Allocator, data: T) !*Node {
                const new_node = try alloc.create(Node);
                new_node.* = .{.data = data};
                return new_node;
            }
        };

        len: usize = 0,
        head: ?*Node = null,
        tail: ?*Node = null,

        alloc: std.mem.Allocator,

        fn init(alloc: std.mem.Allocator) Self {
            return .{ .alloc = alloc };
        }

        fn peek_back(self: Self) ?T {
            if (self.tail == null) {
                return null;
            }
            return self.tail.?.data;
        }

        fn peek_front(self: Self) ?T {
            if (self.head == null) {
                return null;
            }
            return self.head.?.data;
        }

        fn push_back(self: *Self, item: T) !void {
            const new_node = try Node.create(self.alloc, item);

            if (self.len == 0) {
                self.head = new_node;
                self.tail = new_node;
            } else {
                new_node.prev = self.tail;
                self.tail.?.next = new_node;
                self.tail = new_node;
            }
            self.len += 1;
        }

        fn push_front(self: *Self, item: T) !void {
            const new_node = try Node.create(self.alloc, item);

            if (self.len == 0) {
                self.head = new_node;
                self.tail = new_node;
            } else {
                new_node.next = self.head;
                self.head.?.prev = new_node;
                self.head = new_node;
            }
            self.len += 1;
        }

        fn pop_back(self: *Self) ?T {
            if (self.len == 0) {
                return null;
            }

            const ret = self.tail.?.data;
            const prev_tail = self.tail.?;
            if (self.len == 1) {
                self.head = null;
                self.tail = null;
            }
            else {
                self.tail.?.prev.?.next = null;
                self.tail = self.tail.?.prev;
            }

            self.alloc.destroy(prev_tail);
            self.len -= 1;
            return ret;
        }

        fn pop_front(self: *Self) ?T {
            if (self.len == 0) {
                return null;
            }

            const ret = self.head.?.data;
            const prev_head = self.head.?;
            if (self.len == 1) {
                self.head = null;
                self.tail = null;
            } else {
                self.head.?.next.?.prev = null;
                self.head = self.head.?.next;
            }

            self.alloc.destroy(prev_head);
            self.len -= 1;
            return ret;
        }
    };
}

test LinkedList {
    var list = LinkedList(u12).init(std.testing.allocator);

    try list.push_back(1);
    try list.push_back(2);
    try list.push_back(3);
    try list.push_front(0);
    try list.push_front(69);
    try list.push_back(420);

    try std.testing.expectEqual(6, list.len);
    try std.testing.expectEqual(69, list.peek_front());
    try std.testing.expectEqual(420, list.peek_back());

    try std.testing.expectEqual(420, list.pop_back());
    try std.testing.expectEqual(5, list.len);

    try std.testing.expectEqual(69, list.pop_front());
    try std.testing.expectEqual(4, list.len);

    try std.testing.expectEqual(0, list.pop_front());
    try std.testing.expectEqual(1, list.pop_front());
    try std.testing.expectEqual(3, list.pop_back());
    try std.testing.expectEqual(2, list.pop_back());

    try std.testing.expectEqual(0, list.len);
    try std.testing.expectEqual(null, list.head);
    try std.testing.expectEqual(null, list.tail);
}
