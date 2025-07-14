import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';
import '../utils/pdf_utils.dart';

class PdfViewerWidget extends StatefulWidget {
  final String base64String;
  final String title;
  final String? patientName;

  const PdfViewerWidget({
    super.key,
    required this.base64String,
    required this.title,
    this.patientName,
  });

  @override
  State<PdfViewerWidget> createState() => _PdfViewerWidgetState();
}

class _PdfViewerWidgetState extends State<PdfViewerWidget> {
  File? _pdfFile;
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 0;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final fileName = PdfUtils.generateFileName(
        'medical_report',
        patientName: widget.patientName,
      );

      final file = await PdfUtils.base64ToPdf(widget.base64String, fileName);
      
      if (file != null && await file.exists()) {
        setState(() {
          _pdfFile = file;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load PDF file';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading PDF: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _sharePdf() async {
    if (_pdfFile != null) {
      await PdfUtils.sharePdf(_pdfFile!, widget.title);
    }
  }

  Future<void> _downloadPdf() async {
    try {
      final fileName = PdfUtils.generateFileName(
        'medical_report',
        patientName: widget.patientName,
      );

      final file = await PdfUtils.savePdfToDownloads(widget.base64String, fileName);
      
      if (file != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF saved to ${file.path}'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Share',
              onPressed: () => PdfUtils.sharePdf(file, widget.title),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (_pdfFile != null) ...[
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _sharePdf,
              tooltip: 'Share PDF',
            ),
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _downloadPdf,
              tooltip: 'Download PDF',
            ),
          ],
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _pdfFile != null && _totalPages > 0
          ? Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Page ${_currentPage + 1} of $_totalPages',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading PDF...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading PDF',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadPdf,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_pdfFile == null) {
      return const Center(
        child: Text('No PDF file available'),
      );
    }

    return PDFView(
      filePath: _pdfFile!.path,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: false,
      pageFling: true,
      pageSnap: true,
      defaultPage: _currentPage,
      fitPolicy: FitPolicy.BOTH,
      preventLinkNavigation: false,
      onRender: (pages) {
        setState(() {
          _totalPages = pages ?? 0;
        });
      },
      onError: (error) {
        setState(() {
          _errorMessage = 'PDF rendering error: $error';
        });
      },
      onPageError: (page, error) {
        setState(() {
          _errorMessage = 'Page $page error: $error';
        });
      },
      onViewCreated: (PDFViewController pdfViewController) {
        // PDF view created
      },
      onLinkHandler: (String? uri) {
        // Handle link clicks
      },
      onPageChanged: (int? page, int? total) {
        setState(() {
          _currentPage = page ?? 0;
          _totalPages = total ?? 0;
        });
      },
    );
  }

  @override
  void dispose() {
    // Clean up temporary file
    _pdfFile?.delete().catchError((e) {
      debugPrint('Error deleting temporary PDF file: $e');
    });
    super.dispose();
  }
}