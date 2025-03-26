import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smart_trip_optimizer/controller/home_controller.dart';

class ChooseDestinationsScreen extends StatefulWidget {
  @override
  _ChooseDestinationsScreenState createState() =>
      _ChooseDestinationsScreenState();
}

class _ChooseDestinationsScreenState extends State<ChooseDestinationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final HomeController homeController = Get.find();

  Set<String> selected = {}; // Persist selection across filters

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      homeController.filterPlaces(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Destinations')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search places...',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              final places =
                  homeController.filteredPlaces; // Use filtered places
              return places.isEmpty
                  ? const Center(child: Text('No results found'))
                  : ListView.builder(
                      itemCount: places.length,
                      itemBuilder: (context, index) {
                        final place = places[index];
                        final placeId = place['name']!;
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12)),
                                child: CachedNetworkImage(
                                  imageUrl: place['image']!,
                                  width: double.infinity,
                                  height: 180,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error, size: 50),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      place['name']!,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(place['description']!,
                                        style:
                                            TextStyle(color: Colors.grey[700])),
                                  ],
                                ),
                              ),
                              const Divider(),
                              CheckboxListTile(
                                value: selected.contains(placeId),
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value == true) {
                                      selected.add(placeId);
                                    } else {
                                      selected.remove(placeId);
                                    }
                                  });
                                },
                                title: const Text('Select'),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              ),
                            ],
                          ),
                        );
                      },
                    );
            }),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                final selectedPlaces = homeController.places
                    .where((place) => selected.contains(place['name']))
                    .map((place) => place.cast<String, String>())
                    .toList();

                Get.to(() =>
                    ConfirmPrioritizeScreen(selectedPlaces: selectedPlaces));
              },
              child: const Text('Next',
                  style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class ConfirmPrioritizeScreen extends StatefulWidget {
  final List<Map<String, String>> selectedPlaces;
  ConfirmPrioritizeScreen({required this.selectedPlaces});

  @override
  _ConfirmPrioritizeScreenState createState() =>
      _ConfirmPrioritizeScreenState();
}

class _ConfirmPrioritizeScreenState extends State<ConfirmPrioritizeScreen> {
  late List<Map<String, String>> places;
  final HomeController homeController = Get.find();
  double totalTravelTime = 0;
  @override
  void initState() {
    super.initState();
    places = List.from(widget.selectedPlaces);
    applyPSO();
  }

  void applyPSO() async {
    int numParticles = 20, maxIterations = 100;
    double inertiaWeight = 0.9, inertiaDecay = 0.99;
    double cognitiveFactor = 2.0, socialFactor = 2.5;

    List<List<Map<String, String>>> particles =
        List.generate(numParticles, (i) => [...places]..shuffle());

    List<List<Map<String, String>>> pBest = List.from(particles);
    List<Map<String, String>> gBest = particles.first;

    List<List<int>> velocities =
        List.generate(numParticles, (i) => List<int>.filled(places.length, 0));

    double fitness(List<Map<String, String>> order) {
      double totalTime = 0;
      for (int i = 0; i < order.length - 1; i++) {
        double distance = homeController.haversine(
          double.parse(order[i]['lat']!),
          double.parse(order[i]['lng']!),
          double.parse(order[i + 1]['lat']!),
          double.parse(order[i + 1]['lng']!),
        );
        totalTime += homeController.getEstimatedTravelTime(distance);
      }
      return totalTime;
    }

    // Find initial bests
    for (var particle in particles) {
      if (fitness(particle) < fitness(gBest)) {
        gBest = List.from(particle);
      }
    }

    for (int iteration = 0; iteration < maxIterations; iteration++) {
      for (int i = 0; i < numParticles; i++) {
        if (fitness(particles[i]) < fitness(pBest[i])) {
          pBest[i] = List.from(particles[i]);
        }
        if (fitness(pBest[i]) < fitness(gBest)) {
          gBest = List.from(pBest[i]);
        }
      }

      // Update velocity and position
      for (int i = 0; i < numParticles; i++) {
        velocities[i] = updateVelocity(velocities[i], particles[i], pBest[i],
            gBest, inertiaWeight, cognitiveFactor, socialFactor);
        particles[i] = applyVelocity(particles[i], velocities[i]);
      }

      // Decay inertia over time
      inertiaWeight *= inertiaDecay;
    }

    setState(() {
      places = gBest;
      totalTravelTime = fitness(gBest);
    });
  }

// Velocity update function
  List<int> updateVelocity(
      List<int> velocity,
      List<Map<String, String>> current,
      List<Map<String, String>> pBest,
      List<Map<String, String>> gBest,
      double inertiaWeight,
      double cognitiveFactor,
      double socialFactor) {
    Random rand = Random();
    List<int> newVelocity = List.from(velocity);

    for (int i = 0; i < newVelocity.length; i++) {
      int personalInfluence = rand.nextDouble() < cognitiveFactor
          ? pBest.indexOf(current[i]) - i
          : 0;
      int globalInfluence =
          rand.nextDouble() < socialFactor ? gBest.indexOf(current[i]) - i : 0;

      newVelocity[i] =
          (inertiaWeight * newVelocity[i] + personalInfluence + globalInfluence)
              .toInt();
    }

    return newVelocity;
  }

// Apply velocity to update particle order
  List<Map<String, String>> applyVelocity(
      List<Map<String, String>> route, List<int> velocity) {
    List<Map<String, String>> newRoute = List.from(route);
    for (int i = 0; i < velocity.length; i++) {
      int swapIdx = i + velocity[i];
      if (swapIdx >= 0 && swapIdx < newRoute.length) {
        var temp = newRoute[i];
        newRoute[i] = newRoute[swapIdx];
        newRoute[swapIdx] = temp;
      }
    }
    return newRoute;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Optimized Route')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'Total Travel Time: ${totalTravelTime.toStringAsFixed(2)} mins',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ReorderableListView(
              padding: EdgeInsets.all(8),
              children: List.generate(
                places.length,
                (index) => Card(
                  key: ValueKey(index),
                  child: ListTile(
                    leading: CachedNetworkImage(
                      imageUrl: places[index]['image']!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                    title: Text('${index + 1}. ${places[index]['name']!}'),
                  ),
                ),
              ),
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = places.removeAt(oldIndex);
                  places.insert(newIndex, item);
                });
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: FloatingActionButton.extended(
          onPressed: () {
            Get.toNamed('/map', arguments: places);
          },
          icon: Icon(Icons.map_rounded),
          label: Text('Show on Map'),
          backgroundColor: Colors.blueAccent,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
