import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  String toFormattedString({String format = 'dd/MM/yyyy'}) {
    return DateFormat(format).format(this);
  }

  String toFormattedTime({String format = 'HH:mm'}) {
    return DateFormat(format).format(this);
  }

  String toRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return 'Hace unos segundos';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} minuto(s)';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} hora(s)';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} día(s)';
    } else {
      return toFormattedString();
    }
  }
}

extension StringExtension on String {
  bool isValidEmail() {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String truncate(int length) {
    if (this.length <= length) {
      return this;
    }
    return '${substring(0, length)}...';
  }
}

extension NumExtension on num {
  String toFormattedString({int decimals = 2}) {
    return toStringAsFixed(decimals);
  }
}
