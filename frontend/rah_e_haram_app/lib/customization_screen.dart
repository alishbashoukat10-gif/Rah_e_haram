
import 'package:flutter/material.dart';
import 'services/api_service.dart';

class CustomizationScreen extends StatefulWidget {
  final Map<String, dynamic> package;

  const CustomizationScreen({
    super.key,
    required this.package,
  });

  @override
  State<CustomizationScreen> createState() =>
      _CustomizationScreenState();
}

class _CustomizationScreenState extends State<CustomizationScreen> {
  static const Color green = Color(0xFF063D34);
  static const Color gold = Color(0xFFB58A3A);

  final TextEditingController requirementsController =
      TextEditingController();

  int selectedDuration = 21;
  bool isSubmitting = false;

  double get basePrice {
    return (widget.package['price'] as num?)?.toDouble() ?? 0;
  }

  int get baseDuration {
    return (widget.package['durationDays'] as num?)?.toInt() ?? 1;
  }

  double get estimatedPrice {
    if (baseDuration <= 0) return basePrice;

    return basePrice * selectedDuration / baseDuration;
  }

  @override
  void initState() {
    super.initState();

    final originalDuration = baseDuration;
    selectedDuration = [21, 27, 30].contains(originalDuration)
        ? originalDuration
        : 21;
  }

  @override
  void dispose() {
    requirementsController.dispose();
    super.dispose();
  }

  Widget durationOption(int days) {
    final selected = selectedDuration == days;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedDuration = days;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: selected ? green : Colors.white,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: selected ? green : Colors.grey.shade300,
            ),
          ),
          child: Column(
            children: [
              Text(
                '$days',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: selected ? Colors.white : green,
                ),
              ),
              Text(
                'Days',
                style: TextStyle(
                  fontSize: 11,
                  color: selected ? Colors.white70 : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Submit customization request to backend
  Future<void> submitRequest() async {
    if (requirementsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter your customization requirements.',
          ),
        ),
      );
      return;
    }

    final packageId = widget.package['_id']?.toString();

    if (packageId == null || packageId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Package ID is missing. Please select a valid package.',
          ),
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final response = await ApiService.submitCustomization(
        packageId: packageId,
        requestedDuration: selectedDuration,
        specialRequirements:
            requirementsController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        isSubmitting = false;
      });

      await showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text(
            'Request Submitted Successfully',
            style: TextStyle(
              color: green,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Your customization request for $selectedDuration days '
            'has been saved successfully.\n\n'
            'The selected agency can now review your requirements '
            'and respond with availability and a confirmed price.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
              child: const Text(
                'Done',
                style: TextStyle(
                  color: green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to submit request: ${error.toString()}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted && isSubmitting) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final packageName =
        widget.package['packageName']?.toString() ??
            'Selected Package';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F5),
      appBar: AppBar(
        backgroundColor: green,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Customize Package'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Make It Your Journey',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: green,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Request changes according to your travel needs.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 22),

            // Selected package
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SELECTED PACKAGE',
                    style: TextStyle(
                      color: gold,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    packageName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'Original duration: $baseDuration days',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Original price: Rs. ${basePrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 23),

            const Text(
              'Choose Your Trip Duration',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Select your preferred number of days.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 13),

            Row(
              children: [
                durationOption(21),
                const SizedBox(width: 10),
                durationOption(27),
                const SizedBox(width: 10),
                durationOption(30),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              'Special Requirements',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Mention any additional changes you need.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: requirementsController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText:
                    'e.g. Hotel closer to Haram, additional transport, '
                    'room preferences...',
                hintStyle: const TextStyle(fontSize: 12),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: green),
                ),
              ),
            ),

            const SizedBox(height: 23),

            // Estimated cost
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4DD),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: const Color(0xFFEAD9B2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Preliminary Estimated Cost',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'Rs. ${estimatedPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: green,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'This is a proportional estimate based on the original '
                    'package price and duration. It is not an agency quote. '
                    'Final cost depends on agency confirmation.',
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            SizedBox(
              width: double.infinity,
              height: 49,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: green.withOpacity(0.6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        height: 21,
                        width: 21,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Submit Customization Request',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
