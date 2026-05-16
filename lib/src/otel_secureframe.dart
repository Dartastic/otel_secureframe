// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_secureframe_suppression.dart';

const _tracerName = 'dartastic_otel_libs_secureframe';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

class SecureframeResult {
  const SecureframeResult({
    this.companyId,
    this.framework,
    this.controlId,
    this.testId,
    this.testStatus,
    this.assertion,
    this.entityKind,
    this.entityId,
    this.severity,
    this.failingEntities,
    this.passingEntities,
    this.exceptedEntities,
    this.dueDateSec,
    this.evidenceTaskId,
    this.vendorSlug,
    this.auditId,
    this.statusCode,
  });

  /// Secureframe company (tenant).
  final String? companyId;

  /// `soc2_type_1` / `soc2_type_2` / `iso_27001` / `iso_27017` /
  /// `iso_27018` / `iso_27701` / `hipaa` / `pci_dss` / `gdpr` /
  /// `nist_csf` / `nist_800_53` / `nist_800_171` / `cmmc` /
  /// `essential_eight`.
  final String? framework;

  final String? controlId;
  final String? testId;

  /// `pass` / `fail` / `cant_run` / `disabled` / `excepted`.
  final String? testStatus;

  /// Free-text description of what the test asserts (e.g.,
  /// `MFA is enabled for all production accounts`).
  final String? assertion;

  /// `Employee` / `Device` / `Vendor` / `Repository` / `CloudResource`
  /// / `Database` / `IamRole` / `IamUser` / `S3Bucket` / `Group`.
  final String? entityKind;

  final String? entityId;

  /// `low` / `medium` / `high` / `critical`.
  final String? severity;

  final int? failingEntities;
  final int? passingEntities;

  /// Entities the customer marked as exception (not counted as
  /// failures during audits).
  final int? exceptedEntities;

  /// Remediation deadline (unix seconds).
  final int? dueDateSec;

  /// Manual evidence task id (for tests that require human upload).
  final String? evidenceTaskId;

  /// `aws` / `gcp` / `azure` / `okta` / `google_workspace` / `github`
  /// / `jamf` / `kandji` / `intune` — source integration.
  final String? vendorSlug;

  /// Audit in progress (for Type 2 evidence collection windows).
  final String? auditId;

  final int? statusCode;
}

class SecureframeCallResult<T> {
  const SecureframeCallResult({required this.value, this.result});
  final T value;
  final SecureframeResult? result;
}

/// Wraps a Secureframe API call in a CLIENT span. [operation] is one
/// of `controls.list`, `controls.get`, `tests.list`, `tests.run`,
/// `evidence_tasks.list`, `evidence_tasks.complete`,
/// `vendors.list`, `personnel.list`, `policies.list`,
/// `audits.list`.
Future<T> tracedSecureframe<T>({
  required String operation,
  required Future<SecureframeCallResult<T>> Function() invoke,
}) async {
  if (secureframeInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'secureframe',
    'rpc.method': operation,
    'secureframe.operation': operation,
  };

  final span = _tracer().startSpan(
    'secureframe $operation',
    kind: SpanKind.client,
    attributes: OTel.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final extras = <Attribute<Object>>[];
      if (r.result!.companyId != null) {
        extras.add(OTel.attributeString(
          'secureframe.company.id',
          r.result!.companyId!,
        ));
      }
      if (r.result!.framework != null) {
        extras.add(OTel.attributeString(
          'secureframe.framework',
          r.result!.framework!,
        ));
      }
      if (r.result!.controlId != null) {
        extras.add(OTel.attributeString(
          'secureframe.control.id',
          r.result!.controlId!,
        ));
      }
      if (r.result!.testId != null) {
        extras.add(OTel.attributeString(
          'secureframe.test.id',
          r.result!.testId!,
        ));
      }
      if (r.result!.testStatus != null) {
        extras.add(OTel.attributeString(
          'secureframe.test.status',
          r.result!.testStatus!,
        ));
        if (r.result!.testStatus == 'fail') {
          span.setStatus(SpanStatusCode.Error, 'Secureframe test fail');
        }
      }
      if (r.result!.assertion != null) {
        extras.add(OTel.attributeString(
          'secureframe.test.assertion',
          r.result!.assertion!,
        ));
      }
      if (r.result!.entityKind != null) {
        extras.add(OTel.attributeString(
          'secureframe.entity.kind',
          r.result!.entityKind!,
        ));
      }
      if (r.result!.entityId != null) {
        extras.add(OTel.attributeString(
          'secureframe.entity.id',
          r.result!.entityId!,
        ));
      }
      if (r.result!.severity != null) {
        extras.add(OTel.attributeString(
          'secureframe.severity',
          r.result!.severity!,
        ));
      }
      if (r.result!.failingEntities != null) {
        extras.add(OTel.attributeInt(
          'secureframe.failing.entities',
          r.result!.failingEntities!,
        ));
      }
      if (r.result!.passingEntities != null) {
        extras.add(OTel.attributeInt(
          'secureframe.passing.entities',
          r.result!.passingEntities!,
        ));
      }
      if (r.result!.exceptedEntities != null) {
        extras.add(OTel.attributeInt(
          'secureframe.excepted.entities',
          r.result!.exceptedEntities!,
        ));
      }
      if (r.result!.dueDateSec != null) {
        extras.add(OTel.attributeInt(
          'secureframe.due_date_sec',
          r.result!.dueDateSec!,
        ));
      }
      if (r.result!.evidenceTaskId != null) {
        extras.add(OTel.attributeString(
          'secureframe.evidence_task.id',
          r.result!.evidenceTaskId!,
        ));
      }
      if (r.result!.vendorSlug != null) {
        extras.add(OTel.attributeString(
          'secureframe.vendor.slug',
          r.result!.vendorSlug!,
        ));
      }
      if (r.result!.auditId != null) {
        extras.add(OTel.attributeString(
          'secureframe.audit.id',
          r.result!.auditId!,
        ));
      }
      if (r.result!.statusCode != null) {
        extras.add(OTel.attributeInt(
          'http.response.status_code',
          r.result!.statusCode!,
        ));
        if (r.result!.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'Secureframe HTTP ${r.result!.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTel.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTel.attributes([
      OTel.attributeString(
        ErrorResource.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
