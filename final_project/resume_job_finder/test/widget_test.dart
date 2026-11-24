import 'package:flutter_test/flutter_test.dart';
import 'package:resume_job_finder/main.dart';

void main() {
  testWidgets('App basic smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ResumeJobFinderApp());
    expect(find.textContaining('Dashboard'), findsWidgets);
  });
}
