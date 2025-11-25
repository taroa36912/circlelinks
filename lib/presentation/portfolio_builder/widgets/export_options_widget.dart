import 'dart:convert';
import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:sizer/sizer.dart';
import 'package:universal_html/html.dart' as html;

import '../../../core/app_export.dart';

class ExportOptionsWidget extends StatelessWidget {
  final Map<String, dynamic> portfolioData;
  final VoidCallback onClose;

  const ExportOptionsWidget({
    super.key,
    required this.portfolioData,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(6.w)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10.w,
            height: 1.h,
            margin: EdgeInsets.symmetric(vertical: 2.h),
            decoration: BoxDecoration(
              color: colorScheme.outline,
              borderRadius: BorderRadius.circular(0.5.h),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Export Portfolio',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: colorScheme.onSurfaceVariant,
                    size: 6.w,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          _buildExportOption(
            context,
            'PDF Portfolio',
            'Professional format for job applications',
            'picture_as_pdf',
            AppTheme.error,
            () => _exportToPDF(context),
          ),
          _buildExportOption(
            context,
            'CSV Data',
            'Spreadsheet format for data analysis',
            'table_chart',
            AppTheme.success,
            () => _exportToCSV(context),
          ),
          _buildExportOption(
            context,
            'JSON Export',
            'Complete data backup format',
            'code',
            AppTheme.warning,
            () => _exportToJSON(context),
          ),
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              'Template Styles',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          _buildTemplateOption(
            context,
            'Corporate Style',
            'Traditional Japanese business format',
            'business',
            AppTheme.primary,
            () => _exportWithTemplate(context, 'corporate'),
          ),
          _buildTemplateOption(
            context,
            'Creative Style',
            'Modern design for creative industries',
            'palette',
            AppTheme.secondary,
            () => _exportWithTemplate(context, 'creative'),
          ),
          _buildTemplateOption(
            context,
            'Technical Style',
            'Clean format for tech positions',
            'computer',
            AppTheme.success,
            () => _exportWithTemplate(context, 'technical'),
          ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildExportOption(
    BuildContext context,
    String title,
    String description,
    String icon,
    Color color,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(2.w),
        ),
        child: CustomIconWidget(
          iconName: icon,
          color: color,
          size: 6.w,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        description,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: CustomIconWidget(
        iconName: 'download',
        color: colorScheme.onSurfaceVariant,
        size: 5.w,
      ),
    );
  }

  Widget _buildTemplateOption(
    BuildContext context,
    String title,
    String description,
    String icon,
    Color color,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(2.w),
        ),
        child: CustomIconWidget(
          iconName: icon,
          color: color,
          size: 6.w,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        description,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: CustomIconWidget(
        iconName: 'arrow_forward_ios',
        color: colorScheme.onSurfaceVariant,
        size: 4.w,
      ),
    );
  }

  Future<void> _exportToPDF(BuildContext context) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Text(
                    'Portfolio - ${portfolioData['userName'] ?? 'Student'}',
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'University: ${portfolioData['university'] ?? 'N/A'}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.Text(
                  'Major: ${portfolioData['major'] ?? 'N/A'}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.SizedBox(height: 30),
                pw.Header(
                  level: 1,
                  child: pw.Text('Leadership Roles'),
                ),
                ..._buildPDFSection(portfolioData['leadership']
                        as List<Map<String, dynamic>>? ??
                    []),
                pw.SizedBox(height: 20),
                pw.Header(
                  level: 1,
                  child: pw.Text('Event Organization'),
                ),
                ..._buildPDFSection(
                    portfolioData['events'] as List<Map<String, dynamic>>? ??
                        []),
                pw.SizedBox(height: 20),
                pw.Header(
                  level: 1,
                  child: pw.Text('Project Contributions'),
                ),
                ..._buildPDFSection(
                    portfolioData['projects'] as List<Map<String, dynamic>>? ??
                        []),
              ],
            );
          },
        ),
      );

      final pdfBytes = await pdf.save();
      await _downloadFile(pdfBytes, 'portfolio.pdf', 'application/pdf');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Portfolio exported as PDF successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to export PDF')),
        );
      }
    }
  }

  List<pw.Widget> _buildPDFSection(List<Map<String, dynamic>> items) {
    return items
        .map((item) => pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 10),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    item['title'] as String? ?? '',
                    style: pw.TextStyle(
                        fontSize: 16, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    item['organization'] as String? ?? '',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                  pw.Text(
                    item['description'] as String? ?? '',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                  pw.SizedBox(height: 5),
                ],
              ),
            ))
        .toList();
  }

  Future<void> _exportToCSV(BuildContext context) async {
    try {
      final csvData = _generateCSVData();
      await _downloadFile(utf8.encode(csvData), 'portfolio.csv', 'text/csv');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Portfolio exported as CSV successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to export CSV')),
        );
      }
    }
  }

  String _generateCSVData() {
    final buffer = StringBuffer();
    buffer.writeln(
        'Category,Title,Organization,Description,Date,Impact Score,Verified');

    final allItems = [
      ...(portfolioData['leadership'] as List<Map<String, dynamic>>? ?? [])
          .map((item) => {...item, 'category': 'Leadership'}),
      ...(portfolioData['events'] as List<Map<String, dynamic>>? ?? [])
          .map((item) => {...item, 'category': 'Event'}),
      ...(portfolioData['projects'] as List<Map<String, dynamic>>? ?? [])
          .map((item) => {...item, 'category': 'Project'}),
    ];

    for (final item in allItems) {
      buffer.writeln([
        item['category'] ?? '',
        '"${item['title'] ?? ''}"',
        '"${item['organization'] ?? ''}"',
        '"${item['description'] ?? ''}"',
        item['date'] ?? '',
        item['impactScore'] ?? 0,
        item['isVerified'] ?? false,
      ].join(','));
    }

    return buffer.toString();
  }

  Future<void> _exportToJSON(BuildContext context) async {
    try {
      final jsonData = jsonEncode(portfolioData);
      await _downloadFile(
          utf8.encode(jsonData), 'portfolio.json', 'application/json');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Portfolio exported as JSON successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to export JSON')),
        );
      }
    }
  }

  Future<void> _exportWithTemplate(
      BuildContext context, String template) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return _buildTemplatedPDF(template);
          },
        ),
      );

      final pdfBytes = await pdf.save();
      await _downloadFile(
          pdfBytes, 'portfolio_$template.pdf', 'application/pdf');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Portfolio exported with $template template')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to export with template')),
        );
      }
    }
  }

  pw.Widget _buildTemplatedPDF(String template) {
    switch (template) {
      case 'corporate':
        return _buildCorporateTemplate();
      case 'creative':
        return _buildCreativeTemplate();
      case 'technical':
        return _buildTechnicalTemplate();
      default:
        return _buildCorporateTemplate();
    }
  }

  pw.Widget _buildCorporateTemplate() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(20),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey200,
            borderRadius: pw.BorderRadius.circular(5),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                portfolioData['userName'] as String? ?? 'Student Name',
                style:
                    pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                '${portfolioData['university'] ?? 'University'} | ${portfolioData['major'] ?? 'Major'}',
                style: const pw.TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 30),
        ..._buildPDFSection(
            portfolioData['leadership'] as List<Map<String, dynamic>>? ?? []),
      ],
    );
  }

  pw.Widget _buildCreativeTemplate() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(20),
          decoration: pw.BoxDecoration(
            gradient: const pw.LinearGradient(
              colors: [PdfColors.blue, PdfColors.purple],
            ),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                portfolioData['userName'] as String? ?? 'Student Name',
                style: pw.TextStyle(
                  fontSize: 32,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Creative Portfolio',
                style: pw.TextStyle(
                  fontSize: 18,
                  color: PdfColors.white,
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 30),
        ..._buildPDFSection(
            portfolioData['projects'] as List<Map<String, dynamic>>? ?? []),
      ],
    );
  }

  pw.Widget _buildTechnicalTemplate() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    portfolioData['userName'] as String? ?? 'Student Name',
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    'Technical Portfolio',
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            pw.Container(
              width: 100,
              height: 100,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey),
                borderRadius: pw.BorderRadius.circular(50),
              ),
              child: pw.Center(
                child: pw.Text('PHOTO'),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 30),
        ..._buildPDFSection(
            portfolioData['projects'] as List<Map<String, dynamic>>? ?? []),
      ],
    );
  }

  Future<void> _downloadFile(
      List<int> bytes, String filename, String mimeType) async {
    if (kIsWeb) {
      final blob = html.Blob([bytes], mimeType);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute("download", filename)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsBytes(bytes);
    }
  }
}
