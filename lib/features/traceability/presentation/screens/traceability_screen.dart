import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/models/inventory_log_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/traceability_bloc.dart';
import '../bloc/traceability_event.dart';
import '../bloc/traceability_state.dart';

class TraceabilityScreen extends StatefulWidget {
  const TraceabilityScreen({super.key});

  @override
  State<TraceabilityScreen> createState() => _TraceabilityScreenState();
}

class _TraceabilityScreenState extends State<TraceabilityScreen> {
  final TextEditingController _traceController = TextEditingController();
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<TraceabilityBloc>()..add(FetchInventoryLogs()),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: AppTheme.bgColor,
            body: BlocListener<TraceabilityBloc, TraceabilityState>(
              listener: (context, state) {
                if (state is TraceabilityError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else if (state is TraceabilityActionSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (state is TraceBatchResult) {
                  _showTraceResultModal(context, state.traceData);
                }
              },
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildHeader(context),
                      const SizedBox(height: 24),
                      _buildTraceBar(context),
                      const SizedBox(height: 24),
                      Expanded(
                        child: BlocBuilder<TraceabilityBloc, TraceabilityState>(
                          builder: (context, state) {
                            if (state is TraceabilityLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (state is TraceabilityLoaded) {
                              final filteredLogs = state.logs
                                  .where(
                                    (l) =>
                                        l.batchId.toLowerCase().contains(
                                          _searchQuery.toLowerCase(),
                                        ) ||
                                        l.reason.toLowerCase().contains(
                                          _searchQuery.toLowerCase(),
                                        ),
                                  )
                                  .toList();
                              return _buildLogsList(context, filteredLogs);
                            }
                            return const Center(
                              child: Text(
                                "No logs found",
                                style: TextStyle(color: Colors.white54),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "INVENTORY",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            Text(
              "& TRACEABILITY",
              style: TextStyle(
                color: Colors.white38,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () =>
              _showAddLogModal(context, context.read<TraceabilityBloc>()),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.btnColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppTheme.btnColor.withOpacity(0.3)),
            ),
            child: Icon(Icons.add_rounded, color: AppTheme.btnColor, size: 28),
          ),
        ),
      ],
    );
  }

  Widget _buildTraceBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextField(
        controller: _traceController,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Trace Batch ID...",
          hintStyle: const TextStyle(color: Colors.white24),
          prefixIcon: const Icon(
            Icons.qr_code_scanner_rounded,
            color: Colors.white38,
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.search_rounded, color: AppTheme.btnColor),
            onPressed: () {
              if (_traceController.text.isNotEmpty) {
                context.read<TraceabilityBloc>().add(
                  TraceBatch(_traceController.text),
                );
              }
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildLogsList(BuildContext context, List<InventoryLogModel> logs) {
    if (logs.isEmpty) {
      return const Center(
        child: Text(
          "No inventory logs available",
          style: TextStyle(color: Colors.white38),
        ),
      );
    }
    return ListView.separated(
      itemCount: logs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final log = logs[index];
        return _buildLogCard(context, log);
      },
    );
  }

  Widget _buildLogCard(BuildContext context, InventoryLogModel log) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.btnColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              color: AppTheme.btnColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.batchId,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  log.reason,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "-${log.lossWeight.toStringAsFixed(1)} kg",
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
              Text(
                DateFormat('MMM dd, HH:mm').format(log.createdAt),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white38, size: 20),
            onSelected: (val) {
              if (val == 'delete') {
                context.read<TraceabilityBloc>().add(
                  DeleteInventoryLog(log.id),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'delete', child: Text("Delete")),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddLogModal(BuildContext context, TraceabilityBloc bloc) {
    final batchController = TextEditingController();
    final inputController = TextEditingController();
    final outputController = TextEditingController();
    final reasonController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bContext) => BlocProvider.value(
        value: bloc,
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bContext).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          decoration: BoxDecoration(
            color: AppTheme.bgColor.withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Create Inventory Log",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                _buildField("Batch ID", batchController, icon: Icons.qr_code),
                _buildField(
                  "Input Quantity",
                  inputController,
                  icon: Icons.input,
                  isNumber: true,
                ),
                _buildField(
                  "Output Quantity",
                  outputController,
                  icon: Icons.output,
                  isNumber: true,
                ),
                _buildField("Reason", reasonController, icon: Icons.notes),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      final data = {
                        "batchId": batchController.text,
                        "inputQty": double.tryParse(inputController.text) ?? 0,
                        "outputQty":
                            double.tryParse(outputController.text) ?? 0,
                        "reason": reasonController.text,
                      };
                      bloc.add(CreateInventoryLog(data));
                      Navigator.pop(bContext);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.btnColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "SAVE LOG",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    required IconData icon,
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white38),
          prefixIcon: Icon(icon, color: AppTheme.btnColor, size: 20),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.btnColor),
          ),
        ),
      ),
    );
  }

  void _showTraceResultModal(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1721),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Batch Traceability",
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTraceInfo("Batch ID", data['batchId'] ?? "N/A"),
              _buildTraceInfo("Input Total", "${data['inputTotal'] ?? 0} kg"),
              _buildTraceInfo("Output Total", "${data['outputTotal'] ?? 0} kg"),
              _buildTraceInfo(
                "Net Loss",
                "${(data['inputTotal'] ?? 0) - (data['outputTotal'] ?? 0)} kg",
              ),
              const SizedBox(height: 12),
              const Divider(color: Colors.white10),
              const SizedBox(height: 12),
              const Text(
                "Operational History",
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...(data['history'] as List? ?? [])
                  .map(
                    (h) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        "• ${h['action']} - ${DateFormat('MMM dd').format(DateTime.parse(h['date']))}",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("CLOSE", style: TextStyle(color: AppTheme.btnColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildTraceInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
