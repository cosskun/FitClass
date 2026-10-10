import 'dart:convert';
import 'dart:html' as html;

void saveFileToUser(String content, String fileName) {
  final bytes = utf8.encode(content);
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute("download", fileName)
    ..click();
  html.Url.revokeObjectUrl(url);
}

Future<String?> pickFileFromUser() async {
  final uploadInput = html.FileUploadInputElement()..accept = '.json';
  uploadInput.click();
  
  // Wait for the file selection to complete
  await uploadInput.onChange.first;
  
  if (uploadInput.files == null || uploadInput.files!.isEmpty) {
    return null;
  }
  
  final file = uploadInput.files![0];
  final reader = html.FileReader();
  reader.readAsText(file);
  
  await reader.onLoadEnd.first;
  return reader.result as String?;
}
