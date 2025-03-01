import 'package:flutter/material.dart';

class FoodLinkPage extends StatefulWidget {
  const FoodLinkPage({super.key});

  @override
  State<FoodLinkPage> createState() => _FoodLinkPageState();
}

class _FoodLinkPageState extends State<FoodLinkPage> {
  List<bool> linkedFoods = [true, true];
  List<bool> unlinkedFoods = List.generate(6, (index) => false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Background matches design
      appBar: AppBar(
        title: const Text('Liên kết món ăn',
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
      ),
      body: Column(
        children: [
          _buildSection('Đã liên kết', linkedFoods, isLinked: true),
          _buildSection('Chưa liên kết', unlinkedFoods, isLinked: false),
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
                    Text(
                      index.isEven ? 'Cơm sườn' : 'Cơm chiên dương châu',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        '35.000đ',
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
