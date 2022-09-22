// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'homebrew_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomebrewConfig _$HomebrewConfigFromJson(Map<String, dynamic> json) =>
    HomebrewConfig(
      optionalClassName: json['class_name'] as String?,
      optionalDescription: json['optionalDescription'] as String?,
      optionalHomePage: json['home_page'] as String?,
      optionalBinSrc: json['bin_src_file'] as String?,
      optionalExecutableName: json['executable_name'] as String?,
    );

Map<String, dynamic> _$HomebrewConfigToJson(HomebrewConfig instance) =>
    <String, dynamic>{
      'class_name': instance.optionalClassName,
      'optionalDescription': instance.optionalDescription,
      'home_page': instance.optionalHomePage,
      'bin_src_file': instance.optionalBinSrc,
      'executable_name': instance.optionalExecutableName,
    };
