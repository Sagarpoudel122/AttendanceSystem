import 'package:attendance/library/InitialAvatar.dart';
import 'package:flutter/material.dart';

class DetailAttendance extends StatelessWidget {
  final Future loadedAttendance;
  final String formattedDate;

  const DetailAttendance({Key key, this.loadedAttendance, this.formattedDate})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        FutureBuilder(
          future: loadedAttendance,
          builder: (context, AsyncSnapshot asynShot) {
            if (asynShot.hasData) {
              var data = asynShot.data['data'];
              if (data.length > 0) {
                return Expanded(
                  child: ListView.separated(
                    separatorBuilder: (context, i) {
                      return Divider();
                    },
                    itemCount: data.length,
                    itemBuilder: (context, i) {
                      return ListTile(
                        leading: InitialAvatar(
                          nameString: data[i]['name'],
                        ),
                        trailing: Text(
                          data[i]['value'],
                        ),
                        title: Text(
                          data[i]['name'],
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      );
                    },
                  ),
                );
              } else {
                return Expanded(
                    child: Center(
                  child: Container(
                    child: Text(
                      "No attendance found at " + formattedDate,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                ));
              }
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ],
    );
  }
}
