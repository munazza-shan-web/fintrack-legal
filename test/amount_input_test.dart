import 'package:fintrack/utils/amount_input.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const formatter = AmountInputFormatter();
  TextEditingValue edit(String text) => formatter.formatEditUpdate(
    TextEditingValue.empty,
    TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    ),
  );
  test('Groups thousands without rounding typed decimals', () {
    expect(edit('1000').text, '1,000');
    expect(edit('10000').text, '10,000');
    expect(edit('100000').text, '100,000');
    expect(edit('100000.05').text, '100,000.05');
    expect(edit('1000.').text, '1,000.');
    expect(edit('.5').text, '0.5');
    expect(edit('100000.05').selection.baseOffset, 10);
  });
  test('Invalid edits keep the previous value', () {
    final previous = edit('1000');
    for (final text in ['-10', '1.2.3', '1e6', '10.123', '1000000000000']) {
      expect(
        formatter.formatEditUpdate(previous, TextEditingValue(text: text)),
        previous,
      );
    }
  });
  test('Insertion in the middle keeps the caret next to the edited digits', () {
    final result = formatter.formatEditUpdate(
      edit('1234'),
      const TextEditingValue(
        text: '19,234',
        selection: TextSelection.collapsed(offset: 2),
      ),
    );
    expect(result.text, '19,234');
    expect(result.selection.baseOffset, 2);
  });
  test('Explains magnitudes and decimal digits as entered', () {
    expect(amountInWords('100'), 'One hundred');
    expect(amountInWords('1,000'), 'One thousand');
    expect(amountInWords('10,000'), 'Ten thousand');
    expect(amountInWords('100,000'), 'One hundred thousand (1 lakh)');
    expect(
      amountInWords('250000.50'),
      'Two hundred fifty thousand point five zero (2.5 lakh)',
    );
    expect(amountInWords('1000000'), 'One million (10 lakh)');
    expect(amountInWords(''), '');
  });
}
