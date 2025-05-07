import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

class EducationPage extends StatefulWidget {
  const EducationPage({super.key});

  @override
  State<EducationPage> createState() => _EducationPageState();
}

class _EducationPageState extends State<EducationPage> {
  final List<Map<String, String>> materials = [
    {
      'title': 'Foam Rolling Basics',
      'description': 'Learn how to relieve muscle tension with foam rolling.',
      'url':
          'https://firebasestorage.googleapis.com/v0/b/fitpro-3a587.firebasestorage.app/o/Reducing%20Physical%20Tension%20in%20your%20Body%20-%20Assert%20Yourself%20-%2005%20-%20Reducing%20Physical%20Tension.pdf?alt=media&token=8231ba05-6898-4364-bde4-c8b0bea64ca9',
    },
    {
      'title': 'Stretching Guide',
      'description': 'A visual guide for full-body stretching after workouts.',
      'url':
          'https://firebasestorage.googleapis.com/v0/b/fitpro-3a587.firebasestorage.app/o/Reducing%20Physical%20Tension%20in%20your%20Body%20-%20Assert%20Yourself%20-%2005%20-%20Reducing%20Physical%20Tension.pdf?alt=media&token=8231ba05-6898-4364-bde4-c8b0bea64ca9',
    },
    {
      'title': 'Nutrition Tips',
      'description': 'Basic nutrition principles for athletes and students.',
      'url':
          'https://firebasestorage.googleapis.com/v0/b/fitpro-3a587.firebasestorage.app/o/Reducing%20Physical%20Tension%20in%20your%20Body%20-%20Assert%20Yourself%20-%2005%20-%20Reducing%20Physical%20Tension.pdf?alt=media&token=8231ba05-6898-4364-bde4-c8b0bea64ca9',
    },
  ];

  Future<void> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.isGranted) {
        return;
      }

      if (await Permission.storage.request().isGranted) {
        return;
      }

      // For Android 11+ (API level 30+)
      if (await Permission.manageExternalStorage.request().isGranted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Storage permission denied")),
      );
    }
  }

  Future<void> _downloadAndOpenFile(String url, String filename) async {
    // Request storage permission
    await _requestStoragePermission();

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$filename';

    try {
      // Download the file
      final response = await http.get(Uri.parse(url));
      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Downloaded to $filePath")));

        // Open the file
        final result = await OpenFile.open(filePath);
        if (result.type != ResultType.done) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to open file: ${result.message}")),
          );
        }
      } else {
        throw Exception("Failed to download file: ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Download failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Education'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        itemCount: materials.length,
        itemBuilder: (context, index) {
          final material = materials[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(material['title']!),
              subtitle: Text(material['description']!),
              trailing: IconButton(
                icon: const Icon(
                  Icons.download_rounded,
                  color: Colors.deepPurple,
                ),
                onPressed:
                    () => _downloadAndOpenFile(
                      material['url']!,
                      '${material['title']!.replaceAll(' ', '_')}.pdf',
                    ),
              ),
            ),
          );
        },
      ),
    );
  }
}
