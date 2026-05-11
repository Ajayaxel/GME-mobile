import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/services/injection_container.dart';
import '../../domain/models/processing_batch.dart';
import '../bloc/processing_bloc.dart';
import '../bloc/processing_event.dart';
import '../bloc/processing_state.dart';

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ProcessingBloc>()..add(FetchProcessingBatches()),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocBuilder<ProcessingBloc, ProcessingState>(
          builder: (context, state) {
            if (state is ProcessingLoading) {
              return const Center(child: CircularProgressIndicator(color: Colors.white70));
            } else if (state is ProcessingLoaded) {
              final filteredBatches = state.batches
                  .where((b) => b.batchId.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                                b.supplierName.toLowerCase().contains(_searchQuery.toLowerCase()))
                  .toList();

              return Column(
                children: [
                  _buildHeader(state.batches),
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
    );
  }

  Widget _buildHeader(List<ProcessingBatch> batches) {
    final pendingCount = batches.where((b) => b.status.toLowerCase() != 'completed').length;
    final completedCount = batches.length - pendingCount;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: IntrinsicHeight(
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
          const Spacer(),
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
          mainAxisExtent: isTablet ? 320 : 260,
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
                        const Text(
                          "Status",
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
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
}
