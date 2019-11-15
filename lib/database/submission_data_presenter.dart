import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:wfto_change_agent/database/i_submission_view.dart';
import 'package:wfto_change_agent/models/activity.dart';
import 'package:wfto_change_agent/models/challenge.dart';
import 'package:wfto_change_agent/models/submission.dart';
import 'package:wfto_change_agent/models/user.dart';
import 'package:wfto_change_agent/utils/strings_util.dart';

import 'database_helper.dart';
import 'i_submission_view.dart';

class SubmissionDataPresenter {
  ISubmissionView _iSubmissionView;
  Submission _submission;
  List _submissionList = List<Submission>();
  final DatabaseHelper databaseHelper = DatabaseHelper();
  final databaseReference = Firestore.instance;
  Challenge _challenge;
  Activity _activity;
  User _user;

  SubmissionDataPresenter(ISubmissionView iSubmissionView, Challenge challenge,
      Activity activity, User user) {
    this._iSubmissionView = iSubmissionView;
    this._challenge = challenge;
    this._activity = activity;
    this._user = user;

    _updateUserSelectedActivity();
  }

  void _updateUserSelectedActivity() {
    if (_user.currentActivityID != _activity.id) {
      debugPrint("_()#_(_%%*%(@#_%@%(_@)%(5");
      _user.currentActivityID = _activity.id;
      _user.currentActivity = _activity.name;
      _user.currentActivityStatus = "started";
      _user.currentChallengeID = _challenge.id;
      _user.currentActivityStartTime = getCurrentTime();
      _saveSpecifiedUser(_user);
      updateUserInFireBase();
    }
  }

  String getCurrentTime() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  void setSubmission(Submission submission) {
    _submission = submission;
    _submission.finishTime = getCurrentTime();
    saveSubmissionToFireBase();

    _user.currentActivityID = _activity.id;
    _user.currentActivity = _activity.name;
    _user.currentActivityStatus = "pending";
    _user.activityStatus = getStatusList();
    _user.currentChallengeID = _challenge.id;

    _saveSpecifiedUser(_user);
    updateUserInFireBase();
  }

  String getStatusList() {
    var statuses = StringsUtil.getDelimitedList(_user.activityStatus);
    int i = getIndex();
    statuses[i] = "pending";

    String statusList = "";
    statuses.forEach((status) {
      if(statuses.indexOf(status) != statuses.length - 1) {
        statusList = statusList + status+"*";
      }else{
        statusList = statusList + status;
      }
    });
    return statusList;
  }

  int getIndex(){
    return int.parse(_activity.name[_activity.name.indexOf(".") - 1]) - 1;
  }

//  void _saveSubmission() async {
//    int result;
//    //todo change this implementation as it will save each time
//    if (_submission.currentActivityID == null) {
//      initializeSubmission();
//      saveSubmissionToFireBase();
//      result = await databaseHelper.insertSubmission(_submission);
//    } else {
//      return;
//    }
//
//    if (result != 0) {
//      // success
//      _iSubmissionView.showSuccessMessage(_submission.name + " saved");
//    } else {
//      //failure
//      _iSubmissionView.showSuccessMessage(_submission.name + "not saved");
//    }
//  }

//  void _saveSpecifiedSubmission(Submission submission) async {
//    int result;
//
//    result = await databaseHelper.insertSubmission(submission);
//
//    if (result != 0) {
//      // success
//      _iSubmissionView.showSuccessMessage(_submission.name + " saved");
//    } else {
//      //failure
//      _iSubmissionView.showSuccessMessage(_submission.name + "not saved");
//    }
//  }

//  void updateSubmission() async {
//    int result;
//    if (_submission.id != null) {
//      //create
//      updateSubmissionInFireBase();
//      result = await databaseHelper.updateSubmission(_submission);
//    }
//
//    if (result != 0) {
//      // success
//      _iSubmissionView.showSuccessMessage(_submission.name + " saved");
//    } else {
//      //failure
//      _iSubmissionView.showSuccessMessage(_submission.name + "not saved");
//    }
//  }

