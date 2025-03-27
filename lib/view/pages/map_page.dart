import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:foodygo/repository/building_repository.dart';
import 'package:foodygo/repository/hub_repository.dart';
import 'package:foodygo/service/location_service.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapPage extends StatefulWidget {
  final String location; // 'building' or 'hub'
  final String callOfOrigin;

  const MapPage(
      {super.key, required this.location, required this.callOfOrigin});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  late final _animatedMapController = AnimatedMapController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      cancelPreviousAnimations: true);
  final _locationService = LocationService.instance;
  final _logger = AppLogger.instance;
  final _hubRepository = HubRepository.instance;
  final _buildingRepository = BuildingRepository.instance;

  LatLng? _userLocation;
  LatLng? selectedLocation;
  List<dynamic>? _items;

  bool _isLoading = true;
  dynamic selectedItem;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    LatLng? userLocation = await fetchUserLocation();
    if (userLocation != null) {
      setState(() {
        _userLocation = userLocation;
      });
      bool loadItems = widget.location == 'BUILDING'
          ? await fetchBuildings(userLocation: userLocation)
          : await fetchHubs(userLocation: userLocation);
      if (loadItems) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }
    _logger.error('Hu roi');
  }

  Future<LatLng?> fetchUserLocation() async {
    try {
      Position position = await _locationService.getUserLocation();
      _logger.info(
          'User Location: Long:${position.longitude} - Lat:${position.latitude}');
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      _logger.error('Error getting user location');
      return null;
    }
  }

  Future<bool> fetchHubs({required LatLng userLocation}) async {
    List<dynamic>? hubs = await _hubRepository.getHubs();
    if (hubs != null) {
      List<dynamic> hubsWithLocation = hubs.map((h) {
        double distance = _locationService.calculateDistance(
            userLocation.latitude,
            userLocation.longitude,
            h['latitude'],
            h['longitude']);
        return {...h, "distance": distance};
      }).toList();
      _logger.info(hubs[0].toString());
      hubsWithLocation.sort((a, b) => a["distance"].compareTo(b["distance"]));
      setState(() {
        _items = hubsWithLocation;
      });
      return true;
    }
    _logger.error("Unable to fetch hubs");
    return false;
  }

  Future<bool> fetchBuildings({required LatLng userLocation}) async {
    List<dynamic>? buildings = await _buildingRepository.getAllBuildings();
    if (buildings != null) {
      List<dynamic> buildingsWithLocation = buildings.map((h) {
        double distance = _locationService.calculateDistance(
            userLocation.latitude,
            userLocation.longitude,
            h['latitude'],
            h['longitude']);
        return {...h, "distance": distance};
      }).toList();
      _logger.info(buildings[0].toString());
      buildingsWithLocation
          .sort((a, b) => a["distance"].compareTo(b["distance"]));
      setState(() {
        _items = buildingsWithLocation;
      });
      return true;
    }
    _logger.error("Unable to fetch buildings");
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
          appBar: AppBar(title: Text("Chọn ${widget.location}")),
          body: Center(
            child: CircularProgressIndicator(),
          ));
    }
    return Scaffold(
      appBar: AppBar(title: Text("Chọn ${widget.location}")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: FlutterMap(
                    mapController: _animatedMapController.mapController,
                    options: MapOptions(
                      initialCenter: _userLocation!,
                      initialZoom: 17.0,
                      onTap: (_, __) => setState(() => selectedLocation = null),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      ),
                      MarkerLayer(
                        markers: [
                          // User's location marker
                          Marker(
                            point: _userLocation!,
                            child: Icon(Icons.my_location,
                                color: Colors.blue, size: 40),
                          ),
                          if (_items != null)
                            for (var item in _items!)
                              Marker(
                                point:
                                    LatLng(item["latitude"], item["longitude"]),
                                child: GestureDetector(
                                  onTap: () async {
                                    await _animatedMapController.animateTo(
                                        dest: LatLng(item["latitude"],
                                            item["longitude"]),
                                        zoom: 17.0);
                                    setState(() {
                                      selectedLocation = LatLng(
                                          item["latitude"], item["longitude"]);
                                      selectedItem = item;
                                    });
                                  },
                                  child: Icon(
                                    Icons.location_pin,
                                    color: selectedItem?["id"] == item["id"]
                                        ? Colors.red
                                        : Colors.grey,
                                    size: 40,
                                  ),
                                ),
                              ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Selected Hub Info
                if (selectedItem != null)
                  Container(
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          spreadRadius: 2,
                        )
                      ],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment
                          .center, // Ensure vertical centering
                      children: [
                        // Image or Placeholder
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: selectedItem != null &&
                                  selectedItem?["image"] != null
                              ? Image.network(
                                  selectedItem?["image"], // Fallback image
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  'assets/images/no_image.jpg',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        SizedBox(width: 10),
                        // Details and Button
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment
                                .spaceBetween, // Align text & button properly
                            crossAxisAlignment: CrossAxisAlignment
                                .center, // Center everything vertically
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment
                                      .center, // Center vertically inside Column
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      selectedItem?["name"] ?? "Unknown",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      selectedItem?["description"] ??
                                          "No description available",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700]),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 10),
                              TextButton(
                                onPressed: () {
                                  if (widget.location == 'BUILDING') {
                                    Map<String, dynamic> extra = {
                                      'chosenBuildingId': selectedItem['id'],
                                      'chosenBuildingName': selectedItem['name']
                                    };
                                    _logger.info("Passing $extra");
                                    GoRouter.of(context)
                                        .go(widget.callOfOrigin, extra: extra);
                                  } else {
                                    Map<String, dynamic> extra = {
                                      'chosenHubId': selectedItem['id'],
                                      'chosenHubName': selectedItem['name'],
                                      'hubLocation': LatLng(
                                          selectedItem['latitude'],
                                          selectedItem['longitude'])
                                    };
                                    _logger.info("Passing $extra");
                                    GoRouter.of(context)
                                        .go(widget.callOfOrigin, extra: extra);
                                  }
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.red, // Red background
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        10), // Rounded border
                                  ),
                                ),
                                child: Text(
                                  "Xác nhận",
                                  style: TextStyle(
                                      color: Colors
                                          .white), // White text for contrast
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView(
                    children: _items!.map((item) {
                      return ListTile(
                        title: Text("${widget.location} ID: ${item["id"]}"),
                        subtitle: Text(
                            "Distance: ${item['distance'].toStringAsFixed(2)} km"),
                        trailing: ElevatedButton(
                          onPressed: () async {
                            await _animatedMapController.animateTo(
                                dest:
                                    LatLng(item["latitude"], item["longitude"]),
                                zoom: 17.0);
                            setState(() {
                              selectedLocation =
                                  LatLng(item["latitude"], item["longitude"]);
                              selectedItem = item;
                            });
                          },
                          child: Text("Chọn địa điểm"),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }
}
