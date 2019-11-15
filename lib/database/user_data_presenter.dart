import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:wfto_change_agent/database/i_user_view.dart';
import 'package:wfto_change_agent/models/activity.dart';
import 'package:wfto_change_agent/models/user.dart';

import 'database_helper.dart';

class UserDataPresenter {
  IUserView _iUserView;
  User _user;
  List _userList = List<User>();
  final DatabaseHelper databaseHelper = DatabaseHelper();
  final databaseReference = Firestore.instance;
//  List<Activity>activities = List();

  UserDataPresenter(IUserView iUserView) {
    this._iUserView = iUserView;
//    getActivities();
//    activities.forEach((activity) {
//      saveActivitiesToFireBase(activity);
//    });
  }

  void setUser(User user) {
    _user = user;
    _getUserFromFireBase();
  }

  void _saveUser() async {
    int result;
    //todo change this implementation as it will save each time
    if (_user.currentActivityID == null) {
      initializeUser();
      saveUserToFireBase();
      result = await databaseHelper.insertUser(_user);
    } else {
      return;
    }

    if (result != 0) {
      // success
      _iUserView.showSuccessMessage(_user.name + " saved");
    } else {
      //failure
      _iUserView.showSuccessMessage(_user.name + "not saved");
    }
  }

  void _saveSpecifiedUser(User user) async {
    int result;

    result = await databaseHelper.insertUser(user);

    if (result != 0) {
      // success
      _iUserView.showSuccessMessage(_user.name + " saved");
    } else {
      //failure
      _iUserView.showSuccessMessage(_user.name + "not saved");
    }
  }

  void updateUser() async {
    int result;
    if (_user.id != null) {
      //create
      updateUserInFireBase();
      result = await databaseHelper.updateUser(_user);
    }

    if (result != 0) {
      // success
      _iUserView.showSuccessMessage(_user.name + " saved");
    } else {
      //failure
      _iUserView.showSuccessMessage(_user.name + "not saved");
    }
  }

  void _retrieveUser() {
    debugPrint("=-=-=-=-=-=" + _userList.length.toString());

    if (_userList.length == 0) {
      _userList = List<User>();
      final Future<Database> dbFuture = databaseHelper.initializeDatabase();
      dbFuture.then((database) {
        Future<List<User>> userListFuture = databaseHelper.getUserList();
        userListFuture.then((userList) {
          if (userList.isNotEmpty) {
            debugPrint("=-=-=-=-=-=" + userList[0].userEmail);
            _userList = userList;
            setDataBaseUser();
          }
        });
      });
    }
  }

  void initializeUser() {
    _user.currentActivityID = "none";
    _user.currentActivity = "none";
    _user.currentActivityStatus = "none";
    _user.currentLevel = "Change Dreamer";
    _user.currentChallengeID = "1";
    _user.points = 0;
    _user.activitiesDone = "none";
    _user.currentActivityStartTime = "";
    _user.currentActivitySubmissionTime = "";
    _user.activityStatus =
    "unlocked*locked*locked*locked*locked*locked*locked*locked*locked";

  }

  void setDataBaseUser() {
    _userList.forEach((user) {
      if (user.id == _user.id) {
        _iUserView.setUser(user);
      }
    });
  }

  void saveUserToFireBase() async {
    await databaseReference.collection("users").document(_user.id).setData({
      'id': _user.id,
      'name': _user.name,
      'current_level': _user.currentLevel,
      'current_activity_id': _user.currentActivityID,
      'current_activity': _user.currentActivity,
      'current_activity_status': _user.currentActivityStatus,
      'photo_url': _user.photoUrl,
      'current_challenge_id': _user.currentChallengeID,
      'current_activity_start_time': _user.currentActivityStartTime,
      'current_activity_submission_time': _user.currentActivitySubmissionTime,
      'points': _user.points,
      'user_email': _user.userEmail,
      'activities_done': _user.activitiesDone,
      'activity_status': _user.activityStatus,
    });

    ///does same thing just with a randomized ID
//    DocumentReference ref = await databaseReference.collection("books")
//        .add({
//      'title': 'Flutter in Action',
//      'description': 'Complete Programming Guide to learn Flutter'
//    });
//    print(ref.documentID);
  }

