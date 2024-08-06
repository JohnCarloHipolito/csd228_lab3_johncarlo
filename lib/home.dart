import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 's3_service.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<String> _images = [];
  final CarouselController _carouselController = CarouselController();
  final S3Service _s3Service = S3Service();
  int _currentIndex = 0;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _loadAllImages();
  }

  void _loadAllImages() async {
    final images = await _s3Service.fetchImages();
    setState(() {
      _images.addAll(images);
    });
  }

  void _pauseOrResume() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _goBack() {
    _carouselController.previousPage();
  }

  void _goForward() {
    _carouselController.nextPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: _images.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Text(
            _images[_currentIndex].split('/').last,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          CarouselSlider(
            options: CarouselOptions(
              height: 400.0,
              autoPlay: !_isPaused,
              autoPlayInterval: const Duration(seconds: 10),
              enlargeCenterPage: true,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
            items: _images.map((imageUrl) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    margin: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Image.network(imageUrl),
                  );
                },
              );
            }).toList(),
            carouselController: _carouselController,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _images.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () => _carouselController.animateToPage(entry.key),
                child: Container(
                  width: 12.0,
                  height: 12.0,
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)
                        .withOpacity(_currentIndex == entry.key ? 0.9 : 0.4),
                  ),
                ),
              );
            }).toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: _goBack,
              ),
              IconButton(
                icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                onPressed: _pauseOrResume,
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: _goForward,
              ),
            ],
          ),
        ],
      ),
    );
  }
}