import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/injection_container.dart';
import '../bloc/weighbridge_bloc.dart';
import '../bloc/weighbridge_event.dart';
import '../bloc/weighbridge_state.dart';
import '../../domain/models/weighbridge_record.dart';
import '../../../client_mgmt/domain/repository/clients_repository.dart';
import '../../../client_mgmt/domain/models/client.dart';
import '../../../yard_intake/domain/repository/yard_intake_repository.dart';
import '../../../yard_intake/data/models/yard_intake_model.dart';
import 'package:dartz/dartz.dart' as dartz;

class WeighbridgeScreen extends StatefulWidget {
  const WeighbridgeScreen({super.key});

  @override
  State<WeighbridgeScreen> createState() => _WeighbridgeScreenState();
}

class _WeighbridgeScreenState extends State<WeighbridgeScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<WeighbridgeBloc>()..add(FetchWeighbridgeLogs()),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
            onPressed: () => _showAddLogModal(context),
            backgroundColor: AppTheme.btnColor,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
        body: BlocBuilder<WeighbridgeBloc, WeighbridgeState>(
          builder: (context, state) {
            if (state is WeighbridgeLoading) {
              return const Center(child: CircularProgressIndicator(color: Colors.white70));
            } else if (state is WeighbridgeLoaded) {
              final filteredLogs = state.logs.where((log) {
                return log.vehicleNo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                       log.supplierName.toLowerCase().contains(_searchQuery.toLowerCase());
              }).toList();

              return Column(
                children: [
                  _buildHeader(state.logs),
                  _buildSearchSection(),
                  Expanded(
                    child: _buildLogList(context, filteredLogs),
                  ),
                ],
              );
            } else if (state is WeighbridgeError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                    const SizedBox(height: 16),
                    Text(state.message, style: const TextStyle(color: Colors.white70)),
                    TextButton(
                      onPressed: () => context.read<WeighbridgeBloc>().add(FetchWeighbridgeLogs()),
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

  Widget _buildHeader(List<WeighbridgeRecord> logs) {
    int activeLogs = logs.where((l) => l.status == 'In-Progress').length;
    int completedLogs = logs.where((l) => l.status == 'Completed').length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          _buildStatItem("ACTIVE", "$activeLogs", Colors.blueAccent, Icons.timer_outlined),
          const SizedBox(width: 12),
          _buildStatItem("COMPLETED", "$completedLogs", Colors.greenAccent, Icons.check_circle_outline),
          const SizedBox(width: 12),
          _buildStatItem("TOTAL TODAY", "${logs.length}", Colors.orangeAccent, Icons.analytics_outlined),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color.withOpacity(0.7), size: 20),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          onChanged: (v) => setState(() => _searchQuery = v),
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: const InputDecoration(
            hintText: "Search Vehicle or Supplier...",
            hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
            prefixIcon: Icon(Icons.search, color: Colors.white38, size: 18),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildLogList(BuildContext context, List<WeighbridgeRecord> logs) {
    return RefreshIndicator(
      onRefresh: () async => context.read<WeighbridgeBloc>().add(FetchWeighbridgeLogs()),
      color: AppTheme.btnColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: logs.length,
        itemBuilder: (context, index) => WeighbridgeLogCard(record: logs[index]),
      ),
    );
  }

  void _showAddLogModal(BuildContext context) async {
    final weighbridgeBloc = context.read<WeighbridgeBloc>();
    final List<Client> clients = await sl<ClientsRepository>().getClients();
    final yardIntakeResult = await sl<YardIntakeRepository>().getYardIntake();
    
    List<YardIntakeModel> yardIntakes = [];
    yardIntakeResult.fold((l) => null, (r) => yardIntakes = r);

    if (!mounted) return;

    final formKey = GlobalKey<FormState>();
    final grossController = TextEditingController();
    final tareController = TextEditingController();
    final netController = TextEditingController();

    String selectedType = "Inbound";
    String? selectedVehicle;
    String? selectedSupplier;
    String selectedStatus = "Completed";

    void calculateNet() {
      final gross = double.tryParse(grossController.text) ?? 0;
      final tare = double.tryParse(tareController.text) ?? 0;
      netController.text = (gross - tare).toString();
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: const Color(0xFFF9FAFB),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text("Create Weighbridge Log", style: TextStyle(fontWeight: FontWeight.w900)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildModalDropdown("Log Type", selectedType, ["Inbound", "Outbound"], (val) {
                    setModalState(() => selectedType = val!);
                  }),
                  const SizedBox(height: 16),
                  _buildModalDropdown("Vehicle Number", selectedVehicle, yardIntakes.map((i) => i.vehicleNumber).toSet().toList().cast<String>(), (val) {
                    setModalState(() => selectedVehicle = val);
                  }),
                  const SizedBox(height: 16),
                  _buildModalDropdown("Supplier/Client", selectedSupplier, clients.map((c) => c.name).toSet().toList().cast<String>(), (val) {
                    setModalState(() => selectedSupplier = val);
                  }),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildModalTextField("Gross Weight (kg)", grossController, keyboardType: TextInputType.number, onChanged: (v) => calculateNet()),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildModalTextField("Tare Weight (kg)", tareController, keyboardType: TextInputType.number, onChanged: (v) => calculateNet()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildModalTextField("Net Weight (kg)", netController, enabled: false),
                  const SizedBox(height: 16),
                  _buildModalDropdown("Status", selectedStatus, ["In-Progress", "Completed"], (val) {
                    setModalState(() => selectedStatus = val!);
                  }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate() && selectedVehicle != null && selectedSupplier != null) {
                  weighbridgeBloc.add(CreateWeighbridgeLog(data: {
                    "vehicleNo": selectedVehicle,
                    "type": selectedType,
                    "supplierName": selectedSupplier,
                    "grossWeight": double.parse(grossController.text),
                    "tareWeight": double.parse(tareController.text),
                    "netWeight": double.parse(netController.text),
                    "status": selectedStatus,
                    "dateTime": DateTime.now().toIso8601String(),
                  }));
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.btnColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text("CREATE LOG", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModalTextField(String label, TextEditingController controller, {bool enabled = true, TextInputType? keyboardType, Function(String)? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          onChanged: onChanged,
          validator: (v) => v == null || v.isEmpty ? "Required" : null,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey.withOpacity(0.1),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.withOpacity(0.2))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.withOpacity(0.2))),
          ),
        ),
      ],
    );
  }

  Widget _buildModalDropdown(String label, String? value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          validator: (v) => v == null ? "Required" : null,
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)))).toList(),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.withOpacity(0.2))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.withOpacity(0.2))),
          ),
        ),
      ],
    );
  }
}

