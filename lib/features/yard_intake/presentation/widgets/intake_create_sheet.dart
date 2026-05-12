import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../data/models/yard_intake_model.dart';

class IntakeCreateSheet extends StatefulWidget {
  final List<YardIntakeModel> existingIntakes;
  final Function(Map<String, dynamic>) onCreate;

  const IntakeCreateSheet({
    super.key,
    required this.existingIntakes,
    required this.onCreate,
  });

  @override
  State<IntakeCreateSheet> createState() => _IntakeCreateSheetState();
}

class _IntakeCreateSheetState extends State<IntakeCreateSheet> {
  final _supplierController = TextEditingController();
  final _vehicleController = TextEditingController();
  final _customerController = TextEditingController();
  String _status = "Pending";
  final List<Map<String, dynamic>> _materialTypes = [
    {"name": "", "grossWeight": 0.0, "tareWeight": 0.0, "netWeight": 0.0},
  ];

  late List<String> _supplierSuggestions;
  late List<String> _vehicleSuggestions;

  @override
  void initState() {
    super.initState();
    _supplierSuggestions = widget.existingIntakes
        .map((e) => e.supplierName)
        .toSet()
        .toList();
    _vehicleSuggestions = widget.existingIntakes
        .map((e) => e.vehicleNumber)
        .toSet()
        .toList();
  }

  @override
  void dispose() {
    _supplierController.dispose();
    _vehicleController.dispose();
    _customerController.dispose();
    super.dispose();
  }

  void _addMaterial() {
    setState(() {
      _materialTypes.add({
        "name": "",
        "grossWeight": 0.0,
        "tareWeight": 0.0,
        "netWeight": 0.0,
      });
    });
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
                const Text(
                  "Create Yard Intake",
                  style: TextStyle(
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
                  _buildAutocompleteField(
                    _supplierController,
                    "Supplier Name",
                    _supplierSuggestions,
                  ),
                  const SizedBox(height: 16),
                  _buildAutocompleteField(
                    _vehicleController,
                    "Vehicle Number",
                    _vehicleSuggestions,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(_customerController, "Customer Name"),
                  const SizedBox(height: 16),
                  const Text(
                    "Status",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _status,
                    dropdownColor: AppTheme.bgColor,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: ["Pending", "Completed", "Paid"]
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (value) => setState(() => _status = value!),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Material Types",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _addMaterial,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text("Add"),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.orangeAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ..._materialTypes.asMap().entries.map(
                    (entry) => _buildMaterialItem(entry.key, entry.value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            AppButton(
              text: "Create Intake",
              onPressed: () {
                widget.onCreate({
                  "supplierName": _supplierController.text,
                  "vehicleNumber": _vehicleController.text,
                  "customerName": _customerController.text,
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

  Widget _buildAutocompleteField(
    TextEditingController controller,
    String label,
    List<String> options,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text == '') {
              return options;
            }
            return options.where((String option) {
              return option.toLowerCase().contains(
                textEditingValue.text.toLowerCase(),
              );
            });
          },
          onSelected: (String selection) {
            controller.text = selection;
          },
          fieldViewBuilder:
              (context, fieldController, focusNode, onFieldSubmitted) {
                // Sync with our controller
                if (controller.text.isNotEmpty &&
                    fieldController.text.isEmpty) {
                  fieldController.text = controller.text;
                }
                fieldController.addListener(() {
                  controller.text = fieldController.text;
                });
                return TextField(
                  controller: fieldController,
                  focusNode: focusNode,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: label,
                    labelStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white38,
                    ),
                  ),
                );
              },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                color: Colors.transparent,
                child: Container(
                  width: constraints.maxWidth,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.bgColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white10),
                  ),
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (context, index) =>
                        const Divider(color: Colors.white10, height: 1),
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        title: Text(
                          option,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialItem(int idx, Map<String, dynamic> material) {
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
            onChanged: (val) => material["name"] = val,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: "Material Name",
              labelStyle: TextStyle(color: Colors.white54),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    material["grossWeight"] = double.tryParse(val) ?? 0.0;
                    material["netWeight"] =
                        material["grossWeight"] - material["tareWeight"];
                    setState(() {});
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Gross Wt",
                    labelStyle: TextStyle(color: Colors.white54),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    material["tareWeight"] = double.tryParse(val) ?? 0.0;
                    material["netWeight"] =
                        material["grossWeight"] - material["tareWeight"];
                    setState(() {});
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Tare Wt",
                    labelStyle: TextStyle(color: Colors.white54),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "${material["netWeight"]} kg",
                  style: const TextStyle(
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
