import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/services/injection_container.dart';
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
    return BlocProvider(
      create: (context) => sl<AssayingBloc>()..add(FetchAssayingRecords()),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocBuilder<AssayingBloc, AssayingState>(
          builder: (context, state) {
            if (state is AssayingLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white70),
              );
            } else if (state is AssayingLoaded) {
              final filteredRecords = state.records.where((r) {
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
                  _buildHeader(state.records),
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
    );
  }

  Widget _buildHeader(List<AssayingRecord> records) {
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
              child: _buildActionCard(),
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
          const Spacer(),
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

  Widget _buildActionCard() {
    return Container(
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
        mainAxisExtent: isTablet ? 320 : 280,
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
                _buildStatTile("Purity", record.purity),
                _buildStatTile("Submitted", record.submittedDate),
                _buildStatTile("Result Date", record.resultDate),
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
