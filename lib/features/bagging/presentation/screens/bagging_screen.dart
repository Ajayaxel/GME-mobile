import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/services/injection_container.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/models/bagging_record.dart';
import '../bloc/bagging_bloc.dart';
import '../bloc/bagging_event.dart';
import '../bloc/bagging_state.dart';
import 'package:gme/features/processing/presentation/bloc/processing_bloc.dart';
import 'package:gme/features/processing/presentation/bloc/processing_event.dart';
import 'package:gme/features/processing/presentation/bloc/processing_state.dart';

class BaggingScreen extends StatefulWidget {
  const BaggingScreen({super.key});

  @override
  State<BaggingScreen> createState() => _BaggingScreenState();
}

class _BaggingScreenState extends State<BaggingScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<BaggingBloc>()..add(FetchBaggingEntries())),
        BlocProvider(create: (context) => sl<ProcessingBloc>()..add(FetchProcessingBatches())),
      ],
      child: BlocListener<BaggingBloc, BaggingState>(
        listener: (context, state) {
          if (state is BaggingActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
          } else if (state is BaggingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: BlocBuilder<BaggingBloc, BaggingState>(
            builder: (context, state) {
              if (state is BaggingLoading) {
                return const Center(child: CircularProgressIndicator(color: Colors.white70));
              } else if (state is BaggingLoaded || state is BaggingActionLoading || state is BaggingActionSuccess) {
                final List<BaggingRecord> records = 
                    (state is BaggingLoaded) ? state.records :
                    (state is BaggingActionLoading) ? state.records :
                    (state is BaggingActionSuccess) ? state.records : <BaggingRecord>[];

                final filteredRecords = records.where((r) {
                  return r.baggingId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                         r.batchId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                         r.customerName.toLowerCase().contains(_searchQuery.toLowerCase());
                }).toList();

                return Column(
                  children: [
                    _buildHeader(context, records),
                    _buildFilterSection(),
                    Expanded(child: _buildRecordList(context, filteredRecords)),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, List<BaggingRecord> records) {
    final totalBags = records.fold(0, (sum, r) => sum + r.numberOfBags);
    final totalWeight = records.fold(0.0, (sum, r) => sum + r.totalWeight);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _buildStatItem("TOTAL ENTRIES", "${records.length}", AppTheme.btnColor, Icons.inventory_2_outlined),
            const SizedBox(width: 8),
            _buildStatItem("TOTAL BAGS", "$totalBags", Colors.greenAccent, Icons.shopping_bag_outlined),
            const SizedBox(width: 8),
            _buildStatItem("TOTAL WEIGHT", "${totalWeight.toStringAsFixed(1)} kg", Colors.amberAccent, Icons.scale_outlined),
            const SizedBox(width: 8),
            _buildActionCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Container(
      width: 110,
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
          Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 7, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context) {
    return InkWell(
      onTap: () => _showNewEntrySheet(context),
      child: Container(
        width: 110,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [AppTheme.btnColor, AppTheme.btnColor.withOpacity(0.8)]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_box_outlined, color: Colors.white, size: 20),
            SizedBox(height: 4),
            Text("NEW ENTRY", style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _showNewEntrySheet(BuildContext context) {
    final baggingBloc = context.read<BaggingBloc>();
    final processingBloc = context.read<ProcessingBloc>();

    final idController = TextEditingController(text: "BAG-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}");
    final supplierController = TextEditingController();
    final customerController = TextEditingController();
    final bagsController = TextEditingController();
    final weightController = TextEditingController(text: "50");
    final locationController = TextEditingController();
    String? selectedBatch;
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppTheme.bgColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (innerContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: baggingBloc),
          BlocProvider.value(value: processingBloc),
        ],
        child: StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("New Bagging Entry", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text("Record new bagging and warehouse placement", style: TextStyle(color: Colors.white54, fontSize: 14)),
                  const SizedBox(height: 32),
                  
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel("Bagging ID"),
                            _buildSheetTextField(idController, enabled: false, hint: "Auto-generated"),
                            
                            const SizedBox(height: 20),
                            _buildFieldLabel("Supplier Name"),
                            _buildSheetTextField(supplierController, enabled: false, hint: "Select batch"),

                            const SizedBox(height: 20),
                            _buildFieldLabel("Number of Bags"),
                            _buildSheetTextField(bagsController, hint: "Enter count", keyboardType: TextInputType.number),

                            const SizedBox(height: 20),
                            _buildFieldLabel("Warehouse Location"),
                            _buildSheetTextField(locationController, hint: "Section/Rack ID"),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel("Batch ID"),
                            BlocBuilder<ProcessingBloc, ProcessingState>(
                              builder: (context, state) {
                                final batches = (state is ProcessingLoaded) ? state.batches : [];
                                return _buildSheetDropdown(
                                  value: selectedBatch,
                                  hint: "Select Batch",
                                  items: batches.map((e) => DropdownMenuItem<String>(value: e.batchId, child: Text(e.batchId, style: const TextStyle(color: Colors.white)))).toList(),
                                  onChanged: (val) {
                                    setModalState(() {
                                      selectedBatch = val;
                                      if (state is ProcessingLoaded && val != null) {
                                        final batch = state.batches.firstWhere((b) => b.batchId == val);
                                        supplierController.text = batch.supplierName;
                                        customerController.text = batch.customerName;
                                      }
                                    });
                                  },
                                );
                              },
                            ),

                            const SizedBox(height: 20),
                            _buildFieldLabel("Customer Name"),
                            _buildSheetTextField(customerController, enabled: false, hint: "Select batch"),

                            const SizedBox(height: 20),
                            _buildFieldLabel("Weight per Bag (kg)"),
                            _buildSheetTextField(weightController, hint: "Default 50kg", keyboardType: TextInputType.number),

                            const SizedBox(height: 20),
                            _buildFieldLabel("Bagging Date"),
                            _buildDatePicker(context, selectedDate, (date) => setModalState(() => selectedDate = date)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold))),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 180,
                        child: AppButton(
                          text: "Submit Entry",
                          onPressed: () {
                            if (selectedBatch == null || bagsController.text.isEmpty || locationController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all required fields")));
                              return;
                            }
                            
                            baggingBloc.add(CreateBaggingEntry({
                              'baggingId': idController.text,
                              'batchId': selectedBatch,
                              'supplierName': supplierController.text,
                              'customerName': customerController.text,
                              'numberOfBags': int.parse(bagsController.text),
                              'weightPerBag': double.parse(weightController.text),
                              'warehouseLocation': locationController.text,
                              'baggingDate': selectedDate.toIso8601String(),
                              'status': 'Completed'
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

  Widget _buildFieldLabel(String label) => Padding(padding: const EdgeInsets.only(bottom: 8.0), child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)));

  Widget _buildSheetTextField(TextEditingController controller, {String? hint, bool enabled = true, int maxLines = 1, TextInputType? keyboardType}) {
    return TextField(
      controller: controller, enabled: enabled, maxLines: maxLines, keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint, hintStyle: const TextStyle(color: Colors.white24),
        filled: true, fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildSheetDropdown({required String? value, required String hint, required List<DropdownMenuItem<String>> items, required Function(String?) onChanged}) {
    return DropdownButtonFormField<String>(
      value: value, dropdownColor: AppTheme.bgColor, icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
      decoration: InputDecoration(filled: true, fillColor: Colors.white.withOpacity(0.05), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
      hint: Text(hint, style: const TextStyle(color: Colors.white24, fontSize: 14)),
      items: items, onChanged: onChanged,
    );
  }

  Widget _buildDatePicker(BuildContext context, DateTime selectedDate, Function(DateTime) onPicked) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context, initialDate: selectedDate, firstDate: DateTime(2020), lastDate: DateTime(2030),
          builder: (context, child) => Theme(data: ThemeData.dark().copyWith(colorScheme: ColorScheme.dark(primary: AppTheme.btnColor, onPrimary: Colors.white, surface: AppTheme.bgColor, onSurface: Colors.white), dialogBackgroundColor: AppTheme.bgColor), child: child!),
        );
        if (picked != null) onPicked(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
        child: Row(children: [const Icon(Icons.calendar_today, color: Colors.white54, size: 18), const SizedBox(width: 12), Text("${selectedDate.day}/${selectedDate.month}/${selectedDate.year}", style: const TextStyle(color: Colors.white, fontSize: 16)), const Spacer(), const Icon(Icons.arrow_drop_down, color: Colors.white54)]),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
        child: TextField(
          onChanged: (v) => setState(() => _searchQuery = v),
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: const InputDecoration(hintText: "Search by ID, Batch or Customer...", hintStyle: TextStyle(color: Colors.white38, fontSize: 13), prefixIcon: Icon(Icons.search, color: Colors.white38, size: 18), border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 12)),
        ),
      ),
    );
  }

  Widget _buildRecordList(BuildContext context, List<BaggingRecord> records) {
    final bool isTablet = Responsive.isTablet(context);
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 2 : 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 220,
      ),
      itemBuilder: (context, index) => BaggingCard(record: records[index]),
    );
  }
}

class BaggingCard extends StatelessWidget {
  final BaggingRecord record;
  const BaggingCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: Color(0xFFF9FAFB), borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, 
                    children: [
                      const Text("BAGGING ID", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey)), 
                      Text(record.baggingId, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14))
                    ]
                  ),
                ),
                IconButton(
                  onPressed: () => _showDetails(context), 
                  icon: const Icon(Icons.visibility_outlined, color: Colors.blueAccent, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _confirmDelete(context, record), 
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
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
                  Row(
                    children: [
                      _buildMiniInfoCol("BATCH", record.batchId),
                      _buildMiniInfoCol("LOCATION", record.warehouseLocation),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      _buildMiniInfoCol("BAGS", "${record.numberOfBags}"),
                      _buildMiniInfoCol("WEIGHT", "${record.totalWeight}kg"),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(color: Color(0xFFF3F4F6), borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
            child: Row(
              children: [
                Expanded(child: Text(record.customerName, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.black54), overflow: TextOverflow.ellipsis)),
                Text(
                  record.baggingDate.length >= 10 
                      ? record.baggingDate.substring(0, 10) 
                      : record.baggingDate, 
                  style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniInfoCol(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 7, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
        ],
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24, right: 24, top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Entry Details", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white54)),
                  ],
                ),
                const Divider(color: Colors.white24, height: 32),
                _detailRow("Bagging ID", record.baggingId),
                _detailRow("Batch ID", record.batchId),
                _detailRow("Supplier", record.supplierName),
                _detailRow("Customer", record.customerName),
                _detailRow("Warehouse Location", record.warehouseLocation),
                _detailRow("Number of Bags", "${record.numberOfBags}"),
                _detailRow("Weight per Bag", "${record.weightPerBag} kg"),
                _detailRow("Total Weight", "${record.totalWeight} kg"),
                _detailRow("Date", record.baggingDate.length >= 10 ? record.baggingDate.substring(0, 10) : record.baggingDate),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 14)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, BaggingRecord record) {
    showDialog(
      context: context,
      builder: (innerContext) => AlertDialog(
        backgroundColor: AppTheme.bgColor,
        title: const Text("Delete Entry", style: TextStyle(color: Colors.white)),
        content: Text("Are you sure you want to delete bagging entry ${record.baggingId}?", style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(innerContext), child: const Text("Cancel", style: TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () {
              context.read<BaggingBloc>().add(DeleteBaggingEntry(record.id));
              Navigator.pop(innerContext);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
