import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/report_model.dart';

/// Loads report content and scoring settings from
/// assets/reports/<assessmentId>.json, and keeps them in memory.
class ReportService {
  ReportService({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  final Map<String, ReportConfig> _cache = <String, ReportConfig>{};

  Future<ReportConfig> load(String assessmentId) async {
    final ReportConfig? cached = _cache[assessmentId];
    if (cached != null) return cached;

    final String raw =
        await _bundle.loadString('assets/reports/$assessmentId.json');
    final ReportConfig config =
        ReportConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    _cache[assessmentId] = config;
    return config;
  }
}
