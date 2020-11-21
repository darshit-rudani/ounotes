import 'package:FSOUNotes/app/locator.dart';
import 'package:FSOUNotes/app/logger.dart';
import 'package:FSOUNotes/enums/constants.dart';
import 'package:FSOUNotes/models/link.dart';
import 'package:FSOUNotes/models/notes.dart';
import 'package:FSOUNotes/models/question_paper.dart';
import 'package:FSOUNotes/models/report.dart';
import 'package:FSOUNotes/models/syllabus.dart';
import 'package:FSOUNotes/services/funtional_services/analytics_service.dart';
import 'package:FSOUNotes/services/funtional_services/firestore_service.dart';
import 'package:FSOUNotes/services/funtional_services/google_drive_service.dart';
import 'package:FSOUNotes/services/state_services/report_service.dart';
import 'package:FSOUNotes/ui/views/notes/notes_viewmodel.dart';
import 'package:FSOUNotes/ui/widgets/smart_widgets/notes_tile/notes_tile_viewmodel.dart';
import 'package:logger/logger.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class ReportViewModel extends FutureViewModel {
  FirestoreService _firestoreService = locator<FirestoreService>();
  DialogService _dialogService = locator<DialogService>();
  AnalyticsService _analyticsService = locator<AnalyticsService>();
  Logger log = getLogger("UploadLogViewModel");

  List<Report> _reports;

  List<Report> get reports => _reports;

  fetchReports() async {
    _reports = await _firestoreService.loadReportsFromFirebase();
  }

  @override
  Future futureToRun() => fetchReports();

  deleteReport(Report report) async {
    var dialogResult = await _dialogService.showConfirmationDialog(
      title: "Are you sure?",
      description:
          "Report will be deleted. As an admin please make sure the issue is resolved",
      cancelTitle: "WAIT",
      confirmationTitle: "OK"
    );
    if(dialogResult.confirmed)await _firestoreService.deleteReport(report);
  }

  void accept(Report report) async {
    String title = "Thank you for reporting";
    String message = "We have reviewed the document you have reported \" ${report.title} \" in the \" ${report.subjectName} \" subject and we have removed it ! Thank you again for making OU Notes a better place !";
    DialogResponse result = await _dialogService.showConfirmationDialog(title: "Sure?",description: "");
    if(result.confirmed){
    _analyticsService.sendNotification(id: report.reporter_id,message: message,title: title);
    }
  }

  void deny(Report report)  async {
    String title = "Thank you for reporting";
    String message = "We have reviewed the document you have reported \" ${report.title} \" in the \" ${report.subjectName} \" subject and we have found NO ISSUE with it. Feel free to contact us using the feedback feature !";
    DialogResponse result = await _dialogService.showConfirmationDialog(title: "Sure?",description: "");
    if(result.confirmed){
    _analyticsService.sendNotification(id: report.reporter_id,message: message,title: title);
    }
  }

  void ban(Report report)  async {
    String title = "We're Sorry !";
    String message = "We're sad to say that you won't be allowed to report or upload any documents. Feel free to contact us using the feedback feature !";
    DialogResponse result = await _dialogService.showConfirmationDialog(title: "Sure?",description: "");
    if(result.confirmed){
    _analyticsService.sendNotification(id: report.reporter_id,message: message,title: title);
    }
  }

  void viewDocument(Report report) {
      setBusy(true);
      NotesViewModel notesViewModel = NotesViewModel();

      if (report.type == Constants.links){
        _showLink(report);
      }else{

      notesViewModel.onTap(
        notesName: report.title, 
        subName: report.subjectName,
        type: report.type,
      );

      }
      setBusy(false);
  }

  void deleteDocument(Report report) async {
    DialogResponse result = await _dialogService.showConfirmationDialog(title:"Sure?",description:"pakka?");
      if (result.confirmed){

        setBusy(true);
        log.e(report);
        log.e(report.type);

        if (report.type != Constants.notes)
        {
          log.e("document to be deleted is not Notes type");
          _deleteDocument(report);
          setBusy(false);
          return;
        }
        GoogleDriveService _googleDriveService = locator<GoogleDriveService>();
        Note note = await _firestoreService.getNoteById(report.id);
        String result = await _googleDriveService.processFile(note: note, addToGdrive: false);
        _dialogService.showDialog(title: "OUTPUT" , description: result);
        setBusy(false);
      
      }
    }
  
  void _deleteDocument(Report report) async {
      NotesTileViewModel notesTileViewModel = NotesTileViewModel();
      log.e(report.type);
      if (report.type == Constants.questionPapers)
      {
        QuestionPaper questionPaper = await _firestoreService.getQuestionPaperById(report.id);
        notesTileViewModel.delete(questionPaper);
      }else if(report.type == Constants.syllabus){
        Syllabus syllabus = await _firestoreService.getSyllabusById(report.id);
        notesTileViewModel.delete(syllabus);
      }else if(report.type == Constants.links){
        Link link = await _firestoreService.deleteLinkById(report.id);
      }
    }

  void _showLink(Report report) async {
      Link link = await _firestoreService.getLinkById(report.id);
      _dialogService.showDialog(title: "Link Content" , description: link.linkUrl);
    }
}
