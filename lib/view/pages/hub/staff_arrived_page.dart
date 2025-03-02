import 'package:flutter/material.dart';

class StaffArrivedPage extends StatelessWidget {
  const StaffArrivedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: List.generate(3, (index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("#06", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Lộc Test"),
                Text("2 Món | 75.000đ"),
                Text("1 x Cơm sườn trứng"),
                Text("1 x Đùi gà rán"),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("14:08"),
                    Row(
                      children: [
                        OutlinedButton(
                            onPressed: () {}, child: Text("Xem thêm")),
                        const SizedBox(width: 8),
                        ElevatedButton(
                            onPressed: () {}, child: Text("Đã nhận")),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}
