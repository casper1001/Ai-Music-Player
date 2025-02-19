extension StringExtension on String {

  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }


  String pluralize(int count) {
    if (count == 1) {
      return this;
    } else {
      var lastChar = this[length - 1];
      if (lastChar == 'y') {
        return '${substring(0, length - 1)}ies';
      } else if (lastChar == 's' || lastChar == 'x' || lastChar == 'z') {
        return '${this}es';
      } else if (lastChar == 'h' && substring(0, length - 1) == 'ch') {
        return '${this}es';
      } else if (lastChar == 'h' && substring(0, length - 1) == 'sh') {
        return '${this}es';
      } else if (lastChar == 'f') {
        return '${substring(0, length - 1)}ves';
      }

      return '${this}s';
    }
  }
}
