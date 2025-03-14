import 'package:flutter/material.dart';

class HeaderComponent extends StatelessWidget {
  final String userName;
  final String userRole;
  final VoidCallback onSendNotification;

  const HeaderComponent({
    Key? key,
    required this.userName,
    required this.userRole,
    required this.onSendNotification,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Nếu màn hình nhỏ (width < 600), chuyển sang layout dạng Column
        if (constraints.maxWidth < 600) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User greeting
              Row(
                children: [
                  Text(
                    'Xin chào ',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '👋',
                    style: TextStyle(fontSize: 20, color: Colors.amber[500]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '$userRole $userName',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              const SizedBox(height: 16),
              // Notification & Profile in a single row
              Row(
                children: [
                  ElevatedButton(
                    onPressed: onSendNotification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[500],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    child: const Text('Gửi thông báo'),
                  ),
                  const SizedBox(width: 12),
                  // Bell icon with counter
                  Stack(
                    children: [
                      Icon(
                        Icons.notifications,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 14,
                            minHeight: 14,
                          ),
                          child: const Text(
                            '1',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  // User avatar and info
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(
                      'https://storage.googleapis.com/a1aa/image/PZdlgZSigXXdw1boMLsZu7HDxZy0MWPSzfZjdG2vCoQ.jpg',
                    ),
                    onBackgroundImageError: (exception, stackTrace) {},
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName.toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        userRole,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        } else {
          // Với màn hình rộng, sử dụng layout dạng Row như ban đầu
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left side: User greeting
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Xin chào ',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '👋',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.amber[500],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$userRole $userName',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              // Right side: Notification & Profile
              Row(
                children: [
                  ElevatedButton(
                    onPressed: onSendNotification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[500],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: const Text('Gửi thông báo'),
                  ),
                  const SizedBox(width: 16),
                  Stack(
                    children: [
                      Icon(
                        Icons.notifications,
                        color: Colors.grey[600],
                        size: 24,
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: const Text(
                            '1',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(
                          'https://storage.googleapis.com/a1aa/image/PZdlgZSigXXdw1boMLsZu7HDxZy0MWPSzfZjdG2vCoQ.jpg',
                        ),
                        onBackgroundImageError: (exception, stackTrace) {},
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName.toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            userRole,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        }
      },
    );
  }
}
