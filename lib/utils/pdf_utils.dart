import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';

class PdfUtils {
  static Future<File?> base64ToPdf(String base64String, String fileName) async {
    try {
      // Decode base64 string
      final bytes = base64Decode(base64String);
      
      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName.pdf');
      
      // Write PDF to file
      await file.writeAsBytes(bytes);
      
      return file;
    } catch (e) {
      debugPrint('Error converting base64 to PDF: $e');
      return null;
    }
  }

  static Future<void> sharePdf(File pdfFile, String title) async {
    try {
      await Share.shareXFiles(
        [XFile(pdfFile.path)],
        text: title,
        subject: title,
      );
    } catch (e) {
      debugPrint('Error sharing PDF: $e');
    }
  }

  static Future<File?> savePdfToDownloads(String base64String, String fileName) async {
    try {
      // Decode base64 string
      final bytes = base64Decode(base64String);
      
      // Get downloads directory (Android) or documents directory (iOS)
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }
      
      if (directory == null) return null;
      
      final file = File('${directory.path}/$fileName.pdf');
      
      // Write PDF to file
      await file.writeAsBytes(bytes);
      
      return file;
    } catch (e) {
      debugPrint('Error saving PDF to downloads: $e');
      return null;
    }
  }

  static String generateFileName(String prefix, {String? patientName, DateTime? date}) {
    final timestamp = (date ?? DateTime.now()).millisecondsSinceEpoch;
    final patientPrefix = patientName?.replaceAll(' ', '_') ?? 'patient';
    return '${prefix}_${patientPrefix}_$timestamp';
  }
}