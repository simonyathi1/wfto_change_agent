import 'package:wfto_change_agent/models/submission.dart';

import 'i_submission_view.dart';

abstract class IAdminSubmissionView extends ISubmissionView {
  void setSubmissionList(List<Submission> submissionList);

  void setSubmission(Submission submission);
}
