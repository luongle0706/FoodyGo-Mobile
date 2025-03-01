import 'package:flutter/material.dart';

class ToppingSelectionPage extends StatefulWidget {
  const ToppingSelectionPage({super.key});

  @override
  State<ToppingSelectionPage> createState() => _ToppingSelectionPageState();
}

class _ToppingSelectionPageState extends State<ToppingSelectionPage> {
  List<bool> linkedToppings = [true, true];
  List<bool> unlinkedToppings = List.generate(6, (index) => false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Matches the background
      appBar: AppBar(
        title:
            const Text('Nhóm Topping', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
      ),
      body: Column(
        children: [
          _buildSection('Đã liên kết', linkedToppings, isLinked: true),
          _buildSection('Chưa liên kết', unlinkedToppings, isLinked: false),
          _buildCompleteButton(),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<bool> selection,
      {required bool isLinked}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: Colors.grey[300],
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          color: isLinked
              ? Colors.grey[100]
              : Colors.white, // Gray bg for linked items
          child: Column(
            children: List.generate(selection.length, (index) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: Row(
                  children: [
                    Checkbox(
                      value: selection[index],
                      onChanged: isLinked
                          ? null
                          : (value) {
                              setState(() => selection[index] = value!);
                            },
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Size nhỏ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'trân châu, phô mai tươi, sương sáo',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildCompleteButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[600], // Matches the button in the design
          minimumSize: const Size(double.infinity, 50),
        ),
        child: const Text('Hoàn tất',
            style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}
