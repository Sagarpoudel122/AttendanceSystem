import 'package:attendance/screens/ViewAttendanceScreen.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class Chart extends StatelessWidget {
  final Future loadedChartFuture;
  final String formattedDate;
  Chart({this.loadedChartFuture, this.formattedDate});
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(8.0),
        child: Container(
          child: Center(
              child: Column(
            children: <Widget>[
              SizedBox(
                height: 10.0,
              ),
              Text(
                'Over All Student attendance Report ',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 10.0,
              ),
              FutureBuilder(
                  future: loadedChartFuture,
                  builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
                    if (asyncSnapshot.hasData) {
                      if (asyncSnapshot.data['chartData'].length > 0) {
                        List<charts.Series<ViewAttendanceChart, String>> data =
                            asyncSnapshot.data['chartData'];
                        return Expanded(
                          child: charts.PieChart(data,
                              animate: true,
                              animationDuration: Duration(seconds: 1),
                              behaviors: [
                                new charts.DatumLegend(
                                  outsideJustification:
                                      charts.OutsideJustification.endDrawArea,
                                  horizontalFirst: false,
                                  desiredMaxRows: 2,
                                  // position: ,
                                  cellPadding: new EdgeInsets.only(
                                      right: 6.0, bottom: 6.0),
                                  entryTextStyle: charts.TextStyleSpec(
                                      color: charts
                                          .MaterialPalette.purple.shadeDefault,
                                      fontFamily: 'Georgia',
                                      fontSize: 11),
                                )
                              ],
                              defaultRenderer: new charts.ArcRendererConfig(
                                  arcWidth: 100,
                                  arcRendererDecorators: [
                                    new charts.ArcLabelDecorator(
                                        labelPosition:
                                            charts.ArcLabelPosition.inside)
                                  ])),
                        );
                      } else {
                        return Expanded(
                          child: Center(
                            child: Container(
                              child: Text(
                                "No Attendance Found on " + formattedDate,
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                          ),
                        );
                      }
                    } else {
                      return Expanded(
                        child: Center(
                          child: Container(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      );
                    }
                  }),
            ],
          )),
        ));
  }
}
