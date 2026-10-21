class CategoryModel {
  final int id;
  final String name;
  final String slug;
  final bool isActive;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.isActive,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'isActive': isActive,
      };
}
