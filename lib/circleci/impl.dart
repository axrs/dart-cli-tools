import 'dart:convert';
import 'dart:io';
import '../ci.dart' as CI;

class CircleCiBuild implements CI.Build {
  final Map<String, dynamic> _json;

  CircleCiBuild.fromJson(Map<String, dynamic> json) : _json = json;

  @override
  String getBranch() {
    return _json['branch'];
  }

  @override
  String getAuthor() {
    return _json['committer_name'];
  }

  @override
  String getCommitSubject() {
    return _json['subject'];
  }

  @override
  String getJobName() {
    return _json['workflows']['job_name'];
  }

  @override
  String getWorkflowId() {
    return _json['workflows']['workflow_id'];
  }

  @override
  String getWorkflowName() {
    return _json['workflows']['workflow_name'];
  }

  @override
  String getProject() {
    return _json['reponame'];
  }

  @override
  String getStatus() {
    return _json['status'];
  }

  @override
  String getStartTime() {
    return _json['start_time'];
  }

  @override
  String getBuildUrl() {
    return _json['build_url'];
  }

  @override
  int getBuildTime() {
    return _json['build_time_millis'];
  }
}

class CircleCi implements CI.Service {
  final String _apiKey;

  CircleCi(this._apiKey);

  Future<List<CI.Build>> fetchBuilds(int limit) async {
    var url = _getRecentBuildsUrl(limit: limit);
    var request = await HttpClient().getUrl(url);
    request.headers
      ..add('Circle-Token', _apiKey)
      ..add('Accept', 'application/json');
    var response = await request.close();
    List<dynamic> body =
        await response.transform(Utf8Decoder()).transform(json.decoder).first;
    return body
        .map<CI.Build>((json) => CircleCiBuild.fromJson(json))
        .toList();
  }

  Uri _getRecentBuildsUrl({int limit = 30}) {
    var queryParams = {
      'limit': limit.toString(),
      'shallow': 'true',
    };
    var url = Uri.https('circleci.com', '/api/v1.1/recent-builds', queryParams);
    return url;
  }
}
