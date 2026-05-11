import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/services/injection_container.dart';
import '../../domain/models/dispatch_record.dart';
import '../bloc/dispatch_bloc.dart';
import '../bloc/dispatch_event.dart';
import '../bloc/dispatch_state.dart';

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
                  _buildHeader(state.records),
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

  Widget _buildHeader(List<DispatchRecord> records) {
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
            SizedBox(width: 100, child: _buildActionCard(),),
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

  Widget _buildActionCard() {
    return Container(
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
