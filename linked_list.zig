const std = @import("std");
const assert = std.debug.assert;

fn LinkedList(comptime T: type) type {
    return struct {
        const Node = struct {
            value: T,
            next: ?*Node,
            prev: ?*Node,

            fn init (self: *Node, val: T) void {
                self.value = val;
                self.next = null;
                self.prev = null;
            }
        };

        const Self = @This();

        len: usize,
        head: ?*Node,
        tail: ?*Node,

        alloc: std.mem.Allocator,

        fn init(alloc: std.mem.Allocator) Self {
            return Self{
                .head = null,
                .tail = null,
                .len = 0,
                .alloc = alloc,
            };
        }

        fn peek_front(self: Self) ?T {
            if (self.head) |head| {
                return head.value;
            }
            return null;
        }

        fn peek_back(self: Self) ?T {
            if (self.tail) |tail| {
                return tail.value;
            }
            return null;
        }

        fn push_back(self: *Self, val: T) !void {
            const node = try self.alloc.create(Node);
            node.init(val);

            if (self.tail) |tail| {
                assert(self.len != 0);
                assert(self.head != null);
                assert(tail.next == null);

                tail.next = node;
                node.prev = self.tail;
                self.tail = node;
            } else {
                assert(self.len == 0);
                assert(self.head == null);

                self.head = node;
                self.tail = node;
            }

            self.len += 1;
        }

        fn push_front(self: *Self, val: T) !void {
            const node = try self.alloc.create(Node);
            node.init(val);

            if (self.head) |head| {
                assert(self.len != 0);
                assert(self.tail != null);
                assert(head.prev == null);

                head.prev = node;
                node.next = self.head;
                self.head = node;
            } else {
                assert(self.len == 0);
                assert(self.tail == null);

                self.head = node;
                self.tail = node;
            }

            self.len += 1;
        }

        fn pop_back(self: *Self) ?T {
            if (self.tail) |tail| {
                const val = tail.value;
                if (self.tail == self.head) {
                    assert(self.len == 1);
                    self.tail = null;
                    self.head = null;
                } else {
                    tail.prev.?.next = null;
                    self.tail = tail.prev;
                }
                self.alloc.destroy(tail);

                self.len -= 1;
                return val;
            } else {
                assert(self.head == null);
                assert(self.len == 0);
                return null;
            }
        }

        fn pop_front(self: *Self) ?T {
            if (self.head) |head| {
                const val = head.value;
                if (self.tail == self.head) {
                    assert(self.len == 1);
                    self.tail = null;
                    self.head = null;
                } else {
                    head.next.?.prev = null;
                    self.head = head.next;
                }
                self.alloc.destroy(head);

                self.len -= 1;
                return val;
            } else {
                assert(self.head == null);
                assert(self.len == 0);
                return null;
            }
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

pub fn main() !void {
    var allocator = std.heap.DebugAllocator(.{}).init;
    const alloc = allocator.allocator();
    var list = LinkedList(i32).init(alloc);

    try list.push_back(1);
    try list.push_back(2);
    try list.push_back(3);
    try list.push_back(4);
    try list.push_front(0);
    try list.push_front(-1);
    try list.push_front(-2);
    try list.push_front(-3);

    std.debug.print("Len: {}\n", .{list.len});

    var curr = list.head;
    std.debug.print("Forward:\n", .{});
    while (curr) |c| : (curr = c.next) {
        std.debug.print("->{d:^4}", .{c.value});
    }
    std.debug.print("\n", .{});

    curr = list.tail;
    std.debug.print("Backward:\n", .{});
    while (curr) |c| : (curr = c.prev) {
        std.debug.print("->{d:^4}", .{c.value});
    }
    std.debug.print("\n", .{});
}
