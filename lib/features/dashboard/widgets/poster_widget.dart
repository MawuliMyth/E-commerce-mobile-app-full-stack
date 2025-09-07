import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../controllers/poster_controller.dart';
import '../models/poster_model.dart';

class PosterCarousel extends StatefulWidget {
  const PosterCarousel({super.key});

  @override
  State<PosterCarousel> createState() => _PosterCarouselState();
}

class _PosterCarouselState extends State<PosterCarousel> {
  final PageController _pageController = PageController();
  final PosterController _posterController = PosterController();
  late Future<List<Poster>> futurePosters;
  Timer? _autoPlayTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    futurePosters = _posterController.fetchPosters();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    // Start a timer that changes the page every 3 seconds
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        futurePosters.then((posters) {
          if (posters.isNotEmpty) {
            _currentPage = (_currentPage + 1) % posters.length;
            _pageController.animateToPage(
              _currentPage,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel(); // Cancel the timer to prevent memory leaks
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Poster>>(
      future: futurePosters,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No posters available"));
        }

        final posters = snapshot.data!;

        return SizedBox(
          height: 180,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: posters.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index; // Update current page on manual swipe
                  });
                },
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      posters[index].imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  );
                },
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: posters.length,
                    effect: const ExpandingDotsEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      activeDotColor: Color(0xff0042E0),
                      dotColor: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}