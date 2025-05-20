import 'dart:io';
import 'package:excel/excel.dart';

// void excelMain(List<String> args) {
void excelMain() {

  var file = "S:/Data/temp test game json/xlsx test/example.xlsx";
  var bytes = File(file).readAsBytesSync();
  var excel = Excel.decodeBytes(bytes);

  for (var table in excel.tables.keys) {
    print(table); //sheet Name
    print(excel.tables[table]?.maxColumns);
    print(excel.tables[table]?.maxRows);
    for (var row in excel.tables[table]!.rows) {
      for (var cell in row) {
        print('cell ${cell?.rowIndex}/${cell?.columnIndex}');
        final value = cell?.value;
        final numFormat = cell?.cellStyle?.numberFormat ?? NumFormat.standard_0;
        switch(value){
          case null:
            print('  empty cell');
            print('  format: ${numFormat}');
          case TextCellValue():
            print('  text: ${value.value}');
          case FormulaCellValue():
            print('  formula: ${value.formula}');
            print('  format: ${numFormat}');
          case IntCellValue():
            print('  int: ${value.value}');
            print('  format: ${numFormat}');
          case BoolCellValue():
            print('  bool: ${value.value ? 'YES!!' : 'NO..' }');
            print('  format: ${numFormat}');
          case DoubleCellValue():
            print('  double: ${value.value}');
            print('  format: ${numFormat}');
          case DateCellValue():
            print('  date: ${value.year} ${value.month} ${value.day} (${value.asDateTimeLocal()})');
          case TimeCellValue():
            print('  time: ${value.hour} ${value.minute} ... (${value.asDuration()})');
          case DateTimeCellValue():
            print('  date with time: ${value.year} ${value.month} ${value.day} ${value.hour} ... (${value.asDateTimeLocal()})');
        }

        print('$row');
      }
    }
  }

}