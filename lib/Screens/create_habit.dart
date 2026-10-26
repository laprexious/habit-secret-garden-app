
import 'package:flutter/material.dart';

class CreateHabitScreen extends StatefulWidget {
  const CreateHabitScreen({super.key});

  @override
  State<CreateHabitScreen> createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends State<CreateHabitScreen> {
  String? _selectedCategory;
  String? _customCategoryName;
  String? _selectedIcon;
  int? _weeklyTarget;

  //PRESET ICON SETTINGS FOR PRESET CATEGORIES
    final Map<String, String> _categoryIcons = {
      'Health': 'assets/images/habit_icons/health-icon.png',
      'Personal Growth':
          'assets/images/habit_icons/personal-growth-icon.png',
      'Productivity': 'assets/images/habit_icons/productivity-icon.png',
    };
    //DISPLAY ICON CHOICES AVAILABLE TO USER//

    final List<String> _habitIcons = [
      'assets/images/habit-icons/academic-icon.png',
      'assets/images/habit-icons/bee-icon.png',
      'assets/images/habit-icons/butterfly-icon.png',
      'assets/images/habit-icons/clover-icon.png',
      'assets/images/habit-icons/fitness-icon.png',
      'assets/images/habit-icons/flowers-icon.png',
      'assets/images/habit-icons/mushroom-icon.png',
      'assets/images/habit-icons/self-care-icon.png',
      'assets/images/habit-icons/snail-icon.png',
      'assets/images/habit-icons/study-icon.png',
      'assets/images/habit-icons/watering-icon.png',
    ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3EFE6),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Image.asset(
            'assets/images/back-icon.png',
            width: 54,
            height: 54,
          ),
          tooltip: 'Back to Garden',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Create New Habit'),
      ),
      //SCREEN BODY
      //HABIT NAME FIELD
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Habit Name *',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'e.g. Read for 20 minutes',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            
            //CATEGORY DROP-DOWN
            const SizedBox(height: 20),
            const Text(
              'Category *',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
                initialValue: _selectedCategory,              decoration: InputDecoration(
                hintText: 'Select a category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Health',
                  child: Text('Health'),
                ),
                DropdownMenuItem(
                  value: 'Personal Growth',
                  child: Text('Personal Growth'),
                ),
                DropdownMenuItem(
                  value: 'Productivity',
                  child: Text('Productivity'),
                ),
                DropdownMenuItem(
                  value: 'Other',
                  child: Text('Other'),
                ),
              ],
              //LOGIC FOR OTHER SELECTION// 
              //SETS THE STATE AND CALLS APP TO REBUILD WITH 
              //CATEGORY INPUT FIELD AND ICON SELECTIONS
              onChanged: (String? value) {
                setState(() {
                  _selectedCategory = value;

                  if (value == 'Other') {
                    _selectedIcon = null;
                    _customCategoryName = null;
                  } else {
                    _selectedIcon = _categoryIcons[value];
                    _customCategoryName = null;
                  }
                });
              },
            ),
            //OFFERS CUSTOM TEXT FIELD FOR CATEGORY NAME INPUT AND ICON SELECTION//
            if (_selectedCategory == 'Other') ...[
              const SizedBox(height: 20),
              const Text(
                'Custom Category Name *',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'e.g. Gym, Finance, Self-Care, Academics',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  _customCategoryName = value;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Choose an Icon *',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                ),
              ),
              //VISUAL LAYOUT FOR ICONS//
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemCount: _habitIcons.length,
                  itemBuilder: (context, index) {
                    final iconPath = _habitIcons[index];
                    final isSelected = _selectedIcon == iconPath;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedIcon = iconPath;
                        });
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned.fill(
                            child: Image.asset(
                              iconPath,
                              fit: BoxFit.contain,
                            ),
                          ),
                          if (isSelected)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Icon(
                                Icons.check_circle,
                                color: Theme.of(context).colorScheme.primary,
                                size: 24,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
            // WEEKLY TARGET SELECTION
            const SizedBox(height: 28),
            const Text(
              'Weekly Target *',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'How many days per week?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: List.generate(7, (index) {
                final days = index + 1;
                final isSelected = _weeklyTarget == days;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: AspectRatio(
                      aspectRatio: 1,
                      //buttons ui
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _weeklyTarget = days;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          foregroundColor: isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurface,
                          side: BorderSide(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        child: Text(
                          '$days',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            // GARDEN GUIDE SUGGESTION
            const SizedBox(height: 28),
            const Text(
              'Garden Guide Suggestion',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE5EEDC),
                border: Border.all(
                  color: const Color.fromARGB(255, 124, 199, 121),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/grass-icon.png',
                    width: 62,
                    height: 62,
                    fit: BoxFit.contain,
        
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 4),
                        const Text(
                          'Start small and stay consistent. '
                          'Choose a weekly goal that fits your routine '
                          'so your habit has room to grow!',
                          style: TextStyle(
                            fontSize: 18,
                            color:  Color.fromARGB(255, 52, 105, 52),
                            fontWeight: FontWeight.w600,

                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // OPTIONAL MOTIVATION NOTE
            const SizedBox(height: 24),
            const Text(
              'Motivation Note (Optional)',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Why is this habit important to you?',
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Write your motivation here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                // Motivation will be saved when we add habit storage.
              },
            ),
          ],
        ),
      ),
      // Save and Cancel buttons pinned to bottom nav bar*
      bottomNavigationBar: Container(
        color: const Color.fromARGB(255, 228, 223, 211),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Save Habit',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