class WeighbridgeLogCard extends StatelessWidget {
  final WeighbridgeRecord record;
  const WeighbridgeLogCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFFBFBFB),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: (record.type == 'Inbound' ? Colors.blue : Colors.orange).withOpacity(0.1),
                  child: Icon(
                    record.type == 'Inbound' ? Icons.login : Icons.logout,
                    color: record.type == 'Inbound' ? Colors.blue : Colors.orange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(record.vehicleNo, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                          _buildStatusChip(record.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(record.supplierName, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildWeightInfo("Gross", "${record.grossWeight} kg", Colors.black87),
                    _buildWeightInfo("Tare", "${record.tareWeight} kg", Colors.grey),
                    _buildWeightInfo("Net", "${record.netWeight} kg", AppTheme.btnColor),
                  ],
                ),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('dd MMM yyyy, HH:mm').format(record.dateTime),
                          style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Text(
                      record.type.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: record.type == 'Inbound' ? Colors.blue : Colors.orange,
                        letterSpacing: 1,
                      ),
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

  Widget _buildWeightInfo(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color)),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    bool isCompleted = status == 'Completed';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isCompleted ? Colors.green : Colors.blue).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: isCompleted ? Colors.green : Colors.blue, fontSize: 9, fontWeight: FontWeight.w900),
      ),
    );
  }
}
