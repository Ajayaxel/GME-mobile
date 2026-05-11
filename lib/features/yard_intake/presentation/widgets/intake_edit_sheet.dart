import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../data/models/yard_intake_model.dart';

class IntakeEditSheet extends StatefulWidget {
  final YardIntakeModel intake;
  final Function(Map<String, dynamic>) onSave;

  const IntakeEditSheet({
    super.key,
    required this.intake,
    required this.onSave,
  });

  @override
  State<IntakeEditSheet> createState() => _IntakeEditSheetState();
}

class _IntakeEditSheetState extends State<IntakeEditSheet> {
  late String _status;
  late List<Map<String, dynamic>> _materialTypes;

  @override
  void initState() {
    super.initState();
    _status = widget.intake.status;
    _materialTypes = widget.intake.materialTypes
        .map((m) => {
              "name": m.name,
              "grossWeight": m.grossWeight,
              "tareWeight": m.tareWeight,
              "netWeight": m.netWeight,
            })
        .toList();
    if (_materialTypes.isEmpty) {
      _materialTypes.add({
        "name": "",
        "grossWeight": 0.0,
        "tareWeight": 0.0,
        "netWeight": 0.0,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Edit Intake - ${widget.intake.grnNumber}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
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
                  const Text("Status", style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _status,
                    dropdownColor: AppTheme.bgColor,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                    items: ["Pending", "Completed", "Paid"]
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (value) => setState(() => _status = value!),
                  ),
                  const SizedBox(height: 20),
                  const Text("Material Types", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ..._materialTypes.asMap().entries.map((entry) {
                    int idx = entry.key;
                    Map<String, dynamic> material = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: TextEditingController(text: material["name"])
                              ..selection = TextSelection.collapsed(offset: material["name"].length),
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(labelText: "Material Name", labelStyle: TextStyle(color: Colors.white54)),
                            onChanged: (val) => material["name"] = val,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  controller: TextEditingController(text: material["grossWeight"].toString()),
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(labelText: "Gross Wt", labelStyle: TextStyle(color: Colors.white54)),
                                  onChanged: (val) {
                                    material["grossWeight"] = double.tryParse(val) ?? 0.0;
                                    material["netWeight"] = material["grossWeight"] - material["tareWeight"];
                                    setState(() {});
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  controller: TextEditingController(text: material["tareWeight"].toString()),
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(labelText: "Tare Wt", labelStyle: TextStyle(color: Colors.white54)),
                                  onChanged: (val) {
                                    material["tareWeight"] = double.tryParse(val) ?? 0.0;
                                    material["netWeight"] = material["grossWeight"] - material["tareWeight"];
                                    setState(() {});
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "${material["netWeight"]} kg",
                                  style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 10),
            AppButton(
              text: "Save Changes",
              onPressed: () {
                widget.onSave({
                  "status": _status,
                  "materialType": _materialTypes,
                });
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
