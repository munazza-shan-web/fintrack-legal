import 'package:flutter/services.dart';

/// Groups the editable integer part without rounding or losing a trailing dot.
String groupAmount(String value) {
  final parts = value.replaceAll(',', '').split('.');
  var whole = parts.first;
  if (whole.isEmpty && parts.length > 1) whole = '0';
  whole = whole.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
  return parts.length == 1 ? whole : '$whole.${parts[1]}';
}

class AmountInputFormatter extends TextInputFormatter {
  const AmountInputFormatter();
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (!newValue.composing.isCollapsed) return newValue;
    final raw = newValue.text.replaceAll(',', '');
    if (!RegExp(r'^\d{0,12}(\.\d{0,2})?$').hasMatch(raw)) return oldValue;
    final text = groupAmount(raw);
    int mapOffset(int offset) {
      if (offset < 0) return text.length;
      var count = newValue.text
          .substring(0, offset.clamp(0, newValue.text.length))
          .replaceAll(',', '')
          .length;
      if (count == 0) return 0;
      if (raw.startsWith('.')) count++;
      var seen = 0;
      for (var i = 0; i < text.length; i++) {
        if (text[i] != ',') seen++;
        if (seen == count) return i + 1;
      }
      return text.length;
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection(
        baseOffset: mapOffset(newValue.selection.baseOffset),
        extentOffset: mapOffset(newValue.selection.extentOffset),
      ),
    );
  }
}

const _small = [
  'zero',
  'one',
  'two',
  'three',
  'four',
  'five',
  'six',
  'seven',
  'eight',
  'nine',
  'ten',
  'eleven',
  'twelve',
  'thirteen',
  'fourteen',
  'fifteen',
  'sixteen',
  'seventeen',
  'eighteen',
  'nineteen',
];
const _tens = [
  '',
  '',
  'twenty',
  'thirty',
  'forty',
  'fifty',
  'sixty',
  'seventy',
  'eighty',
  'ninety',
];
String _words(int value) {
  if (value < 20) return _small[value];
  if (value < 100) {
    return '${_tens[value ~/ 10]}${value % 10 == 0 ? '' : '-${_small[value % 10]}'}';
  }
  for (final unit in [
    (1000000000, 'billion'),
    (1000000, 'million'),
    (1000, 'thousand'),
    (100, 'hundred'),
  ]) {
    if (value >= unit.$1) {
      return '${_words(value ~/ unit.$1)} ${unit.$2}${value % unit.$1 == 0 ? '' : ' ${_words(value % unit.$1)}'}';
    }
  }
  return '';
}

String amountInWords(String value) {
  final raw = value.replaceAll(',', '');
  if (raw.isEmpty || !RegExp(r'^\d+(\.\d{0,2})?$').hasMatch(raw)) return '';
  final parts = raw.split('.');
  final number = int.tryParse(parts.first);
  if (number == null || number > 999999999999) return '';
  var result = _words(number);
  if (parts.length > 1 && parts[1].isNotEmpty) {
    result +=
        ' point ${parts[1].split('').map((d) => _small[int.parse(d)]).join(' ')}';
  }
  if (number >= 100000 && number < 10000000) {
    final lakh = number / 100000;
    final label = lakh.toStringAsFixed(5).replaceFirst(RegExp(r'\.?0+$'), '');
    result += ' ($label lakh)';
  }
  return '${result[0].toUpperCase()}${result.substring(1)}';
}
