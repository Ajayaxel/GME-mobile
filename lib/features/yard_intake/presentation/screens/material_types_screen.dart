import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/injection_container.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../settings/presentation/bloc/settings_event.dart';
import '../../../settings/presentation/bloc/settings_state.dart';
import '../../../settings/domain/models/company_settings.dart';
import '../../../../core/widgets/app_button.dart';

class MaterialTypesScreen extends StatefulWidget {
  const MaterialTypesScreen({super.key});

  @override
  State<MaterialTypesScreen> createState() => _MaterialTypesScreenState();
}

class _MaterialTypesScreenState extends State<MaterialTypesScreen> {
  final TextEditingController _materialController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _materialController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SettingsBloc>()..add(LoadSettings()),
      child: BlocListener<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is SettingsUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Materials updated successfully")),
            );
            _materialController.clear();
          } else if (state is SettingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error: ${state.message}"), backgroundColor: Colors.redAccent),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Material Management",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Manage the list of minerals and materials handled in the yard",
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
                const SizedBox(height: 32),
                _buildAddMaterialSection(context),
                const SizedBox(height: 40),
                _buildMaterialRegistrySection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddMaterialSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Add New Material",
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        const Text(
          "e.g., Quartz, Lithium Ore",
          style: TextStyle(color: Colors.white38, fontSize: 12),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _materialController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Enter material name...",
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            BlocBuilder<SettingsBloc, SettingsState>(
              builder: (context, state) {
                return SizedBox(
                  width: 150,
                  height: 54,
                  child: AppButton(
                    text: state is SettingsUpdating ? "Adding..." : "Add Material",
                    onPressed: state is SettingsUpdating 
                        ? null 
                        : () => _addMaterial(context),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMaterialRegistrySection(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Material Registry",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              BlocBuilder<SettingsBloc, SettingsState>(
                builder: (context, state) {
                  if (state is SettingsLoaded) {
                    return Text(
                      "${state.settings.materialTypes.length} Total",
                      style: const TextStyle(color: Colors.white54, fontSize: 13),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Search materials...",
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon: const Icon(Icons.search, color: Colors.white38),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: BlocBuilder<SettingsBloc, SettingsState>(
              builder: (context, state) {
                if (state is SettingsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is SettingsLoaded) {
                  final filteredList = state.settings.materialTypes
                      .where((m) => m.toLowerCase().contains(_searchQuery.toLowerCase()))
                      .toList();

                  if (filteredList.isEmpty) {
                    return const Center(
                      child: Text("No materials found", style: TextStyle(color: Colors.white38)),
                    );
                  }

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: Responsive.isTablet(context) ? 3 : 2,
                      childAspectRatio: Responsive.isTablet(context) ? 2.5 : 2.8,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final material = filteredList[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.category, color: Colors.white54, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                material,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                              onPressed: () => _deleteMaterial(context, state.settings, material),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else if (state is SettingsError) {
                  return Center(child: Text(state.message, style: const TextStyle(color: Colors.redAccent)));
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _addMaterial(BuildContext context) {
    final material = _materialController.text.trim();
    if (material.isEmpty) return;

    final state = context.read<SettingsBloc>().state;
    if (state is SettingsLoaded) {
      if (state.settings.materialTypes.contains(material)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Material already exists")),
        );
        return;
      }

      final updatedList = List<String>.from(state.settings.materialTypes)..add(material);
      final updatedSettings = state.settings.copyWith(materialTypes: updatedList);
      
      context.read<SettingsBloc>().add(UpdateSettings(updatedSettings));
    }
  }

  void _deleteMaterial(BuildContext context, CompanySettings settings, String material) {
    showDialog(
      context: context,
      builder: (innerContext) => AlertDialog(
        backgroundColor: AppTheme.bgColor,
        title: const Text("Delete Material", style: TextStyle(color: Colors.white)),
        content: Text("Are you sure you want to remove $material?", style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(innerContext),
            child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(innerContext);
              final updatedList = List<String>.from(settings.materialTypes)..remove(material);
              final updatedSettings = settings.copyWith(materialTypes: updatedList);
              context.read<SettingsBloc>().add(UpdateSettings(updatedSettings));
            },
            child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
