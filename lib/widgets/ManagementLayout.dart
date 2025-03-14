import 'package:flutter/material.dart';
import 'Sidebar.dart'; // Đường dẫn theo dự án của bạn
import 'Header.dart';

class ManagementLayout extends StatelessWidget {
  final String selectedRoute;
  final Widget mainContent;
  final Function(String) onRouteSelected;
  final String title; // tiêu đề hiển thị trên AppBar (đối với mobile)
  final VoidCallback? onSendNotification;
  final String userName;
  final String userRole;

  const ManagementLayout({
    super.key,
    required this.selectedRoute,
    required this.mainContent,
    required this.onRouteSelected,
    this.title = '',
    required this.userName,
    required this.userRole,
    this.onSendNotification,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 800;
        if (isMobile) {
          return Scaffold(
            backgroundColor: Colors.grey[100],
            drawer: Drawer(
              child: SidebarComponent(
                selectedRoute: selectedRoute,
                onRouteSelected: (route) {
                  Navigator.of(context).pop();
                  onRouteSelected(route);
                },
              ),
            ),
            appBar: AppBar(
              title: Text(title.isNotEmpty ? title : 'Quản lý'),
              leading: Builder(
                builder:
                    (context) => IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  HeaderComponent(
                    userName: userName,
                    userRole: userRole,
                    onSendNotification:
                        onSendNotification ?? () => print('Send notification'),
                  ),
                  const SizedBox(height: 16),
                  Expanded(child: mainContent),
                ],
              ),
            ),
          );
        } else {
          // Desktop/Tablet: hiển thị Sidebar cố định bên trái
          return Scaffold(
            backgroundColor: Colors.grey[100],
            body: Row(
              children: [
                SidebarComponent(
                  selectedRoute: selectedRoute,
                  onRouteSelected: onRouteSelected,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        HeaderComponent(
                          userName: userName,
                          userRole: userRole,
                          onSendNotification:
                              onSendNotification ??
                              () => print('Send notification'),
                        ),
                        const SizedBox(height: 16),
                        Expanded(child: mainContent),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
