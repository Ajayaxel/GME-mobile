import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/services/injection_container.dart';
import '../../domain/models/export_record.dart';
import '../bloc/export_bloc.dart';
import '../bloc/export_event.dart';
import '../bloc/export_state.dart';
import 'package:file_picker/file_picker.dart';
import '../../../dispatch/domain/repository/dispatch_repository.dart';
import '../../../dispatch/domain/models/dispatch_record.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ExportBloc>()..add(FetchExportRecords()),
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: Colors.transparent,
          body: BlocListener<ExportBloc, ExportState>(
            listener: (context, state) {
              if (state is ExportActionSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: Colors.green),
                );
              } else if (state is ExportError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent),
                );
              }
            },
            child: BlocBuilder<ExportBloc, ExportState>(
              builder: (context, state) {
                if (state is ExportLoading) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white70));
                } else if (state is ExportLoaded || state is ExportActionSuccess) {
                  final records = (state is ExportLoaded) 
                      ? state.records 
                      : (context.read<ExportBloc>().state is ExportLoaded 
                          ? (context.read<ExportBloc>().state as ExportLoaded).records 
                          : <ExportRecord>[]);
                  
                  final filteredRecords = records.where((r) {
                    return r.shipmentId.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                           r.customer.toLowerCase().contains(_searchQuery.toLowerCase());
                  }).toList();

                  return Column(
                    children: [
                      _buildHeader(context, records),
                      _buildSearchSection(),
                      Expanded(
                        child: _buildRecordList(context, filteredRecords),
                      ),
                    ],
                  );
                } else if (state is ExportError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                        const SizedBox(height: 16),
                        Text(state.message, style: const TextStyle(color: Colors.white70)),
                        TextButton(
                          onPressed: () => context.read<ExportBloc>().add(FetchExportRecords()),
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
      ),
    );
  }

  Widget _buildHeader(BuildContext context, List<ExportRecord> records) {
    int pendingDocs = 0;
    for (var r in records) {
      pendingDocs += r.documents.values.where((v) => v.toLowerCase() == 'pending').length;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: IntrinsicHeight(
        child: Row(
          children: [
            SizedBox(
              width: 100,
              child: _buildStatItem("ACTIVE", "${records.length}", Colors.blueAccent, Icons.shop),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 100,
              child: _buildStatItem("PENDING DOCS", "$pendingDocs", Colors.orangeAccent, Icons.description_outlined),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 100,
              child: _buildStatItem("COMPLIANCE", "99.2%", Colors.greenAccent, Icons.verified_user_outlined),
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
          Text(
            value,
            style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w900),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 7, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
  Widget _buildActionCard(BuildContext context) {
    return InkWell(
      onTap: () => _showAddShipmentModal(context),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [AppTheme.btnColor, AppTheme.btnColor.withOpacity(0.8)]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_task_outlined, color: Colors.white, size: 20),
            SizedBox(height: 4),
            Text("NEW SHIPMENT", style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _showAddShipmentModal(BuildContext context) async {
    final exportBloc = context.read<ExportBloc>();
    final TextEditingController shipmentIdController = TextEditingController(
      text: "SHIP-${DateTime.now().year}-${100 + (DateTime.now().millisecond % 900)}"
    );
    final TextEditingController customerController = TextEditingController();
    final TextEditingController destinationController = TextEditingController();
    
    String? selectedDispatch;
    List<DispatchRecord> dispatches = [];

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    try {
      dispatches = await sl<DispatchRepository>().getRecords();
      Navigator.pop(context);
    } catch (e) {
      Navigator.pop(context);
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: const Color(0xFFF9FAFB),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Initialize New Shipment", style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildModalTextField("Shipment ID", shipmentIdController, enabled: false),
                const SizedBox(height: 16),
                _buildModalDropdown("Linked Dispatch (Optional)", selectedDispatch, dispatches.map((d) => d.dispatchId).toList().cast<String>(), (val) {
                  setModalState(() {
                    selectedDispatch = val;
                    final dispatch = dispatches.firstWhere((d) => d.dispatchId == val);
                    customerController.text = dispatch.customerName;
                    destinationController.text = dispatch.destination;
                  });
                }),
                const SizedBox(height: 16),
                _buildModalTextField("Customer/Client", customerController),
                const SizedBox(height: 16),
                _buildModalTextField("Destination", destinationController),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                if (customerController.text.isEmpty || destinationController.text.isEmpty) return;
                exportBloc.add(CreateExportRecord(record: {
                  "shipmentId": shipmentIdController.text,
                  "dispatchId": selectedDispatch,
                  "customer": customerController.text,
                  "destination": destinationController.text,
                  "status": "In Progress"
                }));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.btnColor, foregroundColor: Colors.white),
              child: const Text("Create"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModalTextField(String label, TextEditingController controller, {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[200],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildModalDropdown(String label, String? value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              hint: const Text("Select Dispatch"),
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
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
          textAlignVertical: TextAlignVertical.center,
          decoration: const InputDecoration(
            hintText: "Search Shipment ID or Customer...",
            hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
            prefixIcon: Icon(Icons.search, color: Colors.white38, size: 18),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }

  Widget _buildRecordList(BuildContext context, List<ExportRecord> records) {
    return RefreshIndicator(
      onRefresh: () async => context.read<ExportBloc>().add(FetchExportRecords()),
      color: AppTheme.btnColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: records.length,
        itemBuilder: (context, index) => ExportRecordCard(record: records[index]),
      ),
    );
  }
}

class ExportRecordCard extends StatelessWidget {
  final ExportRecord record;
  const ExportRecordCard({super.key, required this.record});

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
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFFBFBFB),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.btnColor.withOpacity(0.1),
                  child: Icon(Icons.local_shipping_outlined, color: AppTheme.btnColor, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text(
                            record.shipmentId,
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                            overflow: TextOverflow.ellipsis,
                          ),
                          _buildStatusChip(record.status),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${record.customer} • Destination: ${record.destination}",
                        style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (record.dispatchId != null)
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        "Batch: ${record.dispatchId}",
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Document Table
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 8),
                  child: Text("EXPORT DOCUMENTATION CHECKLIST", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 0.5)),
                ),
                _buildDocItem(context, "Commercial Invoice", "commercialInvoice", record.documents['commercialInvoice'] ?? 'Pending'),
                _buildDocItem(context, "Packing List", "packingList", record.documents['packingList'] ?? 'Pending'),
                _buildDocItem(context, "Certificate of Origin", "certificateOfOrigin", record.documents['certificateOfOrigin'] ?? 'Pending'),
                _buildDocItem(context, "Inspection Certificate", "inspectionCert", record.documents['inspectionCert'] ?? 'Pending'),
                _buildDocItem(context, "Bill of Lading", "billOfLading", record.documents['billOfLading'] ?? 'Pending'),
                _buildDocItem(context, "Customs Documents", "customsDocs", record.documents['customsDocs'] ?? 'Pending'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocItem(BuildContext context, String name, String docKey, String status) {
    bool isAvailable = status.toLowerCase() != 'pending';
    return InkWell(
      onLongPress: isAvailable ? () {
        showDialog(
          context: context,
          builder: (dContext) => AlertDialog(
            title: const Text("Delete Document"),
            content: Text("Are you sure you want to delete the $name?"),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dContext), child: const Text("Cancel")),
              TextButton(
                onPressed: () {
                  context.read<ExportBloc>().add(DeleteExportDocument(id: record.id, docKey: docKey));
                  Navigator.pop(dContext);
                }, 
                child: const Text("Delete", style: TextStyle(color: Colors.red))
              ),
            ],
          ),
        );
      } : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: isAvailable ? const Color(0xFFF0FDF4) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isAvailable ? Colors.green.withOpacity(0.1) : Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(isAvailable ? Icons.check_circle_rounded : Icons.radio_button_unchecked, size: 16, color: isAvailable ? Colors.green : Colors.grey[400]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isAvailable ? const Color(0xFF166534) : Colors.black87),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            Text(isAvailable ? "AVAILABLE" : "PENDING", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: isAvailable ? Colors.green : Colors.orange)),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () async {
                if (!isAvailable) {
                  final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'jpg', 'png']);
                  if (result != null && result.files.single.path != null) {
                    context.read<ExportBloc>().add(UploadExportDocument(
                      id: record.id, 
                      docKey: docKey, 
                      filePath: result.files.single.path!
                    ));
                  }
                } else {
                  // View/Download logic could go here
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Document already uploaded. Long press to delete.")));
                }
              },
              child: _buildActionIcon(isAvailable)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionIcon(bool isAvailable) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.withOpacity(0.2))),
      child: Icon(isAvailable ? Icons.download_rounded : Icons.upload_rounded, size: 14, color: AppTheme.btnColor),
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(status.toUpperCase(), style: const TextStyle(color: Colors.blue, fontSize: 8, fontWeight: FontWeight.w900)),
    );
  }
}
