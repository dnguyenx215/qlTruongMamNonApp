// lib/screens/holiday_configuration_screen.dart
import 'dart:convert';
import 'package:QL_TruongMamNon/widgets/holiday/holiday_add_edit_modal.dart';
import 'package:QL_TruongMamNon/widgets/holiday/holiday_delete_modal.dart';
import 'package:QL_TruongMamNon/widgets/holiday/month_calendar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../models/holiday.dart';
import '../services/holiday_service.dart';
import '../widgets/ManagementLayout.dart';

class HolidayConfigurationScreen extends StatefulWidget {
  const HolidayConfigurationScreen({super.key});

  @override
  _HolidayConfigurationScreenState createState() =>
      _HolidayConfigurationScreenState();
}

class _HolidayConfigurationScreenState
    extends State<HolidayConfigurationScreen> {
  // State variables
  bool _isLoading = false;
  String _userName = '';
  String _userRole = '';
  List<Holiday> _holidaysList = [];

  // Filter variables
  String _searchKeyword = '';
  int _selectedYear = DateTime.now().year;
  String _selectedHolidayType = 'all';

  final List<String> _holidayTypes = ['all', 'weekend', 'national', 'school'];
  final Map<String, String> _holidayTypeLabels = {
    'all': 'Tất cả',
    'weekend': 'Cuối tuần',
    'national': 'Lễ quốc gia',
    'school': 'Nghỉ trường',
  };

  @override
  void initState() {
    super.initState();
    _loadUser();
    _fetchHolidays();
  }

  /// Lấy thông tin user
  Future<void> _loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('user');
    if (userDataString != null) {
      try {
        final userData = jsonDecode(userDataString);
        setState(() {
          _userName = userData['name'] ?? 'Người dùng';
          _userRole = userData['role'] ?? 'Quản lý';
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

  /// Gọi API lấy danh sách ngày nghỉ
  Future<void> _fetchHolidays() async {
    setState(() => _isLoading = true);

    try {
      final holidaysData = await HolidayService.fetchHolidays(_selectedYear);
      setState(() {
        _holidaysList =
            holidaysData.map((item) => Holiday.fromJson(item)).toList();
        // Sắp xếp ngày nghỉ theo ngày
        _holidaysList.sort((a, b) => a.holidayDate.compareTo(b.holidayDate));
      });
    } catch (e) {
      debugPrint("Lỗi khi tải danh sách ngày nghỉ: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải danh sách ngày nghỉ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Lọc danh sách ngày nghỉ theo bộ lọc hiện tại
  List<Holiday> get _filteredHolidaysList {
    return _holidaysList.where((holiday) {
      // Lọc theo từ khóa tìm kiếm
      final nameMatch = holiday.holidayName.toLowerCase().contains(
        _searchKeyword.toLowerCase(),
      );
      final dateMatch = holiday.holidayDate.contains(
        _searchKeyword.toLowerCase(),
      );
      final descMatch = holiday.description.toLowerCase().contains(
        _searchKeyword.toLowerCase(),
      );

      // Lọc theo loại ngày nghỉ
      final typeMatch =
          _selectedHolidayType == 'all' ||
          holiday.holidayType == _selectedHolidayType;

      return (nameMatch || dateMatch || descMatch) && typeMatch;
    }).toList();
  }

  // Hiển thị modal thêm/sửa ngày nghỉ
  void _showAddEditModal([Holiday? existingHoliday]) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return HolidayAddEditModal(
          existingHoliday: existingHoliday,
          onSave: _fetchHolidays,
        );
      },
    );
  }

  // Hiển thị modal xóa ngày nghỉ
  void _showDeleteModal(Holiday holiday) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return HolidayDeleteModal(holiday: holiday, onDelete: _fetchHolidays);
      },
    );
  }

  // Xử lý tạo tự động ngày nghỉ cuối tuần
  Future<void> _createWeekendHolidays() async {
    setState(() => _isLoading = true);

    try {
      await HolidayService.createWeekendHolidays(_selectedYear);
      await _fetchHolidays(); // Refresh list

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã tạo ngày nghỉ cuối tuần thành công'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Xử lý các nút chức năng
  void _themMoi() => _showAddEditModal();

  void _sua() {
    final selectedHolidays =
        _filteredHolidaysList.where((h) => h.checked).toList();

    if (selectedHolidays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn một ngày nghỉ để sửa'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (selectedHolidays.length > 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chỉ chọn một ngày nghỉ để sửa'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    _showAddEditModal(selectedHolidays.first);
  }

  void _xoa() {
    final selectedHolidays =
        _filteredHolidaysList.where((h) => h.checked).toList();

    if (selectedHolidays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất một ngày nghỉ để xóa'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Nếu chỉ có 1 ngày được chọn, hiển thị modal xoá
    if (selectedHolidays.length == 1) {
      _showDeleteModal(selectedHolidays.first);
      return;
    }

    // Nếu có nhiều ngày được chọn, hiển thị dialog xác nhận
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: Text(
              'Bạn có chắc chắn muốn xóa ${selectedHolidays.length} ngày nghỉ đã chọn không?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  Navigator.pop(context);

                  setState(() => _isLoading = true);

                  try {
                    // Xóa lần lượt các ngày nghỉ đã chọn
                    for (var holiday in selectedHolidays) {
                      if (holiday.id != null) {
                        await HolidayService.deleteHoliday(holiday.id!);
                      }
                    }

                    await _fetchHolidays(); // Refresh list

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã xóa các ngày nghỉ thành công'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Lỗi: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } finally {
                    setState(() => _isLoading = false);
                  }
                },
                child: const Text('Xóa'),
              ),
            ],
          ),
    );
  }

  // Bảng hiển thị danh sách ngày nghỉ
  Widget _buildHolidaysTable() {
    final holidays = _filteredHolidaysList;

    if (holidays.isEmpty) {
      return const Center(
        child: Text(
          "Không có ngày nghỉ nào.",
          style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;

        // For small screens, use a ListView with cards instead of a table
        if (isSmallScreen) {
          return ListView.builder(
            itemCount: holidays.length,
            itemBuilder: (context, index) {
              final holiday = holidays[index];

              // Format holiday date to display
              final dateFormatter = DateFormat('dd/MM/yyyy');
              final holidayDate = DateTime.parse(holiday.holidayDate);
              final formattedDate = dateFormatter.format(holidayDate);

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Checkbox(
                    value: holiday.checked,
                    onChanged: (value) {
                      setState(() {
                        holiday.checked = value ?? false;
                      });
                    },
                  ),
                  title: Text(
                    holiday.holidayName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ngày: $formattedDate'),
                      Text(
                        'Loại: ${_holidayTypeLabels[holiday.holidayType] ?? holiday.holidayType}',
                      ),
                      if (holiday.description.isNotEmpty)
                        Text('Mô tả: ${holiday.description}'),
                    ],
                  ),
                  isThreeLine: holiday.description.isNotEmpty,
                ),
              );
            },
          );
        }

        // For larger screens, use a DataTable
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('')), // Checkbox
                  DataColumn(label: Text('STT')),
                  DataColumn(label: Text('NGÀY')),
                  DataColumn(label: Text('TÊN SỰ KIỆN')),
                  DataColumn(label: Text('LOẠI')),
                  DataColumn(label: Text('MÔ TẢ')),
                ],
                rows:
                    holidays.asMap().entries.map((entry) {
                      final index = entry.key;
                      final holiday = entry.value;

                      // Format holiday date to display
                      final dateFormatter = DateFormat('dd/MM/yyyy');
                      final holidayDate = DateTime.parse(holiday.holidayDate);
                      final formattedDate = dateFormatter.format(holidayDate);

                      return DataRow(
                        cells: [
                          DataCell(
                            Checkbox(
                              value: holiday.checked,
                              onChanged: (value) {
                                setState(() {
                                  holiday.checked = value ?? false;
                                });
                              },
                            ),
                          ),
                          DataCell(Text('${index + 1}')),
                          DataCell(Text(formattedDate)),
                          DataCell(Text(holiday.holidayName)),
                          DataCell(
                            Text(
                              _holidayTypeLabels[holiday.holidayType] ??
                                  holiday.holidayType,
                            ),
                          ),
                          DataCell(Text(holiday.description)),
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
      selectedRoute: '/holidays',
      userName: _userName,
      userRole: _userRole,
      title: 'Cấu hình ngày nghỉ',
      onRouteSelected: (route) => Navigator.pushNamed(context, route),
      mainContent: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 600;
          final isMediumScreen = constraints.maxWidth < 900;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề trang
              const Text(
                'CẤU HÌNH NGÀY NGHỈ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Filter & buttons - Responsive Wrap
              Wrap(
                spacing: 8,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Search box
                  SizedBox(
                    width: isSmallScreen ? constraints.maxWidth * 0.9 : 250,
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Tìm kiếm...',
                        prefixIcon: Icon(Icons.search),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onChanged: (value) {
                        setState(() => _searchKeyword = value);
                      },
                    ),
                  ),

                  // Year selector
                  SizedBox(
                    width: isSmallScreen ? constraints.maxWidth * 0.45 : 120,
                    child: DropdownButtonFormField<int>(
                      isDense: true,
                      decoration: const InputDecoration(
                        labelText: 'Năm',
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 10,
                        ),
                      ),
                      value: _selectedYear,
                      items: [
                        for (
                          int year = DateTime.now().year - 2;
                          year <= DateTime.now().year + 2;
                          year++
                        )
                          DropdownMenuItem(
                            value: year,
                            child: Text(year.toString()),
                          ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedYear = value);
                          _fetchHolidays();
                        }
                      },
                    ),
                  ),

                  // Holiday type filter
                  SizedBox(
                    width: isSmallScreen ? constraints.maxWidth * 0.45 : 150,
                    child: DropdownButtonFormField<String>(
                      isDense: true,
                      decoration: const InputDecoration(
                        labelText: 'Loại ngày nghỉ',
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 10,
                        ),
                      ),
                      value: _selectedHolidayType,
                      items:
                          _holidayTypes
                              .map(
                                (type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(_holidayTypeLabels[type] ?? type),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedHolidayType = value);
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Action buttons - Responsive Wrap
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment:
                      isSmallScreen
                          ? WrapAlignment.center
                          : WrapAlignment.start,
                  children: [
                    _buildActionButton(
                      icon: Icons.add,
                      label: isSmallScreen ? '' : 'Thêm mới',
                      tooltip: 'Thêm mới ngày nghỉ',
                      onPressed: _themMoi,
                    ),
                    _buildActionButton(
                      icon: Icons.edit,
                      label: isSmallScreen ? '' : 'Sửa',
                      tooltip: 'Sửa ngày nghỉ',
                      onPressed: _sua,
                    ),
                    _buildActionButton(
                      icon: Icons.delete,
                      label: isSmallScreen ? '' : 'Xóa',
                      tooltip: 'Xóa ngày nghỉ',
                      onPressed: _xoa,
                    ),
                    _buildActionButton(
                      icon: Icons.weekend,
                      label: isSmallScreen ? '' : 'Tạo ngày nghỉ cuối tuần',
                      tooltip: 'Tạo ngày nghỉ cuối tuần',
                      onPressed: _createWeekendHolidays,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Responsive layout for calendar and table
              Expanded(
                child:
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : isMediumScreen
                        // Stack layout for small/medium screens
                        ? Column(
                          children: [
                            // Calendar view
                            HolidayMonthCalendar(
                              year: _selectedYear,
                              holidays: _holidaysList,
                              onRefresh: _fetchHolidays,
                            ),
                            const SizedBox(height: 16),
                            // Table view
                            Expanded(child: _buildHolidaysTable()),
                          ],
                        )
                        // Side-by-side layout for large screens
                        : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left: Calendar view
                            Expanded(
                              flex: 3,
                              child: HolidayMonthCalendar(
                                year: _selectedYear,
                                holidays: _holidaysList,
                                onRefresh: _fetchHolidays,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Right: Table view
                            Expanded(flex: 4, child: _buildHolidaysTable()),
                          ],
                        ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Helper to build action buttons
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child:
          label.isEmpty
              // Icon-only button for small screens
              ? ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(8),
                  minimumSize: const Size(40, 40),
                ),
                child: Icon(icon, size: 20),
              )
              // Button with text for larger screens
              : ElevatedButton.icon(
                onPressed: onPressed,
                icon: Icon(icon, size: 18),
                label: Text(label),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
    );
  }
}
