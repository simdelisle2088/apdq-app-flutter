import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class PdfViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PdfViewerScreen({
    super.key,
    required this.pdfUrl,
    required this.title,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  String? localPdfPath;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      final response = await http.get(Uri.parse(widget.pdfUrl));

      if (response.statusCode == 200) {
        // Get temporary directory for storing PDF
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/temp.pdf');

        // Write PDF data to file
        await file.writeAsBytes(response.bodyBytes);

        setState(() {
          localPdfPath = file.path;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load PDF: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading PDF: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xFFEBF6F1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : PDFView(
                  filePath: localPdfPath!,
                  enableSwipe: true,
                  swipeHorizontal: false,
                  autoSpacing: true,
                  pageFling: true,
                  pageSnap: true,
                  onError: (error) {
                    print('Error loading PDF: $error');
                  },
                  onPageError: (page, error) {
                    print('Error loading page $page: $error');
                  },
                ),
    );
  }
}
