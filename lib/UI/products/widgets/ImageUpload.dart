import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

class ImageUpload extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15),
      child: DottedBorder(
        color: Colors.black, //color of dotted/dash line
        strokeWidth: 1, //thickness of dash/dots
        dashPattern: [10, 6],
        child: SizedBox(
          width: double.infinity,
          height: 150,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.blue.shade50),
              foregroundColor: MaterialStateProperty.all(Colors.black),
              elevation: MaterialStateProperty.all(0),
            ),
            child: Container(
              alignment: Alignment.center,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(70),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.library_add_rounded),
                  SizedBox(width: 5),
                  Text('Add Images'),
                ],
              ),
            ),
            onPressed: () async {
              final result = await FilePicker.platform.pickFiles();
              if (result == null) return;
              final file = result.files.first;
              openFile(file);
            },
          ),
        ),
      ),
    );
  }

  void openFile(PlatformFile file) {
    OpenFile.open(file.path);
  }
}
