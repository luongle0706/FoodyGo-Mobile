import 'package:flutter/material.dart';
import 'package:foodygo/view/pages/restaurant/custome_appbar_order_restaurant_list.dart';
import 'package:foodygo/view/pages/welcome_screen.dart';
import 'package:go_router/go_router.dart';

class RestaurantMenu extends StatefulWidget {
  const RestaurantMenu({super.key});

  @override
  State<RestaurantMenu> createState() => _RestaurantMenuState();
}

class _RestaurantMenuState extends State<RestaurantMenu> {
  int selectedTab = 1;
  // Mặc định chọn tab Thực đơn
  Map<String, dynamic> restaurant = {
    "name": "Cơm tấm Ngô Quyền",
    "isOpen": true, // true = open, false = close
  };

  List<Map<String, dynamic>> categorizedMenu = [
    {
      "title": "Cơm",
      "isExpanded": true,
      "items": [
        {
          "name": "Cơm tấm sườn que",
          "price": "25.000đ",
          "image": "assets/comtam.png",
          "isAvailable": true
        },
        {
          "name": "Cơm gà xối mỡ",
          "price": "30.000đ",
          "image": "assets/comga.png",
          "isAvailable": false
        },
      ]
    },
    {
      "title": "Phở",
      "isExpanded": true,
      "items": [
        {
          "name": "Phở bò",
          "price": "35.000đ",
          "image": "assets/phobo.png",
          "isAvailable": true
        },
      ]
    },
    {
      "title": "Bún",
      "isExpanded": true,
      "items": [
        {
          "name": "Bún bò Huế",
          "price": "40.000đ",
          "image": "assets/bunbo.png",
          "isAvailable": true
        },
      ]
    },
  ];

  List<Map<String, dynamic>> toppingGroups = [
    {"name": "Topping 1", "description": "Mô tả topping 1"},
    {"name": "Topping 2", "description": "Mô tả topping 2"},
    {"name": "Topping 3", "description": "Mô tả topping 3"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomFootageRestaurantOrderAppBar(
        title: "Cơm tấm Ngô Quyền",
      ),
      backgroundColor: Colors.grey[300],
      body: Column(
        children: [
          Expanded(
            child: selectedTab == 1
                ? MenuScreen(
                    toppingGroups: toppingGroups, categoryMenu: categorizedMenu)
                : WelcomeScreen(),
          ),
        ],
      ),
    );
  }

  Widget buildTabButton(String title, int index) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedTab = index;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selectedTab == index ? Colors.grey[400] : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: selectedTab == index ? Colors.black : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

class MenuScreen extends StatefulWidget {
  final List<Map<String, dynamic>> toppingGroups;
  final List<Map<String, dynamic>> categoryMenu;
  const MenuScreen(
      {super.key, required this.toppingGroups, required this.categoryMenu});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int selectedTab = 0;
  // 0: Món, 1: Nhóm Topping
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filter = widget.categoryMenu
        .map((category) {
          List<Map<String, dynamic>> filteredItems =
              (category["items"] as List<dynamic>)
                  .cast<Map<String, dynamic>>()
                  .where((item) => item["name"]
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase()))
                  .toList();

          return {
            "title": category["title"],
            "isExpanded": category["isExpanded"],
            "items": filteredItems,
          };
        })
        .where((category) => category["items"].isNotEmpty)
        .toList();

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(10),
          child: TextField(
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: "Nhập tên món ăn",
              prefixIcon: Icon(Icons.search),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            ),
          ),
        ),
        // Thanh menu
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () => setState(() => selectedTab = 0),
                child: Text(
                  "Món",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: selectedTab == 0 ? Colors.blue : Colors.black,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => selectedTab = 1),
                child: Text(
                  "Nhóm Topping",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: selectedTab == 1 ? Colors.blue : Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(),

        Container(
          margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          // padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[400],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () {
                  // Xử lý khi nhấn nút Vị trí
                },
                icon: Icon(Icons.list, color: Colors.black),
                label: Text("Vị trí", style: TextStyle(color: Colors.black)),
              ),
              TextButton.icon(
                onPressed: () {
                  GoRouter.of(context).push('/protected/add-dish');
                },
                icon: Icon(Icons.add, color: Colors.black),
                label: Text("Thêm", style: TextStyle(color: Colors.black)),
              ),
              TextButton.icon(
                onPressed: () {
                  GoRouter.of(context).push('/protected/manage-categories');
                },
                icon: Icon(Icons.edit, color: Colors.black),
                label: Text("Chỉnh sửa danh mục",
                    style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),

        // Nội dung dựa theo tab
        Expanded(
          child: ListView.builder(
            itemCount:
                selectedTab == 0 ? filter.length : widget.toppingGroups.length,
            itemBuilder: (context, categoryIndex) {
              if (selectedTab == 0) {
                var category = filter[categoryIndex];
                return Column(
                  children: [
                    ListTile(
                      title: Text(
                        category["title"],
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                              "${category["items"].where((item) => item["isAvailable"] == true).length}/${category["items"].length}"),
                          IconButton(
                            icon: Icon(category["isExpanded"]
                                ? Icons.expand_less
                                : Icons.expand_more),
                            onPressed: () {
                              setState(() {
                                int originalIndex = widget.categoryMenu
                                    .indexWhere((cat) =>
                                        cat["title"] == category["title"]);
                                if (originalIndex != -1) {
                                  widget.categoryMenu[originalIndex]
                                          ["isExpanded"] =
                                      !widget.categoryMenu[originalIndex]
                                          ["isExpanded"];
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    if (category["isExpanded"])
                      Column(
                        children: category["items"].map<Widget>((item) {
                          return ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey[400],
                              child: Center(child: Text("Ảnh")),
                            ),
                            title: Text(item["name"]),
                            subtitle: Text(item["price"]),
                            trailing: Switch(
                              value: item["isAvailable"],
                              onChanged: (value) {
                                setState(() {
                                  item["isAvailable"] = value;
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                );
              } else {
                var item = widget.toppingGroups[categoryIndex];
                return ListTile(
                  title: Text(item["name"]),
                  subtitle: Text("Số lượng topping: ${item["count"]}"),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
