import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/home_controller.dart';

class SeeAllScreen extends StatelessWidget {
  SeeAllScreen({super.key});
  final HomeController _homeController = Get.find();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = (screenWidth / 180).floor(); // Dynamically calculate

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Recommended Places'),
        ),
        body: Obx(
          () => _homeController.places.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: _homeController.places.length,
                  itemBuilder: (context, index) {
                    final place = _homeController.places[index];
                    final name = place['name'] ?? 'Unknown Place';
                    final address =
                        place['address'] ?? 'No description available';
                    final imageUrl =
                        place['image'] ?? 'https://via.placeholder.com/300';
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(15)),
                                child: AspectRatio(
                                    aspectRatio: 16 / 14,
                                    child: CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      width: 300,
                                      height: 369,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        width: 300,
                                        height: 369,
                                        color: Colors.grey[300],
                                        child: const Center(
                                            child: CircularProgressIndicator()),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        width: 300,
                                        height: 369,
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: Icon(Icons.error,
                                              color: Colors.red),
                                        ),
                                      ),
                                    )),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: CircleAvatar(
                                  backgroundColor:
                                      Colors.white.withOpacity(0.8),
                                  child: Icon(Icons.bookmark_border,
                                      color: Colors.grey[800]),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text(address,
                                    style: const TextStyle(color: Colors.grey),
                                    overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
