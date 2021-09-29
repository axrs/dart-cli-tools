import 'dart:io' show exit;

import 'package:barbecue/barbecue.dart';
import 'package:collection/collection.dart';
import 'package:colorize/colorize.dart';
import 'package:duration/duration.dart';
import 'package:fpdart/fpdart.dart';
import 'package:io_axrs_dart_cli_tools/ansi.dart';
import 'package:io_axrs_dart_cli_tools/ci.dart' as CI;
import 'package:io_axrs_dart_cli_tools/circleci/impl.dart';
import 'package:smart_arg/smart_arg.dart';

import 'ci.reflectable.dart';

@SmartArg.reflectable
@Parser(description: 'Continuous Integration CLI Helper')
class CiArgs extends SmartArg {
  @StringArgument(
    help: 'CircleCI API Key',
    isRequired: true,
    environmentVariable: 'CIRCLECI_API_KEY',
  )
  String circleciApiKey;

  @IntegerArgument(
    help: 'Number of recent CI Builds to limit to. Defaults to 30.',
    minimum: 1,
    maximum: 100,
  )
  int limit = 30;

  @HelpArgument()
  bool help = false;
}

final colorizeRow = (String status, String value) {
  if (value == null) {
    return '';
  }
  switch (status) {
    case "failed":
      value = new Colorize(value).red().toString();
      break;
    case "success":
      value = new Colorize(value).green().toString();
      break;
    case "not_run":
      value = new Colorize(value).lightGray().toString();
      break;
  }
  return value;
};

List<Cell> buildEntryToTableCells(CI.Build entry) {
  var currentStatus = entry.getStatus();
  return [
    entry.getProject(),
    entry.getBranch(),
    entry.getJobName(),
    currentStatus,
    prettyDuration(
      Duration(milliseconds: entry.getBuildTime() ?? 0),
      abbreviated: true,
    ),
    entry.getCommitSubject(),
    hyperlink('🔨', entry.getBuildUrl()),
  ]
      .map<String>(curry2(colorizeRow)(currentStatus))
      .map<Cell>(toTableCell)
      .toList();
}

const headerRow = [
  'PROJECT',
  'BRANCH',
  'JOB',
  'STATUS',
  'DURATION',
  'COMMIT',
  ''
];

Cell toTableCell(String v) => Cell(v);

CiArgs _readArgs(List<String> arguments) {
  initializeReflectable();
  var args = CiArgs()..parse(arguments);
  if (args.help) {
    print(args.usage());
    exit(0);
  }
  return args;
}

void main(List<String> arguments) async {
  var args = _readArgs(arguments);
  var ci = new CircleCi(args.circleciApiKey);
  List<CI.Build> builds = await ci.fetchBuilds(args.limit);
  var rows = groupBy(builds, CI.buildWorkflowId)
      .entries
      .map((e) => e.value)
      .map(CI.sortBuildsByStartTimeDesc)
      .expand(identity)
      .map(buildEntryToTableCells)
      .map((cells) => Row(cells: cells))
      .toList();

  print(Table(
      header: TableSection(rows: [
        Row(
          cells: headerRow.map(toTableCell).toList(),
          cellStyle: CellStyle(borderBottom: true),
        ),
      ]),
      body: TableSection(
        cellStyle: CellStyle(paddingRight: 2),
        rows: rows,
      )).render());
  exit(0);
}
