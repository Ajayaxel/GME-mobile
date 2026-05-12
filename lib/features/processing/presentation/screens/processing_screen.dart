import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/services/injection_container.dart';
import '../../domain/models/processing_batch.dart';
import '../bloc/processing_bloc.dart';
import '../bloc/processing_event.dart';
import '../bloc/processing_state.dart';
import '../../../yard_intake/presentation/bloc/yard_intake_bloc.dart';
import '../../../yard_intake/presentation/bloc/yard_intake_event.dart';
import '../../../yard_intake/presentation/bloc/yard_intake_state.dart';
import '../../../client_mgmt/presentation/bloc/clients_bloc.dart';
import '../../../client_mgmt/presentation/bloc/clients_event.dart';
import '../../../client_mgmt/presentation/bloc/clients_state.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../settings/presentation/bloc/settings_event.dart';
import '../../../settings/presentation/bloc/settings_state.dart';
import '../../../../core/widgets/app_button.dart';

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<ProcessingBloc>()..add(FetchProcessingBatches())),
        BlocProvider(create: (context) => sl<YardIntakeBloc>()..add(FetchYardIntake())),
        BlocProvider(create: (context) => sl<SettingsBloc>()..add(LoadSettings())),
        BlocProvider(create: (context) => sl<ClientsBloc>()..add(FetchClients())),
      ],
      child: BlocListener<ProcessingBloc, ProcessingState>(
        listener: (context, state) {
          if (state is ProcessingActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
          } else if (state is ProcessingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: BlocBuilder<ProcessingBloc, ProcessingState>(
            builder: (context, state) {
              if (state is ProcessingLoading || state is ProcessingActionLoading) {
                return const Center(child: CircularProgressIndicator(color: Colors.white70));
              } else if (state is ProcessingLoaded || state is ProcessingActionSuccess) {
                final batches = (state is ProcessingLoaded) 
                    ? state.batches 
                    : (context.read<ProcessingBloc>().state as ProcessingLoaded).batches;
                
                final filteredBatches = batches
                    .where((b) => b.batchId.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                                  b.supplierName.toLowerCase().contains(_searchQuery.toLowerCase()))
                    .toList();

                return Column(
                  children: [
                    _buildHeader(context, batches),
                    _buildSearchBar(),
                    Expanded(
                      child: _buildBatchList(context, filteredBatches),
                    ),
                  ],
                );
              } else if (state is ProcessingError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                      const SizedBox(height: 16),
                      Text(state.message, style: const TextStyle(color: Colors.white70)),
                      TextButton(
                        onPressed: () => context.read<ProcessingBloc>().add(FetchProcessingBatches()),
                        child: const Text("RETRY", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, List<ProcessingBatch> batches) {
    final pendingCount = batches.where((b) => b.status.toLowerCase() != 'completed').length;
    final completedCount = batches.length - pendingCount;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(width: 120, child: _buildStatItem("TOTAL", "${batches.length}", Colors.white, Icons.layers_outlined)),
                  const SizedBox(width: 12),
                  SizedBox(width: 120, child: _buildStatItem("PENDING", "$pendingCount", AppTheme.btnColor, Icons.pending_actions_outlined)),
                  const SizedBox(width: 12),
                  SizedBox(width: 120, child: _buildStatItem("COMPLETED", "$completedCount", Colors.greenAccent, Icons.check_circle_outline)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: () => _showCreateBatchSheet(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text("Create Batch"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.btnColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color.withOpacity(0.7), size: 18),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w900),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          onChanged: (value) => setState(() => _searchQuery = value),
          style: const TextStyle(color: Colors.white),
          textAlignVertical: TextAlignVertical.center,
          decoration: const InputDecoration(
            hintText: "Search Batch ID or Company...",
            hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
            prefixIcon: Icon(Icons.search, color: Colors.white38),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }

  Widget _buildBatchList(BuildContext context, List<ProcessingBatch> batches) {
    final bool isTablet = Responsive.isTablet(context);
    
    return RefreshIndicator(
      color: AppTheme.btnColor,
      onRefresh: () async {
        context.read<ProcessingBloc>().add(FetchProcessingBatches());
      },
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        itemCount: batches.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isTablet ? 2 : 1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          mainAxisExtent: isTablet ? 320 : 300,
        ),
        itemBuilder: (context, index) {
          return ProcessingCard(batch: batches[index]);
        },
      ),
    );
  }
}

class ProcessingCard extends StatelessWidget {
  final ProcessingBatch batch;
  const ProcessingCard({super.key, required this.batch});

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = batch.status.toLowerCase() == 'completed';
    final Color statusColor = isCompleted ? Colors.greenAccent : AppTheme.btnColor;
    final bool isTablet = Responsive.isTablet(context);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0, top: 0, bottom: 0, width: 4,
            child: Container(color: statusColor),
          ),
          
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Batch ID",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            batch.batchId,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: isTablet ? 17 : 15,
                              color: const Color(0xFF1A1A1A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            const Text(
                              "Status",
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                              onPressed: () => _showDeleteDialog(context),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        _buildStatusChip(batch.status, statusColor),
                      ],
                    ),
                  ],
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Divider(height: 1, color: Color(0xFFF0F0F0)),
                ),
                
                Expanded(
                  child: Column(
                    children: [
                      _buildRow(Icons.business_center_outlined, "Company", batch.supplierName),
                      const SizedBox(height: 8),
                      _buildRow(Icons.layers_outlined, "Raw Material", batch.rawMaterial.join(", ")),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(child: _buildBadge(Icons.settings_input_component_outlined, "Assigned Machine", batch.machineAssigned)),
                          const SizedBox(width: 8),
                          Expanded(child: _buildBadge(Icons.auto_awesome_outlined, "Output Grade", batch.outputGrade)),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.05)),
                  ),
                  child: Row(
                    children: [
                      _buildStat("Input Qty (kg)", "${batch.inputQuantity} kg", Colors.blueGrey),
                      Container(height: 25, width: 1, color: Colors.grey.withOpacity(0.2), margin: const EdgeInsets.symmetric(horizontal: 16)),
                      _buildStat("Output Qty (kg)", "${batch.outputQuantity} kg", AppTheme.btnColor),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text("Processing Date", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                          const SizedBox(height: 2),
                          Text(
                            "${batch.processingDate.day}/${batch.processingDate.month}/${batch.processingDate.year}",
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black54),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildRow(IconData icon, String heading, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[400]),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
              children: [
                TextSpan(text: "$heading: ", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                TextSpan(text: text, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
              ],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(IconData icon, String heading, String text) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(heading, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(icon, size: 12, color: AppTheme.btnColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF374151)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color)),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (innerContext) => AlertDialog(
        backgroundColor: AppTheme.bgColor,
        title: const Text("Delete Batch", style: TextStyle(color: Colors.white)),
        content: Text("Are you sure you want to delete batch ${batch.batchId}?", style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(innerContext),
            child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(innerContext);
              context.read<ProcessingBloc>().add(DeleteProcessingBatch(batch.id));
            },
            child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

void _showCreateBatchSheet(BuildContext context) {
  final processingBloc = context.read<ProcessingBloc>();
  final yardIntakeBloc = context.read<YardIntakeBloc>();
  final settingsBloc = context.read<SettingsBloc>();
  final clientsBloc = context.read<ClientsBloc>();

  final batchIdController = TextEditingController(text: "BATCH-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}");
  final quantityController = TextEditingController();
  
  String? selectedGRN;
  String? selectedMaterial;
  String? selectedMachine;
  String? selectedGrade;
  String? selectedSupplier;
  String? selectedCustomer;
  DateTime selectedDate = DateTime.now();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppTheme.bgColor,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
    builder: (innerContext) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: processingBloc),
        BlocProvider.value(value: yardIntakeBloc),
        BlocProvider.value(value: settingsBloc),
        BlocProvider.value(value: clientsBloc),
      ],
      child: StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Create Processing Batch", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text("Start a new crushing and processing batch", style: TextStyle(color: Colors.white54, fontSize: 14)),
                const SizedBox(height: 32),
                
                _buildFieldLabel("Batch ID (Auto-generated)"),
                _buildSheetTextField(batchIdController, enabled: false),
                
                const SizedBox(height: 20),
                _buildFieldLabel("Select GRN"),
                BlocBuilder<YardIntakeBloc, YardIntakeState>(
                  builder: (context, state) {
                    final grns = (state is YardIntakeLoaded) ? state.intakeList : [];
                    return _buildSheetDropdown(
                      value: selectedGRN,
                      hint: "Select GRN Reference",
                      items: grns.map((e) => DropdownMenuItem<String>(value: e.grnNumber, child: Text(e.grnNumber, style: const TextStyle(color: Colors.white)))).toList(),
                      onChanged: (val) => setModalState(() => selectedGRN = val),
                    );
                  },
                ),

                const SizedBox(height: 20),
                _buildFieldLabel("Select Material"),
                BlocBuilder<SettingsBloc, SettingsState>(
                  builder: (context, state) {
                    final materials = (state is SettingsLoaded) ? state.settings.materialTypes : [];
                    return _buildSheetDropdown(
                      value: selectedMaterial,
                      hint: "Select raw material",
                      items: materials.map((e) => DropdownMenuItem<String>(value: e, child: Text(e, style: const TextStyle(color: Colors.white)))).toList(),
                      onChanged: (val) => setModalState(() => selectedMaterial = val),
                    );
                  },
                ),

                const SizedBox(height: 20),
                _buildFieldLabel("Input Quantity (kg)"),
                _buildSheetTextField(quantityController, hint: "0", keyboardType: TextInputType.number),

                const SizedBox(height: 20),
                _buildFieldLabel("Select Machine"),
                BlocBuilder<SettingsBloc, SettingsState>(
                  builder: (context, state) {
                    final machines = (state is SettingsLoaded) ? state.settings.machines : [];
                    return _buildSheetDropdown(
                      value: selectedMachine,
                      hint: "Select assigned machine",
                      items: machines.map((e) => DropdownMenuItem<String>(value: e, child: Text(e, style: const TextStyle(color: Colors.white)))).toList(),
                      onChanged: (val) => setModalState(() => selectedMachine = val),
                    );
                  },
                ),

                const SizedBox(height: 20),
                _buildFieldLabel("Select Grade"),
                _buildSheetDropdown(
                  value: selectedGrade,
                  hint: "Select output grade",
                  items: ["High", "Medium", "Low", "Grade A", "Grade B"]
                      .map((e) => DropdownMenuItem<String>(value: e, child: Text(e, style: const TextStyle(color: Colors.white)))).toList(),
                  onChanged: (val) => setModalState(() => selectedGrade = val),
                ),

                const SizedBox(height: 20),
                _buildFieldLabel("Select Supplier"),
                BlocBuilder<ClientsBloc, ClientsState>(
                  builder: (context, state) {
                    final clients = (state is ClientsLoaded) ? state.clients : [];
                    return _buildSheetDropdown(
                      value: selectedSupplier,
                      hint: "Select supplier name",
                      items: clients.map((e) => DropdownMenuItem<String>(value: e.name, child: Text(e.name, style: const TextStyle(color: Colors.white)))).toList(),
                      onChanged: (val) => setModalState(() => selectedSupplier = val),
                    );
                  },
                ),

                const SizedBox(height: 20),
                _buildFieldLabel("Select Customer"),
                BlocBuilder<ClientsBloc, ClientsState>(
                  builder: (context, state) {
                    final clients = (state is ClientsLoaded) ? state.clients : [];
                    return _buildSheetDropdown(
                      value: selectedCustomer,
                      hint: "Select customer name",
                      items: clients.map((e) => DropdownMenuItem<String>(value: e.name, child: Text(e.name, style: const TextStyle(color: Colors.white)))).toList(),
                      onChanged: (val) => setModalState(() => selectedCustomer = val),
                    );
                  },
                ),

                const SizedBox(height: 20),
                _buildFieldLabel("Processing Date"),
                InkWell(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                      builder: (context, child) => Theme(
                        data: ThemeData.dark().copyWith(
                          colorScheme:  ColorScheme.dark(primary: AppTheme.btnColor, onPrimary: Colors.white, surface: AppTheme.bgColor, onSurface: Colors.white),
                          dialogBackgroundColor: AppTheme.bgColor,
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null && picked != selectedDate) {
                      setModalState(() => selectedDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.white54, size: 18),
                        const SizedBox(width: 12),
                        Text("${selectedDate.day}/${selectedDate.month}/${selectedDate.year}", style: const TextStyle(color: Colors.white, fontSize: 16)),
                        const Spacer(),
                        const Icon(Icons.arrow_drop_down, color: Colors.white54),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppButton(
                        text: "Create Batch",
                        onPressed: () {
                          if (selectedMaterial == null || quantityController.text.isEmpty || selectedMachine == null || selectedGrade == null || selectedSupplier == null || selectedCustomer == null) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all required fields")));
                            return;
                          }
                          
                          processingBloc.add(CreateProcessingBatch({
                            'batchId': batchIdController.text,
                            'rawMaterial': [selectedMaterial],
                            'inputQuantity': double.tryParse(quantityController.text) ?? 0,
                            'machineAssigned': selectedMachine,
                            'outputGrade': selectedGrade,
                            'grnReference': selectedGRN ?? 'N/A',
                            'supplierName': selectedSupplier,
                            'customerName': selectedCustomer,
                            'processingDate': selectedDate.toIso8601String(),
                            'status': 'Processing'
                          }));
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
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

Widget _buildFieldLabel(String label) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
  );
}

Widget _buildSheetTextField(TextEditingController controller, {String? hint, bool enabled = true, TextInputType? keyboardType}) {
  return TextField(
    controller: controller,
    enabled: enabled,
    keyboardType: keyboardType,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white24),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    ),
  );
}

Widget _buildSheetDropdown({required String? value, required String hint, required List<DropdownMenuItem<String>> items, required Function(String?) onChanged}) {
  return DropdownButtonFormField<String>(
    value: value,
    dropdownColor: AppTheme.bgColor,
    icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    ),
    hint: Text(hint, style: const TextStyle(color: Colors.white24, fontSize: 14)),
    items: items,
    onChanged: onChanged,
  );
}
