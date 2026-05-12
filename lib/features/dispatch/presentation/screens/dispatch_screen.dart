import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/services/injection_container.dart';
import '../../domain/models/dispatch_record.dart';
import '../bloc/dispatch_bloc.dart';
import '../bloc/dispatch_event.dart';
import '../bloc/dispatch_state.dart';
import '../../../settings/domain/repository/settings_repository.dart';
import '../../../processing/domain/repository/processing_repository.dart';
import '../../../processing/domain/models/processing_batch.dart';
import '../../../yard_intake/domain/repository/yard_intake_repository.dart';
import '../../../yard_intake/data/models/yard_intake_model.dart';
import 'package:intl/intl.dart';

class DispatchScreen extends StatefulWidget {
  const DispatchScreen({super.key});

  @override
  State<DispatchScreen> createState() => _DispatchScreenState();
}

class _DispatchScreenState extends State<DispatchScreen> {
  String _searchQuery = "";
  String _statusFilter = "All";

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DispatchBloc>()..add(FetchDispatchRecords()),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocBuilder<DispatchBloc, DispatchState>(
          builder: (context, state) {
            if (state is DispatchLoading) {
              return const Center(child: CircularProgressIndicator(color: Colors.white70));
            } else if (state is DispatchLoaded) {
              final filteredRecords = state.records.where((r) {
                final matchesSearch = r.dispatchId.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                                     r.batchId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                                     r.supplierName.toLowerCase().contains(_searchQuery.toLowerCase());
                final matchesStatus = _statusFilter == "All" || r.status.toLowerCase() == _statusFilter.toLowerCase();
                return matchesSearch && matchesStatus;
              }).toList();

              return Column(
                children: [
                  _buildHeader(context, state.records),
                  _buildFilterSection(),
                  Expanded(
                    child: _buildRecordList(context, filteredRecords),
                  ),
                ],
              );
            } else if (state is DispatchError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                    const SizedBox(height: 16),
                    Text(state.message, style: const TextStyle(color: Colors.white70)),
                    TextButton(
                      onPressed: () => context.read<DispatchBloc>().add(FetchDispatchRecords()),
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
    );
  }

  Widget _buildHeader(BuildContext context, List<DispatchRecord> records) {
    final pendingCount = records.where((r) => r.status.toLowerCase() == 'loaded').length;
    final inTransitCount = records.where((r) => r.status.toLowerCase() == 'in transit').length;
    final deliveredCount = records.where((r) => r.status.toLowerCase() == 'delivered').length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: IntrinsicHeight(
        child: Row(
          children: [
            SizedBox(width: 100, child: _buildStatItem("PENDING", "$pendingCount", Colors.orangeAccent, Icons.hourglass_empty_rounded)),
            const SizedBox(width: 8),
            SizedBox(width: 100, child: _buildStatItem("IN TRANSIT", "$inTransitCount", Colors.blueAccent, Icons.local_shipping_outlined)),
            const SizedBox(width: 8),
            SizedBox(width: 100, child: _buildStatItem("DELIVERED", "$deliveredCount", Colors.greenAccent, Icons.task_alt_rounded)),
            const SizedBox(width: 8),
            SizedBox(width: 100, child: _buildStatItem("ON-TIME", "98%", AppTheme.btnColor, Icons.timer_outlined)),
            const SizedBox(width: 8),
            SizedBox(width: 100, child: _buildActionCard(context),),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
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
          const Spacer(),
          Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w900), overflow: TextOverflow.ellipsis, maxLines: 1),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 7, fontWeight: FontWeight.bold, letterSpacing: 0.5), overflow: TextOverflow.ellipsis, maxLines: 1),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAddDispatchModal(context),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [AppTheme.btnColor, AppTheme.btnColor.withOpacity(0.8)]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_road_outlined, color: Colors.white, size: 20),
            SizedBox(height: 4),
            Text("NEW DISPATCH", style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, maxLines: 1),
          ],
        ),
      ),
    );
  }

  void _showAddDispatchModal(BuildContext context) async {
    final dispatchBloc = context.read<DispatchBloc>();
    final TextEditingController dispatchIdController = TextEditingController(
      text: "DISP-${DateTime.now().year}-${DateFormat('SSS').format(DateTime.now())}${100 + (DateTime.now().millisecond % 900)}"
    );
    final TextEditingController loadingWeightController = TextEditingController(text: "0");
    final TextEditingController driverNameController = TextEditingController();
    final TextEditingController contactNumberController = TextEditingController();
    final TextEditingController dispatchDateController = TextEditingController(text: DateFormat('dd/MM/yyyy').format(DateTime.now()));
    final TextEditingController vehicleNumberController = TextEditingController();
    
    String? selectedBatch;
    String? selectedDestination;
    String customerName = "N/A";
    String supplierName = "N/A";

    final formKey = GlobalKey<FormState>();

    List<ProcessingBatch> batches = [];
    List<YardIntakeModel> intakes = [];
    List<String> vehicles = [];
    List<String> destinations = [];

    // Show loading dialog while fetching data
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator(color: AppTheme.btnColor)),
    );

    try {
      batches = await sl<ProcessingRepository>().getProcessingBatches();
      final settings = await sl<SettingsRepository>().getCompanySettings();
      final List<String> registeredVehicles = settings.vehicles;
      destinations = settings.destinations;
      
      final intakeResult = await sl<YardIntakeRepository>().getYardIntake();
      intakeResult.fold(
        (l) => null,
        (r) {
          intakes = r;
          // Combine registered vehicles with vehicles from yard intake, and ensure uniqueness
          final intakeVehicles = r.map((i) => i.vehicleNumber).where((v) => v.isNotEmpty).toList();
          vehicles = {...registeredVehicles, ...intakeVehicles}.toList();
          vehicles.sort();
        }
      );
      
      Navigator.pop(context); // Close loading dialog
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching data: $e")));
      return;
    }

    showDialog(
      context: context,
      builder: (modalContext) => StatefulBuilder(
        builder: (modalContext, setModalState) => AlertDialog(
          backgroundColor: const Color(0xFFF9FAFB),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: EdgeInsets.zero,
          content: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.all(24),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Create New Dispatch", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
                            SizedBox(height: 4),
                            Text("Schedule a new shipment dispatch and assign container/truck", style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildModalTextField("Dispatch ID", dispatchIdController, enabled: false),
                        const SizedBox(height: 16),
                        _buildModalDropdown("Select Batch", selectedBatch, batches.map((b) => b.batchId).toList(), (val) {
                          setModalState(() {
                            selectedBatch = val;
                            final batch = batches.firstWhere((b) => b.batchId == val);
                            customerName = batch.customerName;
                            supplierName = batch.supplierName;
                            
                            if (batch.grnReference != 'N/A' && batch.grnReference.isNotEmpty) {
                              final intake = intakes.where((i) => i.grnNumber == batch.grnReference).firstOrNull;
                              if (intake != null) {
                                vehicleNumberController.text = intake.vehicleNumber;
                              }
                            }
                          });
                        }, validator: (v) => v == null ? "Required" : null),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildModalTextField("Company Name", TextEditingController(text: customerName), enabled: false),
                        const SizedBox(height: 16),
                        const Text("Container/Truck Number", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF374151))),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildModalTextField("", vehicleNumberController, showLabel: false, validator: (v) => (v == null || v.isEmpty) ? "Required" : null)),
                            const SizedBox(width: 8),
                            Container(
                              height: 48,
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey[200]!)),
                              child: IconButton(
                                icon: const Icon(Icons.search, color: Colors.grey, size: 20),
                                onPressed: () {
                                  _showSearchableListModal(
                                    context, 
                                    "Select Vehicle", 
                                    vehicles, 
                                    (val) => setModalState(() => vehicleNumberController.text = val)
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildModalTextField("Loading Weight (kg)", loadingWeightController, keyboardType: TextInputType.number, validator: (v) => (v == null || v.isEmpty || v == "0") ? "Required" : null),
                        const SizedBox(height: 16),
                        _buildModalDropdown("Destination", selectedDestination, destinations, (val) {
                          setModalState(() => selectedDestination = val);
                        }, validator: (v) => v == null ? "Required" : null),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildModalTextField(
                          "Dispatch Date", 
                          dispatchDateController, 
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context, 
                              initialDate: DateTime.now(), 
                              firstDate: DateTime(2000), 
                              lastDate: DateTime(2100)
                            );
                            if (date != null) {
                              dispatchDateController.text = DateFormat('dd/MM/yyyy').format(date);
                            }
                          }
                        ),
                        const SizedBox(height: 16),
                        _buildModalTextField("Driver Name", driverNameController, validator: (v) => (v == null || v.isEmpty) ? "Required" : null),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildModalTextField("Contact Number", contactNumberController, keyboardType: TextInputType.phone, validator: (v) => (v == null || v.isEmpty) ? "Required" : null),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(modalContext),
                          child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (formKey.currentState?.validate() != true) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all required fields correctly")));
                              return;
                            }
                            
                            dispatchBloc.add(CreateDispatchRecord(record: {
                              "dispatchId": dispatchIdController.text,
                              "batchId": selectedBatch,
                              "customerName": customerName,
                              "supplierName": supplierName,
                              "containerNumber": vehicleNumberController.text,
                              "loadingWeight": double.tryParse(loadingWeightController.text) ?? 0,
                              "destination": selectedDestination,
                              "dispatchDate": dispatchDateController.text,
                              "driverName": driverNameController.text,
                              "contactNumber": contactNumberController.text,
                              "status": "Loaded"
                            }));
                            Navigator.pop(modalContext);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF064E3B),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.add_road_outlined, size: 18),
                          label: const Text("Create Dispatch", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModalTextField(String label, TextEditingController controller, {bool enabled = true, bool showLabel = true, TextInputType? keyboardType, VoidCallback? onTap, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF374151))),
        if (showLabel) const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          readOnly: onTap != null,
          onTap: onTap,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[200]!)),
            errorStyle: const TextStyle(fontSize: 10, height: 0.8),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  void _showSearchableListModal(BuildContext context, String title, List<String> items, Function(String) onSelected) {
    String searchQuery = "";
    showDialog(
      context: context,
      builder: (modalContext) => StatefulBuilder(
        builder: (modalContext, setModalState) {
          final filteredItems = items.where((i) => i.toLowerCase().contains(searchQuery.toLowerCase())).toList();
          
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => Navigator.pop(modalContext), icon: const Icon(Icons.close)),
              ],
            ),
            content: SizedBox(
              width: 400,
              height: 500,
              child: Column(
                children: [
                  TextField(
                    onChanged: (val) => setModalState(() => searchQuery = val),
                    decoration: InputDecoration(
                      hintText: "Search...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      itemCount: filteredItems.length,
                      separatorBuilder: (context, index) => Divider(color: Colors.grey[100]),
                      itemBuilder: (context, index) => ListTile(
                        title: Text(filteredItems[index], style: const TextStyle(fontWeight: FontWeight.w600)),
                        onTap: () {
                          onSelected(filteredItems[index]);
                          Navigator.pop(modalContext);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModalDropdown(String label, String? value, List<String> items, Function(String?) onChanged, {String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF374151))),
        const SizedBox(height: 8),
        FormField<String>(
          validator: validator,
          builder: (state) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: state.hasError ? Colors.redAccent : Colors.grey[200]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: value,
                    hint: const Text("Select option", style: TextStyle(fontSize: 14, color: Colors.grey)),
                    items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
                    onChanged: (val) {
                      onChanged(val);
                      state.didChange(val);
                    },
                  ),
                ),
              ),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 8),
                  child: Text(state.errorText!, style: const TextStyle(color: Colors.redAccent, fontSize: 10)),
                ),
            ],
          ),
        ),
      ],
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
                  hintText: "Search ID or Company...",
                  hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                  prefixIcon: Icon(Icons.search, color: Colors.white38, size: 18),
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
              items: ["All", "Loaded", "In Transit", "Delivered"].map((String s) {
                return DropdownMenuItem<String>(value: s, child: Text(s));
              }).toList(),
              onChanged: (v) => setState(() => _statusFilter = v!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordList(BuildContext context, List<DispatchRecord> records) {
    final bool isTablet = Responsive.isTablet(context);
    return RefreshIndicator(
      onRefresh: () async => context.read<DispatchBloc>().add(FetchDispatchRecords()),
      color: AppTheme.btnColor,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: records.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isTablet ? 2 : 1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          mainAxisExtent: isTablet ? 340 : 300,
        ),
        itemBuilder: (context, index) => DispatchCard(record: records[index]),
      ),
    );
  }
}

