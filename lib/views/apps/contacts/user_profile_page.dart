import 'package:flutter/material.dart';
import 'package:webkit/helpers/widgets/my_button.dart';
import 'package:webkit/models/app_user.dart';
import 'package:webkit/helpers/widgets/my_text.dart';
import 'package:webkit/helpers/widgets/my_spacing.dart';

class UserProfilePage extends StatelessWidget {
  final AppUserModel user;
  const UserProfilePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF835FFF);
    const bgColor = Color(0xFFEFF1FE);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("${user.name}'s Profile"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(user.avatarUrl),
              ),
              MySpacing.height(16),
              MyText.titleLarge(user.name, fontWeight: 700, color: Colors.black87),
              MySpacing.height(8),
              MyText.bodyMedium(user.email, color: Colors.grey[700]),
              MySpacing.height(8),
              MyText.bodyMedium("Country: ${user.country}", color: Colors.grey[700]),
              MySpacing.height(24),
              MyButton(
                onPressed: () => Navigator.pop(context),
                elevation: 0,
                backgroundColor: primaryColor,
                borderRadiusAll: 12,
                padding: MySpacing.xy(20, 12),
                child: MyText.bodyMedium(
                  "Back to List",
                  color: Colors.white,
                  fontWeight: 600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
