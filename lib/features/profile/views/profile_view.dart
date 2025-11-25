// import 'package:ecommerce_firebase/features/auth/controllers/auth_controller.dart';
// import 'package:ecommerce_firebase/features/auth/views/login_view.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../auth/provider/auth_provider.dart';
//
// class ProfileView extends StatefulWidget {
//   static const String id = 'profile_view';
//   const ProfileView({super.key});
//
//   @override
//   State<ProfileView> createState() => _ProfileViewState();
// }
//
// class _ProfileViewState extends State<ProfileView> {
//   final AuthController _authController = AuthController();
//
//   Future<void> _logout(BuildContext context) async {
//     // 1️⃣ Clear secure storage tokens
//     await _authController.clearTokens();
//
//     // 2️⃣ Clear AuthProvider user
//     Provider.of<AuthProvider>(context, listen: false).clearUser();
//
//     // 3️⃣ Navigate to Login Screen and remove all previous routes
//     Navigator.pushNamedAndRemoveUntil(
//       context,
//       LoginView.id, // <-- make sure this matches your actual login route name
//       (route) => false,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final user = Provider.of<AuthProvider>(context).user;
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Profile')),
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (user != null) ...[
//               Text(
//                 'Welcome, ${user.fullname}',
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text('User ID: ${user.userId}'),
//             ],
//             const Spacer(),
//             ElevatedButton.icon(
//               onPressed: () => _logout(context),
//               icon: const Icon(Icons.logout),
//               label: const Text('Logout'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.redAccent,
//                 foregroundColor: Colors.white,
//                 minimumSize: const Size(double.infinity, 48),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Presentation/category_screen.dart';
import '../../../widgets/circle_icon_button.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/provider/auth_provider.dart';
import '../../dashboard/widgets/category_grid_widget.dart';
import '../../wishlist/controllers/wishlist_provider.dart';

class ProfileView extends StatefulWidget {
  static const String id = 'profile_view';
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final AuthController _authController = AuthController();

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final hasWishlistItems = wishlistProvider.wishlistItems.isNotEmpty;

    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(),
                const SizedBox(height: 24),
                _buildGreeting(),
                const SizedBox(height: 24),
                _buildAnnouncement(),
                const SizedBox(height: 32),
                _buildRecentlyViewed(context, wishlistProvider),
                const SizedBox(height: 32),
                _buildMyOrders(),
                const SizedBox(height: 32),
                _buildStories(),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'See All',
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        CircleIconButton(
                          icon: Icons.arrow_forward,
                          onPressed: () {
                            Navigator.pushNamed(context, CategoriesScreen.id);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Category grid
                CategoriesView(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blue, width: 2),
          ),
          child: ClipOval(
            child: Image.network(
              'https://i.pravatar.cc/150?img=5',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Text(
            'My Activity',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Spacer(),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.message_outlined,
            color: Colors.grey,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.tune, color: Colors.grey, size: 20),
        ),
        const SizedBox(width: 12),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.settings_outlined,
            color: Colors.grey,
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildGreeting() {
    final user = Provider.of<AuthProvider>(context).user;
    final name = user?.fullname ?? 'Guest';

    return Text(
      'Hello, $name!',
      style: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        // color: Colors.black,
      ),
    );
  }

  Widget _buildAnnouncement() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Announcement',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas hendrerit luctus libero ac vulputate.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).primaryColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_forward,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentlyViewed(BuildContext context, WishlistProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recently viewed',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            // color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 80,
          child: provider.recentlyViewed.isEmpty
              ? Center(
                  child: Text(
                    'No recently viewed items',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                )
              : ListView.builder(
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    final product = provider.recentlyViewed[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 3,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.network(
                            product.images.isNotEmpty ? product.images[0] : '',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.image,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMyOrders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Orders',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            // color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildOrderButton('To Pay', false)),
            const SizedBox(width: 12),
            Expanded(child: _buildOrderButton('To Recieve', true)),
            const SizedBox(width: 12),
            Expanded(child: _buildOrderButton('To Review', false)),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderButton(String text, bool hasNotification) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (hasNotification)
            Positioned(
              right: 12,
              top: -2,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Stories',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            // color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            itemBuilder: (context, index) {
              return _buildStoryCard(index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStoryCard(int index) {
    final colors = [
      Colors.blue,
      Colors.pink.shade100,
      Colors.blue.shade300,
      Colors.orange,
    ];

    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: colors[index % colors.length],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              'https://i.pravatar.cc/300?img=${index + 20}',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          if (index == 0)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Live',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Center(
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
