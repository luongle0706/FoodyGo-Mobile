import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:foodygo/repository/hub_repository.dart';
import 'package:foodygo/service/location_service.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class HubSelectionMapPage extends StatefulWidget {
  const HubSelectionMapPage({super.key});

  @override
  State<HubSelectionMapPage> createState() => _HubSelectionMapPageState();
}

class _HubSelectionMapPageState extends State<HubSelectionMapPage> {
  final _locationService = LocationService.instance;
  final _logger = AppLogger.instance;
  final _hubRepository = HubRepository.instance;
  final MapController _mapController = MapController();
  LatLng? userLocation;
  LatLng? selectedHub;
  List<dynamic>? _hubs;
  bool _isLoading = true;
  int? selectedHubId;

  // List of hub locations with IDs
  final List<Map<String, dynamic>> hubs = [
    {"id": 1, "lat": 10.7769, "lng": 106.7009}, // Hub 1
    {"id": 2, "lat": 10.7805, "lng": 106.6956}, // Hub 2
    {"id": 3, "lat": 10.7701, "lng": 106.7038}, // Hub 3
  ];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    bool fetchedUserLocation = await _fetchUserLocation();
    bool fetchedHubs = await fetchHubs();
    if (fetchedUserLocation && fetchedHubs) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    _logger.error('Hu roi');
  }

  Future<bool> _fetchUserLocation() async {
    try {
      Position position = await _locationService.getUserLocation();
      _logger.info('Long:${position.longitude} - Lat:${position.latitude}');
      setState(() {
        userLocation = LatLng(position.latitude, position.longitude);
      });
      return true;
    } catch (e) {
      _logger.error('Error getting user location');
      return false;
    }
  }

  Future<bool> fetchHubs() async {
    List<dynamic>? hubs = await _hubRepository.getHubs();
    if (hubs != null) {
      setState(() {
        _hubs = hubs;
      });
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select a Hub")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: userLocation!,
                      initialZoom: 14.0,
                      onTap: (_, __) => setState(() => selectedHub = null),
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
                            point: userLocation!,
                            child: Icon(Icons.my_location,
                                color: Colors.blue, size: 40),
                          ),
                          // Hub markers
                          for (var hub in _hubs!)
                            Marker(
                              point: LatLng(hub["latitude"], hub["longitude"]),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedHub = LatLng(
                                        hub["latitude"], hub["longitude"]);
                                    selectedHubId = hub["id"];
                                  });
                                },
                                child: Icon(
                                  Icons.location_pin,
                                  color: selectedHubId == hub["id"]
                                      ? Colors.green
                                      : Colors.red,
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
                if (selectedHub != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Selected Hub ID: $selectedHubId",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                Expanded(
                  child: ListView(
                    children: _hubs!.map((hub) {
                      double distance = _locationService.calculateDistance(
                          userLocation!.latitude,
                          userLocation!.longitude,
                          hub["latitude"],
                          hub["longitude"]);
                      return ListTile(
                        title: Text("Hub ID: ${hub["id"]}"),
                        subtitle:
                            Text("Distance: ${distance.toStringAsFixed(2)} km"),
                        trailing: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedHub =
                                  LatLng(hub["latitude"], hub["longitude"]);
                              selectedHubId = hub["id"];
                              _mapController.move(
                                  LatLng(hub["latitude"], hub["longitude"]),
                                  14.0);
                            });
                          },
                          child: Text("Select"),
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
