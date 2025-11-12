import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FlagPhoneWidget extends StatelessWidget {
  final String? flagUrl;
  final double size;

  const FlagPhoneWidget({
    super.key,
    required this.flagUrl,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: flagUrl?.isNotEmpty == true
          ? CachedNetworkImage(
        imageUrl: flagUrl!,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey[300]!, width: 0.5),
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey[300]!, width: 0.5),
        color: Colors.grey[100],
      ),
      child: Icon(
        Icons.flag,
        size: size * 0.6,
        color: Colors.grey[600],
      ),
    );
  }
}