extension DurationExtension on Duration {

  String toHms() {
    final String hours = inHours.toString().padLeft(2, '0');
    final String minutes = (inMinutes % 60).toString().padLeft(2, '0');
    final String seconds = (inSeconds % 60).toString().padLeft(2, '0');
    if (hours == '00') {
      return '$minutes:$seconds';
    } else {
      return '$hours:$minutes:$seconds';
    }
  }
}
