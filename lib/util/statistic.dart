import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';
import 'package:image_utils/reader/png/png_reader.dart';

gen_statistic_fl_chart(PNGReader pngReader) {
  List<PieChartSectionData> _typeSizeGroup = [];
  List<String> _typeSizeKeyGroup = [];
  pngReader.chunkTypeSizeMap.forEach((key, value) {
    _typeSizeGroup.add(PieChartSectionData(
      value: value / 1024,
    ));
  });
  return PieChart(
    PieChartData(
      sections: [],
    ),
  );
}
