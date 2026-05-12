import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/services/injection_container.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/models/inspection_record.dart';
import '../bloc/inspection_bloc.dart';
import '../bloc/inspection_event.dart';
import '../bloc/inspection_state.dart';
import 'package:gme/features/processing/presentation/bloc/processing_bloc.dart';
import 'package:gme/features/processing/presentation/bloc/processing_event.dart';
import 'package:gme/features/processing/presentation/bloc/processing_state.dart';
import 'package:gme/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:gme/features/settings/presentation/bloc/settings_event.dart';
import 'package:gme/features/settings/presentation/bloc/settings_state.dart';

class InspectionScreen extends StatefulWidget {
  const InspectionScreen({super.key});

  @override
  State<InspectionScreen> createState() => _InspectionScreenState();
}

class _InspectionScreenState extends State<InspectionScreen> {
  String _searchQuery = "";
  String _statusFilter = "All";

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              sl<InspectionBloc>()..add(FetchInspectionRecords()),
        ),
        BlocProvider(
          create: (context) =>
              sl<ProcessingBloc>()..add(FetchProcessingBatches()),
        ),
        BlocProvider(
          create: (context) => sl<SettingsBloc>()..add(LoadSettings()),
        ),
      ],
      child: BlocListener<InspectionBloc, InspectionState>(
        listener: (context, state) {
          if (state is InspectionActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is InspectionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: BlocBuilder<InspectionBloc, InspectionState>(
            builder: (context, state) {
              if (state is InspectionLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white70),
                );
              } else if (state is InspectionLoaded ||
                  state is InspectionActionLoading ||
                  state is InspectionActionSuccess) {
                final List<InspectionRecord> displayRecords =
                    (state is InspectionLoaded)
                    ? state.records
                    : (state is InspectionActionLoading)
                    ? state.records
                    : (state is InspectionActionSuccess)
                    ? state.records
                    : <InspectionRecord>[];

                final filteredRecords = displayRecords.where((r) {
                  final matchesSearch =
                      r.inspectionId.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ) ||
                      r.supplierName.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ) ||
                      r.inspectorName.toLowerCase().contains(
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
              } else if (state is InspectionError) {
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
                        onPressed: () => context.read<InspectionBloc>().add(
                          FetchInspectionRecords(),
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

  Widget _buildHeader(BuildContext context, List<InspectionRecord> records) {
    final pendingCount = records
        .where((r) => r.status.toLowerCase() == 'pending')
        .length;
    final completedCount = records
        .where(
          (r) =>
              r.status.toLowerCase() == 'completed' ||
              r.status.toLowerCase() == 'approved',
        )
        .length;
    final failedCount = records
        .where(
          (r) =>
              r.status.toLowerCase() == 'failed' ||
              r.status.toLowerCase() == 'rejected',
        )
        .length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _buildStatItem(
              "PENDING",
              "$pendingCount",
              AppTheme.btnColor,
              Icons.schedule_outlined,
            ),
            const SizedBox(width: 8),
            _buildStatItem(
              "COMPLETED",
              "$completedCount",
              Colors.greenAccent,
              Icons.verified_outlined,
            ),
            const SizedBox(width: 8),
            _buildStatItem(
              "FAILED",
              "$failedCount",
              Colors.redAccent,
              Icons.report_problem_outlined,
            ),
            const SizedBox(width: 8),
            _buildStatItem(
              "AVG RATING",
              "4.8",
              Colors.amberAccent,
              Icons.star_outline,
            ),
            const SizedBox(width: 8),
            _buildActionCard(context),
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
      width: 100,
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
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context) {
    return InkWell(
      onTap: () => _showScheduleSheet(context),
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.btnColor, AppTheme.btnColor.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_task_outlined, color: Colors.white, size: 20),
            SizedBox(height: 4),
            Text(
              "NEW INSPECTION",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 7,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showScheduleSheet(BuildContext context) {
    final inspectionBloc = context.read<InspectionBloc>();
    final processingBloc = context.read<ProcessingBloc>();
    final settingsBloc = context.read<SettingsBloc>();

    final idController = TextEditingController(
      text:
          "INS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}",
    );
    final companyController = TextEditingController();
    final observationsController = TextEditingController();
    String? selectedBatch;
    String? selectedType;
    String? selectedInspector;
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppTheme.bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (innerContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: inspectionBloc),
          BlocProvider.value(value: processingBloc),
          BlocProvider.value(value: settingsBloc),
        ],
        child: StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Schedule New Inspection",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Create an inspection record and assign inspector",
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                  const SizedBox(height: 32),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel("Inspection ID"),
                            _buildSheetTextField(
                              idController,
                              enabled: false,
                              hint: "Auto-generated",
                            ),

                            const SizedBox(height: 20),
                            _buildFieldLabel("Company Name"),
                            _buildSheetTextField(
                              companyController,
                              enabled: false,
                              hint: "Select batch to autofill",
                            ),

                            const SizedBox(height: 20),
                            _buildFieldLabel("Inspection Type"),
                            BlocBuilder<SettingsBloc, SettingsState>(
                              builder: (context, state) {
                                final types = (state is SettingsLoaded)
                                    ? state.settings.inspectionTypes
                                    : [];
                                return _buildSheetDropdown(
                                  value: selectedType,
                                  hint: "Select type",
                                  items: types
                                      .map(
                                        (e) => DropdownMenuItem<String>(
                                          value: e,
                                          child: Text(
                                            e,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (val) =>
                                      setModalState(() => selectedType = val),
                                );
                              },
                            ),

                            const SizedBox(height: 20),
                            _buildFieldLabel("Scheduled Time"),
                            _buildTimePicker(
                              context,
                              selectedTime,
                              (time) =>
                                  setModalState(() => selectedTime = time),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Right Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel("Batch ID"),
                            BlocBuilder<ProcessingBloc, ProcessingState>(
                              builder: (context, state) {
                                final batches = (state is ProcessingLoaded)
                                    ? state.batches
                                    : [];
                                return _buildSheetDropdown(
                                  value: selectedBatch,
                                  hint: "Select Batch",
                                  items: batches
                                      .map(
                                        (e) => DropdownMenuItem<String>(
                                          value: e.batchId,
                                          child: Text(
                                            e.batchId,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (val) {
                                    setModalState(() {
                                      selectedBatch = val;
                                      if (state is ProcessingLoaded &&
                                          val != null) {
                                        final batch = state.batches.firstWhere(
                                          (b) => b.batchId == val,
                                        );
                                        companyController.text =
                                            batch.customerName;
                                      }
                                    });
                                  },
                                );
                              },
                            ),

                            const SizedBox(height: 20),
                            _buildFieldLabel("Inspector Name"),
                            BlocBuilder<SettingsBloc, SettingsState>(
                              builder: (context, state) {
                                final inspectors = (state is SettingsLoaded)
                                    ? state.settings.inspectors
                                    : [];
                                return _buildSheetDropdown(
                                  value: selectedInspector,
                                  hint: "Assign inspector",
                                  items: inspectors
                                      .map(
                                        (e) => DropdownMenuItem<String>(
                                          value: e,
                                          child: Text(
                                            e,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (val) => setModalState(
                                    () => selectedInspector = val,
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 20),
                            _buildFieldLabel("Scheduled Date"),
                            _buildDatePicker(
                              context,
                              selectedDate,
                              (date) =>
                                  setModalState(() => selectedDate = date),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  _buildFieldLabel("Observations / Notes"),
                  _buildSheetTextField(
                    observationsController,
                    hint: "Enter inspection observations...",
                    maxLines: 3,
                  ),

                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            color: Colors.white54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 200,
                        child: AppButton(
                          text: "Schedule Inspection",
                          onPressed: () {
                            if (selectedBatch == null ||
                                selectedType == null ||
                                selectedInspector == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Please fill all required fields",
                                  ),
                                ),
                              );
                              return;
                            }

                            final batchState = processingBloc.state;
                            String supplier = "N/A";
                            if (batchState is ProcessingLoaded) {
                              final batch = batchState.batches.firstWhere(
                                (b) => b.batchId == selectedBatch,
                              );
                              supplier = batch.supplierName;
                            }

                            final combinedDateTime = DateTime(
                              selectedDate.year,
                              selectedDate.month,
                              selectedDate.day,
                              selectedTime.hour,
                              selectedTime.minute,
                            );

                            inspectionBloc.add(
                              CreateInspectionRecord({
                                'inspectionId': idController.text,
                                'batchId': selectedBatch,
                                'supplierName': supplier,
                                'customerName': companyController.text,
                                'inspectorName': selectedInspector,
                                'inspectionType': selectedType,
                                'scheduledDate': combinedDateTime
                                    .toIso8601String(),
                                'observations': observationsController.text,
                                'status': 'Pending',
                              }),
                            );
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

  Widget _buildFieldLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(
      label,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget _buildSheetTextField(
    TextEditingController controller, {
    String? hint,
    bool enabled = true,
    int maxLines = 1,
  }) {
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSheetDropdown({
    required String? value,
    required String hint,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: AppTheme.bgColor,
      icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      hint: Text(
        hint,
        style: const TextStyle(color: Colors.white24, fontSize: 14),
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _buildDatePicker(
    BuildContext context,
    DateTime selectedDate,
    Function(DateTime) onPicked,
  ) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          builder: (context, child) => Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(
                primary: AppTheme.btnColor,
                onPrimary: Colors.white,
                surface: AppTheme.bgColor,
                onSurface: Colors.white,
              ),
              dialogBackgroundColor: AppTheme.bgColor,
            ),
            child: child!,
          ),
        );
        if (picked != null) onPicked(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.white54, size: 18),
            const SizedBox(width: 12),
            Text(
              "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const Spacer(),
            const Icon(Icons.arrow_drop_down, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(
    BuildContext context,
    TimeOfDay selectedTime,
    Function(TimeOfDay) onPicked,
  ) {
    return InkWell(
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: selectedTime,
          builder: (context, child) => Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(
                primary: AppTheme.btnColor,
                onPrimary: Colors.white,
                surface: AppTheme.bgColor,
                onSurface: Colors.white,
              ),
              dialogBackgroundColor: AppTheme.bgColor,
            ),
            child: child!,
          ),
        );
        if (picked != null) onPicked(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: Colors.white54, size: 18),
            const SizedBox(width: 12),
            Text(
              selectedTime.format(context),
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const Spacer(),
            const Icon(Icons.arrow_drop_down, color: Colors.white54),
          ],
        ),
      ),
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
                  hintText: "Search inspections...",
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
              items: ["All", "Pending", "Completed", "Failed"]
                  .map(
                    (String s) =>
                        DropdownMenuItem<String>(value: s, child: Text(s)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _statusFilter = v!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordList(
    BuildContext context,
    List<InspectionRecord> records,
  ) {
    final bool isTablet = Responsive.isTablet(context);
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 2 : 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: isTablet ? 260 : 300,
      ),
      itemBuilder: (context, index) => InspectionCard(record: records[index]),
    );
  }
}

class InspectionCard extends StatelessWidget {
  final InspectionRecord record;
  const InspectionCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final Color statusColor =
        record.status.toLowerCase() == 'completed' ||
            record.status.toLowerCase() == 'approved'
        ? Colors.green
        : record.status.toLowerCase() == 'failed' ||
              record.status.toLowerCase() == 'rejected'
        ? Colors.red
        : AppTheme.btnColor;

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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFFBFBFB),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "INSPECTION ID",
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        record.inspectionId,
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
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                    size: 18,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildMiniRow(Icons.link, "Linked Batch", record.batchId),
                  const SizedBox(height: 8),
                  _buildMiniRow(
                    Icons.person_outline,
                    "Inspector",
                    record.inspectorName,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMiniRow(
                          Icons.category_outlined,
                          "Type",
                          record.inspectionType,
                        ),
                      ),
                      Expanded(
                        child: _buildMiniRow(
                          Icons.business_outlined,
                          "Supplier",
                          record.supplierName,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatTile(
                  "Scheduled",
                  record.scheduledDate.length >= 10 
                      ? record.scheduledDate.substring(0, 10) 
                      : record.scheduledDate,
                ),
                _buildStatTile("Completed", record.completedDate),
                _buildStatTile("Customer", record.customerName),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, InspectionRecord record) {
    showDialog(
      context: context,
      builder: (innerContext) => AlertDialog(
        backgroundColor: AppTheme.bgColor,
        title: const Text(
          "Delete Inspection",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          "Are you sure you want to delete inspection ${record.inspectionId}?",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(innerContext),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<InspectionBloc>().add(
                DeleteInspectionRecord(record.id),
              );
              Navigator.pop(innerContext);
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) => Container(
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

  Widget _buildMiniRow(IconData icon, String label, String value) => Row(
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

  Widget _buildStatTile(String label, String value) => Column(
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
