import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../domain/models/company_settings.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedIndex = 0;
  bool _showDetailOnMobile = false;
  final List<String> _sections = [
    'Company Info',
    'Lists Management',
    'Financial Settings',
    'Notifications',
    'Security',
    'System',
  ];

  CompanySettings? _editedSettings;
  bool _isModified = false;

  final Map<String, TextEditingController> _controllers = {};

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initControllers(CompanySettings settings) {
    _editedSettings = settings;
    _controllers['name'] = TextEditingController(text: settings.name);
    _controllers['address'] = TextEditingController(text: settings.address);
    _controllers['rcNumber'] = TextEditingController(text: settings.rcNumber);
    _controllers['tin'] = TextEditingController(text: settings.tin);
    _controllers['phone'] = TextEditingController(text: settings.phone);
    _controllers['email'] = TextEditingController(text: settings.email);
    _controllers['vat'] = TextEditingController(text: settings.vatPercentage.toString());
    _controllers['discountValue'] = TextEditingController(text: settings.defaultDiscountValue.toString());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SettingsBloc>()..add(LoadSettings()),
      child: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is SettingsUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Settings updated successfully')),
            );
            setState(() {
              _isModified = false;
            });
          } else if (state is SettingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          } else if (state is SettingsLoaded) {
            if (_editedSettings == null) {
              _initControllers(state.settings);
            }
          }
        },
        builder: (context, state) {
          if (state is SettingsLoading && _editedSettings == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_editedSettings == null && state is! SettingsLoaded) {
            return const Center(child: Text("Initializing..."));
          }

          final currentSettings = _editedSettings!;
          final isTablet = Responsive.isTablet(context);

          return Scaffold(
            backgroundColor: Colors.transparent,
            appBar: (!isTablet && _showDetailOnMobile)
                ? AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                      onPressed: () => setState(() => _showDetailOnMobile = false),
                    ),
                    title: Text(
                      _sections[_selectedIndex],
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  )
                : null,
            body: isTablet 
                ? Row(
                    children: [
                      // Sidebar (Tablet)
                      _buildSidebar(context),
                      // Content Area (Tablet)
                      Expanded(
                        child: _buildDetailView(context, currentSettings),
                      ),
                    ],
                  )
                : _showDetailOnMobile
                    ? _buildDetailView(context, currentSettings)
                    : _buildMobileMenu(context),
          );
        },
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.15),
        border: Border(right: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Settings",
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                ),
                SizedBox(height: 8),
                Text(
                  "System Preferences",
                  style: TextStyle(color: Colors.white38, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: ListView.builder(
              itemCount: _sections.length,
              itemBuilder: (context, index) => _buildSidebarItem(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileMenu(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Settings",
                  style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1),
                ),
                const SizedBox(height: 8),
                Text(
                  "Manage your application experience",
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 15),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.btnColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_getSectionIcon(index), color: AppTheme.btnColor, size: 22),
                  ),
                  title: Text(
                    _sections[index],
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(
                    _getSectionDescription(index),
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                      _showDetailOnMobile = true;
                    });
                  },
                ),
              ),
              childCount: _sections.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailView(BuildContext context, CompanySettings currentSettings) {
    final isTablet = Responsive.isTablet(context);
    
    return Container(
      padding: EdgeInsets.all(isTablet ? 40 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isTablet) ...[
            _buildSectionHeader(),
            const SizedBox(height: 40),
          ],
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: _buildSectionContent(context, currentSettings),
            ),
          ),
          if (_isModified) _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index) {
    bool isSelected = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.btnColor.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                _getSectionIcon(index),
                color: isSelected ? AppTheme.btnColor : Colors.white.withOpacity(0.4),
                size: 20,
              ),
              const SizedBox(width: 16),
              Text(
                _sections[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getSectionIcon(int index) {
    switch (index) {
      case 0: return Icons.business;
      case 1: return Icons.list_alt;
      case 2: return Icons.account_balance;
      case 3: return Icons.notifications;
      case 4: return Icons.security;
      case 5: return Icons.settings_system_daydream;
      default: return Icons.settings;
    }
  }

  Widget _buildSectionHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _sections[_selectedIndex],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _getSectionDescription(_selectedIndex),
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  String _getSectionDescription(int index) {
    switch (index) {
      case 0: return "Update your company details and branding for compliance";
      case 1: return "Manage dropdown lists and categorization options";
      case 2: return "Configure taxes, discounts and financial defaults";
      case 3: return "Manage how you receive alerts and updates";
      case 4: return "Update password and authentication preferences";
      case 5: return "Core system configurations and preferences";
      default: return "";
    }
  }

  Widget _buildSectionContent(BuildContext context, CompanySettings settings) {
    switch (_selectedIndex) {
      case 0: return _buildCompanyInfoForm(settings);
      case 1: return _buildListsManagement(settings);
      case 2: return _buildFinancialSettings(settings);
      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.construction, size: 64, color: Colors.white.withOpacity(0.2)),
              const SizedBox(height: 20),
              Text(
                "Section under development",
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 18),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildCompanyInfoForm(CompanySettings settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField("Company Name", _controllers['name']!, (val) {
          _editedSettings = _editedSettings!.copyWith(name: val);
          setState(() => _isModified = true);
        }),
        _buildTextField("RC Number", _controllers['rcNumber']!, (val) {
          _editedSettings = _editedSettings!.copyWith(rcNumber: val);
          setState(() => _isModified = true);
        }),
        _buildTextField("Address", _controllers['address']!, (val) {
          _editedSettings = _editedSettings!.copyWith(address: val);
          setState(() => _isModified = true);
        }, maxLines: 3),
        Row(
          children: [
            Expanded(
              child: _buildTextField("Phone Number", _controllers['phone']!, (val) {
                _editedSettings = _editedSettings!.copyWith(phone: val);
                setState(() => _isModified = true);
              }),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildTextField("Email Address", _controllers['email']!, (val) {
                _editedSettings = _editedSettings!.copyWith(email: val);
                setState(() => _isModified = true);
              }),
            ),
          ],
        ),
        _buildTextField("TIN (Tax Identification Number)", _controllers['tin']!, (val) {
          _editedSettings = _editedSettings!.copyWith(tin: val);
          setState(() => _isModified = true);
        }),
      ],
    );
  }

  Widget _buildFinancialSettings(CompanySettings settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField("VAT Percentage (%)", _controllers['vat']!, (val) {
                double? v = double.tryParse(val);
                if (v != null) {
                  _editedSettings = _editedSettings!.copyWith(vatPercentage: v);
                  setState(() => _isModified = true);
                }
              }),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildTextField("Default Discount Value", _controllers['discountValue']!, (val) {
                double? v = double.tryParse(val);
                if (v != null) {
                  _editedSettings = _editedSettings!.copyWith(defaultDiscountValue: v);
                  setState(() => _isModified = true);
                }
              }),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          "Default Discount Type",
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildChoiceChip("Percentage", settings.defaultDiscountType == "Percentage", (selected) {
              if (selected) {
                _editedSettings = _editedSettings!.copyWith(defaultDiscountType: "Percentage");
                setState(() => _isModified = true);
              }
            }),
            const SizedBox(width: 10),
            _buildChoiceChip("Fixed", settings.defaultDiscountType == "Fixed", (selected) {
              if (selected) {
                _editedSettings = _editedSettings!.copyWith(defaultDiscountType: "Fixed");
                setState(() => _isModified = true);
              }
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildListsManagement(CompanySettings settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildListManager("Vehicles", settings.vehicles, (newList) {
          _editedSettings = _editedSettings!.copyWith(vehicles: newList);
          setState(() => _isModified = true);
        }),
        _buildListManager("Material Types", settings.materialTypes, (newList) {
          _editedSettings = _editedSettings!.copyWith(materialTypes: newList);
          setState(() => _isModified = true);
        }),
        _buildListManager("Inspection Types", settings.inspectionTypes, (newList) {
          _editedSettings = _editedSettings!.copyWith(inspectionTypes: newList);
          setState(() => _isModified = true);
        }),
        _buildListManager("Inspectors", settings.inspectors, (newList) {
          _editedSettings = _editedSettings!.copyWith(inspectors: newList);
          setState(() => _isModified = true);
        }),
        _buildListManager("Laboratories", settings.laboratories, (newList) {
          _editedSettings = _editedSettings!.copyWith(laboratories: newList);
          setState(() => _isModified = true);
        }),
        _buildListManager("Machines", settings.machines, (newList) {
          _editedSettings = _editedSettings!.copyWith(machines: newList);
          setState(() => _isModified = true);
        }),
        _buildListManager("Warehouses", settings.warehouses, (newList) {
          _editedSettings = _editedSettings!.copyWith(warehouses: newList);
          setState(() => _isModified = true);
        }),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, Function(String) onChanged, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            onChanged: onChanged,
            maxLines: maxLines,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.btnColor),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip(String label, bool isSelected, Function(bool) onSelected) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: AppTheme.btnColor,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
      backgroundColor: AppTheme.fieldColor,
    );
  }

  Widget _buildListManager(String title, List<String> items, Function(List<String>) onUpdate) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.white),
                onPressed: () => _addItemDialog(title, items, onUpdate),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: items.map((item) => Chip(
              label: Text(item),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () {
                var newList = List<String>.from(items)..remove(item);
                onUpdate(newList);
              },
            )).toList(),
          ),
        ],
      ),
    );
  }

  void _addItemDialog(String title, List<String> items, Function(List<String>) onUpdate) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add to $title"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter value"),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                var newList = List<String>.from(items)..add(controller.text);
                onUpdate(newList);
                Navigator.pop(context);
              }
            },
            child: const Text("ADD"),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () {
              // Reload settings to reset
              context.read<SettingsBloc>().add(LoadSettings());
              setState(() {
                _isModified = false;
                _editedSettings = null; // Forces re-init on load
              });
            },
            child: const Text("Reset", style: TextStyle(color: Colors.white70)),
          ),
          const SizedBox(width: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.btnColor,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              context.read<SettingsBloc>().add(UpdateSettings(_editedSettings!));
            },
            child: const Text("Save Changes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
