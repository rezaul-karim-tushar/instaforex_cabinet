import 'package:equatable/equatable.dart';

class PromoEntity extends Equatable {
  final String title;
  final String description;
  final String imageUrl;
  final String link;
  final String code;

  const PromoEntity({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.link,
    required this.code,
  });

  bool get hasImage => imageUrl.isNotEmpty;
  bool get hasLink => link.isNotEmpty;
  bool get hasCode => code.isNotEmpty;

  @override
  List<Object> get props => [title, imageUrl, link];
}
