import 'dart:convert';
import 'dart:io' show Platform, exit, HttpClient;
import 'package:dolumns/dolumns.dart';
import 'package:smart_arg/smart_arg.dart';
import 'home.reflectable.dart';

@SmartArg.reflectable
@Parser(description: 'Hello World application')
class Args extends SmartArg {
  @StringArgument(
    help: 'CircleCI API Key',
    isRequired: true,
    environmentVariable: 'CIRCLECI_API_KEY',
  )
  String circleciApiKey = Platform.environment["CIRCLECI_API_KEY"];

  @BooleanArgument(help: 'My Pipelines Only?')
  bool mine = false;

  @StringArgument(
    help: 'Organisation Slug',
    isRequired: true,
    environmentVariable: 'CIRCLECI_ORG_SLUG',
  )
  String orgSlug;

  @HelpArgument()
  bool help = false;

  Uri pipelineUri() {
    var queryParams = {'org-slug': this.orgSlug};
    if (this.mine) {
      queryParams.putIfAbsent('mine', () => 'true');
    }
    return Uri.https('circleci.com', '/api/v2/pipeline', queryParams);
  }
}

String _circleCiApiToken;

Args _readArgs(List<String> arguments) {
  initializeReflectable();
  var args = Args()..parse(arguments);
  if (args.help) {
    print(args.usage());
    exit(0);
  }
  _circleCiApiToken = args.circleciApiKey;
  return args;
}

Future<dynamic> _circleCiGet(Uri url) async {
  var request = await HttpClient().getUrl(url);
  request.headers.add('Circle-Token', _circleCiApiToken);
  request.headers.add('Accept', 'application/json');
  var response = await request.close();
  if (response.statusCode >= 300) {
    exit(1);
  }
  return await response.transform(Utf8Decoder()).transform(json.decoder).first;
}

void main(List<String> arguments) async {
  var args = _readArgs(arguments);
  var body = await _circleCiGet(args.pipelineUri());
  List items = body['items'];
  var headerRow = ['BRANCH', 'COMMIT', 'STATE'];
  var columns = items.fold(<List<Object>>[headerRow], (
    dynamic previousValue,
    dynamic element,
  ) {
    previousValue.add([
      element['vcs']['branch'],
      element['vcs']['commit']['subject'],
      element['state'],
    ]);
    return previousValue;
  });
  print(dolumnify(
    columns,
    columnSplitter: ' | ',
    headerIncluded: true,
    headerSeparator: '-',
  ));
  exit(0);
}
