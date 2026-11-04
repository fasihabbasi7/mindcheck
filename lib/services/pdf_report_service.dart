import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/assessment_model.dart';
import '../models/assessment_result_model.dart';
import '../models/report_model.dart';
import '../models/trait_score_model.dart';
import '../utils/app_strings.dart';
import '../utils/helpers.dart';

/// Builds a styled PDF version of a report and opens the system share
/// sheet. The PDF is created on the device; nothing is uploaded.
class PdfReportService {
  const PdfReportService();

  static const PdfColor _primary = PdfColor.fromInt(0xFF7565D8);
  static const PdfColor _lavender = PdfColor.fromInt(0xFFE9E4FB);
  static const PdfColor _text = PdfColor.fromInt(0xFF25243A);
  static const PdfColor _muted = PdfColor.fromInt(0xFF77758A);

  Future<void> share({
    required AssessmentResult result,
    required AssessmentModel assessment,
    required ReportConfig report,
  }) async {
    final Uint8List bytes = await build(
      result: result,
      assessment: assessment,
      report: report,
    );
    final String date = result.completedAt.toIso8601String().substring(0, 10);
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'MindCheck-${assessment.id}-$date.pdf',
    );
  }

  Future<Uint8List> build({
    required AssessmentResult result,
    required AssessmentModel assessment,
    required ReportConfig report,
  }) async {
    final pw.Document doc = pw.Document(
      title: '${assessment.title} report',
      author: AppStrings.appName,
    );
    final OverallScore? overall = result.overall;

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(40, 40, 40, 48),
        footer: (pw.Context context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: <pw.Widget>[
            pw.Text(
              _clean('MindCheck · for self-reflection, not diagnosis'),
              style: const pw.TextStyle(fontSize: 8, color: _muted),
            ),
            pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 8, color: _muted),
            ),
          ],
        ),
        build: (pw.Context context) => <pw.Widget>[
          // ---------- Header ----------
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: const pw.BoxDecoration(
              color: _lavender,
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(14)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.Text(
                  'MINDCHECK REPORT',
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: _primary,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  _clean(assessment.title),
                  style: pw.TextStyle(
                    fontSize: 22,
                    color: _text,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  _clean(
                    'Completed ${Helpers.formatDateTime(result.completedAt)} '
                    '- ${result.answers.length} answers',
                  ),
                  style: const pw.TextStyle(fontSize: 10, color: _muted),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 18),

          // ---------- Main result ----------
          if (overall != null)
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: <pw.Widget>[
                pw.Text(
                  overall.display,
                  style: pw.TextStyle(
                    fontSize: 34,
                    color: _primary,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(width: 6),
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 6),
                  child: pw.Text(
                    _clean('out of ${overall.max.round()} - ${overall.label}'),
                    style: const pw.TextStyle(fontSize: 10, color: _muted),
                  ),
                ),
              ],
            ),
          pw.Text(
            _clean(result.headline),
            style: pw.TextStyle(
              fontSize: 15,
              color: _text,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 6),
          _paragraph(overall?.bandSummary ?? report.intro ?? ''),
          pw.SizedBox(height: 18),

          // ---------- Safety support (PHQ-9 question 9) ----------
          if (result.extras['safetyFlag'] == 1) ...<pw.Widget>[
            _heading(AppStrings.safetyTitle),
            _paragraph(
              '${AppStrings.safetyBody} ${AppStrings.safetyEmergency}',
            ),
            _bullet(AppStrings.safetyHelplinePakistan),
            _bullet(AppStrings.safetyHelplineWorld),
            pw.SizedBox(height: 12),
          ],

          // ---------- Traits ----------
          if (result.traits.isNotEmpty) ...<pw.Widget>[
            _heading('Your profile'),
            for (final TraitScore trait in result.traits)
              _traitBlock(trait, report),
          ],

          // ---------- Suggestions ----------
          if (report.suggestions.isNotEmpty) ...<pw.Widget>[
            pw.SizedBox(height: 6),
            _heading('Things to keep in mind'),
            for (final String s in report.suggestions) _bullet(s),
          ],

          // ---------- Scoring + disclaimer ----------
          pw.SizedBox(height: 14),
          _heading('How your score was calculated'),
          _paragraph(report.note),
          pw.SizedBox(height: 10),
          _heading('Source'),
          _paragraph('${assessment.sourceName}. ${assessment.citation}'),
          if (assessment.copyrightNotice != null)
            _paragraph(assessment.copyrightNotice!),
          pw.SizedBox(height: 14),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: _primary, width: 0.8),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
            ),
            child: _paragraph(
              '${AppStrings.resultDisclaimer} '
              '${assessment.sourceType.label}: '
              '${assessment.sourceType.explanation}',
            ),
          ),
        ],
      ),
    );

    return doc.save();
  }

  // ---------- Pieces ----------

  pw.Widget _heading(String text) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 8),
        child: pw.Text(
          _clean(text),
          style: pw.TextStyle(
            fontSize: 13,
            color: _primary,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      );

  pw.Widget _paragraph(String text) => pw.Text(
        _clean(text),
        style: const pw.TextStyle(fontSize: 10, color: _text, lineSpacing: 2),
      );

  pw.Widget _bullet(String text) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 4),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: <pw.Widget>[
            pw.Container(
              width: 4,
              height: 4,
              margin: const pw.EdgeInsets.only(top: 4, right: 8),
              decoration: const pw.BoxDecoration(
                color: _primary,
                shape: pw.BoxShape.circle,
              ),
            ),
            pw.Expanded(child: _paragraph(text)),
          ],
        ),
      );

  pw.Widget _traitBlock(TraitScore trait, ReportConfig report) {
    final TraitText? text = report.traitTexts[trait.traitId];
    final int filled = trait.percent.round().clamp(0, 100).toInt();

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Row(
            children: <pw.Widget>[
              pw.Expanded(
                child: pw.Text(
                  _clean(trait.name),
                  style: pw.TextStyle(
                    fontSize: 11,
                    color: _text,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Text(
                _clean(
                  '${report.levelLabel(trait.level)} - '
                  '${trait.percent.round()}/100',
                ),
                style: const pw.TextStyle(fontSize: 9, color: _muted),
              ),
            ],
          ),
          pw.SizedBox(height: 4),
          // Score bar: two flexible parts, filled and empty.
          pw.ClipRRect(
            horizontalRadius: 3,
            verticalRadius: 3,
            child: pw.SizedBox(
              height: 6,
              child: pw.Row(
                children: <pw.Widget>[
                  if (filled > 0)
                    pw.Expanded(
                      flex: filled,
                      child: pw.Container(color: _primary),
                    ),
                  if (filled < 100)
                    pw.Expanded(
                      flex: 100 - filled,
                      child: pw.Container(color: _lavender),
                    ),
                ],
              ),
            ),
          ),
          if (text != null) ...<pw.Widget>[
            pw.SizedBox(height: 5),
            _paragraph(text.forLevel(trait.level)),
            pw.SizedBox(height: 3),
            pw.Text(
              _clean('Reflect: ${text.reflect}'),
              style: pw.TextStyle(
                fontSize: 9,
                color: _muted,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// The built-in PDF fonts only cover basic Latin characters, so replace
  /// typographic symbols and drop anything else they cannot draw.
  static String _clean(String input) {
    final String replaced = input
        .replaceAll(RegExp('[‘’]'), "'")
        .replaceAll(RegExp('[“”]'), '"')
        .replaceAll(RegExp('[–—]'), '-')
        .replaceAll('·', '-')
        .replaceAll('…', '...')
        .replaceAll('→', '->')
        .replaceAll('ö', 'o')
        .replaceAll('©', '(c)');
    return replaced.replaceAll(RegExp(r'[^\x20-\x7E\n]'), '');
  }
}
