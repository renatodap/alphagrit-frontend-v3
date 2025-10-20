import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../winter_arc_theme.dart';

class MacroCalculator extends StatefulWidget {
  const MacroCalculator({super.key});

  @override
  State<MacroCalculator> createState() => _MacroCalculatorState();
}

class _MacroCalculatorState extends State<MacroCalculator> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();

  String _gender = 'male';
  String _activityLevel = '1.55'; // Moderately active default
  String _goal = 'maintain';

  // Results
  double? _bmr;
  double? _tdee;
  double? _targetCalories;
  double? _protein;
  double? _fats;
  double? _carbs;

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    final weight = double.parse(_weightController.text);
    final height = double.parse(_heightController.text);
    final age = int.parse(_ageController.text);

    // Calculate BMR (Mifflin-St Jeor)
    double bmr;
    if (_gender == 'male') {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }

    // Calculate TDEE
    final tdee = bmr * double.parse(_activityLevel);

    // Calculate target calories based on goal
    double targetCalories;
    if (_goal == 'cut') {
      targetCalories = tdee - 400; // Moderate deficit
    } else if (_goal == 'bulk') {
      targetCalories = tdee + 400; // Moderate surplus
    } else {
      targetCalories = tdee;
    }

    // Calculate macros
    final protein = _goal == 'cut' ? 2.2 * weight : 2.0 * weight;
    final fats = 0.9 * weight;
    final proteinCalories = protein * 4;
    final fatCalories = fats * 9;
    final carbCalories = targetCalories - proteinCalories - fatCalories;
    final carbs = carbCalories / 4;

    setState(() {
      _bmr = bmr;
      _tdee = tdee;
      _targetCalories = targetCalories;
      _protein = protein;
      _fats = fats;
      _carbs = carbs.clamp(0, double.infinity); // Prevent negative carbs
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = WinterArcTheme.isMobile(context);

    return Container(
      padding: EdgeInsets.all(isMobile ? WinterArcTheme.spacingM : WinterArcTheme.spacingL),
      decoration: BoxDecoration(
        color: WinterArcTheme.darkGray,
        borderRadius: BorderRadius.circular(WinterArcTheme.radiusL),
        border: Border.all(
          color: WinterArcTheme.iceBlue.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: WinterArcTheme.cardShadow,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Macro Calculator',
              style: isMobile
                  ? WinterArcTheme.subsectionTitleMobile
                  : WinterArcTheme.subsectionTitle,
            ),

            const SizedBox(height: WinterArcTheme.spacingS),

            Text(
              'Calculate your daily calories and macronutrient needs',
              style: isMobile
                  ? WinterArcTheme.bodyMediumMobile
                  : WinterArcTheme.bodyMedium,
            ),

            const SizedBox(height: WinterArcTheme.spacingL),

            // Form fields
            isMobile
                ? _buildMobileForm()
                : _buildDesktopForm(),

            const SizedBox(height: WinterArcTheme.spacingL),

            // Calculate button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _calculate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: WinterArcTheme.iceBlue,
                  padding: const EdgeInsets.symmetric(vertical: WinterArcTheme.spacingM),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(WinterArcTheme.radiusM),
                  ),
                ),
                child: Text(
                  'CALCULATE',
                  style: WinterArcTheme.buttonText,
                ),
              ),
            ),

            // Results
            if (_tdee != null) ...[
              const SizedBox(height: WinterArcTheme.spacingXL),
              _buildResults(isMobile),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMobileForm() {
    return Column(
      children: [
        _buildTextField('Weight (kg)', _weightController),
        const SizedBox(height: WinterArcTheme.spacingM),
        _buildTextField('Height (cm)', _heightController),
        const SizedBox(height: WinterArcTheme.spacingM),
        _buildTextField('Age', _ageController),
        const SizedBox(height: WinterArcTheme.spacingM),
        _buildGenderSelector(),
        const SizedBox(height: WinterArcTheme.spacingM),
        _buildActivitySelector(),
        const SizedBox(height: WinterArcTheme.spacingM),
        _buildGoalSelector(),
      ],
    );
  }

  Widget _buildDesktopForm() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildTextField('Weight (kg)', _weightController)),
            const SizedBox(width: WinterArcTheme.spacingM),
            Expanded(child: _buildTextField('Height (cm)', _heightController)),
            const SizedBox(width: WinterArcTheme.spacingM),
            Expanded(child: _buildTextField('Age', _ageController)),
          ],
        ),
        const SizedBox(height: WinterArcTheme.spacingM),
        Row(
          children: [
            Expanded(child: _buildGenderSelector()),
            const SizedBox(width: WinterArcTheme.spacingM),
            Expanded(child: _buildActivitySelector()),
            const SizedBox(width: WinterArcTheme.spacingM),
            Expanded(child: _buildGoalSelector()),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
      style: const TextStyle(color: WinterArcTheme.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: WinterArcTheme.lightGray),
        filled: true,
        fillColor: WinterArcTheme.charcoal,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(WinterArcTheme.radiusM),
          borderSide: BorderSide(color: WinterArcTheme.gray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(WinterArcTheme.radiusM),
          borderSide: BorderSide(color: WinterArcTheme.gray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(WinterArcTheme.radiusM),
          borderSide: BorderSide(color: WinterArcTheme.iceBlue),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Required';
        }
        return null;
      },
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: WinterArcTheme.bodyMedium.copyWith(fontSize: 14),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildRadio('Male', 'male'),
            const SizedBox(width: 16),
            _buildRadio('Female', 'female'),
          ],
        ),
      ],
    );
  }

  Widget _buildRadio(String label, String value) {
    return GestureDetector(
      onTap: () => setState(() => _gender = value),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: WinterArcTheme.iceBlue, width: 2),
              color: _gender == value ? WinterArcTheme.iceBlue : Colors.transparent,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(color: WinterArcTheme.offWhite),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySelector() {
    return DropdownButtonFormField<String>(
      value: _activityLevel,
      dropdownColor: WinterArcTheme.charcoal,
      style: const TextStyle(color: WinterArcTheme.white),
      decoration: InputDecoration(
        labelText: 'Activity Level',
        labelStyle: const TextStyle(color: WinterArcTheme.lightGray),
        filled: true,
        fillColor: WinterArcTheme.charcoal,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(WinterArcTheme.radiusM),
        ),
      ),
      items: const [
        DropdownMenuItem(value: '1.2', child: Text('Sedentary')),
        DropdownMenuItem(value: '1.375', child: Text('Lightly Active')),
        DropdownMenuItem(value: '1.55', child: Text('Moderately Active')),
        DropdownMenuItem(value: '1.725', child: Text('Very Active')),
        DropdownMenuItem(value: '1.9', child: Text('Extremely Active')),
      ],
      onChanged: (value) => setState(() => _activityLevel = value!),
    );
  }

  Widget _buildGoalSelector() {
    return DropdownButtonFormField<String>(
      value: _goal,
      dropdownColor: WinterArcTheme.charcoal,
      style: const TextStyle(color: WinterArcTheme.white),
      decoration: InputDecoration(
        labelText: 'Goal',
        labelStyle: const TextStyle(color: WinterArcTheme.lightGray),
        filled: true,
        fillColor: WinterArcTheme.charcoal,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(WinterArcTheme.radiusM),
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'cut', child: Text('Winter Cut (Lose Fat)')),
        DropdownMenuItem(value: 'maintain', child: Text('Maintain')),
        DropdownMenuItem(value: 'bulk', child: Text('Winter Build (Gain Muscle)')),
      ],
      onChanged: (value) => setState(() => _goal = value!),
    );
  }

  Widget _buildResults(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? WinterArcTheme.spacingM : WinterArcTheme.spacingL),
      decoration: BoxDecoration(
        gradient: WinterArcTheme.accentGradient,
        borderRadius: BorderRadius.circular(WinterArcTheme.radiusL),
      ),
      child: Column(
        children: [
          Text(
            'Your Results',
            style: isMobile
                ? WinterArcTheme.subsectionTitleMobile
                : WinterArcTheme.subsectionTitle,
          ),
          const SizedBox(height: WinterArcTheme.spacingM),
          isMobile ? _buildMobileResults() : _buildDesktopResults(),
        ],
      ),
    );
  }

  Widget _buildMobileResults() {
    return Column(
      children: [
        _buildResultItem('BMR', '${_bmr!.toStringAsFixed(0)} cal'),
        const SizedBox(height: WinterArcTheme.spacingS),
        _buildResultItem('TDEE', '${_tdee!.toStringAsFixed(0)} cal'),
        const SizedBox(height: WinterArcTheme.spacingS),
        _buildResultItem('Target Calories', '${_targetCalories!.toStringAsFixed(0)} cal'),
        const Divider(color: WinterArcTheme.white, height: WinterArcTheme.spacingL),
        _buildResultItem('Protein', '${_protein!.toStringAsFixed(0)}g'),
        const SizedBox(height: WinterArcTheme.spacingS),
        _buildResultItem('Fats', '${_fats!.toStringAsFixed(0)}g'),
        const SizedBox(height: WinterArcTheme.spacingS),
        _buildResultItem('Carbs', '${_carbs!.toStringAsFixed(0)}g'),
      ],
    );
  }

  Widget _buildDesktopResults() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildResultItem('BMR', '${_bmr!.toStringAsFixed(0)} cal'),
            _buildResultItem('TDEE', '${_tdee!.toStringAsFixed(0)} cal'),
            _buildResultItem('Target', '${_targetCalories!.toStringAsFixed(0)} cal'),
          ],
        ),
        const Divider(color: WinterArcTheme.white, height: WinterArcTheme.spacingL),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildResultItem('Protein', '${_protein!.toStringAsFixed(0)}g'),
            _buildResultItem('Fats', '${_fats!.toStringAsFixed(0)}g'),
            _buildResultItem('Carbs', '${_carbs!.toStringAsFixed(0)}g'),
          ],
        ),
      ],
    );
  }

  Widget _buildResultItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: WinterArcTheme.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: WinterArcTheme.white,
          ),
        ),
      ],
    );
  }
}
