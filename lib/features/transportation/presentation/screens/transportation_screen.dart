import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/services/injection_container.dart';
import '../../domain/models/transporter.dart';
import '../bloc/transportation_bloc.dart';
import '../bloc/transportation_event.dart';
import '../bloc/transportation_state.dart';

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
        body: BlocBuilder<TransportationBloc, TransportationState>(
          builder: (context, state) {
            if (state is TransportationLoading) {
              return const Center(child: CircularProgressIndicator(color: Colors.white70));
            } else if (state is TransportationLoaded) {
              final filteredTransporters = state.transporters.where((t) {
                return t.companyName.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                       t.contactPerson.toLowerCase().contains(_searchQuery.toLowerCase());
              }).toList();

              return Column(
                children: [
                  _buildHeader(state.transporters),
                  _buildSearchSection(),
                  Expanded(
                    child: _buildTransporterList(context, filteredTransporters),
                  ),
                ],
              );
            } else if (state is TransportationError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                    const SizedBox(height: 16),
                    Text(state.message, style: const TextStyle(color: Colors.white70)),
                    TextButton(
                      onPressed: () => context.read<TransportationBloc>().add(FetchTransporters()),
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

  Widget _buildHeader(List<Transporter> transporters) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: IntrinsicHeight(
        child: Row(
          children: [
            SizedBox(width: 130, child: _buildStatItem("ACTIVE TRANSPORTERS", "${transporters.length}", Colors.blueAccent, Icons.local_shipping_outlined)),
            const SizedBox(width: 8),
            SizedBox(width: 100, child: _buildStatItem("ACTIVE TRIPS", "0", Colors.orangeAccent, Icons.route_outlined)),
            const SizedBox(width: 8),
            SizedBox(width: 100, child: _buildStatItem("FREIGHT (MON)", "GH₵ 0.00", Colors.greenAccent, Icons.payments_outlined)),
            const SizedBox(width: 8),
            SizedBox(width: 100, child: _buildStatItem("ON-TIME", "96%", AppTheme.btnColor, Icons.timer_outlined)),
            const SizedBox(width: 8),
            SizedBox(width: 100, child: _buildActionColumn()),
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
          Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w900), overflow: TextOverflow.ellipsis, maxLines: 1),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 7, fontWeight: FontWeight.bold, letterSpacing: 0.5), overflow: TextOverflow.ellipsis, maxLines: 1),
        ],
      ),
    );
  }

  Widget _buildActionColumn() {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.btnColor, AppTheme.btnColor.withOpacity(0.8)]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(child: Icon(Icons.add, color: Colors.white, size: 16)),
          ),
        ),
        const SizedBox(height: 4),
        const Text("ADD NEW", style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, maxLines: 1),
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

  Widget _buildTransporterList(BuildContext context, List<Transporter> transporters) {
    final bool isTablet = Responsive.isTablet(context);
    return RefreshIndicator(
      onRefresh: () async => context.read<TransportationBloc>().add(FetchTransporters()),
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
        itemBuilder: (context, index) => TransporterCard(transporter: transporters[index]),
      ),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 8))],
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
                  child: Icon(Icons.local_shipping_outlined, color: AppTheme.btnColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transporter.companyName,
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          "VAT/GST: ${transporter.vatNumber}",
                          style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
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
                Expanded(child: _buildContactInfo(Icons.phone_outlined, transporter.phone)),
                Expanded(child: _buildContactInfo(Icons.mail_outline_rounded, transporter.email)),
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
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(label.toUpperCase(), style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.w900)),
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
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
