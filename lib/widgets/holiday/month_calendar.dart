// lib/widgets/holidays/holiday_month_calendar.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../models/holiday.dart';
import '../../services/holiday_service.dart';
import 'holiday_add_edit_modal.dart';

class HolidayMonthCalendar extends StatefulWidget {
  final int year;
  final List<Holiday> holidays;
  final Function() onRefresh;

  const HolidayMonthCalendar({
    super.key,
    required this.year,
    required this.holidays,
    required this.onRefresh,
  });

  @override
  _HolidayMonthCalendarState createState() => _HolidayMonthCalendarState();
}

class _HolidayMonthCalendarState extends State<HolidayMonthCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Holiday>> _holidaysByDay = {};

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime(widget.year, 1, 1);
    _processHolidays();
  }

  @override
  void didUpdateWidget(HolidayMonthCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.year != widget.year ||
        oldWidget.holidays != widget.holidays) {
      _processHolidays();
      _focusedDay = DateTime(widget.year, _focusedDay.month, 1);
    }
  }

  // Process holidays to group by date
  void _processHolidays() {
    _holidaysByDay = {};

    for (var holiday in widget.holidays) {
      final holidayDate = DateTime.parse(holiday.holidayDate);

      // Normalize date (set time to midnight)
      final normalizedDate = DateTime(
        holidayDate.year,
        holidayDate.month,
        holidayDate.day,
      );

      if (!_holidaysByDay.containsKey(normalizedDate)) {
        _holidaysByDay[normalizedDate] = [];
      }

      _holidaysByDay[normalizedDate]!.add(holiday);
    }
  }

  // Check if a date has holidays
  bool _hasHoliday(DateTime day) {
    final normalizedDate = DateTime(day.year, day.month, day.day);
    return _holidaysByDay.containsKey(normalizedDate);
  }

  // Show bottom sheet with holiday details
  void _showHolidayDetails(DateTime day) {
    final normalizedDate = DateTime(day.year, day.month, day.day);

    if (!_holidaysByDay.containsKey(normalizedDate)) {
      return;
    }

    final holidays = _holidaysByDay[normalizedDate]!;

    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // This helps to make the sheet take up most of the screen
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.8, // Limit height
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 8, bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    DateFormat(
                      'EEEE, d MMMM yyyy',
                      'vi_VN',
                    ).format(normalizedDate),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: holidays.length,
                    itemBuilder: (context, index) {
                      final holiday = holidays[index];

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      holiday.holidayName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 20),
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.all(8),
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _showEditModal(holiday);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          size: 20,
                                        ),
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.all(8),
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _showDeleteConfirmation(holiday);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildInfoRow(
                                Icons.category,
                                'Loại: ${_getHolidayTypeLabel(holiday.holidayType)}',
                              ),
                              if (holiday.description.isNotEmpty)
                                _buildInfoRow(
                                  Icons.description,
                                  'Mô tả: ${holiday.description}',
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showAddModal(normalizedDate);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Thêm ngày nghỉ mới'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper to build info rows in the bottom sheet
  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(color: Colors.grey[800])),
          ),
        ],
      ),
    );
  }

  // Get human-readable label for holiday type
  String _getHolidayTypeLabel(String type) {
    switch (type) {
      case 'weekend':
        return 'Cuối tuần';
      case 'national':
        return 'Lễ quốc gia';
      case 'school':
        return 'Nghỉ trường';
      default:
        return 'Khác';
    }
  }

  // Show edit modal for holiday
  void _showEditModal(Holiday holiday) {
    showDialog(
      context: context,
      builder: (context) {
        return HolidayAddEditModal(
          existingHoliday: holiday,
          onSave: widget.onRefresh,
        );
      },
    );
  }

  // Show delete confirmation for holiday
  void _showDeleteConfirmation(Holiday holiday) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Text(
            'Bạn có chắc chắn muốn xóa ngày nghỉ "${holiday.holidayName}" không?',
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

                if (holiday.id == null) return;

                try {
                  await HolidayService.deleteHoliday(holiday.id!);
                  widget.onRefresh();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã xóa ngày nghỉ thành công'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Lỗi: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  // Show add modal for a specific date
  void _showAddModal(DateTime date) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);

    final newHoliday = Holiday(
      holidayDate: formattedDate,
      holidayName: '',
      holidayType: 'school', // Default type
    );

    showDialog(
      context: context,
      builder: (context) {
        return HolidayAddEditModal(
          existingHoliday: newHoliday,
          onSave: widget.onRefresh,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Adjust calendar based on screen size
        final isSmallScreen = constraints.maxWidth < 400;

        return Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Responsive header for calendar
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  child:
                      isSmallScreen
                          ? Column(
                            children: [
                              Text(
                                DateFormat(
                                  'MMMM yyyy',
                                  'vi_VN',
                                ).format(_focusedDay),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.chevron_left),
                                    onPressed: () {
                                      setState(() {
                                        _focusedDay = DateTime(
                                          _focusedDay.year,
                                          _focusedDay.month - 1,
                                          1,
                                        );
                                      });
                                    },
                                  ),
                                  Text(
                                    'Thay đổi tháng',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.chevron_right),
                                    onPressed: () {
                                      setState(() {
                                        _focusedDay = DateTime(
                                          _focusedDay.year,
                                          _focusedDay.month + 1,
                                          1,
                                        );
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left),
                                onPressed: () {
                                  setState(() {
                                    _focusedDay = DateTime(
                                      _focusedDay.year,
                                      _focusedDay.month - 1,
                                      1,
                                    );
                                  });
                                },
                              ),
                              Text(
                                DateFormat(
                                  'MMMM yyyy',
                                  'vi_VN',
                                ).format(_focusedDay),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.chevron_right),
                                onPressed: () {
                                  setState(() {
                                    _focusedDay = DateTime(
                                      _focusedDay.year,
                                      _focusedDay.month + 1,
                                      1,
                                    );
                                  });
                                },
                              ),
                            ],
                          ),
                ),
                // Use table_calendar but with responsive sizing
                TableCalendar(
                  firstDay: DateTime(widget.year - 2, 1, 1),
                  lastDay: DateTime(widget.year + 2, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: CalendarFormat.month,
                  availableCalendarFormats: const {
                    CalendarFormat.month: 'Tháng',
                  },
                  headerVisible: false, // Use our custom header
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  daysOfWeekHeight: isSmallScreen ? 20 : 24,
                  rowHeight: isSmallScreen ? 40 : 52,
                  // Calendar style
                  calendarStyle: CalendarStyle(
                    // Mark holiday days with different color
                    markerDecoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    markersMaxCount: 1,
                    // Highlight weekends with light red color
                    weekendTextStyle: const TextStyle(color: Colors.red),
                    weekendDecoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    // Handle small screens with smaller text
                    defaultTextStyle: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                    // weekendTextStyle: TextStyle(
                    //   fontSize: isSmallScreen ? 12 : 14,
                    //   color: Colors.red,
                    // ),
                    outsideTextStyle: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: Colors.grey,
                    ),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                      fontSize: isSmallScreen ? 12 : 13,
                      fontWeight: FontWeight.bold,
                    ),
                    weekendStyle: TextStyle(
                      fontSize: isSmallScreen ? 12 : 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  // Callbacks
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });

                    // Show holiday details if day has holidays
                    if (_hasHoliday(selectedDay)) {
                      _showHolidayDetails(selectedDay);
                    } else {
                      // Show add holiday dialog for the selected day
                      _showAddModal(selectedDay);
                    }
                  },
                  onPageChanged: (focusedDay) {
                    setState(() {
                      _focusedDay = focusedDay;
                    });
                  },
                  // Use markers to indicate holidays
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      if (_hasHoliday(date)) {
                        return Positioned(
                          right: 1,
                          bottom: 1,
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                            ),
                            width: 8,
                            height: 8,
                          ),
                        );
                      }
                      return null;
                    },
                    // Highlight holiday cells
                    defaultBuilder: (context, day, focusedDay) {
                      if (_hasHoliday(day)) {
                        return Container(
                          margin: const EdgeInsets.all(4.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Text(
                            day.day.toString(),
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: isSmallScreen ? 12 : 14,
                            ),
                          ),
                        );
                      }
                      return null;
                    },
                  ),
                ),
                // Add legend for holidays
                Padding(
                  padding: const EdgeInsets.only(
                    top: 8.0,
                    left: 16.0,
                    right: 16.0,
                  ),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _buildLegendItem(
                        'Ngày nghỉ',
                        Colors.red.withOpacity(0.2),
                      ),
                      _buildLegendItem(
                        'Cuối tuần',
                        Colors.red.withOpacity(0.1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper to build legend items
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
      ],
    );
  }
}
