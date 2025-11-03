import 'package:flutter_test/flutter_test.dart';
import 'package:machine_dashboard/blocs/job_management/job_event.dart';
import 'package:machine_dashboard/models/job.dart'; // Needed for event constructors

void main() {
  group('JobEvent', () {
    // Helper mock job
    final mockJob1 = Job(id: '1', title: 'Test Job 1', mode: 'MIG', current: '100A');
    final mockJob2 = Job(id: '2', title: 'Test Job 2', mode: 'TIG', current: '120A');

    group('FetchJobsEvent', () {
      test('supports value equality', () {
        expect(FetchJobsEvent(), equals(FetchJobsEvent()));
      });
      test('props are empty', () {
        expect(FetchJobsEvent().props, isEmpty);
      });
    });

    group('AddNewJobEvent', () {
      test('supports value equality', () {
        expect(AddNewJobEvent(), equals(AddNewJobEvent()));
      });
      test('props are empty', () {
        expect(AddNewJobEvent().props, isEmpty);
      });
    });

    group('DeleteJobEvent', () {
      test('supports value equality', () {
        expect(const DeleteJobEvent('1'), equals(const DeleteJobEvent('1')));
        expect(const DeleteJobEvent('1'), isNot(const DeleteJobEvent('2')));
      });
      test('props are correct', () {
        expect(const DeleteJobEvent('1').props, ['1']);
      });
    });

    group('ToggleJobActiveEvent', () {
      test('supports value equality', () {
        expect(ToggleJobActiveEvent(mockJob1), equals(ToggleJobActiveEvent(mockJob1)));
        expect(ToggleJobActiveEvent(mockJob1), isNot(ToggleJobActiveEvent(mockJob2)));
      });
      test('props are correct', () {
        expect(ToggleJobActiveEvent(mockJob1).props, [mockJob1]);
      });
    });

    group('ClearJobActionEvent', () {
      test('supports value equality', () {
        expect(ClearJobActionEvent(), equals(ClearJobActionEvent()));
      });
      test('props are empty', () {
        expect(ClearJobActionEvent().props, isEmpty);
      });
    });

    group('ApplyJobFilterEvent', () {
      test('supports value equality', () {
        expect(
          const ApplyJobFilterEvent({'MIG'}),
          equals(const ApplyJobFilterEvent({'MIG'})),
        );
        expect(
          const ApplyJobFilterEvent({'MIG'}),
          isNot(const ApplyJobFilterEvent({'TIG'})),
        );
      });
      test('props are correct', () {
        expect(const ApplyJobFilterEvent({'MIG'}).props, [
          {'MIG'}
        ]);
      });
    });

    group('AddSpecificJobEvent', () {
      test('supports value equality', () {
        expect(AddSpecificJobEvent(mockJob1), equals(AddSpecificJobEvent(mockJob1)));
        expect(AddSpecificJobEvent(mockJob1), isNot(AddSpecificJobEvent(mockJob2)));
      });
      test('props are correct', () {
        expect(AddSpecificJobEvent(mockJob1).props, [mockJob1]);
      });
    });

    group('UpdateJobEvent', () {
      test('supports value equality', () {
        expect(UpdateJobEvent(mockJob1), equals(UpdateJobEvent(mockJob1)));
        expect(UpdateJobEvent(mockJob1), isNot(UpdateJobEvent(mockJob2)));
      });
      test('props are correct', () {
        expect(UpdateJobEvent(mockJob1).props, [mockJob1]);
      });
    });

    group('SearchJobsEvent', () {
      test('supports value equality', () {
        expect(const SearchJobsEvent('query'), equals(const SearchJobsEvent('query')));
        expect(const SearchJobsEvent('query'), isNot(const SearchJobsEvent('other')));
      });
      test('props are correct', () {
        expect(const SearchJobsEvent('query').props, ['query']);
      });
    });
  });
}