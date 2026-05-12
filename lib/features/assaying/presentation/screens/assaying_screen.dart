import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gme/features/processing/presentation/bloc/processing_bloc.dart';
import 'package:gme/features/processing/presentation/bloc/processing_event.dart';
import 'package:gme/features/processing/presentation/bloc/processing_state.dart';
import 'package:gme/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:gme/features/settings/presentation/bloc/settings_event.dart';
import 'package:gme/features/settings/presentation/bloc/settings_state.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/services/injection_container.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/models/assaying_record.dart';
import '../bloc/assaying_bloc.dart';
import '../bloc/assaying_event.dart';
import '../bloc/assaying_state.dart';


class AssayingScreen extends StatefulWidget {
  const AssayingScreen({super.key});

  @override
  State<AssayingScreen> createState() => _AssayingScreenState();
}

class _AssayingScreenState extends State<AssayingScreen> {
  String _searchQuery = "";
  String _statusFilter = "All";

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<AssayingBloc>()..add(FetchAssayingRecords())),
        BlocProvider(create: (context) => sl<ProcessingBloc>()..add(FetchProcessingBatches())),
        BlocProvider(create: (context) => sl<SettingsBloc>()..add(LoadSettings())),
      ],
      child: BlocListener<AssayingBloc, AssayingState>(
        listener: (context, state) {
          if (state is AssayingActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
          } else if (state is AssayingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: BlocBuilder<AssayingBloc, AssayingState>(
            builder: (context, state) {
              if (state is AssayingLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white70),
                );
              } else if (state is AssayingLoaded || state is AssayingActionLoading || state is AssayingActionSuccess) {
                final List<AssayingRecord> displayRecords = 
                    (state is AssayingLoaded) ? state.records :
                    (state is AssayingActionLoading) ? state.records :
                    (state is AssayingActionSuccess) ? state.records : <AssayingRecord>[];

                final filteredRecords = displayRecords.where((r) {
                  final matchesSearch =
                      r.sampleId.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ) ||
                      r.supplierName.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      );
                  final matchesStatus =
                      _statusFilter == "All" ||
                      r.status.toLowerCase() == _statusFilter.toLowerCase();
                  return matchesSearch && matchesStatus;
                }).toList();

                return Column(
                  children: [
                    _buildHeader(context, displayRecords),
                    _buildFilterSection(),
                    Expanded(child: _buildRecordList(context, filteredRecords)),
                  ],
                );
              } else if (state is AssayingError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.redAccent,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      TextButton(
                        onPressed: () => context.read<AssayingBloc>().add(
                          FetchAssayingRecords(),
                        ),
                        child: const Text(
                          "RETRY",
                          style: TextStyle(color: Colors.white),
                        ),
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

  Widget _buildHeader(BuildContext context, List<AssayingRecord> records) {
    final pendingCount = records
        .where((r) => r.status.toLowerCase() == 'pending')
        .length;
    final approvedCount = records
        .where((r) => r.status.toLowerCase() == 'approved')
        .length;
    final rejectedCount = records
        .where((r) => r.status.toLowerCase() == 'rejected')
        .length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: IntrinsicHeight(
        child: Row(
          children: [
            SizedBox(
              width: 100,
              child: _buildStatItem(
                "PENDING",
                "$pendingCount",
                AppTheme.btnColor,
                Icons.timer_outlined,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 100,
              child: _buildStatItem(
                "APPROVED",
                "$approvedCount",
                Colors.greenAccent,
                Icons.check_circle_outline,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 100,
              child: _buildStatItem(
                "REJECTED",
                "$rejectedCount",
                Colors.redAccent,
                Icons.highlight_off_rounded,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 100,
              child: _buildStatItem(
                "AVG TIME",
                "2.3D",
                Colors.blueAccent,
                Icons.speed_outlined,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 100,
              child: _buildActionCard(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color.withOpacity(0.7), size: 16),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 7,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context) {
    return InkWell(
      onTap: () => _showNewSampleSheet(context),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.btnColor, AppTheme.btnColor.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_chart_outlined, color: Colors.white, size: 20),
            SizedBox(height: 4),
            Text(
              "NEW SAMPLE",
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNewSampleSheet(BuildContext context) {
    final assayingBloc = context.read<AssayingBloc>();
    final processingBloc = context.read<ProcessingBloc>();
    final settingsBloc = context.read<SettingsBloc>();

    final sampleIdController = TextEditingController(text: "SAM-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}");
    final notesController = TextEditingController();
    String? selectedBatch;
    String? selectedTestType;
    String? selectedLab;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppTheme.bgColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (innerContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: assayingBloc),
          BlocProvider.value(value: processingBloc),
          BlocProvider.value(value: settingsBloc),
        ],
        child: StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Create Quality Test Sample", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text("Submit a new sample for laboratory testing", style: TextStyle(color: Colors.white54, fontSize: 14)),
                  const SizedBox(height: 32),
                  
                  _buildFieldLabel("Sample ID (Auto-generated)"),
                  _buildSheetTextField(sampleIdController, enabled: false),
                  
                  const SizedBox(height: 20),
                  _buildFieldLabel("Select Batch"),
                  BlocBuilder<ProcessingBloc, ProcessingState>(
                    builder: (context, state) {
                      final batches = (state is ProcessingLoaded) ? state.batches : [];
                      return _buildSheetDropdown(
                        value: selectedBatch,
                        hint: "Select batch ID",
                        items: batches.map((e) => DropdownMenuItem<String>(value: e.batchId, child: Text(e.batchId, style: const TextStyle(color: Colors.white)))).toList(),
                        onChanged: (val) => setModalState(() => selectedBatch = val),
                      );
                    },
                  ),

                  const SizedBox(height: 20),
                  _buildFieldLabel("Select Test Type"),
                  _buildSheetDropdown(
                    value: selectedTestType,
                    hint: "Select test type",
                    items: ["Purity Check", "Quality Audit", "Mineral Assay", "Chemical Analysis"]
                        .map((e) => DropdownMenuItem<String>(value: e, child: Text(e, style: const TextStyle(color: Colors.white)))).toList(),
                    onChanged: (val) => setModalState(() => selectedTestType = val),
                  ),

                  const SizedBox(height: 20),
                  _buildFieldLabel("Select Lab"),
                  BlocBuilder<SettingsBloc, SettingsState>(
                    builder: (context, state) {
                      final labs = (state is SettingsLoaded) ? state.settings.laboratories : [];
                      return _buildSheetDropdown(
                        value: selectedLab,
                        hint: "Select laboratory",
                        items: labs.map((e) => DropdownMenuItem<String>(value: e, child: Text(e, style: const TextStyle(color: Colors.white)))).toList(),
                        onChanged: (val) => setModalState(() => selectedLab = val),
                      );
                    },
                  ),

                  const SizedBox(height: 20),
                  _buildFieldLabel("Test Requirements / Notes"),
                  _buildSheetTextField(notesController, hint: "Enter specific requirements...", maxLines: 3),

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
                          text: "Submit Sample",
                          onPressed: () {
                            if (selectedBatch == null || selectedTestType == null || selectedLab == null) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all required fields")));
                              return;
                            }
                            
                            // Find selected batch to get more info
                            final batchState = processingBloc.state;
                            String supplier = "N/A";
                            String customer = "N/A";
                            List<String> minerals = [];
                            if (batchState is ProcessingLoaded) {
                              final batch = batchState.batches.firstWhere((b) => b.batchId == selectedBatch);
                              supplier = batch.supplierName;
                              customer = batch.customerName;
                              minerals = batch.rawMaterial;
                            }

                            assayingBloc.add(CreateAssayingRecord({
                              'sampleId': sampleIdController.text,
                              'batchId': selectedBatch,
                              'testType': selectedTestType,
                              'labName': selectedLab,
                              'notes': notesController.text,
                              'supplierName': supplier,
                              'customerName': customer,
                              'mineralType': minerals,
                              'submittedDate': DateTime.now().toIso8601String(),
                              'status': 'Pending'
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

  Widget _buildSheetTextField(TextEditingController controller, {String? hint, bool enabled = true, int maxLines = 1}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
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

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                style: const TextStyle(color: Colors.white, fontSize: 13),
                textAlignVertical: TextAlignVertical.center,
                decoration: const InputDecoration(
                  hintText: "Search samples...",
                  hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.white38,
                    size: 18,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<String>(
              value: _statusFilter,
              dropdownColor: AppTheme.bgColor,
              underline: const SizedBox(),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              items: ["All", "Pending", "Approved", "Rejected"].map((String s) {
                return DropdownMenuItem<String>(value: s, child: Text(s));
              }).toList(),
              onChanged: (v) => setState(() => _statusFilter = v!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordList(BuildContext context, List<AssayingRecord> records) {
    final bool isTablet = Responsive.isTablet(context);
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 2 : 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: isTablet ? 320 : 310,
      ),
      itemBuilder: (context, index) => AssayingCard(record: records[index]),
    );
  }
}

class AssayingCard extends StatelessWidget {
  final AssayingRecord record;
  const AssayingCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final bool isTablet = Responsive.isTablet(context);
    final Color statusColor = record.status.toLowerCase() == 'approved'
        ? Colors.green
        : record.status.toLowerCase() == 'rejected' ? Colors.red : AppTheme.btnColor;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFBFBFB),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "SAMPLE ID",
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        record.sampleId,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(record.status, statusColor),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _confirmDelete(context, record),
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          // Info Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                children: [
                  _buildMiniRow(Icons.link, "Linked Batch", record.batchId),
                  const SizedBox(height: 8),
                  _buildMiniRow(
                    Icons.business_outlined,
                    "Company",
                    record.supplierName,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMiniRow(
                          Icons.science_outlined,
                          "Test Type",
                          record.testType,
                        ),
                      ),
                      Expanded(
                        child: _buildMiniRow(
                          Icons.biotech_outlined,
                          "Lab Name",
                          record.labName,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildMiniRow(
                    Icons.category_outlined,
                    "Mineral Type",
                    record.mineralType.join(", "),
                  ),
                ],
              ),
            ),
          ),
          // Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatTile("Purity", record.purity.isEmpty ? "Pending" : record.purity),
                _buildStatTile("Submitted", record.submittedDate),
                _buildStatTile("Result Date", record.resultDate.isEmpty ? "Pending" : record.resultDate),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AssayingRecord record) {
    showDialog(
      context: context,
      builder: (innerContext) => AlertDialog(
        backgroundColor: AppTheme.bgColor,
        title: const Text("Delete Sample", style: TextStyle(color: Colors.white)),
        content: Text("Are you sure you want to delete sample ${record.sampleId}?", style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(innerContext),
            child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              context.read<AssayingBloc>().add(DeleteAssayingRecord(record.id));
              Navigator.pop(innerContext);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMiniRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[400]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF374151),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }
}
