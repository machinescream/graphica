import 'package:flutter/material.dart';
import 'package:graphica/graphica.dart';

String monthAbbreviation(int month) {
  if (month < 1 || month > 12) {
    throw ArgumentError('Month must be between 1 and 12');
  }

  const List<String> monthAbbreviations = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  return monthAbbreviations[month - 1];
}

void main() {
  runApp(MaterialApp(
    home: ColoredBox(
      color: Colors.white,
      child: Center(
        child: SizedBox(
          height: 250,
          width: 500,
          child: Graphica(
            backgroundColor: Colors.blue,
            dxIndicatorsColor: Colors.black,
            dyIndicatorsColor: Colors.black,
            lineWidth: 1,
            indicatorsPadding: 8,
            graphsWidth: 5,
            dxLineColor: Colors.black,
            dyLineColor: Colors.black,
            activities: [
              Activity(color: Colors.black26, start: 1, end: 2),
              Activity(color: Colors.black26, start: 3, end: 5),
              Activity(color: Colors.black26, start: 10, end: 12),
            ],
            dyIndicators: List.generate(
              10,
              (index) => "$index",
            ),
            dxIndicators: List.generate(
              12,
              (index) => monthAbbreviation(DateTime.utc(2008, index).month),
            ),
            graphs: [
              GraphData(
                color: Colors.yellow,
                values: [0, 2, 1, 4, 5, 4, 2, 2, 6, 8, 9, 8],
              ),
              GraphData(
                color: Colors.green,
                values: [8, 8, 9, 6, 3, 3, 1, 2, 5, 9, 9, 6],
              ),
              // GraphData(
              //   color: Colors.red,
              //   values: [8, 1, 2, 4, 6, 3, 2, 8, 5, 2],
              // ),
            ],
          ),
        ),
      ),
    ),
  ));
}
