import 'package:FSOUNotes/app/locator.dart';
import 'package:FSOUNotes/models/subject.dart';
import 'package:FSOUNotes/services/funtional_services/authentication_service.dart';
import 'package:FSOUNotes/services/funtional_services/sharedpref_service.dart';
import 'package:FSOUNotes/services/state_services/subjects_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:flutter/src/material/dialog.dart';
import 'package:flutter/src/material/theme.dart';
import 'package:flutter/src/material/button.dart';

class HomeViewModel extends BaseViewModel {
  DialogService _dialogService = locator<DialogService>();
  AuthenticationService _authenticationService =
      locator<AuthenticationService>();
  NavigationService _navigationService = locator<NavigationService>();
  SubjectsService _subjectsService = locator<SubjectsService>();

  ValueNotifier<List<Subject>> get userSubjects =>
      _subjectsService.userSubjects;

  showIntroDialog(BuildContext context) async {
    if (_subjectsService.userSubjects.value.length == 0) {
      //If delay not added, error of build not completed may occur
      await Future.delayed(Duration(seconds: 1));
     await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: Row(
                children: <Widget>[
                  Text(
                    "Welcome to OU Notes App",
                    style: Theme.of(context).textTheme.headline6.copyWith(fontSize: 18),
                  ),
                ],
              ),
              content: Text(
                "Please use \"+\" button to add subjects and swipe left or right to delete them",
                style: Theme.of(context)
                    .textTheme
                    .subtitle1
                    .copyWith(fontSize: 18),
              ),
              actions: <Widget>[
                FlatButton(
                    child: Text(
                      "Ok",
                      style: Theme.of(context)
                          .textTheme
                          .subtitle2
                          .copyWith(fontSize: 17),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
              ]);
        });
    }
  }
}
