import 'dart:core';
import 'package:collection/collection.dart';

abstract class Build {
  String getBranch();

  String getCommitSubject();

  String getProject();

  String getAuthor();

  String getStatus();

  String getJobName();

  String getWorkflowName();

  String getWorkflowId();

  String getStartTime();

  String getBuildUrl();

  int getBuildTime();
}

abstract class Service {
  Future<List<Build>> fetchBuilds(int limit);
}

String buildStartTime(Build b) => b.getStartTime();
String buildWorkflowId(Build b) => b.getWorkflowId();

Iterable<Build> sortBuildsByStartTimeDesc(List<Build> entries) =>
    entries.sortedBy(buildStartTime).reversed;
