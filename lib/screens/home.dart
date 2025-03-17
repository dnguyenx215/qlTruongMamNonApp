import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'login.dart';

// Import components
import '../widgets/Sidebar.dart';
import '../widgets/Header.dart';
import '../widgets/StudentMonitoring.dart';
import '../widgets/FoodTracking.dart';
import '../widgets/TuitionTracking.dart';
import '../widgets/Calendar.dart';
import '../widgets/Notifications.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = '';
  String _userRole = '';
  String _userRoleDisplay = '';
  String _selectedRoute = '/home';
  String _activeNotificationFilter = 'today';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('user');

    if (userDataString != null) {
      try {
        final userData = jsonDecode(userDataString);
        final userRoles = userData['roles'];
        var userRole = userRoles[0];
        setState(() {
          _userName = userData['name'] ?? 'Người dùng';
          _userRole = userRole['name'] ?? 'Chưa xác định';
          _userRoleDisplay = userRole['display_name'] ?? 'Chưa xác định';
        });
      } catch (e) {
        setState(() {
          _userName = 'Người dùng';
          _userRole = 'Quản lý';
        });
      }
    } else {
      setState(() {
        _userName = 'VUONG THI MAI';
        _userRole = 'QL';
      });
    }
  }

  void _handleRouteSelected(String route) {
    final formattedRoute = route.startsWith('/') ? route : '/$route';
    if (route == '/logout') {
      _logout();
    } else if (formattedRoute == '/grade' ||
        formattedRoute == '/class' ||
        formattedRoute == '/students' ||
        formattedRoute == '/holidays' ||
        formattedRoute == '/attendance') {
      Navigator.pushNamed(context, formattedRoute);
    } else {
      // Nếu là menu khác mà vẫn nằm trong HomeScreen, cập nhật _selectedRoute
      setState(() {
        _selectedRoute = formattedRoute;
        Navigator.pushNamed(context, _selectedRoute);
      });
    }
  }

  void _handleFilterChanged(String filter) {
    setState(() {
      _activeNotificationFilter = filter;
    });
  }

  void _handleSendNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chức năng gửi thông báo đang được phát triển'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  // Hàm tạo nội dung chính
  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with user info
          HeaderComponent(
            userName: _userName,
            userRole: _userRoleDisplay,
            onSendNotification: _handleSendNotification,
          ),
          const SizedBox(height: 24),
          // Main content
          Expanded(
            child: SingleChildScrollView(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column (chiếm 2/3 width)
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: const [
                        StudentMonitoringComponent(),
                        SizedBox(height: 16),
                        FoodTrackingComponent(),
                        SizedBox(height: 16),
                        TuitionTrackingComponent(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Right column (chiếm 1/3 width)
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        const CalendarComponent(),
                        const SizedBox(height: 16),
                        NotificationsComponent(
                          activeFilter: _activeNotificationFilter,
                          onFilterChanged: _handleFilterChanged,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Giả sử màn hình nhỏ là dưới 800px
        bool isMobile = constraints.maxWidth < 800;

        if (isMobile) {
          // Mobile layout: Sidebar dưới dạng Drawer
          return Scaffold(
            backgroundColor: Colors.grey[100],
            drawer: Drawer(
              child: SidebarComponent(
                selectedRoute: _selectedRoute,
                onRouteSelected: (route) {
                  Navigator.of(context).pop(); // Đóng drawer
                  _handleRouteSelected(route);
                },
              ),
            ),
            appBar: AppBar(
              title: const Text('Trang chính'),
              leading: Builder(
                builder:
                    (context) => IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
              ),
            ),
            body: _buildMainContent(),
          );
        } else {
          // Tablet/Desktop layout: Sidebar cố định bên trái
          return Scaffold(
            backgroundColor: Colors.grey[100],
            body: Row(
              children: [
                SidebarComponent(
                  selectedRoute: _selectedRoute,
                  onRouteSelected: _handleRouteSelected,
                ),
                Expanded(child: _buildMainContent()),
              ],
            ),
          );
        }
      },
    );
  }
}
