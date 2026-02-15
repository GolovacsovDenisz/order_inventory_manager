enum OrderStatus { newOrder, inProgress, done, cancelled }

extension OrderStatusX on OrderStatus {
  String get label => switch (this) {
    OrderStatus.newOrder => 'New',
    OrderStatus.inProgress => 'In Progress',
    OrderStatus.done => 'Done',
    OrderStatus.cancelled => 'Cancelled',
  };
}
