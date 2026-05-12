import 'package:civic_connect/features/issues/data/mock_card_data.dart';
import 'package:civic_connect/features/issues/utils/issue_sorter.dart';

void updateIssueVotes(String issueId, bool isUpvote) {
    final index = issues.indexWhere((element) => element['id'] == issueId);
    if (index != -1) {
      if (isUpvote) {
        issues[index]['upvotes']++;
      } else {
        issues[index]['downvotes']++;
      }
      sortedIssues = List.from(issues);
      sortIssuesByRelevance();
    }
}