import '../models/issue_model.dart';

class IssueTransformer {
  /// Converts a raw list of issues into a categorized Map for the UI.
  /// This is pre-computed to ensure the TabBarView transitions are stutter-free.
  static Map<int, List<IssueModel>> transformToTabs(List<IssueModel> allIssues) {
    return {
      0: allIssues, // "All" tab
      1: allIssues.where((i) => i.status == 'Reported').toList(),
      2: allIssues.where((i) => i.status == 'In Progress').toList(),
      3: allIssues.where((i) => i.status == 'Resolved').toList(),
    };
  }
}