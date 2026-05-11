import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/services/injection_container.dart';
import '../../domain/models/export_record.dart';
import '../bloc/export_bloc.dart';
import '../bloc/export_event.dart';
import '../bloc/export_state.dart';

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
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocBuilder<ExportBloc, ExportState>(
          builder: (context, state) {
            if (state is ExportLoading) {
              return const Center(child: CircularProgressIndicator(color: Colors.white70));
            } else if (state is ExportLoaded) {
              final filteredRecords = state.records.where((r) {
                return r.shipmentId.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                       r.customer.toLowerCase().contains(_searchQuery.toLowerCase());
              }).toList();

              return Column(
                children: [
                  _buildHeader(state.records),
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
    );
  }

  Widget _buildHeader(List<ExportRecord> records) {
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
              child: _buildActionCard(),
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

  Widget _buildActionCard() {
    return Container(
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
                _buildDocItem("Commercial Invoice", record.documents['commercialInvoice'] ?? 'Pending'),
                _buildDocItem("Packing List", record.documents['packingList'] ?? 'Pending'),
                _buildDocItem("Certificate of Origin", record.documents['certificateOfOrigin'] ?? 'Pending'),
                _buildDocItem("Inspection Certificate", record.documents['inspectionCert'] ?? 'Pending'),
                _buildDocItem("Bill of Lading", record.documents['billOfLading'] ?? 'Pending'),
                _buildDocItem("Customs Documents", record.documents['customsDocs'] ?? 'Pending'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocItem(String name, String status) {
    bool isAvailable = status.toLowerCase() != 'pending';
    return Container(
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
          _buildActionIcon(isAvailable),
        ],
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