  void _getUserFromFireBase() {
    databaseReference
        .collection('users')
        .document(_user.id)
        .get()
        .then((DocumentSnapshot ds) {
      _userUpdated(ds);
    });
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

  void _userUpdated(DocumentSnapshot snapShot) {
    try {
      if (snapShot != null && snapShot["id"] != null) {
        updateUserFromFireBase(User.fromSnapshot(snapShot));
      }
    } on NoSuchMethodError catch (e) {
      _saveUser();
      _iUserView.setUser(_user);
    }
  }

  void updateUserFromFireBase(User user) async {
    int result;
    if (_user.id != null) {
      result = await databaseHelper.updateUser(user);
    }

    if (result != 0) {
      // success
      _retrieveUser();
    } else {
      _saveSpecifiedUser(user);
      if (user.id == _user.id) {
        _iUserView.setUser(user);
      }
    }
  }
//
//  void getActivities() {
//    activities.add(Activity.withID(
//        "activity1_1",
//        "Activity 1.1",
//        "social_post",
//        "Identify economically disadvantaged producers in your  area. Post a creative post on your social media platforms about what they make, where they are and why they are unique. Hashtag the producers, hashtag your community and hashtag ChangeAgent (Minimum 2 producers, maximum 5 producers)",
//        "summary",
//        "instruction",
//        10000,
//        2500,
//        72));
//    activities.add(Activity.withID(
//        "activity1_2",
//        "Activity 1.2",
//        "social_post",
//        "Pay a visit to a previously disadvantaged producer and learn what challenges they are still facing. Take photos of the unique features of the business and post them on social media. Tag the relevant government department in your city to assist in the challenges. Hashtag small businesses create employment, hashtag your community, hashtag Change Agent",
//        "summary",
//        "instruction",
//        20000,
//        5000,
//        168));
//    activities.add(Activity.withID(
//        "activity1_3",
//        "Activity 1.3",
//        "social_post",
//        "Identify business opportunities in your community and post about them on social media - hashtag your community and hashtag ChangeAgent",
//        "summary",
//        "instruction",
//        2000,
//        500,
//        48));
//    activities.add(Activity.withID(
//        "activity2_1",
//        "Activity 2.1",
//        "social_post",
//        "Send in a 60second video on what you believe the  value of transparency of an organization has on its employees. Your video will make up part of a drive to increase transparency in the workplace.",
//        "summary",
//        "instruction",
//        2000,
//        500,
//        48));
//    activities.add(Activity.withID(
//        "activity2_2",
//        "Activity 2.2",
//        "social_post",
//        "Write a post on social media about the importance of community based organizations being transparent and accountable to the communities in which they operate - hashtag your community, hashtag BeTheChange",
//        "summary",
//        "instruction",
//        1000,
//        250,
//        24));
//    activities.add(Activity.withID(
//        "activity3_1",
//        "Activity 3.1",
//        "social_post",
//        "Drop us a 60second video of you and two other people describing what Child labour looks like in your community or in the world today? Is it still the image of children sitting in a sweat factory somewhere or has the image evolved.",
//        "summary",
//        "instruction",
//        10000,
//        2500,
//        72));
//    activities.add(Activity.withID(
//        "activity3_2",
//        "Activity 3.2",
//        "social_post",
//        "What does forced labour look like in the world today. Send a forced labour awareness  video or message  with an image of yourself in the background, this will be used in our campaign against forced labour in 2020",
//        "summary",
//        "instruction",
//        2000,
//        500,
//        48));
//    activities.add(Activity.withID(
//        "activity4_1",
//        "Activity 4.1",
//        "social_post",
//        "Equal work for equal pay remains the leading topic in gender equality in the workplace with the average in the media industry being men earning 22% higher than women in South Africa.  As a team of a minimum of 3 people, post a creative video to stir up conversation on the issue of equal work for equal pay in the work place. Hashtag gender equality, hashtag BeTheChange.",
//        "summary",
//        "instruction",
//        20000,
//        5000,
//        168));
//    activities.add(Activity.withID(
//        "activity4_2",
//        "Activity 4.2",
//        "social_post",
//        "The recruiting of foreign nationals in manufacturing and production sectors to pay them less than what local workers would receive for the same work is one of the major causes of xenophobic attacks. Suggest ways of curbing such situations. Post your suggestions on social media. Hashtag BePartOfTheSolution, hashtag the relevant government department in your city, hashtag BeTheChange.",
//        "summary",
//        "instruction",
//        10000,
//        2500,
//        72));
//    activities.add(Activity.withID(
//        "activity5_1",
//        "Activity 5.1",
//        "social_post",
//        "Post a list of 5 security measures that people need to be aware of in a case of emergency in a public building hashtag BeSafe, hashtag ChangeAgent",
//        "summary",
//        "instruction",
//        1000,
//        250,
//        24));
//    activities.add(Activity.withID(
//        "activity5_2",
//        "Activity 5.2",
//        "social_post",
//        "Take a picture of the safety features in your school/ university/ workplace. Post the images of the safety measures and assembly points and hashtag your school/university/workplace to remind them of the safety measures in place if disaster strikes. Hashtag BeSafe, hashtag BeTheChange ",
//        "summary",
//        "instruction",
//        2000,
//        500,
//        48));
//    activities.add(Activity.withID(
//        "activity6_1",
//        "Activity 6.1",
//        "social_post",
//        "Consider improving the life of your domestic worker or talk to your parents about improving the skillset of your helpers at home. Engage him/her in a discussion of how they would like to improve their skills through training and assist in making it happen.  Put these improvement plans of paper, take a video or images of you and your helper and tell us about the self development plans. Remember nothing is too big or too small. Hashtag BeTheChange",
//        "summary",
//        "instruction",
//        20000,
//        5000,
//        168));
//    activities.add(Activity.withID(
//        "activity6_2",
//        "Activity 6.2",
//        "social_post",
//        "Post a video of yourself equipping a general hands worker with any skill that they do not currently have. Nothing is too bog or too small. Hashtag eachOneTeachOne, hashtag BeTheChange,",
//        "summary",
//        "instruction",
//        15000,
//        3750,
//        120));
//    activities.add(Activity.withID(
//        "activity7_1",
//        "Activity 7.1",
//        "social_post",
//        "Download the 3 minute video on Fair trade and watch is with your colleagues. Post the link on your social media spaces. Tag businesses in your community who you think could adopt the Fair Trade principles to make an impact in their communities. Tag a few of your friends as well so they can learn about FT",
//        "summary",
//        "instruction",
//        1000,
//        250,
//        24));
//    activities.add(Activity.withID(
//        "activity7_2",
//        "Activity 7.2",
//        "social_post",
//        "Send a 1 minute video clip of yourself explaining what your community would look like if more people adopted the fair trade principles as a tool of sustainable lifestyle",
//        "summary",
//        "instruction",
//        10000,
//        2500,
//        72));
//    activities.add(Activity.withID(
//        "activity7_3",
//        "Activity 7.3",
//        "social_post",
//        "From the list of fair trade products in your country, find where you can purchase a Fair Trade product. Take a picture of you with your product, post on social media, remember to #ChangeAgent",
//        "summary",
//        "instruction",
//        15000,
//        3750,
//        120));
//    activities.add(Activity.withID(
//        "activity7_4",
//        "Activity 7.4",
//        "social_post",
//        "Come up with a catchy slogan /song for the fair trade principles - Hashtag ChangeAgent",
//        "summary",
//        "instruction",
//        15000,
//        3750,
//        120));
//    activities.add(Activity.withID(
//        "activity8_1",
//        "Activity 8.1",
//        "social_post",
//        "Set up rubbish sorting bins at home to assist in your recycling process, take pictures of the various bins.  Also take images of where you dispose of the various bags. Post your recycling story on social media and hashtag BeTheChange",
//        "summary",
//        "instruction",
//        15000,
//        3750,
//        120));
//    activities.add(Activity.withID(
//        "activity8_2",
//        "Activity 8.2",
//        "social_post",
//        "Buy a large strong NON-Plastic shopping bag and take a picture of yourself with the groceries in your bag, post that on social media and remember to encourage others to do the same, stop using plastic bags for your groceries  hashtag ChangeAgent",
//        "summary",
//        "instruction",
//        20000,
//        5000,
//        168));
//    activities.add(Activity.withID(
//        "activity8_3",
//        "Activity 8.3",
//        "social_post",
//        "Collect all the clothes that you and your family have not worn in over 3 years and give these away to underprivileged people, remember to post an image of repurposed wardrobe and encourage others around you to do the and #ChangeAgent",
//        "summary",
//        "instruction",
//        20000,
//        5000,
//        168));
//    activities.add(Activity.withID(
//        "activity8_4",
//        "Activity 8.4",
//        "social_post",
//        "Planting trees is giving back to the environment, especially if the tree is indigenous to you area. Find out what tress are indigenous to your area and plant one. Take a picture if the newly planted tree and post about the positive impact of indigenous trees, remember to #ChangeAgent",
//        "summary",
//        "instruction",
//        20000,
//        5000,
//        168));
//    activities.add(Activity.withID(
//        "activity9_1",
//        "Activity 9.1",
//        "social_post",
//        "South Africa generally does not have a culture of looking out for certification/verification labels when they go shopping. The next time you go shopping – take a few photos of the different certification labels and hashtag them – remember to also #ChangeAgent. To increase you pool of knowledge, you can go and do the research on what the certification label stands for. Minimum  5 labels.",
//        "summary",
//        "instruction",
//        15000,
//        3750,
//        120));
//    activities.add(Activity.withID(
//        "activity9_2",
//        "Activity 9.2",
//        "social_post",
//        "Making sustainable lifestyle choices involves changing purchasing and living habits.  Making refence to any one of the 10 principles – tell a story of how you will plan and implement a change in your community – take a month to post the progress on the change, tell us about the struggles and highlights through posting on your desired social media platform  - remember to #ChangeAgent",
//        "summary",
//        "instruction",
//        1000000,
//        250000,
//        720));
//  }


//  void saveActivitiesToFireBase(Activity activity) async {
//    await databaseReference.collection("activities")
//        .document(activity.id)
//        .setData({
//      'id': activity.id,
//      'name': activity.name,
//      'description': activity.description,
//      'summary': activity.summary,
//      'submission_instruction': activity.activitySubmissionInstruction,
//      'submission_type': activity.submissionType,
//      'time_allocation_points': activity.timeAllocationPoints,
//      'hour_allocation': activity.hourAllocation,
//      'points': activity.points,
//    });
//  }
}
