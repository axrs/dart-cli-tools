import 'package:get_it/get_it.dart';
import 'package:io_axrs_dart_cli_tools/circleci/impl.dart';
import 'package:io_axrs_dart_cli_tools/util.dart';
import 'package:smart_arg/smart_arg.dart';
import 'ci.dart' as CI;

/// Represents a CircleCi API Key argument that dynamically registers
/// a new CI.Service instance with GetIt
class CircleCiApiKeyArgument extends StringArgument {
  const CircleCiApiKeyArgument({
    String short,
    dynamic long,
    String help,
    bool isRequired,
    String environmentVariable,
  }) : super(
            short: short,
            long: long,
            help: help,
            isRequired: isRequired,
            environmentVariable: environmentVariable);

  @override
  dynamic handleValue(String key, dynamic value) {
    final String apiKey = cast<String>(value);
    if (isNotBlank(apiKey)) {
      GetIt.instance
          .registerLazySingleton<CI.Service>(() => CircleCi(apiKey.trim()));
      return value;
    } else {
      return null;
    }
  }
}