  void _retrieveSubmission() {
    if (_submissionList.length == 0) {
      _submissionList = List<Submission>();
      final Future<Database> dbFuture = databaseHelper.initializeDatabase();
      dbFuture.then((database) {
        Future<List<Submission>> submissionListFuture =
            databaseHelper.getSubmissionList();
        submissionListFuture.then((submissionList) {
          if (submissionList.isNotEmpty) {
            _submissionList = submissionList;
            //setDataBaseSubmission();
          }
        });
      });
    }
  }

//
//  void setDataBaseSubmission() {
//    _submissionList.forEach((submission) {
//      if (submission.id == _submission.id) {
//        _iSubmissionView.setSubmission(submission);
//      }
//    });
//  }

  void _saveSpecifiedUser(User user) async {
    int result;

    result = await databaseHelper.updateUser(user);

    if (result != 0) {
      // success
      _iSubmissionView.showSuccessMessage("Activity selection saved");
    } else {
      //failure
      _iSubmissionView.showSuccessMessage("Activity selection not saved");
    }
  }

  void saveSubmissionToFireBase() async {
    await databaseReference.collection("submissions").add({
      'title': _submission.title,
      'submitted_material': _submission.submittedMaterial,
      'user_id': _submission.userID,
      'activity_id': _submission.activityID,
      'challenge_id': _submission.challengeID,
      'start_time': _submission.startTime,
      'finish_time': _submission.finishTime,
      'submission_status': _submission.submissionStatus,
      'time_allocation_points': _submission.timeAllocationPoints,
      'points': _submission.points,
    });

    ///does same thing just with a randomized ID
//    DocumentReference ref = await databaseReference.collection("books")
//        .add({
//      'title': 'Flutter in Action',
//      'description': 'Complete Programming Guide to learn Flutter'
//    });
//    print(ref.documentID);
  }

  void updateUserInFireBase() {
    try {
      databaseReference.collection('users').document(_user.id).updateData({
        'current_level': _user.currentLevel,
        'current_activity_id': _user.currentActivityID,
        'current_activity': _user.currentActivity,
        'current_activity_status': _user.currentActivityStatus,
        'current_challenge_id': _user.currentChallengeID,
        'points': _user.points,
        'user_email': _user.userEmail,
        'activities_done': _user.activitiesDone,
        'activity_status': _user.activityStatus,
      });
    } catch (e) {
      print(e.toString());
    }
  }

//  void _getSubmissionFromFireBase() {
//    databaseReference
//        .collection('submissions')
//        .document(_submission.id)
//        .get()
//        .then((DocumentSnapshot ds) {
//      _submissionUpdated(ds);
//    });
//  }

//  void updateSubmissionInFireBase() {
//    try {
//      databaseReference.collection('submissions').document(_submission.id).updateData({
//        'current_level': _submission.currentLevel,
//        'current_activity_id': _submission.currentActivityID,
//        'current_activity': _submission.currentActivity,
//        'current_activity_status': _submission.currentActivityStatus,
//        'current_challenge_id': _submission.currentChallengeID,
//        'points': _submission.points,
//        'submission_email': _submission.submissionEmail,
//        'activities_done': _submission.activitiesDone,
//        'activity_status': _submission.activityStatus,
//      });
//    } catch (e) {
//      print(e.toString());
//    }
//  }

//  void _submissionUpdated(DocumentSnapshot snapShot) {
//    try {
//      if (snapShot != null && snapShot["id"] != null) {
//        updateSubmissionFromFireBase(Submission.fromSnapshot(snapShot));
//      }
//    } on NoSuchMethodError catch (e) {
//      _saveSubmission();
//      _iSubmissionView.setSubmission(_submission);
//    }
//  }

//  void updateSubmissionFromFireBase(Submission submission) async {
//    int result;
//    if (_submission.id != null) {
//      result = await databaseHelper.updateSubmission(submission);
//    }
//
//    if (result != 0) {
//      // success
//      _retrieveSubmission();
//    } else {
//      _saveSpecifiedSubmission(submission);
//      if (submission.id == _submission.id) {
//        _iSubmissionView.setSubmission(submission);
//      }
//    }
//  }
//

}
