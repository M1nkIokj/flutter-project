import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_event.dart';
import '../../bloc/auth_state.dart';
import '../../widgets/auth_text_field.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _formKey.currentState?.reset();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        key: const Key('signup_appbar'),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is Authenticated) {
            // Check if user has token (email confirmed) or not (email confirmation required)
            if (state.user.token != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account created successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              // Navigate to login page after successful signup
              Future.delayed(const Duration(seconds: 2), () {
                Navigator.pop(context);
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Account created successfully! Please check your email to confirm your account.'),
                  backgroundColor: Colors.orange,
                ),
              );
              // Navigate to login page to wait for email confirmation
              Future.delayed(const Duration(seconds: 2), () {
                Navigator.pop(context);
              });
            }
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
                left: 16.0,
                right: 16.0,
                top: 16.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 60),
                    const Icon(
                      Icons.person_add,
                      size: 100,
                      color: Colors.blue,
                      key: Key('signup_icon'),
                    ),
                    const SizedBox(height: 32),
                    AuthTextField(
                      key: const Key('signup_name_field'),
                      controller: _nameController,
                      label: 'Name',
                      textCapitalization: TextCapitalization.words,
                      onChanged: () {
                        // Clear error for this specific field when user types
                        if (_nameController.text.isNotEmpty) {
                          _formKey.currentState?.validate();
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      key: const Key('signup_email_field'),
                      controller: _emailController,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      onChanged: () {
                        // Clear error for this specific field when user types
                        if (_emailController.text.isNotEmpty) {
                          _formKey.currentState?.validate();
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      key: const Key('signup_password_field'),
                      controller: _passwordController,
                      label: 'Password',
                      obscureText: !_isPasswordVisible,
                      onChanged: () {
                        // Clear error for this specific field when user types
                        if (_passwordController.text.isNotEmpty) {
                          _formKey.currentState?.validate();
                        }
                      },
                      suffixIcon: IconButton(
                        key: const Key('signup_password_visibility_toggle'),
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      key: const Key('signup_confirm_password_field'),
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      obscureText: !_isConfirmPasswordVisible,
                      onChanged: () {
                        // Clear error for this specific field when user types
                        if (_confirmPasswordController.text.isNotEmpty) {
                          _formKey.currentState?.validate();
                        }
                      },
                      suffixIcon: IconButton(
                        key: const Key(
                            'signup_confirm_password_visibility_toggle'),
                        icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    state is AuthLoading
                        ? const Center(
                            key: Key('signup_loading_indicator'),
                            child: CircularProgressIndicator())
                        : ElevatedButton(
                            key: const Key('signup_submit_button'),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                context.read<AuthBloc>().add(
                                      SignUpRequested(
                                        email: _emailController.text,
                                        password: _passwordController.text,
                                        name: _nameController.text,
                                      ),
                                    );
                              }
                            },
                            child: const Text('Sign Up'),
                          ),
                    const SizedBox(height: 16),
                    TextButton(
                      key: const Key('signup_login_button'),
                      onPressed: () {
                        _clearForm();
                        Navigator.pop(context);
                      },
                      child: const Text('Already have an account? Login'),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
