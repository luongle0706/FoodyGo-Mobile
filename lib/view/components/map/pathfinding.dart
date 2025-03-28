import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:foodygo/service/location_service.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:http/http.dart' as http;

class OrderMap extends StatefulWidget {
  final int? orderId;
  final LatLng hubLocation;
  final LatLng? restaurantLocation;
  const OrderMap(
      {super.key,
      this.orderId,
      required this.hubLocation,
      this.restaurantLocation});

  @override
  State<OrderMap> createState() => _OrderMapState();
}

class _OrderMapState extends State<OrderMap> {
  final LocationService locationService = LocationService.instance;
  final AppLogger logger = AppLogger.instance;

  LatLng? currentLocation;
  LatLng? shipperLocation;
  List<LatLng> route = [];
  List<LatLng> routeFromCustomer = [];
  late StompClient stompClient;

  @override
  void initState() {
    logger.info('Received: ${widget.orderId}');
    logger.info('Received ${widget.hubLocation.toString()}');
    super.initState();
    getUserLocation();
    if (widget.orderId != null) connectWebSocket();
  }

  // Initialize user's current location using Geolocator
  Future<void> getUserLocation() async {
    try {
      Position position = await locationService.getUserLocation();
      List<LatLng> routeToCustomerData = await fetchRoute(
          start: LatLng(position.latitude, position.longitude));
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
        routeFromCustomer = routeToCustomerData;
      });
    } catch (e) {
      logger.error("Failed to get user's current location");
    }
  }

  // Connect to the websocket using the STOMP client
  void connectWebSocket() {
    stompClient = StompClient(
      config: StompConfig(
        url:
            // 'ws://10.0.2.2:8080/ws', // Replace with your websocket endpoint URL
            'ws://foodygo.theanh0804.duckdns.org/ws',
        onConnect: subscribeOrderLocation,
        onWebSocketError: (dynamic error) {
          logger.error("WebSocket Error: ${error.toString()}");
        },
        onStompError: (dynamic error) {
          logger.error("STOMP Error: ${error.toString()}");
        },
        onDisconnect: (dynamic frame) {
          logger.info("Disconnected from WebSocket");
        },
        // Add reconnect delay
        reconnectDelay: Duration(seconds: 2),
      ),
    );
    stompClient.activate();
  }

  // Once connected, subscribe to the shipper's location updates
  void subscribeOrderLocation(StompFrame frame) {
    stompClient.subscribe(
      destination: '/topic/location/${widget.orderId}',
      callback: (StompFrame frame) async {
        if (frame.body != null) {
          final Map<String, dynamic> result = jsonDecode(frame.body!);
          logger.info('Received: ${result.toString()}');
          if (result.containsKey('latitude') &&
              result.containsKey('longitude')) {
            double latitude = result['latitude'];
            double longitude = result['longitude'];

            LatLng shipperData = LatLng(latitude, longitude);
            List<LatLng> routeData = await fetchRoute(start: shipperData);
            setState(() {
              shipperLocation = shipperData;
              route = routeData;
            });
          }
        }
      },
    );
  }

  // Fetch the route from the OSRM API
  Future<List<LatLng>> fetchRoute({required LatLng start}) async {
    final end = widget.hubLocation;
    // final url =
    //     'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?geometries=geojson';
    final url =
        'https://routing.openstreetmap.de/routed-car/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?geometries=geojson';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final coords = data['routes'][0]['geometry']['coordinates'] as List;
          return coords
              .map<LatLng>((point) => LatLng(point[1], point[0]))
              .toList();
        }
      } else {
        logger.error('Failed to fetch route. Status: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      logger.error('Error fetching route: $e');
      return [];
    }
    return [];
  }

  // Build markers for hub, user, and shipper
  List<Marker> _buildMarkers() {
    List<Marker> markers = [];

    // Hub marker
    markers.add(
      Marker(
        width: 80,
        height: 80,
        point: widget.hubLocation,
        child: Icon(Icons.location_on, color: Colors.red, size: 40),
      ),
    );

    //Restaurant Marker
    if (widget.restaurantLocation != null) {
      markers.add(
        Marker(
          width: 80,
          height: 80,
          point: widget.restaurantLocation!,
          child: Icon(Icons.restaurant, color: Colors.orange, size: 40),
        ),
      );
    }

    // User marker
    if (currentLocation != null) {
      markers.add(
        Marker(
          width: 80,
          height: 80,
          point: currentLocation!,
          child: Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
        ),
      );
    }

    // Shipper marker
    if (shipperLocation != null) {
      markers.add(
        Marker(
          width: 80,
          height: 80,
          point: shipperLocation!,
          child: Icon(Icons.local_shipping, color: Colors.green, size: 40),
        ),
      );
    }

    return markers;
  }

  @override
  void dispose() {
    if (widget.orderId != null) {
      stompClient.deactivate();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (currentLocation == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return FlutterMap(
      options: MapOptions(
        initialCenter: currentLocation!,
        initialZoom: 17.0,
      ),
      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
        ),
        MarkerLayer(
          markers: _buildMarkers(),
        ),

        // Polyline layer for the fetched route
        if (route.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: route,
                strokeWidth: 4.0,
                color: Colors.blue,
              ),
            ],
          ),

        if (routeFromCustomer.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: routeFromCustomer,
                strokeWidth: 4.0,
                color: Colors.orange,
              ),
            ],
          ),
      ],
    );
  }
}