class DispatchCard extends StatelessWidget {
  final DispatchRecord record;
  const DispatchCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final bool isTablet = Responsive.isTablet(context);
    Color statusColor;
    switch (record.status.toLowerCase()) {
      case 'delivered': statusColor = Colors.green; break;
      case 'in transit': statusColor = Colors.blue; break;
      default: statusColor = Colors.orange;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          // Header
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
                        const Text("DISPATCH ID", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey)),
                        Text(
                          record.dispatchId,
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                ),
                _buildStatusChip(record.status, statusColor),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    final dispatchBloc = context.read<DispatchBloc>();
                    showDialog(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text("Delete Dispatch"),
                        content: const Text("Are you sure you want to delete this dispatch record?"),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Cancel")),
                          TextButton(
                            onPressed: () {
                              dispatchBloc.add(DeleteDispatchRecord(id: record.id));
                              Navigator.pop(dialogContext);
                            }, 
                            child: const Text("Delete", style: TextStyle(color: Colors.red))
                          ),
                        ],
                      ),
                    );
                  }, 
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
                  _buildMiniRow(Icons.link, "Batch ID", record.batchId),
                  const SizedBox(height: 8),
                  _buildMiniRow(Icons.business_outlined, "Company", record.supplierName),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _buildMiniRow(Icons.inventory_2_outlined, "Container/Truck", record.containerNumber)),
                      Expanded(child: _buildMiniRow(Icons.monitor_weight_outlined, "Weight", "${record.loadingWeight} kg")),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildMiniRow(Icons.place_outlined, "Destination", record.destination),
                ],
              ),
            ),
          ),
          // Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(color: Color(0xFFF9FAFB), borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatTile("Dispatch", record.dispatchDate),
                _buildStatTile("Delivery", record.deliveryDate),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.2))),
      child: Text(label.toUpperCase(), style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
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
              Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF374151)), overflow: TextOverflow.ellipsis),
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
        Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
      ],
    );
  }
}
