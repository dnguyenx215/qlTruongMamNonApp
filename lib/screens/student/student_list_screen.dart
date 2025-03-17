// lib/screens/student/student_list_screen.dart
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:example_app/widgets/student/student_change_class_dialog.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/student.dart';
import '../../services/student_service.dart';
import '../../utils/constants.dart';
import '../../widgets/ManagementLayout.dart';
import '../../widgets/student/student_filter_widget.dart';
import '../../widgets/student/student_table.dart';
import '../../widgets/student/student_form_dialog.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({Key? key}) : super(key: key);

  @override
  _StudentListScreenState createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  // Thông tin người dùng
  String _userName = '';
  String _userRole = '';

  // Trạng thái dữ liệu
  bool _isLoading = false;
  List<Student> _studentList = [];
  List<Map<String, dynamic>> _classList = [];

  // Trạng thái filter
  String _searchKeyword = '';
  GenderFilter _selectedGender = GenderFilter.all;
  YearFilter _selectedYear = YearFilter.y2023_2024;
  int? _selectedClassId;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _fetchInitialData();
  }

  // Lấy thông tin người dùng
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

  // Lấy dữ liệu ban đầu
  Future<void> _fetchInitialData() async {
    setState(() => _isLoading = true);

    try {
      // Gọi đồng thời các API để tối ưu thời gian
      final studentsData = StudentService.fetchStudents();
      final classesData = StudentService.fetchClasses();

      final students = await studentsData;
      final classes = await classesData;

      setState(() {
        _studentList = students;
        _classList = classes;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error when loading initial data: $e');

      // Hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi tải dữ liệu: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );

      setState(() => _isLoading = false);
    }
  }

  // Lọc danh sách học sinh theo filter
  List<Student> get _filteredStudents {
    return _studentList.where((student) {
      // Lọc theo từ khóa tìm kiếm (tên hoặc mã học sinh)
      final fullName = student.fullName.toLowerCase();
      final studentCode = (student.studentCode ?? '').toLowerCase();
      final keywordMatch =
          _searchKeyword.isEmpty ||
          fullName.contains(_searchKeyword.toLowerCase()) ||
          studentCode.contains(_searchKeyword.toLowerCase());

      // Lọc theo giới tính
      final genderValue = getGenderFilterValue(_selectedGender);
      final genderMatch = genderValue == null || student.gender == genderValue;

      // Lọc theo lớp
      final classMatch =
          _selectedClassId == null || student.classId == _selectedClassId;

      // Áp dụng tất cả bộ lọc
      return keywordMatch && genderMatch && classMatch;
    }).toList();
  }

  // Xử lý khi chọn (checkbox) một học sinh
  void _handleStudentChecked(Student student, bool checked) {
    setState(() {
      final index = _studentList.indexWhere((s) => s.id == student.id);
      if (index != -1) {
        _studentList[index] = _studentList[index].copyWith(checked: checked);
      }
    });
  }

  // Các hàm xử lý chức năng
  void _showAddStudentDialog() {
    showDialog(
      context: context,
      builder:
          (context) =>
              StudentFormDialog(classes: _classList, onSave: _addStudent),
    );
  }

  void _showEditStudentDialog() {
    final selectedStudents = _studentList.where((s) => s.checked).toList();

    if (selectedStudents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn một học sinh để sửa'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (selectedStudents.length > 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chỉ chọn một học sinh để sửa'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => StudentFormDialog(
            student: selectedStudents.first,
            classes: _classList,
            onSave: _updateStudent,
          ),
    );
  }

  void _showChangeClassDialog() {
    final selectedStudents = _studentList.where((s) => s.checked).toList();

    if (selectedStudents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất một học sinh để chuyển lớp'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => ChangeClassDialog(
            selectedStudents: selectedStudents,
            classes: _classList,
            onChangeClass: _changeStudentClass,
          ),
    );
  }

  void _confirmDeleteStudents() {
    final selectedStudents = _studentList.where((s) => s.checked).toList();

    if (selectedStudents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất một học sinh để xóa'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: Text(
              'Bạn có chắc chắn muốn xóa ${selectedStudents.length} học sinh đã chọn không?\n'
              'Hành động này không thể hoàn tác.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _deleteStudents(selectedStudents);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Xóa'),
              ),
            ],
          ),
    );
  }

  Future<void> _exportReport(String format) async {
    try {
      setState(() => _isLoading = true);

      // Lấy danh sách học sinh hiện tại (đã lọc)
      final students = _filteredStudents;

      // Hiển thị Snackbar để thông báo đang xuất báo cáo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đang xuất báo cáo dạng $format...'),
          duration: const Duration(seconds: 2),
        ),
      );

      if (format.toLowerCase() == 'pdf') {
        // Xuất báo cáo PDF
        await _exportToPdf(students);
      } else if (format.toLowerCase() == 'excel') {
        // Xuất báo cáo Excel
        await _exportToExcel(students);
      }

      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Xuất báo cáo $format thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Lỗi khi xuất báo cáo: $e');

      // Hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi xuất báo cáo: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Hàm chuyển đổi chữ có dấu thành không dấu

  String _removeAccents(String input) {
    const _vietnameseAccentMap = vietnameseAccentMap;

    return input.replaceAllMapped(
      RegExp(r'[^\x00-\x7F]'),
      (match) => _vietnameseAccentMap[match.group(0)] ?? match.group(0)!,
    );
  }

  Future<void> _exportToPdf(List<Student> students) async {
    try {
      // Tạo đối tượng PDF
      final pdf = pw.Document();

      // Tạo font cho tiếng Việt
      pw.Font? ttf;
      try {
        final fontData = await rootBundle.load(
          "assets/fonts/Roboto-Regular.ttf", // Kiểm tra đúng đường dẫn font
        );
        ttf = pw.Font.ttf(fontData);
      } catch (e) {
        debugPrint('Lỗi tải font: $e');
        // Nếu không tải được font, sử dụng font mặc định và loại bỏ dấu
        ttf = null;
      }

      // Thêm trang
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          orientation: pw.PageOrientation.landscape,
          build: (pw.Context context) {
            return [
              // Tiêu đề báo cáo
              pw.Header(
                level: 0,
                child: pw.Text(
                  ttf != null
                      ? 'DANH SÁCH HỌC SINH'
                      : _removeAccents('DANH SÁCH HỌC SINH'),
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),

              // Thông tin báo cáo
              pw.Paragraph(
                text:
                    ttf != null
                        ? 'Ngày xuất báo cáo: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'
                        : _removeAccents(
                          'Ngày xuất báo cáo: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                        ),
                style: pw.TextStyle(font: ttf),
              ),
              pw.Paragraph(
                text:
                    ttf != null
                        ? 'Tổng số học sinh: ${students.length}'
                        : _removeAccents(
                          'Tổng số học sinh: ${students.length}',
                        ),
                style: pw.TextStyle(font: ttf),
              ),

              pw.SizedBox(height: 10),

              // Bảng danh sách học sinh
              pw.Table.fromTextArray(
                headerStyle: pw.TextStyle(
                  font: ttf,
                  fontWeight: pw.FontWeight.bold,
                ),
                cellStyle: pw.TextStyle(font: ttf),
                headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
                headers:
                    ttf != null
                        ? [
                          'STT',
                          'Họ và tên',
                          'Mã HS',
                          'Giới tính',
                          'Ngày sinh',
                          'Lớp',
                          'Địa chỉ',
                        ]
                        : [
                          'STT',
                          _removeAccents('Ho va ten'),
                          'Ma HS',
                          _removeAccents('Gioi tinh'),
                          _removeAccents('Ngay sinh'),
                          'Lop',
                          _removeAccents('Dia chi'),
                        ],
                data:
                    students.asMap().entries.map((entry) {
                      final index = entry.key;
                      final student = entry.value;

                      // Hàm chuyển đổi text
                      String processText(String? text) {
                        if (text == null) return '';
                        return ttf != null ? text : _removeAccents(text);
                      }

                      return [
                        (index + 1).toString(),
                        processText(student.fullName),
                        processText(student.studentCode),
                        processText(student.genderText),
                        processText(student.birthday),
                        processText(
                          student.classId?.toString() ?? 'Chua phan lop',
                        ),
                        processText(student.address),
                      ];
                    }).toList(),
              ),
            ];
          },
        ),
      );

      // Lưu tệp PDF
      if (kIsWeb) {
        // Xử lý cho web
        final bytes = await pdf.save();
        final blob = html.Blob([bytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor =
            html.AnchorElement(href: url)
              ..setAttribute('download', 'danh_sach_hoc_sinh.pdf')
              ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        // Xử lý cho mobile/desktop
        if (Platform.isAndroid || Platform.isIOS) {
          // Kiểm tra quyền
          final status = await Permission.storage.request();
          if (!status.isGranted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cần quyền truy cập bộ nhớ để lưu file'),
                backgroundColor: Colors.orange,
              ),
            );
            return;
          }
        }

        final output = await getTemporaryDirectory();
        final file = File('${output.path}/danh_sach_hoc_sinh.pdf');
        await file.writeAsBytes(await pdf.save());

        // Mở tệp PDF
        await OpenFile.open(file.path);
      }
    } catch (e) {
      debugPrint('Lỗi xuất PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi xuất PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _exportToExcel(List<Student> students) async {
    // Tạo đối tượng Excel
    final excel = Excel.createExcel();

    // Tạo sheet
    final sheet = excel['Danh sách học sinh'];

    // Thiết lập tiêu đề
    final headers = [
      'STT',
      'Họ và tên',
      'Mã HS',
      'Giới tính',
      'Ngày sinh',
      'Lớp',
      'Địa chỉ',
    ];
    for (var i = 0; i < headers.length; i++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          .value = headers[i];
      // Style cho tiêu đề
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          .cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: '#CCCCCC',
        horizontalAlign: HorizontalAlign.Center,
      );
    }

    // Thêm dữ liệu
    for (var i = 0; i < students.length; i++) {
      final student = students[i];
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
          .value = i + 1;
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1))
          .value = student.fullName;
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1))
          .value = student.studentCode ?? '';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1))
          .value = student.genderText;
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1))
          .value = student.birthday ?? '';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 1))
          .value = student.classId?.toString() ?? 'Chưa phân lớp';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: i + 1))
          .value = student.address ?? '';
    }

    // Tự động điều chỉnh chiều rộng cột
    for (var i = 0; i < headers.length; i++) {
      sheet.setColWidth(i, 15);
    }

    // Kiểm tra nền tảng trước khi lưu
    if (kIsWeb) {
      // Xử lý đặc biệt cho web
      // Ví dụ: sử dụng html để tải xuống file
      final bytes = excel.encode();
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor =
          html.AnchorElement(href: url)
            ..setAttribute('download', 'danh_sach_hoc_sinh.xlsx')
            ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      // Xử lý cho mobile
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/danh_sach_hoc_sinh.xlsx');
      await file.writeAsBytes(excel.encode()!);
      OpenFile.open(file.path);
    }
  }

  // Xử lý các API calls
  Future<void> _addStudent(Student student) async {
    setState(() => _isLoading = true);

    try {
      final addedStudent = await StudentService.addStudent(student);

      setState(() {
        _studentList.add(addedStudent);
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thêm học sinh thành công'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateStudent(Student student) async {
    setState(() => _isLoading = true);

    try {
      final updatedStudent = await StudentService.updateStudent(student);

      setState(() {
        final index = _studentList.indexWhere((s) => s.id == student.id);
        if (index != -1) {
          _studentList[index] = updatedStudent;
        }
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật học sinh thành công'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _changeStudentClass(List<Student> students, int classId) async {
    setState(() => _isLoading = true);

    try {
      // Danh sách các Promise chuyển lớp
      final List<Future> assignClassPromises = [];

      // Tạo các Promise chuyển lớp
      for (var student in students) {
        assignClassPromises.add(
          StudentService.assignClass(student.id!, classId),
        );
      }

      // Đợi tất cả các Promise hoàn thành
      await Future.wait(assignClassPromises);

      // Cập nhật UI
      setState(() {
        for (var student in students) {
          final index = _studentList.indexWhere((s) => s.id == student.id);
          if (index != -1) {
            _studentList[index] = _studentList[index].copyWith(
              classId: classId,
              checked: false,
            );
          }
        }
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Chuyển lớp ${students.length} học sinh thành công'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteStudents(List<Student> students) async {
    setState(() => _isLoading = true);

    try {
      // Danh sách các Promise xóa học sinh
      final List<Future> deletePromises = [];

      // Danh sách ID học sinh sẽ xóa
      final List<int> deletedIds = [];

      // Tạo các Promise xóa học sinh
      for (var student in students) {
        if (student.id != null) {
          deletePromises.add(StudentService.deleteStudent(student.id!));
          deletedIds.add(student.id!);
        }
      }

      // Đợi tất cả các Promise hoàn thành
      await Future.wait(deletePromises);

      // Cập nhật UI
      setState(() {
        _studentList.removeWhere(
          (student) => student.id != null && deletedIds.contains(student.id),
        );
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xóa ${students.length} học sinh'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ManagementLayout(
      selectedRoute: '/students',
      userName: _userName,
      userRole: _userRole,
      title: 'Quản lý học sinh',
      onRouteSelected: (route) => Navigator.pushNamed(context, route),
      mainContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề trang
          const Text(
            'DANH SÁCH HỌC SINH',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Filter Widget
          StudentFilterWidget(
            searchKeyword: _searchKeyword,
            onSearchChanged: (value) => setState(() => _searchKeyword = value),
            selectedGender: _selectedGender,
            onGenderFilterChanged:
                (value) => setState(() => _selectedGender = value),
            selectedYear: _selectedYear,
            onYearFilterChanged:
                (value) => setState(() => _selectedYear = value),
            selectedClassId: _selectedClassId,
            onClassFilterChanged:
                (value) => setState(() => _selectedClassId = value),
            classes: _classList,
          ),
          const SizedBox(height: 16),

          // Action Buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: _showAddStudentDialog,
                icon: const Icon(Icons.add),
                label: const Text('Thêm mới'),
              ),
              ElevatedButton.icon(
                onPressed: _showEditStudentDialog,
                icon: const Icon(Icons.edit),
                label: const Text('Sửa'),
              ),
              ElevatedButton.icon(
                onPressed: _showChangeClassDialog,
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Chuyển lớp'),
              ),
              ElevatedButton.icon(
                onPressed: _confirmDeleteStudents,
                icon: const Icon(Icons.delete),
                label: const Text('Xóa'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _exportReport('PDF'),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Xuất PDF'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              ),
              ElevatedButton.icon(
                onPressed: () => _exportReport('Excel'),
                icon: const Icon(Icons.table_chart),
                label: const Text('Xuất Excel'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Table
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : StudentTable(
                      students: _filteredStudents,
                      onStudentChecked: _handleStudentChecked,
                      onRefresh: _fetchInitialData,
                    ),
          ),

          // Summary
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tổng số: ${_filteredStudents.length} học sinh',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Đã chọn: ${_studentList.where((s) => s.checked).length} học sinh',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
