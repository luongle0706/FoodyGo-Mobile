import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ViewCartPage extends StatelessWidget {
  const ViewCartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          //Main screen
          Center(child: Text("Main screen content")),
          const Spacer(),
          // Draggable sub-screen at the bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    builder: (context) {
                      return Container(
                        padding: EdgeInsets.all(16),
                        height: MediaQuery.of(context).size.height * 0.8,
                        child: Column(
                          children: [
                            //header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    GoRouter.of(context).pop();
                                  },
                                  child: Text(
                                    "Xóa tất cả",
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.red),
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      "Giỏ hàng",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    GoRouter.of(context).pop();
                                  },
                                  child: Icon(
                                    Icons.close,
                                    size: 30,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            //List item
                            Row(
                              crossAxisAlignment: CrossAxisAlignment
                                  .start, // Align items vertically at the start
                              children: [
                                SizedBox(
                                  width: 80,
                                  height: 60,
                                  child: Image.network(
                                    'https://images.immediate.co.uk/production/volatile/sites/30/2020/08/chorizo-mozarella-gnocchi-bake-cropped-9ab73a3.jpg?resize=768,574',
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) {
                                        return child;
                                      } else {
                                        return Center(
                                            child: CircularProgressIndicator());
                                      }
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(Icons.error);
                                    },
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Name Product",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "Add on item",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.note_alt_outlined,
                                            color: Colors.grey,
                                          ),
                                          // Gesture thêm ghi chú
                                          GestureDetector(
                                            onTap: () {
                                              showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.vertical(
                                                            top:
                                                                Radius.circular(
                                                                    16)),
                                                  ),
                                                  builder: (context) {
                                                    return Container(
                                                      padding:
                                                          EdgeInsets.all(16),
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.7,
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              GestureDetector(
                                                                onTap: () {
                                                                  GoRouter.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                child: Text(
                                                                  "Hủy",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      color: const Color
                                                                          .fromARGB(
                                                                          255,
                                                                          142,
                                                                          139,
                                                                          139)),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Center(
                                                                  child: Text(
                                                                    "Thêm ghi chú",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            20,
                                                                        fontWeight:
                                                                            FontWeight.w500),
                                                                  ),
                                                                ),
                                                              ),
                                                              GestureDetector(
                                                                onTap: () {
                                                                  GoRouter.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                child: Text(
                                                                  "Xong",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      color: Colors
                                                                          .red),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  });
                                            },
                                            child: Text(
                                              "Thêm ghi chú...",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.grey),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start, // Align items at the top
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 10, left: 5),
                                            child: Text(
                                              "46.000đ",
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 16),
                                            ),
                                          ),
                                          Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 12),
                                                child: Row(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {},
                                                      child: Container(
                                                        width: 20,
                                                        height: 20,
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              color:
                                                                  Colors.black,
                                                              width: 1),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                        ),
                                                        child: Center(
                                                          child: Icon(
                                                              Icons.remove,
                                                              color:
                                                                  Colors.black,
                                                              size: 18),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    const Text("1",
                                                        style: TextStyle(
                                                            fontSize: 16)),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {},
                                                      child: Container(
                                                        width: 20,
                                                        height: 20,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Color.fromARGB(
                                                              255, 235, 93, 4),
                                                          border: Border.all(
                                                              width: 1),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                        ),
                                                        child: Center(
                                                          child: Icon(Icons.add,
                                                              color:
                                                                  Colors.white,
                                                              size: 18),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Icon(Icons.shopping_basket,
                                        size: 50, color: Colors.red),
                                    Positioned(
                                      right: 0,
                                      top: -10,
                                      child: Container(
                                        padding: EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          "2",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 100),
                                  child: Text(
                                    "162.000đ",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                  ),
                                  child: Text(
                                    "Giao hàng",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Text("View Cart"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
