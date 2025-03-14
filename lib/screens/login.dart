import 'package:example_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'home.dart';

class LoginScreen extends StatefulWidget {
  // Chuyển sang StatefulWidget
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers để lấy giá trị từ TextField
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Service xử lý đăng nhập
  final AuthService _authService = AuthService();

  // Biến để hiển thị trạng thái đăng nhập
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Hàm xử lý đăng nhập
  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final user = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (user != null) {
        // Đăng nhập thành công, chuyển hướng đến màn hình chính
        // ignore: use_build_context_synchronously
        // Navigator.pushReplacementNamed(
        //   context,
        //   '/home',
        // );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        setState(() {
          _errorMessage = 'Sai tài khoản hoặc mật khẩu';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Lỗi kết nối: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50], // Màu nền tương tự "bg-blue-50"
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            // Giới hạn độ rộng tối đa ~1024px
            constraints: const BoxConstraints(maxWidth: 1024),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white, // Nền trắng tương tự "bg-white"
              borderRadius: BorderRadius.circular(12), // "rounded-lg"
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(50), // "shadow-lg"
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            // Responsive: nếu rộng > 600px thì dùng Row, ngược lại dùng Column
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  // Màn hình rộng -> Row
                  return Row(
                    children: [
                      // Bên trái: hiển thị logo + ảnh
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Logo
                              Image.asset(
                                'lib/assets/logo.png',
                                width: 100,
                                height: 100,
                              ),
                              const SizedBox(height: 16),
                              // Hình các bé
                              Image.asset(
                                'lib/assets/kids.png',
                                width: 400,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Bên phải: form đăng nhập
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue[100], // Tương tự "bg-blue-100"
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          padding: const EdgeInsets.all(24),
                          child: _buildLoginForm(context),
                        ),
                      ),
                    ],
                  );
                } else {
                  // Màn hình hẹp -> Column
                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.white,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'lib/assets/logo.png',
                              width: 100,
                              height: 100,
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: _buildLoginForm(context),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Tách riêng phần form đăng nhập để dễ quản lý
  Widget _buildLoginForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tiêu đề "Đăng nhập"
        Text(
          'Đăng nhập'.toUpperCase(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue[900],
          ),
        ),
        const SizedBox(height: 24),

        // Nhãn "Tài khoản"
        const Text(
          'Tài khoản',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController, // Gán controller
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        const SizedBox(height: 16),

        // Nhãn "Mật khẩu"
        const Text(
          'Mật khẩu',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController, // Gán controller
          obscureText: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        const SizedBox(height: 16),

        // Link "Quên mật khẩu?"
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              // TODO: xử lý quên mật khẩu
            },
            child: const Text(
              'Quên mật khẩu?',
              style: TextStyle(
                color: Color.fromARGB(255, 14, 86, 158),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Hiển thị thông báo lỗi nếu có
        if (_errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),

        // Nút "Đăng nhập"
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                _isLoading
                    ? null
                    : _handleLogin, // Disable button khi đang loading
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child:
                _isLoading
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : const Text(
                      'Đăng nhập',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
          ),
        ),
      ],
    );
  }
}
