import 'package:flutter/material.dart';
import 'package:medical_device_tracking/extension/extension_on_buildcontext.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String id;
  final String role;
  final String imageUrl;
  final VoidCallback? onChangeAvatar;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.id,
    required this.role,
    required this.imageUrl,
    this.onChangeAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: context.pLG,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: context.base * 0.30,
                height: context.base * 0.30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: context.base * 0.015,
                  ),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              Positioned(
                bottom: -context.base * 0.01,
                right: -context.base * 0.01,
                child: GestureDetector(
                  onTap: onChangeAvatar,
                  child: Container(
                    padding: context.pSM,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: context.base * 0.02,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: context.base * 0.05,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: context.base * 0.04),

          Text(
            name,
            style: TextStyle(
              fontSize: context.base * 0.07,
              fontWeight: FontWeight.bold,
              color: const Color(0xff1E293B),
            ),
          ),

          // SizedBox(height: context.base * 0.005),

          Text(
            "ID: $id",
            style: TextStyle(
              fontSize: context.base * 0.045,
              color: Colors.grey,
            ),
          ),

          SizedBox(height: context.base * 0.01),

          Container(
            padding: context.pxy(0.05, 0.015),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: context.radiusLG,
              border: Border.all(
                color: Colors.blue.withOpacity(0.3),
              ),
            ),
            child: Text(
              role,
              style: TextStyle(
                fontSize: context.base * 0.045,
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}