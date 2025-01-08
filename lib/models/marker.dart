class MarkerData {
  final int id;
  final String title;
  final String image;

  MarkerData({required this.id,required this.title, required this.image});

  factory MarkerData.fromJson(Map<String, dynamic> json) {
    return MarkerData(
      image: json['image'],
      id: json['id'],
      title: json['title'],
    );
  }
}