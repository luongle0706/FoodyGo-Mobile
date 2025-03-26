import 'package:flutter/material.dart';
import 'package:foodygo/view/components/map/pathfinding.dart';
import 'package:latlong2/latlong.dart';

class TestMapPage extends StatelessWidget {
  TestMapPage({super.key});

  final int orderId = 1;
  final LatLng hubLocation = LatLng(10.881493470013144, 106.7815895507812);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Example Page'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Some content at the top
            Container(
              padding: EdgeInsets.all(16),
              child: Text(
                'This is some content above the map. '
                'Scroll down to see the map.',
                style: TextStyle(fontSize: 18),
              ),
            ),

            // Fixed height for the map so it’s visible
            SizedBox(
                height: 300,
                child: OrderMap(orderId: orderId, hubLocation: hubLocation)),

            // More content below the map
            Container(
              padding: EdgeInsets.all(16),
              child: Text(
                'Some more content below the map. '
                'Keep scrolling if you like.',
                style: TextStyle(fontSize: 18),
              ),
            ),

            // ... add as many widgets as you want ...
          ],
        ),
      ),
    );
  }
}
