import 'package:flutter_test/flutter_test.dart';
import 'package:machine_dashboard/models/job.dart';

void main() {
  group('Job Model', () {
    // 1. Test factory Job.fromJson
    test('fromJson handles complete data', () {
      final json = {
        '_id': '123',
        'title': 'Test Job',
        'mode': 'MIG',
        'current': '100A',
        'hotStartTime': '1s',
        'wave': 'Sine',
        'base': '50A',
        'pulse': '2Hz',
        'duty': '50%',
        'wire': 'Steel',
        'shieldingGas': 'Argon',
        'arcLength': '5mm',
        'diameter': '1.2mm',
        'inductance': '10',
        'isActive': true,
      };

      final job = Job.fromJson(json);

      expect(job.id, '123');
      expect(job.title, 'Test Job');
      expect(job.mode, 'MIG');
      expect(job.current, '100A');
      expect(job.hotStartTime, '1s');
      expect(job.wave, 'Sine');
      expect(job.base, '50A');
      expect(job.pulse, '2Hz');
      expect(job.duty, '50%');
      expect(job.wire, 'Steel');
      expect(job.shieldingGas, 'Argon');
      expect(job.arcLength, '5mm');
      expect(job.diameter, '1.2mm');
      expect(job.inductance, '10');
      expect(job.isActive, true);
    });

    test('fromJson handles missing data and nulls gracefully', () {
      final json = {
        'id': '456', // Test 'id' instead of '_id'
        'title': 'Minimal Job',
        'mode': 'MMA',
        'current': '80A',
        'hotStartTime': null, // Test null value
        'isActive': null, // Test null value
        // All other fields are missing
      };

      final job = Job.fromJson(json);

      expect(job.id, '456');
      expect(job.title, 'Minimal Job');
      expect(job.mode, 'MMA');
      expect(job.current, '80A');
      // Null/missing fields should be empty strings
      expect(job.hotStartTime, '');
      expect(job.wave, '');
      expect(job.base, '');
      expect(job.pulse, '');
      expect(job.duty, '');
      expect(job.wire, '');
      expect(job.shieldingGas, '');
      expect(job.arcLength, '');
      expect(job.diameter, '');
      expect(job.inductance, '');
      // Null isActive should default to false
      expect(job.isActive, false);
    });

    test('fromJson handles non-string values by converting them', () {
      final json = {
        'title': 'Numeric Job',
        'mode': 'TIG',
        'current': 120, // Test numeric value
        'inductance': 5.5, // Test double value
      };

      final job = Job.fromJson(json);

      expect(job.current, '120');
      expect(job.inductance, '5.5');
    });

    // 2. Test toJson
    test('toJson serializes correctly', () {
      final job = Job(
        id: '123', // ID should be excluded from toJson
        title: 'Test Job',
        mode: 'MIG',
        current: '100A',
        hotStartTime: '1s',
        wave: 'Sine',
        base: '50A',
        pulse: '2Hz',
        duty: '50%',
        wire: 'Steel',
        shieldingGas: 'Argon',
        arcLength: '5mm',
        diameter: '1.2mm',
        inductance: '10',
        isActive: true,
      );

      final json = job.toJson();

      // The 'id' field MUST be excluded
      expect(json.containsKey('id'), false);
      expect(json.containsKey('_id'), false);

      expect(json['title'], 'Test Job');
      expect(json['mode'], 'MIG');
      expect(json['current'], '100A');
      expect(json['hotStartTime'], '1s');
      expect(json['wave'], 'Sine');
      expect(json['base'], '50A');
      expect(json['pulse'], '2Hz');
      expect(json['duty'], '50%');
      expect(json['wire'], 'Steel');
      expect(json['shieldingGas'], 'Argon');
      expect(json['arcLength'], '5mm');
      expect(json['diameter'], '1.2mm');
      expect(json['inductance'], '10');
      expect(json['isActive'], true);
    });

    // 3. Test default constructor
    test('default constructor initializes correctly', () {
      final job = Job(
        title: 'Default Job',
        mode: 'MMA',
        current: '70A',
      );

      expect(job.id, isNull);
      expect(job.title, 'Default Job');
      expect(job.mode, 'MMA');
      expect(job.current, '70A');
      // All other fields should be empty strings
      expect(job.hotStartTime, '');
      expect(job.wave, '');
      expect(job.base, '');
      expect(job.pulse, '');
      expect(job.duty, '');
      expect(job.wire, '');
      expect(job.shieldingGas, '');
      expect(job.arcLength, '');
      expect(job.diameter, '');
      expect(job.inductance, '');
      // isActive should default to false
      expect(job.isActive, false);
    });
  });
}