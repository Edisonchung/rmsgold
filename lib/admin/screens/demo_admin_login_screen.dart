// lib/admin/screens/demo_admin_login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/demo_admin_auth_provider.dart';

class DemoAdminLoginScreen extends StatefulWidget {
  @override
  _DemoAdminLoginScreenState createState() => _DemoAdminLoginScreenState();
}

class _DemoAdminLoginScreenState extends State<DemoAdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1B4332),
              Color(0xFF2D5A47),
            ],
          ),
        ),
        child: Center(
          child: Card(
            margin: EdgeInsets.all(32),
            elevation: 8,
            child: Container(
              width: 400,
              padding: EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Color(0xFF1B4332),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.admin_panel_settings,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 24),
                    
                    Text(
                      'RMS Gold Admin Portal',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B4332),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Administrator Access',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 32),
                    
                    // Demo Credentials Box
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        border: Border.all(color: Colors.blue),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Demo Credentials:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Super Admin: super@rmsgold.com / super123456',
                            style: TextStyle(fontSize: 12),
                          ),
                          Text(
                            'Admin: admin@rmsgold.com / admin123456',
                            style: TextStyle(fontSize: 12),
                          ),
                          Text(
                            'KYC Officer: kyc@rmsgold.com / kyc123456',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    
                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    
                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),
                    
                    // Error Message
                    Consumer<DemoAdminAuthProvider>(
                      builder: (context, auth, _) {
                        if (auth.hasError) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 16),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              border: Border.all(color: Colors.red),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              auth.errorMessage!,
                              style: TextStyle(color: Colors.red),
                            ),
                          );
                        }
                        return Container();
                      },
                    ),
                    
                    // Login Button
                    Consumer<DemoAdminAuthProvider>(
                      builder: (context, auth, _) {
                        return SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: auth.isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF1B4332),
                            ),
                            child: auth.isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    'Login to Admin Portal',
                                    style: TextStyle(fontSize: 16),
                                  ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 16),
                    
                    // Quick Login Buttons
                    Text('Quick Login:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _quickLogin('super@rmsgold.com', 'super123456'),
                            child: Text('Super Admin', style: TextStyle(fontSize: 10)),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _quickLogin('admin@rmsgold.com', 'admin123456'),
                            child: Text('Admin', style: TextStyle(fontSize: 10)),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _quickLogin('kyc@rmsgold.com', 'kyc123456'),
                            child: Text('KYC Officer', style: TextStyle(fontSize: 10)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<DemoAdminAuthProvider>().login(
        _emailController.text,
        _passwordController.text,
      );
    }
  }
  
  void _quickLogin(String email, String password) {
    _emailController.text = email;
    _passwordController.text = password;
    context.read<DemoAdminAuthProvider>().login(email, password);
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
