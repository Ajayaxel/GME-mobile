import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gme/core/theme/app_theme.dart';
import 'package:gme/core/widgets/app_button.dart';
import 'package:gme/core/widgets/custom_toast.dart';
import 'package:gme/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gme/features/auth/presentation/bloc/auth_event.dart';
import 'package:gme/features/auth/presentation/bloc/auth_state.dart';
import 'package:gme/core/services/injection_container.dart';
import '../../../home/home_screen.dart';
import 'package:gme/core/utils/responsive_helper.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AuthBloc>(),
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            (current is AuthSuccess) || (current is AuthFailureState),
        listener: (context, state) {
          if (state is AuthSuccess) {
            CustomToast.show(context: context, message: state.response.message);

            // Navigate to Home Screen and remove Login from stack
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
            );
          } else if (state is AuthFailureState) {
            CustomToast.show(
              context: context,
              message: state.message,
              isError: true,
            );
          }
        },
        child: Scaffold(
          backgroundColor: AppTheme.bgColor,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Center(
                    child: Image.asset(
                      "assets/images/logo/gme.png",
                      height: 140,
                      width: 300,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 40),
                  const FormSection(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FormSection extends StatelessWidget {
  const FormSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: Responsive.horizontalPadding(context),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Please login to your account.",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 30),
          _buildTextField(
            context: context,
            hintText: "Email Address",
            icon: Icons.email_outlined,
            onChanged: (value) =>
                context.read<AuthBloc>().add(EmailChanged(value)),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            context: context,
            hintText: "Password",
            icon: Icons.lock_outline,
            isPassword: true,
            onChanged: (value) =>
                context.read<AuthBloc>().add(PasswordChanged(value)),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "Forgot Password?",
              style: TextStyle(
                fontSize: 14,
                color: Colors.black.withOpacity(0.6),
              ),
            ),
          ),
          const SizedBox(height: 30),
          BlocBuilder<AuthBloc, AuthState>(
            buildWhen: (previous, current) =>
                previous.runtimeType != current.runtimeType,
            builder: (context, state) {
              return AppButton(
                text: state is AuthLoading ? "LOGGING IN..." : "LOGIN",
                onPressed: state is AuthLoading
                    ? null
                    : () =>
                          context.read<AuthBloc>().add(const LoginRequested()),
              );
            },
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.withOpacity(0.3))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  "or",
                  style: TextStyle(color: Colors.grey.withOpacity(0.8)),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey.withOpacity(0.3))),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required String hintText,
    required IconData icon,
    required Function(String) onChanged,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.fieldColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        onChanged: onChanged,
        obscureText: isPassword,
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon, 
            color: Colors.black54, 
            size: Responsive.iconSize(context, base: 22),
          ),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black38, fontSize: 16),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
