import 'package:FSOUNotes/models/UploadLog.dart';
import 'package:FSOUNotes/ui/views/admin/upload_log/upload_log_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class UploadLogView extends StatelessWidget {
  const UploadLogView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<UploadLogViewModel>.reactive(
      builder: (context, model, child) => Scaffold(
        body: Container(
          //color: Colors.yellow,
          height: MediaQuery.of(context).size.height * 0.85,
          // alignment: Alignment.center,
          child: Center(
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                model.isBusy
                    ? Container(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: model.logs.length,
                        itemBuilder: (ctx, index) {
                          UploadLog logItem = model.logs[index];
                          return Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            child: Card(
                              elevation: 10,
                              child: ListTile(
                                contentPadding: EdgeInsets.all(15),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text("File Name : "+ logItem.fileName),
                                    Text("FileType : " + logItem.type),
                                    Text("Subject Name :" + logItem.subjectName),
                                    Text("Email of Uploader : " + logItem.email),
                                    Text("UploadedAt : " + logItem.date.toString()),
                                    Text("Size : " + logItem.size ?? "0"),
                                  ],
                                ),
                                onTap: () async {
                                  await model.deleteLogItem(logItem);
                                },
                              ),
                            ),
                          );
                        },
                      )
              ],
            ),
          ),
        ),
      ),
      viewModelBuilder: () => UploadLogViewModel(),
    );
  }
}