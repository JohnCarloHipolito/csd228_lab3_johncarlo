import 'package:http/http.dart' as http;

class S3Service {
  static const String bucketName = 'csd228pbucket';
  static const String region = 'us-east-1';

  Future<List<String>> fetchImages() async {
    final endpoint = 'https://$bucketName.s3.$region.amazonaws.com';
    final imageNames = ['p1.jpg', 'p2.jpg', 'p3.jpg', 'p4.jpg', 'p5.jpg', 'p6.jpg'];
    final imageUrls = <String>[];

    for (var imageName in imageNames) {
      final url = '$endpoint/$imageName';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        imageUrls.add(url);
      } else {
        throw Exception('Failed to load image: $imageName');
      }
    }

    return imageUrls;
  }
}