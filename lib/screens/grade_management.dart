import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/ManagementLayout.dart';

class GradeScreen extends StatefulWidget {
  const GradeScreen({super.key});

  @override
  _GradeScreenState createState() => _GradeScreenState();
}

class _GradeScreenState extends State<GradeScreen> {
  final List<Map<String, dynamic>> _gradeList = [
    {"checked": false, "stt": 1, "maKhoi": "NT", "tenKhoi": "Nhà trẻ"},
    {"checked": false, "stt": 2, "maKhoi": "MG", "tenKhoi": "Mẫu giáo"},
  ];

  String _userName = '';
  String _userRole = '';

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
        setState(() {
          _userName = userData['name'] ?? 'Người dùng';
          _userRole = userData['roles'][0]['display_name'] ?? 'Quản lý';
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

  Widget _buildGradeTable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: constraints.maxWidth, // Đảm bảo bảng không bị tràn
              ),
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('')),
                  DataColumn(label: Text('STT')),
                  DataColumn(label: Text('MÃ KHỐI')),
                  DataColumn(label: Text('TÊN KHỐI')),
                ],
                rows:
                    _gradeList.map((item) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Checkbox(
                              value: item['checked'],
                              onChanged: (value) {
                                setState(() {
                                  item['checked'] = value!;
                                });
                              },
                            ),
                          ),
                          DataCell(Text(item['stt'].toString())),
                          DataCell(Text(item['maKhoi'].toString())),
                          DataCell(Text(item['tenKhoi'].toString())),
                        ],
                      );
                    }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManagementLayout(
      selectedRoute: 'grade',
      userName: _userName,
      userRole: _userRole,
      title: 'Quản lý khối',
      onRouteSelected: (route) {
        Navigator.pushNamed(context, route);
      },
      mainContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề trang + nhóm nút chức năng
          LayoutBuilder(
            builder: (context, constraints) {
              bool isSmallScreen = constraints.maxWidth < 600;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DANH SÁCH KHỐI',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8, // Giúp tự xuống dòng nếu không đủ chỗ
                    alignment: WrapAlignment.start,
                    children: [
                      ElevatedButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.add),
                        label: const Text('Thêm mới'),
                      ),
                      ElevatedButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.edit),
                        label: const Text('Sửa'),
                      ),
                      ElevatedButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.delete),
                        label: const Text('Xóa'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildGradeTable()), // Đảm bảo bảng không tràn
        ],
      ),
    );
  }
}
