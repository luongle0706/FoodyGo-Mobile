// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// class ViewCartPage extends StatelessWidget {
//   const ViewCartPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Center(child: Text("Main screen content")),
//           // Nút mở giỏ hàng
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: Padding(
//               padding: EdgeInsets.all(16),
//               child: ElevatedButton(
//                 onPressed: () {
//                   showModalBottomSheet(
//                     context: context,
//                     isScrollControlled: true,
//                     shape: RoundedRectangleBorder(
//                       borderRadius:
//                           BorderRadius.vertical(top: Radius.circular(16)),
//                     ),
//                     builder: (context) {
//                       return DraggableScrollableSheet(
//                         expand: false,
//                         initialChildSize: 0.8,
//                         minChildSize: 0.5,
//                         maxChildSize: 0.9,
//                         builder: (context, scrollController) {
//                           return Container(
//                             padding: EdgeInsets.all(16),
//                             child: Column(
//                               children: [
//                                 // Header
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     GestureDetector(
//                                       onTap: () {},
//                                       child: Text(
//                                         "Xóa tất cả",
//                                         style: TextStyle(
//                                             fontSize: 16, color: Colors.red),
//                                       ),
//                                     ),
//                                     Text(
//                                       "Giỏ hàng",
//                                       style: TextStyle(
//                                           fontSize: 20,
//                                           fontWeight: FontWeight.w500),
//                                     ),
//                                     GestureDetector(
//                                       onTap: () {
//                                         GoRouter.of(context).pop();
//                                       },
//                                       child: Icon(Icons.close, size: 30),
//                                     ),
//                                   ],
//                                 ),
//                                 SizedBox(height: 20),
//                                 // Danh sách sản phẩm
//                                 Expanded(
//                                   child: ListView.builder(
//                                     controller: scrollController,
//                                     itemCount: 2, // Thay bằng số lượng thật
//                                     itemBuilder: (context, index) {
//                                       return Padding(
//                                         padding:
//                                             const EdgeInsets.only(bottom: 12),
//                                         child: _buildCartItem(context),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                                 // Footer giỏ hàng
//                                 _buildCartFooter(),
//                               ],
//                             ),
//                           );
//                         },
//                       );
//                     },
//                   );
//                 },
//                 child: Text("View Cart"),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCartItem(BuildContext context) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         ClipRRect(
//           borderRadius: BorderRadius.circular(8),
//           child: Image.network(
//             'https://images.immediate.co.uk/production/volatile/sites/30/2020/08/chorizo-mozarella-gnocchi-bake-cropped-9ab73a3.jpg?resize=768,574',
//             width: 60,
//             height: 60,
//             fit: BoxFit.cover,
//             loadingBuilder: (context, child, progress) {
//               if (progress == null) return child;
//               return Center(child: CircularProgressIndicator());
//             },
//             errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
//           ),
//         ),
//         SizedBox(width: 10),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text("Name Product",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
//               SizedBox(height: 5),
//               Text("Add on item",
//                   style: TextStyle(fontSize: 16, color: Colors.grey)),
//               SizedBox(height: 10),
//               Row(
//                 children: [
//                   Icon(Icons.note_alt_outlined, color: Colors.grey),
//                   GestureDetector(
//                     onTap: () {
//                       _showNoteDialog(context);
//                     },
//                     child: Text("Thêm ghi chú...",
//                         style: TextStyle(color: Colors.grey)),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 10),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text("46.000đ", style: TextStyle(color: Colors.red)),
//                   Row(
//                     children: [
//                       IconButton(
//                         onPressed: () {},
//                         icon: Icon(Icons.remove),
//                         padding: EdgeInsets.zero,
//                         constraints: BoxConstraints(),
//                       ),
//                       Text("1", style: TextStyle(fontSize: 16)),
//                       IconButton(
//                         onPressed: () {},
//                         icon: Icon(Icons.add, color: Colors.orange),
//                         padding: EdgeInsets.zero,
//                         constraints: BoxConstraints(),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   void _showNoteDialog(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (context) {
//         return Container(
//           padding: EdgeInsets.all(16),
//           height: MediaQuery.of(context).size.height * 0.5,
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   GestureDetector(
//                     onTap: () => {},
//                     child: Text("Hủy", style: TextStyle(color: Colors.grey)),
//                   ),
//                   Text("Thêm ghi chú",
//                       style:
//                           TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
//                   GestureDetector(
//                     onTap: () => {},
//                     child: Text("Xong", style: TextStyle(color: Colors.red)),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 10),
//               TextField(
//                 decoration: InputDecoration(
//                   hintText: "Nhập ghi chú...",
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8)),
//                 ),
//                 maxLines: 5,
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildCartFooter() {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 10),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Stack(
//             clipBehavior: Clip.none,
//             children: [
//               Icon(Icons.shopping_basket, size: 50, color: Colors.orange),
//               Positioned(
//                 right: 0,
//                 top: -5,
//                 child: Container(
//                   padding: EdgeInsets.all(6),
//                   decoration: BoxDecoration(
//                       color: Colors.orange, shape: BoxShape.circle),
//                   child: Text("2", style: TextStyle(color: Colors.white)),
//                 ),
//               ),
//             ],
//           ),
//           Text("162.000đ",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           ElevatedButton(
//             onPressed: () {},
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.orange,
//               padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             ),
//             child: Text("Giao hàng", style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }
// }
