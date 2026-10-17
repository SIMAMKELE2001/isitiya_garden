/// Small text formatters for dates, so we do not need an extra package.
abstract final class Format {
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// 15 Oct 2026
  static String date(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

  /// Plain-language availability (FR10).
  static String availability(DateTime? from, DateTime? until) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = from == null ? null : DateTime(from.year, from.month, from.day);

    if (start != null && start.isAfter(today)) {
      return until == null
          ? 'Available from ${date(start)}'
          : 'Available ${date(start)} to ${date(until)}';
    }
    return until == null
        ? 'Available now'
        : 'Available now, until ${date(until)}';
  }

  /// "Listed today", "Listed yesterday", "Listed 3 days ago".
  static String listed(DateTime? createdAt) {
    if (createdAt == null) return 'Recently listed';
    final days = DateTime.now().toUtc().difference(createdAt.toUtc()).inDays;
    if (days <= 0) return 'Listed today';
    if (days == 1) return 'Listed yesterday';
    return 'Listed $days days ago';
  }
}
