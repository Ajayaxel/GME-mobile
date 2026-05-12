import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/services/injection_container.dart';
import '../../domain/models/transporter.dart';
import '../bloc/transportation_bloc.dart';
import '../bloc/transportation_event.dart';
import '../bloc/transportation_state.dart';
import '../../../dispatch/domain/repository/dispatch_repository.dart';
import '../../../dispatch/domain/models/dispatch_record.dart';
import '../../domain/repository/transportation_repository.dart';
import '../../../yard_intake/domain/repository/yard_intake_repository.dart';
import '../../../yard_intake/data/models/yard_intake_model.dart';
import 'package:intl/intl.dart';

class TransportationScreen extends StatefulWidget {
  const TransportationScreen({super.key});

  @override
  State<TransportationScreen> createState() => _TransportationScreenState();
}

class _TransportationScreenState extends State<TransportationScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<TransportationBloc>()..add(FetchTransporters()),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocListener<TransportationBloc, TransportationState>(
          listener: (context, state) {
            if (state is TransportationActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is TransportationError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: BlocBuilder<TransportationBloc, TransportationState>(
            builder: (context, state) {
              if (state is TransportationLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white70),
                );
              } else if (state is TransportationLoaded) {
                final filteredTransporters = state.transporters.where((t) {
                  return t.companyName.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ) ||
                      t.contactPerson.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      );
                }).toList();

                return Column(
                  children: [
                    _buildHeader(context, state.transporters),
                    _buildSearchSection(),
                    Expanded(
                      child: _buildTransporterList(
                        context,
                        filteredTransporters,
                      ),
                    ),
                  ],
                );
              } else if (state is TransportationError) {
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
                        onPressed: () => context.read<TransportationBloc>().add(
                          FetchTransporters(),
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
      ),
    );
  }

  Widget _buildHeader(BuildContext context, List<Transporter> transporters) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: IntrinsicHeight(
        child: Row(
          children: [
            SizedBox(
              width: 130,
              child: _buildStatItem(
                "ACTIVE TRANSPORTERS",
                "${transporters.length}",
                Colors.blueAccent,
                Icons.local_shipping_outlined,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 100,
              child: _buildStatItem(
                "ACTIVE TRIPS",
                "0",
                Colors.orangeAccent,
                Icons.route_outlined,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 100,
              child: _buildStatItem(
                "FREIGHT (MON)",
                "GH₵ 0.00",
                Colors.greenAccent,
                Icons.payments_outlined,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 100,
              child: _buildStatItem(
                "ON-TIME",
                "96%",
                AppTheme.btnColor,
                Icons.timer_outlined,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 100,
              child: _buildActionColumn(
                context,
                "ADD NEW",
                Icons.add,
                () => _showAddTransporterModal(context),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 100,
              child: _buildActionColumn(
                context,
                "ASSIGN TRIP",
                Icons.route_outlined,
                () => _showAssignTripModal(context),
              ),
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
              fontSize: 13,
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

  Widget _buildActionColumn(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.btnColor,
                    AppTheme.btnColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: Icon(icon, color: Colors.white, size: 16)),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 7,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
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
            hintText: "Search transporters...",
            hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
            prefixIcon: Icon(Icons.search, color: Colors.white38, size: 18),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }

  Widget _buildTransporterList(
    BuildContext context,
    List<Transporter> transporters,
  ) {
    final bool isTablet = Responsive.isTablet(context);
    return RefreshIndicator(
      onRefresh: () async =>
          context.read<TransportationBloc>().add(FetchTransporters()),
      color: AppTheme.btnColor,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: transporters.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isTablet ? 2 : 1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          mainAxisExtent: 180,
        ),
        itemBuilder: (context, index) =>
            TransporterCard(transporter: transporters[index]),
      ),
    );
  }

  void _showAddTransporterModal(BuildContext context) {
    final transportationBloc = context.read<TransportationBloc>();
    final formKey = GlobalKey<FormState>();
    final companyNameController = TextEditingController();
    final contactPersonController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final vatController = TextEditingController();

    showDialog(
      context: context,
      builder: (modalContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.zero,
        content: Container(
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
                        Text(
                          "Add New Transporter",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          "Register a new transportation service provider",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(modalContext),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildModalTextField(
                  "Company Name",
                  companyNameController,
                  "ABC Logistics Pvt Ltd",
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildModalTextField(
                        "Contact Person",
                        contactPersonController,
                        "Rajesh Kumar",
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildModalTextField(
                        "Phone Number",
                        phoneController,
                        "+91-98765-43210",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildModalTextField(
                        "Email Address",
                        emailController,
                        "contact@logistics.com",
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildModalTextField(
                        "VAT Number",
                        vatController,
                        "VAT-12345678",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(modalContext),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          transportationBloc.add(
                            CreateTransporter(
                              data: {
                                "companyName": companyNameController.text,
                                "contactPerson": contactPersonController.text,
                                "phone": phoneController.text,
                                "email": emailController.text,
                                "gstNumber": vatController.text,
                              },
                            ),
                          );
                          Navigator.pop(modalContext);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B2E1D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        "Add Transporter",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAssignTripModal(BuildContext context) async {
    final transportationBloc = context.read<TransportationBloc>();

    // Fetch data for dropdowns
    final List<Transporter> transporters = await sl<TransportationRepository>()
        .getTransporters();
    final List<DispatchRecord> dispatches = await sl<DispatchRepository>()
        .getRecords();
    final yardIntakeResult = await sl<YardIntakeRepository>().getYardIntake();
    List<YardIntakeModel> yardIntakes = [];
    yardIntakeResult.fold((l) => null, (r) => yardIntakes = r);

    if (!mounted) return;

    final formKey = GlobalKey<FormState>();
    final tripIdController = TextEditingController(
      text: "TRIP-${DateFormat('yyMMddHHmm').format(DateTime.now())}",
    );
    final freightController = TextEditingController();
    final startDateController = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(DateTime.now()),
    );
    final routeController = TextEditingController();

    String? selectedTransporter;
    String? selectedDispatch;
    String? selectedVehicle;
    String selectedStatus = "Assigned";

    showDialog(
      context: context,
      builder: (modalContext) => StatefulBuilder(
        builder: (modalContext, setModalState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: EdgeInsets.zero,
          content: Container(
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
                          Text(
                            "Assign New Trip",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            "Create a new trip assignment for a transporter and link it to a dispatch.",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(modalContext),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildModalTextField(
                          "Trip ID",
                          tripIdController,
                          "Auto-generated",
                          enabled: false,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildModalDropdown(
                          "Select Transporter",
                          selectedTransporter,
                          transporters.map((t) => t.id).toList(),
                          (val) =>
                              setModalState(() => selectedTransporter = val),
                          itemLabels: Map.fromEntries(
                            transporters.map(
                              (t) => MapEntry(t.id, t.companyName),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildModalDropdown(
                          "Dispatch ID",
                          selectedDispatch,
                          dispatches.map((d) => d.dispatchId).toList(),
                          (val) {
                            setModalState(() {
                              selectedDispatch = val;
                              final dispatch = dispatches.firstWhere(
                                (d) => d.dispatchId == val,
                              );
                              selectedVehicle = dispatch.containerNumber;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildModalDropdown(
                          "Vehicle / Container Number",
                          selectedVehicle,
                          yardIntakes
                              .map((i) => i.vehicleNumber)
                              .toSet()
                              .toList(),
                          (val) => setModalState(() => selectedVehicle = val),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildModalTextField(
                    "Route Details",
                    routeController,
                    "Select or enter route details",
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildModalTextField(
                          "Freight Amount",
                          freightController,
                          "0",
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildModalTextField(
                          "Start Date",
                          startDateController,
                          "DD/MM/YYYY",
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (date != null)
                              startDateController.text = DateFormat(
                                'dd/MM/yyyy',
                              ).format(date);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(modalContext),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate() &&
                              selectedTransporter != null &&
                              selectedDispatch != null) {
                            transportationBloc.add(
                              CreateTrip(
                                data: {
                                  "tripId": tripIdController.text,
                                  "transporterId": selectedTransporter,
                                  "dispatchId": selectedDispatch,
                                  "route": routeController.text,
                                  "freightAmount":
                                      double.tryParse(freightController.text) ??
                                      0,
                                  "startDate": startDateController.text,
                                  "status": selectedStatus,
                                },
                              ),
                            );
                            Navigator.pop(modalContext);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B2E1D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          "Assign Trip",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModalDropdown(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged, {
    Map<String, String>? itemLabels,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: (items.contains(value)) ? value : null,
          onChanged: onChanged,
          validator: (v) => v == null ? "Required" : null,
          items: items
              .map(
                (i) => DropdownMenuItem(
                  value: i,
                  child: Text(
                    itemLabels?[i] ?? i,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
              .toList(),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModalTextField(
    String label,
    TextEditingController controller,
    String hint, {
    bool enabled = true,
    TextInputType? keyboardType,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          onTap: onTap,
          readOnly: onTap != null,
          validator: (v) => v == null || v.isEmpty ? "Required" : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            filled: true,
            fillColor: enabled ? const Color(0xFFF9FAFB) : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            suffixIcon: onTap != null
                ? const Icon(Icons.calendar_today, size: 16, color: Colors.grey)
                : null,
          ),
        ),
      ],
    );
  }
}

class TransporterCard extends StatelessWidget {
  final Transporter transporter;
  const TransporterCard({super.key, required this.transporter});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.btnColor.withOpacity(0.1),
                  child: Icon(
                    Icons.local_shipping_outlined,
                    color: AppTheme.btnColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transporter.companyName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        "VAT/GST: ${transporter.vatNumber}",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                _buildStatusBanner("Active", Colors.green),
              ],
            ),
            const Spacer(),
            const Divider(height: 1, color: Color(0xFFF3F4F6)),
            const Spacer(),
            _buildContactInfo(Icons.person_outline, transporter.contactPerson),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildContactInfo(
                    Icons.phone_outlined,
                    transporter.phone,
                  ),
                ),
                Expanded(
                  child: _buildContactInfo(
                    Icons.mail_outline_rounded,
                    transporter.email,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[400]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
