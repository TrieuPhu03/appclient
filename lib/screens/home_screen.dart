import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            title: const Text(""),
            floating: true,
            pinned: true,
            snap: true,
            expandedHeight: 200.0,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(""),
              background: Image.asset(
                'assets/home_tab_logo.jpg',
                fit: BoxFit.cover,
              ),
            ),
          )
        ];
      },
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Số cột (2 cột)
          crossAxisSpacing: 10.0, // Khoảng cách giữa các cột
          mainAxisSpacing: 10.0, // Khoảng cách giữa các hàng
          childAspectRatio: 1.0, // Tỷ lệ chiều rộng / chiều cao
        ),
        padding: const EdgeInsets.all(10.0), // Khoảng cách lưới với viền ngoài
        itemCount: 6, // Số lượng bài viết
        itemBuilder: (context, index) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 4, // Hiệu ứng đổ bóng
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person, size: 40), // Icon
                const SizedBox(height: 10), // Khoảng cách
                Text(
                  'Post #$index',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                const Text('This is a post description',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          );
        },
      ),
    );
  }
}
