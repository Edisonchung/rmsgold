// lib/screens/registration_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _icController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  int _currentStep = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _icController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.amber.shade700,
        foregroundColor: Colors.white,
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepTapped: (step) {
          setState(() {
            _currentStep = step;
          });
        },
        controlsBuilder: (context, details) {
          final isLast = _currentStep == 3; // Manually check if it's the last step
          return Row(
            children: [
              if (details.stepIndex > 0)
                TextButton(
                  onPressed: details.onStepCancel,
                  child: const Text('Back'),
                ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: details.onStepContinue,
                child: Text(isLast ? 'Register' : 'Next'),
              ),
            ],
          );
        },
        steps: [
          Step(
            title: const Text('Personal Information'),
            content: _buildPersonalInfoForm(),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text('Contact & Address'),
            content: _buildContactForm(),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: const Text('Account Security'),
            content: _buildSecurityForm(),
            isActive: _currentStep >= 2,
          ),
          Step(
            title: const Text('Terms & Conditions'),
            content: _buildTermsForm(),
            isActive: _currentStep >= 3,
          ),
        ],
        onStepContinue: () {
          if (_currentStep < 3) {
            if (_validateCurrentStep()) {
              setState(() {
                _currentStep++;
              });
            }
          } else {
            _handleRegistration();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep--;
            });
          }
        },
      ),
    );
  }

  Widget _buildPersonalInfoForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter your full name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _icController,
            decoration: const InputDecoration(
              labelText: 'IC Number',
              prefixIcon: Icon(Icons.credit_card),
              border: OutlineInputBorder(),
              hintText: '123456-12-1234',
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter your IC number';
              }
              if (!RegExp(r'^\d{6}-\d{2}-\d{4}$').hasMatch(value!)) {
                return 'Please enter a valid IC number (123456-12-1234)';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactForm() {
    return Column(
      children: [
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email Address',
            prefixIcon: Icon(Icons.email),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            prefixIcon: Icon(Icons.phone),
            border: OutlineInputBorder(),
            hintText: '+60123456789',
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter your phone number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _addressController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Address',
            prefixIcon: Icon(Icons.location_on),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter your address';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSecurityForm() {
    return Column(
      children: [
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter a password';
            }
            if (value!.length < 8) {
              return 'Password must be at least 8 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please confirm your password';
            }
            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            border: Border.all(color: Colors.blue.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Password Requirements:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '• At least 8 characters long',
                style: TextStyle(color: Colors.blue.shade700, fontSize: 12),
              ),
              Text(
                '• Include uppercase and lowercase letters',
                style: TextStyle(color: Colors.blue.shade700, fontSize: 12),
              ),
              Text(
                '• Include at least one number',
                style: TextStyle(color: Colors.blue.shade700, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTermsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const SingleChildScrollView(
            child: Text(
              '''Terms and Conditions for RMS Gold Account-i

1. ACCOUNT REGISTRATION
- You must be at least 18 years old to register
- All information provided must be accurate and complete
- KYC verification is required for account activation

2. GOLD TRADING
- Minimum purchase amount: RM 10.00
- T+0 settlement for all transactions
- Gold prices are subject to market fluctuations
- Transaction fees apply as stated in our fee schedule

3. SECURITY & PRIVACY
- You are responsible for maintaining account security
- We employ bank-grade security measures
- Personal data is protected under PDPA

4. RISKS
- Gold prices can fluctuate significantly
- Past performance does not guarantee future returns
- You may lose money in gold investments

5. COMPLIANCE
- All transactions are monitored for compliance
- Suspicious activities will be reported to authorities
- Account may be suspended for non-compliance

By registering, you acknowledge that you have read, understood, and agree to be bound by these terms and conditions.''',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        CheckboxListTile(
          value: _agreeToTerms,
          onChanged: (value) {
            setState(() {
              _agreeToTerms = value ?? false;
            });
          },
          title: const Text(
            'I have read and agree to the Terms and Conditions',
            style: TextStyle(fontSize: 14),
          ),
          controlAffinity: ListTileControlAffinity.leading,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            border: Border.all(color: Colors.orange.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'After registration, you will need to complete KYC verification by uploading your IC and a selfie photo.',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _nameController.text.isNotEmpty && 
               _icController.text.isNotEmpty &&
               RegExp(r'^\d{6}-\d{2}-\d{4}$').hasMatch(_icController.text);
      case 1:
        return _emailController.text.isNotEmpty &&
               _phoneController.text.isNotEmpty &&
               _addressController.text.isNotEmpty &&
               RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text);
      case 2:
        return _passwordController.text.isNotEmpty &&
               _confirmPasswordController.text.isNotEmpty &&
               _passwordController.text == _confirmPasswordController.text &&
               _passwordController.text.length >= 8;
      case 3:
        return _agreeToTerms;
      default:
        return false;
    }
  }

  void _handleRegistration() {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the terms and conditions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Creating your account...'),
          ],
        ),
      ),
    );

    // Simulate registration process
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context); // Close loading dialog
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          icon: Icon(
            Icons.check_circle,
            color: Colors.green.shade600,
            size: 64,
          ),
          title: const Text('Registration Successful!'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your account has been created successfully.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Please check your email for verification instructions and complete your KYC to start trading.',
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close success dialog
                Navigator.pop(context); // Go back to login
              },
              child: const Text('Continue to Login'),
            ),
          ],
        ),
      );
    });
  }
}
