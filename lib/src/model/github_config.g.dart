// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GithubConfig _$GithubConfigFromJson(Map<String, dynamic> json) => GithubConfig(
      repoUser: json['repoUser'] as String,
      repoName: json['repoName'] as String,
      optionalBearerToken: json['bearerToken'] as String?,
    );

Map<String, dynamic> _$GithubConfigToJson(GithubConfig instance) =>
    <String, dynamic>{
      'repoUser': instance.repoUser,
      'repoName': instance.repoName,
      'bearerToken': instance.optionalBearerToken,
    };
