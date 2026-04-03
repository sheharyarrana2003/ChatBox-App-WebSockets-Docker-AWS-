import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NetworkAvatar extends StatelessWidget {
  final String? url;
  final double radius;
  final String name;

  const NetworkAvatar({
    super.key,
    this.url,
    required this.radius,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    // If URL is provided and valid, show network image
    if (url != null && url!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: CachedNetworkImageProvider(url!),
        child: Container(), // Empty container for proper sizing
      );
    }

    // Otherwise show initials avatar
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.teal.shade100,
      child: Text(
        _getInitials(),
        style: TextStyle(
          fontSize: radius * 0.5,
          fontWeight: FontWeight.bold,
          color: Colors.teal.shade800,
        ),
      ),
    );
  }

  String _getInitials() {
    if (name.isEmpty) return '?';

    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else {
      return name[0].toUpperCase();
    }
  }
}