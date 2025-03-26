import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_trip_optimizer/constant/text_cons.dart';
import 'package:smart_trip_optimizer/controller/home_controller.dart';
import 'package:smart_trip_optimizer/model/user_model.dart';

import '../controller/auth_controller.dart';

class HomeScreen extends StatelessWidget {
  final AuthController _authController = Get.find();
  final HomeController _homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<UserModel?>(
          future: _homeController.getUserInfo(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              var userInfo = snapshot.data;
              if (userInfo != null) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(
                          left: 2,
                          right: 6,
                          top: 2,
                          bottom: 2,
                        ),
                        decoration: const BoxDecoration(
                            color: Color(0XFFF7F7F9),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(
                                24,
                              ),
                              topRight: Radius.circular(
                                24,
                              ),
                              bottomLeft: Radius.circular(
                                24,
                              ),
                              bottomRight: Radius.circular(
                                24,
                              ),
                            )),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircleAvatar(
                              backgroundImage: NetworkImage(
                                  'https://marketplace.canva.com/EAFltPVX5QA/1/0/1600w/canva-cute-cartoon-anime-girl-avatar-ZHBl2NicxII.jpg'),
                            ),
                            Text(userInfo.fullName),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      const Text(
                        'Explore the',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Row(
                        children: [
                          const Text(
                            'Beautiful',
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          Stack(
                            children: [
                              const Align(
                                alignment: Alignment.center,
                                child: Text(
                                  ' world!',
                                  style: TextStyle(
                                    fontSize: 38,
                                    fontWeight: FontWeight.w300,
                                    color: StyleConst.auth_second_color,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 20,
                                child: Image.asset(
                                  'assets/images/a.png',
                                  // height: 40.0,
                                  width: 80,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Best Destination',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Get.toNamed('/seeAll');
                            },
                            child: const Text(
                              'View All',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: StyleConst.auth_second_color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Obx(
                          () => _homeController.places.isEmpty
                              ? const Center(child: CircularProgressIndicator())
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _homeController.places.length,
                                  itemBuilder: (context, index) {
                                    final place = _homeController.places[index];
                                    final name =
                                        place['name'] ?? 'Unknown Place';
                                    final address = place['description'] ??
                                        'No description available';
                                    final imageUrl = place['image'] ??
                                        'https://via.placeholder.com/300';

                                    return Container(
                                      width: 300,
                                      height: 400,
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              child: CachedNetworkImage(
                                                imageUrl: imageUrl,
                                                width: 300,
                                                height: 369,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    Container(
                                                  width: 300,
                                                  height: 369,
                                                  color: Colors.grey[300],
                                                  child: const Center(
                                                      child:
                                                          CircularProgressIndicator()),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
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
                                          Text(name,
                                              overflow: TextOverflow.ellipsis),
                                          Text(address,
                                              overflow: TextOverflow.ellipsis),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: OutlinedButton(
                            onPressed: () {
                              Get.toNamed('/chooseTravel');
                            },
                            child: const Text('Plan My Trip')),
                      )
                    ],
                  ),
                );
              } else {
                return const Center(child: Text('User info not found.'));
              }
            } else {
              return const Center(child: Text('No data available.'));
            }
          },
        ),
      ),
    );
  }
}
