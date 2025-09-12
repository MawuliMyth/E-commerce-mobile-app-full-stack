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
  bool _isPageViewBuilt = false;

  @override
  void initState() {
    super.initState();
    futurePosters = _posterController.fetchPosters();
    // Defer auto-play until after the first frame and posters are loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      futurePosters.then((posters) {
        if (mounted && posters.isNotEmpty && posters.length > 1) {
          _startAutoPlay();
        }
      });
    });
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel(); // Cancel any existing timer
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && _pageController.hasClients && _isPageViewBuilt) {
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
      } else if (!mounted) {
        timer.cancel(); // Stop timer if widget is disposed
      }
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Poster>>(
      future: futurePosters,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(

          ));
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Error: ${snapshot.error}"),
                TextButton(
                  onPressed: () {
                    setState(() {
                      futurePosters = _posterController.fetchPosters(forceRefresh: true);
                    });
                  },
                  child: const Text("Retry"),
                ),
              ],
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No posters available"));
        }

        final posters = snapshot.data!;
        _isPageViewBuilt = true;

        return SizedBox(
          height: 180,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: posters.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                    // Pause auto-play on manual swipe, resume after 5 seconds
                    _autoPlayTimer?.cancel();
                    Future.delayed(const Duration(seconds: 5), () {
                      if (mounted && posters.length > 1) {
                        _startAutoPlay();
                      }
                    });
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
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(child: Text("Failed to load image"));
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