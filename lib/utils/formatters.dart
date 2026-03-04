import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  final formatter = DateFormat('MMM d, yyyy');
  return formatter.format(date);
}

String formatDistance(double? meters) {
  if (meters == null) return 'Unknown distance';
  if (meters < 1000) return '${meters.toStringAsFixed(0)} m';
  return '${(meters / 1000).toStringAsFixed(1)} km';
}
