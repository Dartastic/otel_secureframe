// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_secureframe/otel_secureframe.dart';

/// Traces Secureframe calls with OpenTelemetry.
///
/// `otel_secureframe` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Secureframe call in
/// [tracedSecureframe]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'secureframe-example');

  // Wraps a Secureframe API call in a CLIENT span.
  final secureframeId = await tracedSecureframe<String>(
    operation: 'tests.run',
    invoke: () async {
      // Make the Secureframe call here, then report what it returned.
      const id = 'secureframe_8f3a2c';
      return const SecureframeCallResult(
          value: id,
          result: SecureframeResult(
              companyId: 'company_8f3a2c',
              framework: 'soc2_type_1',
              controlId: 'control_8f3a2c',
              testId: 'test_8f3a2c',
              testStatus: 'pass',
              assertion: 'example',
              entityKind: 'Employee',
              entityId: 'entity_8f3a2c',
              severity: 'low',
              failingEntities: 1,
              passingEntities: 1,
              exceptedEntities: 1,
              dueDateSec: 1,
              evidenceTaskId: 'evidencetask_8f3a2c',
              vendorSlug: 'aws',
              auditId: 'audit_8f3a2c',
              statusCode: 200));
    },
  );
  OTelLog.info('tracedSecureframe tests.run returned $secureframeId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutSecureframeInstrumentationAsync.
  await runWithoutSecureframeInstrumentationAsync(
    () => tracedSecureframe<String>(
      operation: 'tests.run',
      invoke: () async {
        const id = 'secureframe_8f3a2c';
        return const SecureframeCallResult(
            value: id,
            result: SecureframeResult(
                companyId: 'company_8f3a2c',
                framework: 'soc2_type_1',
                controlId: 'control_8f3a2c',
                testId: 'test_8f3a2c',
                testStatus: 'pass',
                assertion: 'example',
                entityKind: 'Employee',
                entityId: 'entity_8f3a2c',
                severity: 'low',
                failingEntities: 1,
                passingEntities: 1,
                exceptedEntities: 1,
                dueDateSec: 1,
                evidenceTaskId: 'evidencetask_8f3a2c',
                vendorSlug: 'aws',
                auditId: 'audit_8f3a2c',
                statusCode: 200));
      },
    ),
  );

  await OTel.shutdown();
}
