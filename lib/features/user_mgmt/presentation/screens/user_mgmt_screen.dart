import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/services/injection_container.dart';
import '../../domain/models/user_model.dart';
import '../bloc/users_bloc.dart';
import '../bloc/users_event.dart';
import '../bloc/users_state.dart';

class UserMgmtScreen extends StatefulWidget {
  const UserMgmtScreen({super.key});

  @override
  State<UserMgmtScreen> createState() => _UserMgmtScreenState();
}

class _UserMgmtScreenState extends State<UserMgmtScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<UsersBloc>()..add(FetchUsers()),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocListener<UsersBloc, UsersState>(
          listener: (context, state) {
            if (state is UserActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.green),
              );
            } else if (state is UsersError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent),
              );
            }
          },
          child: BlocBuilder<UsersBloc, UsersState>(
            builder: (context, state) {
              if (state is UsersLoading) {
                return const Center(child: CircularProgressIndicator(color: Colors.white70));
              }

              List<UserModel> users = [];
              if (state is UsersLoaded) {
                users = state.users;
              }

              final filteredUsers = users.where((u) => 
                u.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                u.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                u.role.toLowerCase().contains(_searchQuery.toLowerCase())
              ).toList();

              return Column(
                children: [
                  _buildHeader(context, users),
                  _buildSearchBar(),
                  Expanded(
                    child: filteredUsers.isEmpty && state is UsersLoaded
                        ? _buildEmptyState()
                        : _buildUserList(context, filteredUsers),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, List<UserModel> users) {
    final activeCount = users.where((u) => u.status == 'Active').length;
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          _buildStatCard("TOTAL USERS", users.length.toString(), Icons.people_outline, const Color(0xFF6366F1)),
          const SizedBox(width: 16),
          _buildStatCard("ACTIVE", activeCount.toString(), Icons.check_circle_outline, const Color(0xFF10B981)),
          const SizedBox(width: 16),
          _buildActionCard(context),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _showAddUserModal(context),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.btnColor, AppTheme.btnColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: AppTheme.btnColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
            ],
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_add_outlined, color: Colors.white, size: 28),
              SizedBox(height: 8),
              Text("ADD USER", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search by name, email or role...",
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
          prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.3)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          contentPadding: const EdgeInsets.all(18),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: AppTheme.btnColor.withOpacity(0.5))),
        ),
      ),
    );
  }

  Widget _buildUserList(BuildContext context, List<UserModel> users) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: users.length,
      itemBuilder: (context, index) => _UserCard(user: users[index]),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_outlined, size: 64, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text("No users found", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 16)),
        ],
      ),
    );
  }

  void _showAddUserModal(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    String role = "Staff";
    String department = "Operations";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bContext) => BlocProvider.value(
        value: context.read<UsersBloc>(),
        child: StatefulBuilder(
          builder: (context, setModalState) => Container(
            padding: EdgeInsets.only(bottom: MediaQuery.of(bContext).viewInsets.bottom, left: 24, right: 24, top: 24),
            decoration: const BoxDecoration(
              color: Color(0xFF1F2937),
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Add New User", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  _buildField("Full Name", nameController, Icons.person_outline),
                  _buildField("Email Address", emailController, Icons.email_outlined),
                  _buildField("Phone Number", phoneController, Icons.phone_outlined),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown("Role", role, ["Admin", "Operations Manager", "Staff", "Inspector", "Yard Operator", "Finance", "Lab Technician"], (v) => setModalState(() => role = v!)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDropdown("Department", department, ["Operations", "Logistics", "Management", "Finance", "Laboratory"], (v) => setModalState(() => department = v!)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        final data = {
                          "name": nameController.text,
                          "email": emailController.text,
                          "role": role,
                          "department": department,
                          "phone": phoneController.text,
                          "password": "Welcome123", // Default password
                        };
                        context.read<UsersBloc>().add(CreateUser(userData: data));
                        Navigator.pop(bContext);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.btnColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text("CREATE ACCOUNT", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
          prefixIcon: Icon(icon, color: AppTheme.btnColor, size: 20),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppTheme.btnColor)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: const Color(0xFF1F2937),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              items: items.map((String item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserModel user;
  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppTheme.btnColor.withOpacity(0.1),
            child: Text(user.initials, style: TextStyle(color: AppTheme.btnColor, fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1F2937))),
                    _buildRoleChip(user.role),
                  ],
                ),
                const SizedBox(height: 4),
                Text(user.email, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.work_outline, size: 14, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(user.department, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _showDeleteDialog(context),
                      child: Icon(Icons.delete_outline, size: 20, color: Colors.red.withOpacity(0.6)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleChip(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(role.toUpperCase(), style: const TextStyle(color: Color(0xFF6366F1), fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dContext) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete User", style: TextStyle(color: Colors.white)),
        content: Text("Are you sure you want to delete ${user.name}? This action is permanent.", style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dContext), child: const Text("CANCEL", style: TextStyle(color: Colors.white38))),
          TextButton(
            onPressed: () {
              context.read<UsersBloc>().add(DeleteUser(userId: user.id));
              Navigator.pop(dContext);
            },
            child: const Text("DELETE", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
