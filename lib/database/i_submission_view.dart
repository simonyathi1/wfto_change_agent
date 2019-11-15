import 'package:wfto_change_agent/models/user.dart';

abstract class ISubmissionView{
  void showSuccessMessage(String message);
  void showFailureMessage(String message);
}