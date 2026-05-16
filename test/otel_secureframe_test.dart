// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_secureframe/otel_secureframe.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_secureframe-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('tests.run records framework + entities + audit', () async {
    await tracedSecureframe<String>(
      operation: 'tests.run',
      invoke: () async => const SecureframeCallResult(
        value: 'ok',
        result: SecureframeResult(
          companyId: 'co_1',
          framework: 'soc2_type_2',
          controlId: 'cc_6_1',
          testId: 'test_mfa',
          testStatus: 'pass',
          assertion: 'MFA is enabled for all production accounts',
          entityKind: 'IamUser',
          severity: 'high',
          failingEntities: 0,
          passingEntities: 42,
          exceptedEntities: 2,
          vendorSlug: 'aws',
          auditId: 'audit_2026',
          statusCode: 200,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('secureframe tests.run')!);
    expect(a['secureframe.framework'], 'soc2_type_2');
    expect(a['secureframe.test.assertion'],
        'MFA is enabled for all production accounts');
    expect(a['secureframe.passing.entities'], 42);
    expect(a['secureframe.excepted.entities'], 2);
    expect(a['secureframe.audit.id'], 'audit_2026');
  });

  test('failing test sets span error', () async {
    await tracedSecureframe<String>(
      operation: 'tests.run',
      invoke: () async => const SecureframeCallResult(
        value: 'ok',
        result: SecureframeResult(
          testStatus: 'fail',
          severity: 'critical',
          failingEntities: 3,
        ),
      ),
    );
    expect(
      spans.findSpanByName('secureframe tests.run')!.status,
      SpanStatusCode.Error,
    );
  });

  test('cant_run does NOT set span error', () async {
    await tracedSecureframe<String>(
      operation: 'tests.run',
      invoke: () async => const SecureframeCallResult(
        value: 'ok',
        result: SecureframeResult(testStatus: 'cant_run'),
      ),
    );
    expect(
      spans.findSpanByName('secureframe tests.run')!.status,
      isNot(SpanStatusCode.Error),
    );
  });

  test('suppression skips spans', () async {
    await runWithoutSecureframeInstrumentationAsync(() async {
      await tracedSecureframe<String>(
        operation: 'controls.list',
        invoke: () async => const SecureframeCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('secureframe '), isEmpty);
  });
}
