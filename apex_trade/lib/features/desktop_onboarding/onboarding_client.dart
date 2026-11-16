import 'dart:convert';
import 'dart:io';

class OnboardingCheck {
  const OnboardingCheck({
    required this.name,
    required this.passed,
    required this.detail,
  });

  final String name;
  final bool passed;
  final String detail;

  factory OnboardingCheck.fromJson(Map<String, dynamic> json) =>
      OnboardingCheck(
        name: json['name'] as String? ?? 'Check',
        passed: json['passed'] == true,
        detail: json['detail'] as String? ?? 'No details available',
      );
}

class DemoVerification {
  const DemoVerification({
    required this.verified,
    required this.terminalPath,
    required this.accountFingerprint,
    required this.accountLabel,
    required this.server,
    required this.blockedReason,
    required this.checks,
  });

  final bool verified;
  final String terminalPath;
  final String accountFingerprint;
  final String accountLabel;
  final String server;
  final String blockedReason;
  final List<OnboardingCheck> checks;

  factory DemoVerification.fromJson(Map<String, dynamic> json) {
    if (json['schema'] != 'emtifize-onboarding-v1') {
      throw const FormatException(
        'The local safety service returned an unsupported response.',
      );
    }
    final checks = json['checks'];
    return DemoVerification(
      verified:
          json['account_verified'] == true &&
          json['demo_only'] == true &&
          json['execution_allowed'] == false,
      terminalPath: json['terminal_path'] as String? ?? '',
      accountFingerprint: json['account_fingerprint'] as String? ?? '',
      accountLabel: json['account_label'] as String? ?? 'Unavailable',
      server: json['server'] as String? ?? 'Unavailable',
      blockedReason:
          json['execution_blocked_reason'] as String? ??
          'Automated trading is locked.',
      checks: checks is List
          ? checks
                .whereType<Map<String, dynamic>>()
                .map(OnboardingCheck.fromJson)
                .toList()
          : const [],
    );
  }

  Map<String, dynamic> toStoredJson() => {
    'schema': 'emtifize-desktop-account-v1',
    'terminal_path': terminalPath,
    'account_fingerprint': accountFingerprint,
    'account_label': accountLabel,
    'server': server,
  };
}

abstract interface class OnboardingClient {
  Future<List<String>> detectTerminals();
  Future<DemoVerification> verifyDemo(String terminalPath);
}

class LocalOnboardingClient implements OnboardingClient {
  const LocalOnboardingClient();

  @override
  Future<List<String>> detectTerminals() async {
    final response = await _run(const ['detect']);
    final terminals = response['terminals'];
    if (response['schema'] != 'emtifize-onboarding-v1' || terminals is! List) {
      throw const FormatException(
        'The local safety service returned an invalid terminal list.',
      );
    }
    return terminals.whereType<String>().toList(growable: false);
  }

  @override
  Future<DemoVerification> verifyDemo(String terminalPath) async {
    final response = await _run([
      'verify',
      '--terminal',
      terminalPath,
      '--symbol',
      'EURUSD',
    ], allowVerificationFailure: true);
    return DemoVerification.fromJson(response);
  }

  Future<Map<String, dynamic>> _run(
    List<String> action, {
    bool allowVerificationFailure = false,
  }) async {
    final executableDir = File(Platform.resolvedExecutable).parent;
    final bundled = File(
      '${executableDir.path}${Platform.pathSeparator}runtime'
      '${Platform.pathSeparator}emtifize-onboarding.exe',
    );
    late final String executable;
    late final List<String> arguments;
    String? workingDirectory;
    if (bundled.existsSync()) {
      executable = bundled.path;
      arguments = action;
    } else {
      final python = Platform.environment['EMTIFIZE_BACKEND_PYTHON'];
      final root = Platform.environment['EMTIFIZE_BACKEND_ROOT'];
      if (python == null || root == null) {
        throw const ProcessException(
          'emtifize-onboarding',
          [],
          'The local safety service is missing. Reinstall Emtifize AI.',
        );
      }
      executable = python;
      arguments = ['-B', 'scripts/product_onboarding.py', ...action];
      workingDirectory = root;
    }
    final result = await Process.run(
      executable,
      arguments,
      workingDirectory: workingDirectory,
    );
    if (result.exitCode != 0 &&
        !(allowVerificationFailure && result.exitCode == 2)) {
      throw ProcessException(
        executable,
        arguments,
        'The local safety service could not complete the check.',
        result.exitCode,
      );
    }
    final decoded = jsonDecode((result.stdout as String).trim());
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'The local safety service returned invalid data.',
      );
    }
    return decoded;
  }
}
