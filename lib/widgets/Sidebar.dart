import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SidebarComponent extends StatelessWidget {
  final String selectedRoute;
  final Function(String) onRouteSelected;


  const SidebarComponent({
    super.key,
    required this.selectedRoute,
    required this.onRouteSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Lấy chiều rộng màn hình hiện tại
    final double screenWidth = MediaQuery.of(context).size.width;
    // Nếu màn hình nhỏ (< 600px) thì sidebar chiếm 80% chiều rộng, ngược lại 20%
    final double sidebarWidth =
        screenWidth < 600 ? screenWidth * 0.8 : screenWidth * 0.2;

    return Container(
      width: sidebarWidth,
      color: Colors.blue[100],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Logo and Title
            Row(
              children: [
                Image.network(
                  'https://storage.googleapis.com/a1aa/image/3FwTsLe5qGHs69xcaEeqTt4cI316u7imI_HhA4E5s6w.jpg',
                  width: 50,
                  height: 50,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey[300],
                        child: const Icon(Icons.school),
                      ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'SON CA PRESCHOOL MANAGEMENT',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth < 600 ? 14 : 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Main Navigation
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildNavItem('home', 'Trang chính', FontAwesomeIcons.home),

                    _buildNavItem(
                      'grade',
                      'Quản lý khối',
                      FontAwesomeIcons.layerGroup,
                    ),
                    _buildNavItem(
                      'class',
                      'Quản lý lớp',
                      FontAwesomeIcons.chalkboardTeacher,
                    ),
                    _buildNavItem(
                      'students',
                      'Danh sách học sinh',
                      FontAwesomeIcons.list,
                    ),
                    _buildNavItem(
                      'holidays',
                      'Cấu hình ngày nghỉ',
                      FontAwesomeIcons.calendarAlt,
                    ),
                    _buildNavItem(
                      'attendance',
                      'Điểm danh học sinh',
                      FontAwesomeIcons.checkSquare,
                    ),
                    _buildNavItem(
                      'monitor',
                      'Theo dõi học sinh',
                      FontAwesomeIcons.userCheck,
                    ),
                    _buildNavItem(
                      'receipt',
                      'Phiếu thu',
                      FontAwesomeIcons.receipt,
                    ),
                    _buildNavItem(
                      'tuition',
                      'Sổ thu học phí',
                      FontAwesomeIcons.wallet,
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Navigation Items
            Column(
              children: [
                _buildNavItem('admin', 'Quản trị', FontAwesomeIcons.cogs),
                _buildNavItem(
                  'help',
                  'Trợ giúp',
                  FontAwesomeIcons.questionCircle,
                ),
                _buildNavItem('logout', 'Thoát', FontAwesomeIcons.signOutAlt),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(String route, String title, IconData icon) {
    final bool isSelected = selectedRoute == route;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () => onRouteSelected(route),
        child: Row(
          children: [
            FaIcon(
              icon,
              size: 16,
              color: isSelected ? Colors.blue[600] : Colors.grey[700],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.blue[600] : Colors.grey[700],
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
