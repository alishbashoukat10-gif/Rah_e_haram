
import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'results_screen.dart';

class RequirementsScreen extends StatefulWidget {
  final String packageType;

  const RequirementsScreen({
    super.key,
    required this.packageType,
  });

  @override
  State<RequirementsScreen> createState() => _RequirementsScreenState();
}

class _RequirementsScreenState extends State<RequirementsScreen> {
  static const Color green = Color(0xFF063D34);
  static const Color gold = Color(0xFFB58A3A);

  final TextEditingController budgetController = TextEditingController();

  int selectedDuration = 7;

  double pricePriority = 5;
  double hotelPriority = 5;
  double transportPriority = 5;
  double durationPriority = 5;

  bool isLoading = false;

  @override
  void dispose() {
    budgetController.dispose();
    super.dispose();
  }

  // GET TOPSIS RECOMMENDATIONS
  Future<void> findPackages() async {
    final budget = double.tryParse(
      budgetController.text.trim().replaceAll(',', ''),
    );

    // Validate budget
    if (budget == null || !budget.isFinite || budget <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid maximum budget.'),
        ),
      );
      return;
    }

    // Validate journey type
    if (!['Hajj', 'Umrah'].contains(widget.packageType)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid journey type. Please select Hajj or Umrah.'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Send requirements and priority weights to backend
      final result = await ApiService.recommendPackages(
        maxBudget: budget,
        durationDays: selectedDuration,
        packageType: widget.packageType,
        weights: {
          'price': pricePriority,
          'hotel': hotelPriority,
          'transport': transportPriority,
          'duration': durationPriority,
        },
      );

      if (!mounted) return;

      if (result is! Map) {
        throw Exception('Invalid recommendation response from server.');
      }

      final responseData = Map<String, dynamic>.from(result);

      final rawPackages = responseData['results'];

      if (rawPackages is! List) {
        throw Exception('Package recommendation results were not received.');
      }

      final List<dynamic> packages = rawPackages;

      setState(() {
        isLoading = false;
      });

      // Open results screen, including when no packages match
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen(
            results: packages,
            packageType: widget.packageType,
          ),
        ),
      );

    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not get recommendations: ${error.toString()}',
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // DURATION SELECTION
  Widget durationChip(int days) {
    final isSelected = selectedDuration == days;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDuration = days;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: isSelected ? green : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? green : const Color(0xFFE9E5DA),
          ),
        ),
        child: Text(
          '$days days',
          style: TextStyle(
            fontSize: 13,
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // PRIORITY SLIDER
  Widget prioritySlider(
    String title,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: green,
            inactiveTrackColor: const Color(0xFFEDE9DC),
            thumbColor: green,
            overlayColor: green.withOpacity(0.10),
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 8,
            ),
          ),
          child: Slider(
            value: value,
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Requirements',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF222222),
                ),
              ),

              const SizedBox(height: 3),

              Text(
                'Tell us what matters most for your journey',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 22),

              const Text(
                'Hard requirements',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Maximum budget (Rs.)',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),

                    TextField(
                      controller: budgetController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        hintText: 'e.g. 500000',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[500],
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                'Trip duration',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Wrap(
                spacing: 7,
                children: [
                  durationChip(7),
                  durationChip(14),
                  durationChip(21),
                ],
              ),

              const SizedBox(height: 22),

              const Text(
                'Your priorities',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Slide to show how important each one is',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 13),

              prioritySlider(
                'Price',
                pricePriority,
                (value) => setState(() => pricePriority = value),
              ),

              prioritySlider(
                'Hotel',
                hotelPriority,
                (value) => setState(() => hotelPriority = value),
              ),

              prioritySlider(
                'Transport',
                transportPriority,
                (value) => setState(() => transportPriority = value),
              ),

              prioritySlider(
                'Duration',
                durationPriority,
                (value) => setState(() => durationPriority = value),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading ? null : findPackages,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: green.withOpacity(0.7),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Find Packages',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
