import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/services/injection_container.dart';
import '../../domain/models/invoice.dart';
import '../bloc/financials_bloc.dart';
import '../bloc/financials_event.dart';
import '../bloc/financials_state.dart';
import 'package:intl/intl.dart';

class FinancialsScreen extends StatefulWidget {
  const FinancialsScreen({super.key});

  @override
  State<FinancialsScreen> createState() => _FinancialsScreenState();
}

class _FinancialsScreenState extends State<FinancialsScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<FinancialsBloc>()..add(FetchInvoices()),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocListener<FinancialsBloc, FinancialsState>(
          listener: (context, state) {
            if (state is FinancialsActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.green),
              );
            } else if (state is FinancialsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          child: BlocBuilder<FinancialsBloc, FinancialsState>(
            builder: (context, state) {
            if (state is FinancialsLoading) {
              return _buildShimmerLoading();
            } else if (state is FinancialsLoaded) {
              final invoices = state.invoices;
              final filteredInvoices = invoices.where((i) {
                return i.invoiceNo.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    i.customerName.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    );
              }).toList();

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopStats(context, invoices),
                    const SizedBox(height: 24),
                    _buildFinancialOverview(context, invoices),
                    const SizedBox(height: 24),
                    _buildChartsSection(invoices),
                    const SizedBox(height: 24),
                    _buildSearchAndFilters(context),
                    const SizedBox(height: 16),
                    _buildInvoiceList(filteredInvoices),
                    const SizedBox(height: 24),
                    _buildTopClients(invoices),
                  ],
                ),
              );
            } else if (state is FinancialsError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.white),
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

  Widget _buildTopStats(BuildContext context, List<Invoice> invoices) {
    double totalRevenue = invoices.fold(0, (sum, i) => sum + i.amount);
    double paidTotal = invoices
        .where((i) => i.status.toLowerCase() == 'paid')
        .fold(0, (sum, i) => sum + i.amount);
    double pendingTotal = invoices
        .where((i) => i.status.toLowerCase() == 'pending')
        .fold(0, (sum, i) => sum + i.amount);

    final isTablet = Responsive.isTablet(context);

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isTablet ? 3 : 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: isTablet ? 1.8 : 1.3,
      children: [
        _buildStatCard(
          "TOTAL REVENUE",
          "GH₵${totalRevenue.toStringAsFixed(2)}",
          AppTheme.btnColor,
          Icons.account_balance_wallet_outlined,
        ),
        _buildStatCard(
          "PAID INVOICES",
          "GH₵${paidTotal.toStringAsFixed(2)}",
          Colors.greenAccent,
          Icons.check_circle_outline,
        ),
        _buildStatCard(
          "PENDING",
          "GH₵${pendingTotal.toStringAsFixed(2)}",
          Colors.orangeAccent,
          Icons.pending_actions,
        ),
        _buildActionCard(context),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context) {
    return InkWell(
      onTap: () => _showNewInvoiceSheet(context),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.btnColor, AppTheme.btnColor.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_chart_outlined, color: Colors.white, size: 24),
            SizedBox(height: 8),
            Text(
              "NEW INVOICE",
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNewInvoiceSheet(BuildContext context) {
    final financialsBloc = context.read<FinancialsBloc>();
    final invoiceNoController = TextEditingController(text: "INV-2024-${DateFormat('SSS').format(DateTime.now())}");
    final customerController = TextEditingController();
    final descriptionController = TextEditingController();
    final quantityController = TextEditingController(text: "1");
    final priceController = TextEditingController(text: "0");
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: AppTheme.bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Create New Invoice",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Generate a new financial invoice for services",
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  
                  _buildFieldLabel("Invoice Number"),
                  _buildSheetTextField(invoiceNoController, enabled: false),
                  
                  const SizedBox(height: 20),
                  _buildFieldLabel("Customer Name"),
                  _buildSheetTextField(customerController, hint: "Enter customer name"),

                  const SizedBox(height: 24),
                  const Text(
                    "ITEM DETAILS",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSheetTextField(descriptionController, hint: "Item description (e.g. Lithium Ore Processing)"),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel("Quantity"),
                            _buildSheetTextField(quantityController, keyboardType: TextInputType.number),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel("Unit Price"),
                            _buildSheetTextField(priceController, keyboardType: TextInputType.number),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Builder(
                          builder: (context) {
                            double qty = double.tryParse(quantityController.text) ?? 0;
                            double price = double.tryParse(priceController.text) ?? 0;
                            double subtotal = qty * price;
                            double tax = subtotal * 0.075; // 7.5% tax example
                            double total = subtotal + tax;
                            
                            return Column(
                              children: [
                                _buildSummaryRow("Subtotal", "GH₵${subtotal.toStringAsFixed(2)}", Colors.white70),
                                const SizedBox(height: 8),
                                _buildSummaryRow("Tax (7.5%)", "GH₵${tax.toStringAsFixed(2)}", Colors.white70),
                                const Divider(height: 24, color: Colors.white10),
                                _buildSummaryRow("Total Amount", "GH₵${total.toStringAsFixed(2)}", Colors.white, isTotal: true),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (customerController.text.isEmpty || descriptionController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Please fill all required fields")),
                              );
                              return;
                            }
                            
                            double qty = double.tryParse(quantityController.text) ?? 0;
                            double price = double.tryParse(priceController.text) ?? 0;
                            double subtotal = qty * price;
                            double tax = subtotal * 0.075;
                            double total = subtotal + tax;

                            financialsBloc.add(CreateInvoice(data: {
                              "invoiceNo": invoiceNoController.text,
                              "customerName": customerController.text,
                              "amount": total,
                              "status": "Pending",
                              "items": [
                                {
                                  "description": descriptionController.text,
                                  "quantity": qty.toInt(),
                                  "unitPrice": price
                                }
                              ],
                              "subtotal": subtotal,
                              "taxAmount": tax
                            }));
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.btnColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Create Invoice", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSheetTextField(
    TextEditingController controller, {
    String? hint,
    bool enabled = true,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildFinancialOverview(BuildContext context, List<Invoice> invoices) {
    double totalBilled = invoices.fold(0, (sum, i) => sum + i.amount);
    double avgValue = invoices.isEmpty ? 0 : totalBilled / invoices.length;
    double outstanding = invoices
        .where((i) => i.status.toLowerCase() != 'paid')
        .fold(0, (sum, i) => sum + i.amount);

    final isTablet = Responsive.isTablet(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "OVERVIEW",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildOverviewItem(
                  "Avg. invoice value",
                  "GH₵${avgValue.toStringAsFixed(2)}",
                ),
              ),
              if (isTablet) const SizedBox(width: 24),
              Expanded(
                child: _buildOverviewItem(
                  "Total billed",
                  "GH₵${totalBilled.toStringAsFixed(2)}",
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: Colors.white10),
          ),
          Row(
            children: [
              Expanded(
                child: _buildOverviewItem("Total invoices", "${invoices.length}"),
              ),
              if (isTablet) const SizedBox(width: 24),
              Expanded(
                child: _buildOverviewItem(
                  "Outstanding",
                  "GH₵${outstanding.toStringAsFixed(2)}",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildChartsSection(List<Invoice> invoices) {
    final paidCount = invoices
        .where((i) => i.status.toLowerCase() == 'paid')
        .length;
    final pendingCount = invoices
        .where((i) => i.status.toLowerCase() == 'pending')
        .length;
    final overdueCount = invoices
        .where((i) => i.status.toLowerCase() == 'overdue')
        .length;
    final total = invoices.isEmpty ? 1 : invoices.length;

    final isTablet = Responsive.isTablet(context);
    final chartContent = [
      Expanded(
        flex: isTablet ? 4 : 0,
        child: Container(
          height: 200,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "PAYMENT STATUS",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Expanded(
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 40,
                    sections: [
                      PieChartSectionData(
                        value: paidCount.toDouble(),
                        color: Colors.greenAccent,
                        radius: 15,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        value: pendingCount.toDouble(),
                        color: Colors.orangeAccent,
                        radius: 15,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        value: overdueCount.toDouble(),
                        color: Colors.redAccent,
                        radius: 15,
                        showTitle: false,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      if (!isTablet) const SizedBox(height: 16),
      Expanded(
        flex: isTablet ? 3 : 0,
        child: Column(
          children: [
            _buildChartLegendItem(
              "Paid",
              "${((paidCount / total) * 100).toStringAsFixed(1)}%",
              Colors.greenAccent,
            ),
            const SizedBox(height: 8),
            _buildChartLegendItem(
              "Pending",
              "${((pendingCount / total) * 100).toStringAsFixed(1)}%",
              Colors.orangeAccent,
            ),
            const SizedBox(height: 8),
            _buildChartLegendItem(
              "Overdue",
              "${((overdueCount / total) * 100).toStringAsFixed(1)}%",
              Colors.redAccent,
            ),
          ],
        ),
      ),
    ];

    return isTablet ? Row(children: chartContent) : Column(children: chartContent);
  }

  Widget _buildChartLegendItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context) {
    return Row(
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
              decoration: const InputDecoration(
                hintText: "Search Invoice # or Client...",
                hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                prefixIcon: Icon(Icons.search, color: Colors.white38, size: 18),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        _buildFilterIcon(Icons.tune),
      ],
    );
  }

  Widget _buildFilterIcon(IconData icon, {Color? color}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color ?? Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _buildInvoiceList(List<Invoice> invoices) {
    return Column(children: invoices.map((i) => _buildInvoiceCard(i)).toList());
  }

  Widget _buildInvoiceCard(Invoice invoice) {
    Color statusColor;
    switch (invoice.status.toLowerCase()) {
      case 'paid':
        statusColor = Colors.greenAccent;
        break;
      case 'overdue':
        statusColor = Colors.redAccent;
        break;
      default:
        statusColor = Colors.orangeAccent;
    }

    return GestureDetector(
      onTap: () => _showInvoiceDetails(invoice),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.btnColor.withOpacity(0.1),
              child: Text(
                invoice.customerName.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: AppTheme.btnColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "#${invoice.invoiceNo}",
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    invoice.customerName,
                    style: const TextStyle(
                      color: Colors.black38,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "GH₵${invoice.amount.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                _buildStatusChip(invoice.status, statusColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showInvoiceDetails(Invoice invoice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "INVOICE",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.black87,
                                letterSpacing: -1,
                              ),
                            ),
                            Text(
                              "#${invoice.invoiceNo}",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.btnColor,
                              ),
                            ),
                          ],
                        ),
                        _buildStatusChip(
                          invoice.status,
                          invoice.status.toLowerCase() == 'paid'
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    _buildDetailRow(
                      "Client",
                      invoice.customerName,
                      Icons.business,
                    ),
                    _buildDetailRow(
                      "Shipment ID",
                      invoice.shipmentId,
                      Icons.local_shipping,
                    ),
                    _buildDetailRow(
                      "Issue Date",
                      invoice.dateTime,
                      Icons.calendar_today,
                    ),
                    const Divider(height: 50, color: Color(0xFFF3F4F6)),
                    const Text(
                      "ITEM DETAILS",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.grey,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...invoice.lineItems.map(
                      (li) => Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    li.description,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    "Qty: ${li.quantity} • Rate: GH₵${li.rate}",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              "GH₵${li.total.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111827),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          _buildSummaryRow(
                            "Subtotal",
                            "GH₵${invoice.subtotal.toStringAsFixed(2)}",
                            Colors.white70,
                          ),
                          const SizedBox(height: 12),
                          _buildSummaryRow(
                            "Tax Amount",
                            "GH₵${invoice.taxAmount.toStringAsFixed(2)}",
                            Colors.white70,
                          ),
                          const Divider(height: 32, color: Colors.white10),
                          _buildSummaryRow(
                            "Total Amount",
                            "GH₵${invoice.amount.toStringAsFixed(2)}",
                            Colors.white,
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        Expanded(
                          child: _buildModalAction(
                            "Download PDF",
                            Icons.download,
                            AppTheme.btnColor,
                            Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildModalAction(
                            "Share",
                            Icons.share_outlined,
                            Colors.grey[100]!,
                            Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    Color color, {
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: isTotal ? 16 : 12,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: isTotal ? 20 : 14,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildModalAction(String label, IconData icon, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: text, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: text,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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

  Widget _buildTopClients(List<Invoice> invoices) {
    // Basic aggregation
    Map<String, double> clientTotals = {};
    for (var i in invoices) {
      clientTotals[i.customerName] =
          (clientTotals[i.customerName] ?? 0) + i.amount;
    }
    var sortedClients = clientTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "TOP CLIENTS",
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 16),
        ...sortedClients
            .take(5)
            .map(
              (e) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white10,
                      child: Text(
                        e.key.substring(0, 1),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        e.key,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      "GH₵${e.value.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.white10,
      highlightColor: Colors.white24,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: List.generate(
            6,
            (index) => Container(
              height: 100,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ),
    );
  }
  void _showCreateInvoiceModal(BuildContext context) {
    final financialsBloc = context.read<FinancialsBloc>();
    final formKey = GlobalKey<FormState>();
    final invoiceNoController = TextEditingController(text: "INV-${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}");
    final customerNameController = TextEditingController();
    final shipmentIdController = TextEditingController();
    final quotationIdController = TextEditingController();
    final taxAmountController = TextEditingController(text: "0");
    final discountAmountController = TextEditingController(text: "0");
    final currencyController = TextEditingController(text: "AED");

    List<Map<String, dynamic>> items = [
      {"description": "Service Fee", "quantity": 1, "rate": 0.0}
    ];

    showDialog(
      context: context,
      builder: (modalContext) => StatefulBuilder(
        builder: (modalContext, setModalState) {
          double subtotal = items.fold(0, (sum, item) => sum + (item['quantity'] * item['rate']));
          double tax = double.tryParse(taxAmountController.text) ?? 0;
          double discount = double.tryParse(discountAmountController.text) ?? 0;
          double total = subtotal + tax - discount;

          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            contentPadding: EdgeInsets.zero,
            content: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.all(32),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
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
                              Text("Create New Invoice", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                              Text("Fill in the details to generate a new invoice", style: TextStyle(fontSize: 13, color: Colors.grey)),
                            ],
                          ),
                          IconButton(onPressed: () => Navigator.pop(modalContext), icon: const Icon(Icons.close)),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(child: _buildModalTextField("Invoice Number", invoiceNoController, "INV-2024-001")),
                          const SizedBox(width: 16),
                          Expanded(child: _buildModalTextField("Customer Name", customerNameController, "Emirates Steel")),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildModalTextField("Shipment ID", shipmentIdController, "SHP-2024-123")),
                          const SizedBox(width: 16),
                          Expanded(child: _buildModalTextField("Quotation ID", quotationIdController, "QT-2024-001")),
                        ],
                      ),
                      const Divider(height: 48, color: Color(0xFFF3F4F6)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("LINE ITEMS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1)),
                          TextButton.icon(
                            onPressed: () => setModalState(() => items.add({"description": "", "quantity": 1, "rate": 0})),
                            icon: const Icon(Icons.add, size: 14),
                            label: const Text("Add Item", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...items.asMap().entries.map((entry) {
                        int idx = entry.key;
                        Map<String, dynamic> item = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: TextFormField(
                                  onChanged: (v) => item['description'] = v,
                                  decoration: InputDecoration(
                                    hintText: "Description",
                                    hintStyle: const TextStyle(fontSize: 13),
                                    filled: true,
                                    fillColor: const Color(0xFFF9FAFB),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  initialValue: "1",
                                  keyboardType: TextInputType.number,
                                  onChanged: (v) => setModalState(() => item['quantity'] = int.tryParse(v) ?? 0),
                                  decoration: InputDecoration(
                                    hintText: "Qty",
                                    hintStyle: const TextStyle(fontSize: 13),
                                    filled: true,
                                    fillColor: const Color(0xFFF9FAFB),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  onChanged: (v) => setModalState(() => item['rate'] = double.tryParse(v) ?? 0),
                                  decoration: InputDecoration(
                                    hintText: "Rate",
                                    hintStyle: const TextStyle(fontSize: 13),
                                    filled: true,
                                    fillColor: const Color(0xFFF9FAFB),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                ),
                              ),
                              if (items.length > 1)
                                IconButton(
                                  onPressed: () => setModalState(() => items.removeAt(idx)),
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                ),
                            ],
                          ),
                        );
                      }),
                      const Divider(height: 48, color: Color(0xFFF3F4F6)),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                _buildModalTextField("Currency", currencyController, "AED"),
                                const SizedBox(height: 12),
                                _buildModalTextField("Tax Amount", taxAmountController, "0", keyboardType: TextInputType.number, onChanged: (v) => setModalState(() {})),
                                const SizedBox(height: 12),
                                _buildModalTextField("Discount", discountAmountController, "0", keyboardType: TextInputType.number, onChanged: (v) => setModalState(() {})),
                              ],
                            ),
                          ),
                          const SizedBox(width: 48),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(color: const Color(0xFF111827), borderRadius: BorderRadius.circular(20)),
                              child: Column(
                                children: [
                                  _buildSummaryRow("Subtotal", "${currencyController.text} ${subtotal.toStringAsFixed(2)}", Colors.white70),
                                  const SizedBox(height: 8),
                                  _buildSummaryRow("Tax", "${currencyController.text} ${tax.toStringAsFixed(2)}", Colors.white70),
                                  const SizedBox(height: 8),
                                  _buildSummaryRow("Discount", "${currencyController.text} ${discount.toStringAsFixed(2)}", Colors.white70),
                                  const Divider(height: 32, color: Colors.white10),
                                  _buildSummaryRow("Total", "${currencyController.text} ${total.toStringAsFixed(2)}", Colors.white, isTotal: true),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(modalContext),
                            child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                          const SizedBox(width: 24),
                          ElevatedButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                financialsBloc.add(CreateInvoice(data: {
                                  "invoiceNo": invoiceNoController.text,
                                  "customerName": customerNameController.text,
                                  "shipmentId": shipmentIdController.text,
                                  "quotationId": quotationIdController.text.isEmpty ? null : quotationIdController.text,
                                  "amount": total,
                                  "dateTime": DateTime.now().toIso8601String(),
                                  "status": "Pending",
                                  "items": items.map((i) => {
                                    "description": i['description']?.isEmpty == true ? "Service Fee" : i['description'],
                                    "quantity": i['quantity'] ?? 1,
                                    "rate": i['rate'] ?? 0.0,
                                    "unitPrice": i['rate'] ?? 0.0,
                                    "total": (i['quantity'] ?? 1) * (i['rate'] ?? 0.0),
                                  }).toList(),
                                  "subtotal": subtotal,
                                  "taxAmount": tax,
                                  "discountAmount": discount,
                                  "currency": currencyController.text,
                                }));
                                Navigator.pop(modalContext);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.btnColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: const Text("Create Invoice", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                          ),
                        ],
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

  Widget _buildModalTextField(String label, TextEditingController controller, String hint, {TextInputType? keyboardType, Function(String)? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          validator: (v) => v == null || v.isEmpty ? "Required" : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
