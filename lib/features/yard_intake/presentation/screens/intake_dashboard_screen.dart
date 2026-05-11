import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gme/core/widgets/app_button.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/services/injection_container.dart';
import '../../../../core/widgets/confirmation_sheet.dart';
import '../widgets/intake_edit_sheet.dart';
import '../widgets/intake_create_sheet.dart';
import '../bloc/yard_intake_bloc.dart';
import '../bloc/yard_intake_event.dart';
import '../bloc/yard_intake_state.dart';
import '../../data/models/yard_intake_model.dart';

class IntakeDashboardScreen extends StatelessWidget {
  const IntakeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<YardIntakeBloc>()..add(FetchYardIntake()),
      child: Scaffold(
        backgroundColor: AppTheme.bgColor,
        body: BlocListener<YardIntakeBloc, YardIntakeState>(
          listener: (context, state) {
            if (state is YardIntakeDeleteSuccess || 
                state is YardIntakeUpdateSuccess || 
                state is YardIntakeCreateSuccess) {
              String msg = "Action";
              if (state is YardIntakeDeleteSuccess) msg = "Record deleted";
              if (state is YardIntakeUpdateSuccess) msg = "Record updated";
              if (state is YardIntakeCreateSuccess) msg = "Record created";
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("$msg successfully")),
              );
              context.read<YardIntakeBloc>().add(FetchYardIntake());
            } else if (state is YardIntakeError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          child: BlocBuilder<YardIntakeBloc, YardIntakeState>(
            builder: (context, state) {
              if (state is YardIntakeLoading || 
                  state is YardIntakeDeleteLoading || 
                  state is YardIntakeUpdateLoading ||
                  state is YardIntakeCreateLoading) {
                return _buildLoadingShimmer(context);
              } else if (state is YardIntakeLoaded) {
                return _buildContent(context, state.intakeList);
              } else if (state is YardIntakeError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.message, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<YardIntakeBloc>().add(FetchYardIntake()),
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<YardIntakeModel> intakeList) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: EdgeInsets.all(Responsive.horizontalPadding(context) / 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Intake Records",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showCreateSheet(context, intakeList),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Create"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.btnColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildTableHeader(context),
            const SizedBox(height: 10),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: intakeList.length,
              separatorBuilder: (context, index) => const Divider(color: Colors.white10),
              itemBuilder: (context, index) {
                return _buildIntakeRow(context, intakeList[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(BuildContext context) {
    bool isTablet = Responsive.isTablet(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _headerCell("GRN #", flex: 2),
          _headerCell("Company", flex: 3),
          if (isTablet) _headerCell("Vehicle", flex: 2),
          if (isTablet) _headerCell("Status", flex: 2),
          if (isTablet) _headerCell("Material", flex: 3),
          _headerCell("Net Wt", flex: 2),
          _headerCell("Actions", flex: 2),
        ],
      ),
    );
  }

  Widget _headerCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildIntakeRow(BuildContext context, YardIntakeModel intake) {
    bool isTablet = Responsive.isTablet(context);
    
    // Format material name
    String materialName = intake.materialTypes.isNotEmpty 
        ? intake.materialTypes.map((e) => e.name).join(", ")
        : "N/A";

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        children: [
          _dataCell(intake.grnNumber, flex: 2, color: Colors.orangeAccent),
          _dataCell(intake.supplierName, flex: 3),
          if (isTablet) _dataCell(intake.vehicleNumber, flex: 2),
          if (isTablet) _statusCell(intake.status, flex: 2),
          if (isTablet) _dataCell(materialName, flex: 3, isItalic: true),
          _dataCell("${intake.netWeight.toStringAsFixed(1)} kg", flex: 2),
          _actionCell(context, intake, flex: 2),
        ],
      ),
    );
  }

  Widget _actionCell(BuildContext context, YardIntakeModel intake, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showDetailsModal(context, intake),
            child: const Icon(Icons.visibility_outlined, color: Colors.blueAccent, size: 20),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _showEditSheet(context, intake),
            child: const Icon(Icons.edit_outlined, color: Colors.greenAccent, size: 20),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              ConfirmationSheet.show(
                context: context,
                title: "Delete Intake",
                message: "Are you sure you want to delete intake ${intake.grnNumber}? This action cannot be undone.",
                confirmText: "Delete",
                onConfirm: () {
                  context.read<YardIntakeBloc>().add(DeleteYardIntake(intake.id));
                },
              );
            },
            child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
          ),
        ],
      ),
    );
  }

  void _showCreateSheet(BuildContext context, List<YardIntakeModel> existingIntakes) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppTheme.bgColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (innerContext) => IntakeCreateSheet(
        existingIntakes: existingIntakes,
        onCreate: (data) {
          context.read<YardIntakeBloc>().add(CreateYardIntake(data));
        },
      ),
    );
  }

  void _showEditSheet(BuildContext context, YardIntakeModel intake) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppTheme.bgColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (innerContext) => IntakeEditSheet(
        intake: intake,
        onSave: (data) {
          context.read<YardIntakeBloc>().add(UpdateYardIntake(intake.id, data));
        },
      ),
    );
  }

  void _showDetailsModal(BuildContext context, YardIntakeModel intake) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgColor,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Container(
          padding: const EdgeInsets.all(24),
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Intake Details - ${intake.grnNumber}",
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white54),
                  ),
                ],
              ),
              const Divider(color: Colors.white24, height: 32),
              Expanded(
                child: ListView(
                  children: [
                    _detailItem("Supplier Name", intake.supplierName),
                    _detailItem("Vehicle Number", intake.vehicleNumber),
                    _detailItem("GRN Number", intake.grnNumber),
                    _detailItem("Status", intake.status),
                    _detailItem("Gross Weight", "${intake.grossWeight} kg"),
                    _detailItem("Tare Weight", "${intake.tareWeight} kg"),
                    _detailItem("Net Weight", "${intake.netWeight} kg"),
                    _detailItem("Date", "${intake.date.day}/${intake.date.month}/${intake.date.year}"),
                    const SizedBox(height: 20),
                    const Text(
                      "Materials",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ...intake.materialTypes.map((m) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(m.name, style: const TextStyle(color: Colors.white)),
                          Text("${m.netWeight} kg", style: const TextStyle(color: Colors.orangeAccent)),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              AppButton(
                text: "Download PDF",
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Downloading PDF...")),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 14)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _dataCell(String text, {int flex = 1, Color color = Colors.white, bool isItalic = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _statusCell(String status, {int flex = 1}) {
    Color statusColor = Colors.grey;
    if (status.toLowerCase() == 'completed' || status.toLowerCase() == 'paid') {
      statusColor = Colors.green;
    } else if (status.toLowerCase() == 'pending') {
      statusColor = Colors.orange;
    }

    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: statusColor.withOpacity(0.5), width: 0.5),
        ),
        child: Text(
          status,
          style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Responsive.horizontalPadding(context) / 2),
      child: Shimmer.fromColors(
        baseColor: Colors.white10,
        highlightColor: Colors.white24,
        child: Column(
          children: List.generate(10, (index) => Container(
            height: 50,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          )),
        ),
      ),
    );
  }
}
