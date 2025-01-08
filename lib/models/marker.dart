class MarkerData {
  final int id;
  final String title;
  final String image;
  final String kinhDo;
  final String viDo;

  MarkerData({required this.id,required this.title, required this.image, required this.kinhDo, required this.viDo});

  factory MarkerData.fromJson(Map<String, dynamic> json) {
    return MarkerData(
      image: json['image'] ?? '',
      id: json['id']?? 0,
      title: json['title']??'',
      kinhDo: json['kinhDo']??'',
      viDo: json['viDo']??'',
    );
  }
}