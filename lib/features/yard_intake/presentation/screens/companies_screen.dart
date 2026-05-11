import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gme/features/yard_intake/data/models/yard_intake_model.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/services/injection_container.dart';
import '../bloc/yard_intake_bloc.dart';
import '../bloc/yard_intake_event.dart';
import '../bloc/yard_intake_state.dart';

class CompaniesScreen extends StatefulWidget {
  const CompaniesScreen({super.key});

  @override
  State<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends State<CompaniesScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<YardIntakeBloc>()..add(FetchYardIntake()),
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: AppTheme.bgColor,
          body: BlocBuilder<YardIntakeBloc, YardIntakeState>(
            builder: (context, state) {
              if (state is YardIntakeLoading || state is YardIntakeInitial) {
                return _buildLoadingShimmer(context);
              } else if (state is YardIntakeLoaded) {
                // Group by supplier name to get unique companies
                final uniqueCompanies = state.intakeList.fold<Map<String, YardIntakeModel>>({}, (map, intake) {
                  if (!map.containsKey(intake.supplierName)) {
                    map[intake.supplierName] = intake;
                  }
                  return map;
                }).values.toList();

                return _buildContent(context, uniqueCompanies);
              } else if (state is YardIntakeError) {
                return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<YardIntakeModel> companies) {
    return Padding(
      padding: EdgeInsets.all(Responsive.horizontalPadding(context) / 2),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Partner Companies",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: companies.length,
              itemBuilder: (context, index) {
                final company = companies[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.business, color: Colors.orangeAccent, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              company.supplierName,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              "Last Vehicle: ${company.vehicleNumber}",
                              style: const TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.white10,
        highlightColor: Colors.white24,
        child: Container(
          height: 80,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
