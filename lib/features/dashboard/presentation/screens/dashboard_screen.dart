import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/injection_container.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../../domain/models/dashboard_model.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DashboardBloc>()..add(FetchDashboardData()),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(child: CircularProgressIndicator(color: Colors.white70));
            } else if (state is DashboardError) {
              return Center(child: Text(state.message, style: const TextStyle(color: Colors.redAccent)));
            } else if (state is DashboardLoaded) {
              return _buildDashboardContent(context, state.data);
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, DashboardData data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildStatsGrid(data.stats),
          const SizedBox(height: 32),
          _buildChartsRow(data.trends),
          const SizedBox(height: 32),
          _buildRecentActivities(data.activities),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Operations Dashboard",
          style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        ),
        const SizedBox(height: 4),
        Text(
          "Real-time overview of mineral operations and business metrics",
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(DashboardStats stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 2.2,
          children: [
            _buildStatCard("Total Intake Volume", "${stats.intakeVolume.toStringAsFixed(1)} MT", "↑ Real-time", Icons.local_shipping_outlined, Colors.orange),
            _buildStatCard("Processing Volume", "${stats.processingVolume.toStringAsFixed(1)} MT", "↑ Live", Icons.precision_manufacturing_outlined, Colors.blue),
            _buildStatCard("Active Shipments", "${stats.activeShipments}", "In transit", Icons.directions_boat_outlined, Colors.green),
            _buildStatCard("Pending Receivables", NumberFormat.currency(symbol: '\$').format(stats.pendingReceivables), "↓ ${stats.pendingCount} pending", Icons.account_balance_wallet_outlined, Colors.redAccent),
            _buildStatCard("Inventory Stock", "${stats.inventoryStock.toStringAsFixed(1)} MT", "Across locations", Icons.inventory_2_outlined, Colors.purple),
            _buildStatCard("Total Revenue (Paid)", NumberFormat.currency(symbol: '\$').format(stats.totalRevenue), "↑ Live Updates", Icons.trending_up, const Color(0xFF10B981)),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, String subValue, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subValue, style: TextStyle(color: color.withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsRow(DashboardTrend trends) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          return Row(
            children: [
              Expanded(child: _buildThroughputChart(trends)),
              const SizedBox(width: 24),
              Expanded(child: _buildRevenueVsCostChart(trends)),
            ],
          );
        } else {
          return Column(
            children: [
              _buildThroughputChart(trends),
              const SizedBox(height: 24),
              _buildRevenueVsCostChart(trends),
            ],
          );
        }
      },
    );
  }

  Widget _buildThroughputChart(DashboardTrend trends) {
    return _buildChartContainer(
      "Throughput Trend (MT)",
      LineChart(
        LineChartData(
          gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: Colors.white.withOpacity(0.05), strokeWidth: 1)),
          titlesData: _buildChartTitles(trends.months),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            _buildLineBar(trends.throughput['intake']!, Colors.orange),
            _buildLineBar(trends.throughput['processing']!, Colors.blue),
            _buildLineBar(trends.throughput['export']!, Colors.green),
          ],
          lineTouchData: LineTouchData(touchTooltipData: LineTouchTooltipData(getTooltipColor: (spot) => Colors.black87)),
        ),
      ),
    );
  }

  Widget _buildRevenueVsCostChart(DashboardTrend trends) {
    return _buildChartContainer(
      "Revenue vs Cost",
      BarChart(
        BarChartData(
          gridData: FlGridData(show: false),
          titlesData: _buildChartTitles(trends.months),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(trends.months.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(toY: trends.revenueVsCost['revenue']![i], color: const Color(0xFF10B981), width: 12, borderRadius: BorderRadius.circular(4)),
                BarChartRodData(toY: trends.revenueVsCost['cost']![i], color: Colors.redAccent.withOpacity(0.8), width: 12, borderRadius: BorderRadius.circular(4)),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildChartContainer(String title, Widget chart) {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          Expanded(child: chart),
        ],
      ),
    );
  }

  FlTitlesData _buildChartTitles(List<String> months) {
    return FlTitlesData(
      show: true,
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            if (value.toInt() >= 0 && value.toInt() < months.length) {
              return Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(months[value.toInt()], style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10)),
              );
            }
            return const SizedBox();
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10)),
        ),
      ),
    );
  }

  LineChartBarData _buildLineBar(List<double> data, Color color) {
    return LineChartBarData(
      spots: List.generate(data.length, (i) => FlSpot(i.toDouble(), data[i])),
      isCurved: true,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: true, color: color.withOpacity(0.1)),
    );
  }

  Widget _buildRecentActivities(List<DashboardActivity> activities) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Recent Activities", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildActivityHeader(),
          const Divider(color: Colors.white10, height: 32),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 32),
            itemBuilder: (context, index) => _buildActivityRow(activities[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityHeader() {
    return Row(
      children: [
        Expanded(flex: 2, child: _buildHeaderText("Type")),
        Expanded(flex: 2, child: _buildHeaderText("Reference")),
        Expanded(flex: 3, child: _buildHeaderText("Description")),
        Expanded(flex: 2, child: _buildHeaderText("Timestamp")),
        Expanded(flex: 2, child: _buildHeaderText("Status")),
      ],
    );
  }

  Widget _buildHeaderText(String text) {
    return Text(text, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12, fontWeight: FontWeight.w600));
  }

  Widget _buildActivityRow(DashboardActivity activity) {
    return Row(
      children: [
        Expanded(flex: 2, child: Text(activity.type, style: const TextStyle(color: Colors.white, fontSize: 13))),
        Expanded(
          flex: 2, 
          child: Text(
            activity.reference, 
            style: const TextStyle(color: Colors.blueAccent, fontSize: 13, fontWeight: FontWeight.w600)
          )
        ),
        Expanded(flex: 3, child: Text(activity.description, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13))),
        Expanded(
          flex: 2, 
          child: Text(
            activity.timestamp.length >= 10 ? activity.timestamp.substring(0, 10) : activity.timestamp, 
            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)
          )
        ),
        Expanded(flex: 2, child: Align(alignment: Alignment.centerLeft, child: _buildStatusChip(activity.status))),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    final isCompleted = status.toLowerCase() == 'completed' || status.toLowerCase() == 'active';
    const emerald = Color(0xFF10B981);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: (isCompleted ? emerald : Colors.orange).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: (isCompleted ? emerald : Colors.orange).withOpacity(0.2)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: isCompleted ? emerald : Colors.orange, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
