import 'package:flutter/material.dart';
import 'winter_arc_theme.dart';
import 'widgets/hero_section.dart';
import 'widgets/chapter_navigation.dart';
import 'widgets/macro_calculator.dart';
import 'widgets/mission_builder.dart';
import 'widgets/timer_widget.dart';
import 'widgets/checklist_widget.dart';

class WinterArcGuideScreen extends StatefulWidget {
  const WinterArcGuideScreen({super.key});

  @override
  State<WinterArcGuideScreen> createState() => _WinterArcGuideScreenState();
}

class _WinterArcGuideScreenState extends State<WinterArcGuideScreen> {
  final ScrollController _scrollController = ScrollController();

  // Keys for each section
  final List<GlobalKey> _sectionKeys = List.generate(7, (_) => GlobalKey());

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WinterArcTheme.black,
      body: Stack(
        children: [
          // Main content
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Hero section
              SliverToBoxAdapter(
                child: const HeroSection(),
              ),

              // All content sections
              SliverToBoxAdapter(
                child: _buildAllSections(),
              ),
            ],
          ),

          // Sticky navigation
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ChapterNavigation(
              scrollController: _scrollController,
              sectionKeys: _sectionKeys,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllSections() {
    return Column(
      children: [
        _buildIntroductionSection(),
        _buildChapter1(),
        _buildChapter2(),
        _buildChapter3(),
        _buildChapter4(),
        _buildChapter5(),
        _buildConclusionSection(),
      ],
    );
  }

  // Helper methods for building sections
  Widget _buildSection({
    required int index,
    required String title,
    required List<Widget> children,
    Color? backgroundColor,
  }) {
    final isMobile = WinterArcTheme.isMobile(context);

    return Container(
      key: _sectionKeys[index],
      width: double.infinity,
      color: backgroundColor ?? WinterArcTheme.charcoal,
      padding: WinterArcTheme.responsiveSectionPadding(context),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: WinterArcTheme.desktopMaxWidth),
          child: Padding(
            padding: WinterArcTheme.responsivePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: isMobile
                      ? WinterArcTheme.chapterTitleMobile
                      : WinterArcTheme.chapterTitle,
                ),
                SizedBox(height: isMobile ? WinterArcTheme.spacingL : WinterArcTheme.spacingXL),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubsection(String title, List<Widget> children) {
    final isMobile = WinterArcTheme.isMobile(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: isMobile
              ? WinterArcTheme.subsectionTitleMobile
              : WinterArcTheme.subsectionTitle,
        ),
        const SizedBox(height: WinterArcTheme.spacingM),
        ...children,
        const SizedBox(height: WinterArcTheme.spacingXL),
      ],
    );
  }

  Widget _buildParagraph(String text) {
    final isMobile = WinterArcTheme.isMobile(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: WinterArcTheme.spacingM),
      child: Text(
        text,
        style: isMobile ? WinterArcTheme.bodyLargeMobile : WinterArcTheme.bodyLarge,
      ),
    );
  }

  Widget _buildBulletList(List<String> items) {
    final isMobile = WinterArcTheme.isMobile(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: WinterArcTheme.spacingS),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8, right: 12),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: WinterArcTheme.iceBlue,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  item,
                  style: isMobile ? WinterArcTheme.bodyMediumMobile : WinterArcTheme.bodyMedium,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPullQuote(String quote) {
    final isMobile = WinterArcTheme.isMobile(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: WinterArcTheme.spacingL),
      padding: EdgeInsets.all(isMobile ? WinterArcTheme.spacingM : WinterArcTheme.spacingL),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: WinterArcTheme.iceBlue,
            width: 4,
          ),
        ),
        color: WinterArcTheme.darkGray.withOpacity(0.5),
      ),
      child: Text(
        '"$quote"',
        style: isMobile ? WinterArcTheme.pullQuoteMobile : WinterArcTheme.pullQuote,
      ),
    );
  }

  Widget _buildImagePlaceholder(String label) {
    final isMobile = WinterArcTheme.isMobile(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: WinterArcTheme.spacingL),
      height: isMobile ? 200 : 300,
      decoration: BoxDecoration(
        color: WinterArcTheme.darkGray,
        borderRadius: BorderRadius.circular(WinterArcTheme.radiusL),
        border: Border.all(
          color: WinterArcTheme.gray.withOpacity(0.3),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_outlined,
              size: isMobile ? 48 : 64,
              color: WinterArcTheme.gray,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: WinterArcTheme.bodyMedium.copyWith(
                color: WinterArcTheme.gray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // INTRODUCTION SECTION
  Widget _buildIntroductionSection() {
    return _buildSection(
      index: 0,
      title: 'INTRODUCTION',
      backgroundColor: WinterArcTheme.black,
      children: [
        _buildSubsection(
          'Winter Is Not an Enemy. It\'s an Invitation.',
          [
            _buildParagraph(
              'Winter, for many, is synonymous with retreat, a forced pause, shorter and colder days that invite inertia. It\'s the season when most people slow down, when New Year\'s resolutions begin to fade, and motivation seems to hibernate. However, what most see as an obstacle, the true warrior sees as an opportunity.',
            ),
            _buildPullQuote(
              'The cold exposes. It doesn\'t forgive weaknesses, but, at the same time, it reveals resilience.',
            ),
            _buildParagraph(
              'This guide is not just a manual; it\'s your war plan. It\'s your strategy to transform winter, traditionally seen as a season of stagnation, into your strongest season. While the outside world shelters from the cold, you will be invited to delve deep into yourself, to rebuild, to strengthen, and to emerge more robust, more focused, and more prepared for the challenges to come.',
            ),
            _buildParagraph(
              'Prepare to accelerate while most slow down. Prepare to use the rigor of winter as the catalyst for your best version. Welcome to the Winter Arc. Your journey begins now.',
            ),
          ],
        ),
      ],
    );
  }

  // CHAPTER 1
  Widget _buildChapter1() {
    return _buildSection(
      index: 1,
      title: 'CHAPTER 1 — THE WINTER AS A TEST',
      backgroundColor: WinterArcTheme.charcoal,
      children: [
        _buildImagePlaceholder('Winter landscape / Warrior in snow'),

        _buildSubsection(
          'Why most "die in winter" (mentally and physically)',
          [
            _buildParagraph(
              'Winter is, metaphorically, a proving ground. Reduced sunlight, lower temperatures, and the body\'s natural tendency to conserve energy create an environment conducive to lethargy. Most people succumb to this state, not for lack of will, but for lack of a conscious strategy to combat it.',
            ),
            _buildParagraph(
              'Mentally, the absence of external stimuli and less social interaction can lead to feelings of isolation and demotivation. Physically, the combination of a more caloric diet and decreased physical activity often results in weight gain and loss of fitness. It\'s a vicious cycle: physical inertia fuels mental apathy, and vice versa.',
            ),
            _buildPullQuote(
              'To "die in winter" is to allow external circumstances to dictate your internal state, a silent surrender that compromises the potential for growth.',
            ),
          ],
        ),

        _buildSubsection(
          'The concept of the "Seasonal Warrior"',
          [
            _buildParagraph(
              'The Seasonal Warrior is one who reverses this logic. Instead of seeing winter as a period of survival, they embrace it as a phase of intense preparation and rebirth. It\'s an opportunity to focus on what can be controlled: the body, mind, and spirit.',
            ),
            _buildParagraph(
              'While nature sleeps, the Seasonal Warrior awakens. They use isolation for introspection, the cold to test their resilience, and the darkness to ignite their own inner light. This concept is based on the idea that the seasons of greatest difficulty are, in fact, those that offer the greatest potential for transformation.',
            ),
          ],
        ),

        _buildSubsection(
          'The psychological power of discomfort',
          [
            _buildParagraph(
              'Humans are biologically programmed to seek comfort and avoid discomfort. However, it is precisely in discomfort that growth resides. Embracing the cold of a winter morning to train, resisting the temptation of unhealthy foods, or dedicating time to silence instead of digital distraction are acts of rebellion against our own nature.',
            ),
            _buildParagraph(
              'Every time you choose the harder path, you strengthen your discipline and self-confidence. Voluntary discomfort acts as a psychological vaccine: by exposing yourself to small doses of controlled adversity, you become more resilient to larger, unforeseen challenges.',
            ),
          ],
        ),

        _buildSubsection(
          'Mental routine: 10 minutes of silence and daily purpose',
          [
            _buildParagraph(
              'In the constant noise of the modern world, silence is a powerful tool. Dedicating just 10 minutes of your day to absolute silence can have a transformative impact. This is not a complex meditation practice, but an exercise in presence and intention.',
            ),
            _buildParagraph(
              'Upon waking, before reaching for your phone or getting caught up in the day\'s hustle, sit in silence. Use this time to connect with your purpose. Ask yourself: "What is my mission for today? What do I need to do to get closer to the person I want to be?"',
            ),
          ],
        ),

        const SizedBox(height: WinterArcTheme.spacingXL),

        // Mission Statement Builder
        const MissionStatementBuilder(),
      ],
    );
  }

  // CHAPTER 2
  Widget _buildChapter2() {
    return _buildSection(
      index: 2,
      title: 'CHAPTER 2 — THE BODY AS A FORTRESS',
      backgroundColor: WinterArcTheme.black,
      children: [
        _buildImagePlaceholder('Strong physique / Training scene'),

        _buildSubsection(
          'Understanding that physical strength is emotional strength',
          [
            _buildParagraph(
              'The connection between body and mind is undeniable. A strong body is not just a matter of aesthetics or athletic ability; it is the foundation upon which emotional resilience is built. The act of subjecting oneself to rigorous physical training, of overcoming pain and fatigue, teaches the mind to persevere in the face of adversity.',
            ),
            _buildPullQuote(
              'Every repetition, every set, every drop of sweat is a lesson in discipline and overcoming.',
            ),
            _buildParagraph(
              'When you prove yourself capable of pushing your physical limits, that confidence spills over into other areas of your life. Physical strength becomes a metaphor for emotional strength: the ability to bear the weight of challenges, to stand firm under pressure, and to rise stronger after every fall.',
            ),
          ],
        ),

        _buildSubsection(
          'Why the body is the foundation of confidence and leadership',
          [
            _buildParagraph(
              'Your posture, your energy, and the way you move in the world are direct reflections of your physical condition. A trained body projects confidence. It\'s not about arrogance, but a quiet assurance that emanates from someone who knows they have control over themselves.',
            ),
            _buildParagraph(
              'Leadership, in its essence, begins with self-leadership. How can you lead others if you cannot lead yourself out of bed on a cold morning to train? Commitment to physical health and strength demonstrates responsibility, discipline, and a mindset geared towards excellence – qualities that inspire respect and trust in others.',
            ),
          ],
        ),

        _buildSubsection(
          'How to train in winter — strategies for energy and consistency',
          [
            _buildBulletList([
              'Extended Dynamic Warm-up: Cold weather increases the risk of injury. Start each workout with 10-15 minutes of dynamic warm-up, including jumping jacks, jump rope, joint rotations, and specific movements for the muscle groups you will be training.',
              'Train Early in the Day: If possible, train in the morning. This not only ensures the workout is done before the day\'s excuses accumulate, but also boosts your energy levels and improves your mood for the rest of the day.',
              'Have a Backup Plan: There will be days when going to the gym or training outdoors is impossible. Have a quick and effective home workout plan that can be performed with minimal equipment.',
              'Focus on Performance: Instead of focusing solely on aesthetics, set performance goals: increase the load, do one more repetition, decrease rest time.',
            ]),
          ],
        ),

        _buildSubsection(
          'Zero-to-hero training plan (beginner)',
          [
            _buildParagraph(
              'This 12-week plan is designed to take you from zero to performance, building a solid foundation of strength and endurance.',
            ),

            const SizedBox(height: WinterArcTheme.spacingM),

            _buildTrainingPhase(
              'Week 1–4: Full Body with Bodyweight',
              'Train 3 times a week, on non-consecutive days (e.g., Monday, Wednesday, and Friday).',
              [
                ['Squats', '3', '15-20', '60 sec'],
                ['Push-ups (knees if needed)', '3', 'To failure', '60 sec'],
                ['Plank', '3', '30-60 sec', '60 sec'],
                ['Lunges', '3', '10-12 (each leg)', '60 sec'],
                ['Inverted Row', '3', '10-15', '60 sec'],
                ['Calf Raises', '3', '20-25', '45 sec'],
              ],
            ),

            const SizedBox(height: WinterArcTheme.spacingL),

            // Full example workout details
            _buildParagraph(
              'Full Example Workout - Week 1-4:',
            ),
            const SizedBox(height: WinterArcTheme.spacingS),
            _buildBulletList([
              'Squats: Stand with feet shoulder-width apart, lower your hips back and down as if sitting in a chair, keeping chest up and knees tracking over toes. Return to standing by driving through your heels.',
              'Push-ups: Start in a plank position with hands slightly wider than shoulder-width. Lower your chest to the ground while keeping your body in a straight line, then push back up. (Modify on knees if needed)',
              'Plank: Hold a push-up position with forearms on the ground, keeping your body in a straight line from head to heels. Engage your core and don\'t let your hips sag.',
              'Lunges: Step forward with one leg, lowering your hips until both knees are bent at 90 degrees. Push back to starting position and repeat on the other leg.',
              'Inverted Row: Use a bar at waist height or TRX straps. Hang underneath with body straight, pull chest to bar, then lower back down with control.',
            ]),

            const SizedBox(height: WinterArcTheme.spacingL),

            _buildTrainingPhase(
              'Week 5–8: Resistance + Load',
              'Train 4 times a week (e.g., Monday, Tuesday, Thursday, Friday). Introduce external load (dumbbells, kettlebells, or backpack with weight).',
              [
                ['Dumbbell Bench Press', '4', '8-12', '90 sec'],
                ['Dumbbell Bent-Over Row', '4', '8-12', '90 sec'],
                ['Goblet Squat', '4', '8-12', '90 sec'],
                ['Dumbbell Romanian Deadlift', '4', '8-12', '90 sec'],
              ],
            ),

            const SizedBox(height: WinterArcTheme.spacingL),

            _buildParagraph(
              'Week 9–12: Performance and Aesthetics - Increase intensity with load progression, drop sets, and supersets to maximize strength gains and muscle definition.',
            ),
          ],
        ),

        _buildSubsection(
          'Quick routine for those with only 20 minutes a day',
          [
            _buildParagraph(
              'Perform the following circuit as many times as possible in 20 minutes, with minimal rest between exercises:',
            ),
            _buildBulletList([
              'Burpees: 10 repetitions',
              'Jump Squats: 15 repetitions',
              'Push-ups: 10 repetitions',
              'Mountain Climbers: 30 seconds',
              'Plank: 30 seconds',
            ]),
          ],
        ),

        _buildSubsection(
          'Adapted version for women',
          [
            _buildParagraph(
              'While the fundamental training principles remain the same, women may benefit from additional emphasis on certain movements that address specific biomechanical and aesthetic goals. Add these exercises to your routine 2-3 times per week:',
            ),
            const SizedBox(height: WinterArcTheme.spacingM),
            _buildBulletList([
              'Hip Abduction: Using resistance bands or cable machine, perform lateral leg raises to target the gluteus medius. 3 sets of 15-20 reps per leg. This helps create hip stability and aesthetic hip shape.',
              'Unilateral Hip Thrust: Single-leg hip thrusts with shoulders on a bench. This movement maximizes glute activation and addresses any strength imbalances between sides. 3 sets of 10-12 reps per leg.',
              'Additional Core Work: Women often benefit from extra core training to support posture and functional strength. Add side planks and dead bugs to your routine.',
            ]),
            const SizedBox(height: WinterArcTheme.spacingM),
            _buildParagraph(
              'Note: These are additions to the main program, not replacements. The core compound movements (squats, push-ups, rows) remain essential for building overall strength and fitness.',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrainingPhase(String title, String description, List<List<String>> exercises) {
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: isMobile
                ? WinterArcTheme.subsectionTitleMobile.copyWith(fontSize: 18)
                : WinterArcTheme.subsectionTitle.copyWith(fontSize: 22),
          ),
          const SizedBox(height: WinterArcTheme.spacingS),
          Text(
            description,
            style: isMobile ? WinterArcTheme.bodyMediumMobile : WinterArcTheme.bodyMedium,
          ),
          const SizedBox(height: WinterArcTheme.spacingM),

          // Exercise table
          if (!isMobile)
            _buildExerciseTable(exercises)
          else
            _buildExerciseCards(exercises),
        ],
      ),
    );
  }

  Widget _buildExerciseTable(List<List<String>> exercises) {
    return Table(
      border: TableBorder.all(
        color: WinterArcTheme.gray.withOpacity(0.3),
        width: 1,
      ),
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1.5),
        3: FlexColumnWidth(1.5),
      },
      children: [
        // Header
        TableRow(
          decoration: BoxDecoration(
            color: WinterArcTheme.iceBlue.withOpacity(0.2),
          ),
          children: ['Exercise', 'Sets', 'Reps', 'Rest'].map((header) {
            return Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                header,
                style: WinterArcTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }).toList(),
        ),
        // Rows
        ...exercises.map((exercise) {
          return TableRow(
            children: exercise.map((cell) {
              return Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  cell,
                  style: WinterArcTheme.bodyMedium,
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildExerciseCards(List<List<String>> exercises) {
    return Column(
      children: exercises.map((exercise) {
        return Container(
          margin: const EdgeInsets.only(bottom: WinterArcTheme.spacingS),
          padding: const EdgeInsets.all(WinterArcTheme.spacingS),
          decoration: BoxDecoration(
            color: WinterArcTheme.charcoal,
            borderRadius: BorderRadius.circular(WinterArcTheme.radiusM),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exercise[0],
                style: WinterArcTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: WinterArcTheme.iceBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${exercise[1]} sets × ${exercise[2]} reps',
                style: WinterArcTheme.bodyMedium,
              ),
              Text(
                'Rest: ${exercise[3]}',
                style: WinterArcTheme.bodyMedium.copyWith(fontSize: 14),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // CHAPTER 3
  Widget _buildChapter3() {
    return _buildSection(
      index: 3,
      title: 'CHAPTER 3 — STRATEGIC NUTRITION',
      backgroundColor: WinterArcTheme.charcoal,
      children: [
        _buildImagePlaceholder('Healthy food / Meal prep'),

        _buildSubsection(
          'Why you gain fat in winter (and how to reverse it)',
          [
            _buildParagraph(
              'Winter is a challenging season for maintaining body weight. The body\'s natural tendency is to accumulate fat reserves to protect itself from the cold and to compensate for the historically lower availability of food. Furthermore, decreased sun exposure affects vitamin D production, which is linked to metabolism and mood, and reduced physical activity, combined with increased intake of calorie-rich comfort foods, creates the perfect scenario for fat gain.',
            ),
            _buildParagraph(
              'To reverse this, a conscious and strategic approach is crucial. It\'s not about deprivation, but about smart choices and optimizing metabolism.',
            ),
          ],
        ),

        const SizedBox(height: WinterArcTheme.spacingXL),

        // Macro Calculator
        const MacroCalculator(),

        const SizedBox(height: WinterArcTheme.spacingXL),

        _buildSubsection(
          'Simple strategy for clean and practical eating',
          [
            _buildParagraph(
              'Clean eating doesn\'t have to be complicated. The focus should be on whole, minimally processed foods:',
            ),
            _buildBulletList([
              'Protein Sources: Chicken breast, turkey, fish (salmon, cod), eggs, lean red meat, legumes (lentils, chickpeas), tofu.',
              'Complex Carbohydrate Sources: Sweet potato, brown rice, oats, quinoa, whole-wheat bread, vegetables (broccoli, spinach, cauliflower).',
              'Healthy Fat Sources: Avocado, extra virgin olive oil, nuts (almonds, walnuts), seeds (chia, flaxseed).',
              'Hydration: Drink plenty of water throughout the day. Unsweetened teas are also an excellent option in winter.',
            ]),
            const SizedBox(height: WinterArcTheme.spacingM),
            _buildPullQuote(
              'Meal prep your meals in advance. Cook large quantities of protein and carbohydrates on the weekend to have ready-to-eat meals during the week.',
            ),
          ],
        ),

        _buildSubsection(
          'Food swap table',
          [
            _buildParagraph(
              'Make smart swaps to improve your nutrition without feeling deprived:',
            ),
            const SizedBox(height: WinterArcTheme.spacingM),
            _buildFoodSwapTable(),
          ],
        ),

        _buildSubsection(
          'Winter Cut Plan - Example Daily Meal Plan',
          [
            _buildParagraph(
              'For those looking to lose fat while maintaining muscle mass. This example provides approximately 1800-2000 calories with high protein:',
            ),
            const SizedBox(height: WinterArcTheme.spacingM),
            _buildBulletList([
              'Breakfast: 3 scrambled eggs with spinach + 1 slice whole-wheat toast + black coffee',
              'Mid-Morning Snack: Greek yogurt (200g) with berries',
              'Lunch: Grilled chicken breast (150g) + large salad with olive oil dressing + sweet potato (150g)',
              'Pre-Workout Snack: Apple + handful of almonds',
              'Post-Workout Dinner: Baked salmon (150g) + steamed broccoli + quinoa (100g cooked)',
              'Evening Snack (if needed): Protein shake or cottage cheese',
            ]),
          ],
        ),

        _buildSubsection(
          'Winter Build Plan - Example Daily Meal Plan',
          [
            _buildParagraph(
              'For those looking to build muscle mass and strength. This example provides approximately 2500-2800 calories with emphasis on protein and carbs:',
            ),
            const SizedBox(height: WinterArcTheme.spacingM),
            _buildBulletList([
              'Breakfast: 4 whole eggs + oatmeal (80g dry) with banana and honey',
              'Mid-Morning Snack: Protein shake with milk + peanut butter',
              'Lunch: Lean beef (180g) + brown rice (150g cooked) + mixed vegetables',
              'Pre-Workout Snack: Rice cakes with almond butter + banana',
              'Post-Workout: Protein shake + white rice (100g cooked)',
              'Dinner: Chicken thighs (200g) + sweet potato (200g) + green beans',
              'Evening Snack: Cottage cheese (200g) + walnuts',
            ]),
          ],
        ),

        _buildSubsection(
          'Protocols for focus and energy',
          [
            _buildBulletList([
              'Protein-Rich Breakfast: Start your day with eggs, Greek yogurt, or a protein shake. This stabilizes blood sugar levels and provides sustained energy.',
              'Smart Snacks: Avoid sugar spikes. Opt for snacks that combine protein and healthy fat (e.g., a handful of almonds, cottage cheese).',
              'Strategic Caffeine: Use coffee or green tea for an energy boost, but avoid excessive consumption, especially in the afternoon, to avoid disrupting sleep.',
              'Constant Hydration: Mild dehydration can cause fatigue and lack of concentration. Keep a water bottle nearby.',
            ]),
          ],
        ),

        _buildSubsection(
          'Essential supplements for energy, focus, and immunity',
          [
            _buildParagraph(
              'While diet is the foundation, some supplements can optimize your results in winter:',
            ),
            _buildBulletList([
              'Vitamin D3: Essential due to less sun exposure. Contributes to immunity, bone health, and mood. Dose: 2000-5000 IU/day.',
              'Omega-3 (Fish Oil): Anti-inflammatory, beneficial for brain, cardiovascular, and joint health. Dose: 1-3g EPA+DHA/day.',
              'Creatine: Improves strength, power, and muscle recovery. Dose: 3-5g/day.',
              'Zinc and Magnesium (ZMA): Support for immunity, muscle recovery, and sleep quality. Take before bed.',
              'Vitamin C: Antioxidant and immune support. Dose: 500-1000mg/day.',
            ]),
            const SizedBox(height: WinterArcTheme.spacingM),
            _buildParagraph(
              'Remember, supplements are a complement, not a substitute for proper diet and training. Always consult a healthcare professional before starting any supplementation.',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFoodSwapTable() {
    final isMobile = WinterArcTheme.isMobile(context);

    final swaps = [
      ['White Bread', 'Whole-wheat Bread', 'More fiber, satiety, stable energy'],
      ['White Rice', 'Brown Rice / Quinoa', 'More fiber, vitamins, minerals'],
      ['Soft Drinks', 'Sparkling Water with Lemon', 'No sugar, hydration'],
      ['French Fries', 'Baked Sweet Potato', 'More fiber, vitamins, complex carbs'],
      ['Sweets/Cookies', 'Fresh Fruit / Nuts', 'Vitamins, minerals, healthy fats'],
      ['Processed Meats', 'Chicken Breast / Turkey', 'Less sodium, more lean protein'],
    ];

    if (isMobile) {
      return Column(
        children: swaps.map((swap) {
          return Container(
            margin: const EdgeInsets.only(bottom: WinterArcTheme.spacingS),
            padding: const EdgeInsets.all(WinterArcTheme.spacingM),
            decoration: BoxDecoration(
              color: WinterArcTheme.darkGray,
              borderRadius: BorderRadius.circular(WinterArcTheme.radiusM),
              border: Border.all(
                color: WinterArcTheme.iceBlue.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        swap[0],
                        style: WinterArcTheme.bodyMedium.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: WinterArcTheme.lightGray,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward,
                      color: WinterArcTheme.iceBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        swap[1],
                        style: WinterArcTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: WinterArcTheme.iceBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  swap[2],
                  style: WinterArcTheme.bodyMedium.copyWith(fontSize: 13),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    return Table(
      border: TableBorder.all(
        color: WinterArcTheme.gray.withOpacity(0.3),
        width: 1,
      ),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(3),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: WinterArcTheme.iceBlue.withOpacity(0.2),
          ),
          children: ['Less Healthy', 'Healthy Swap', 'Benefit'].map((header) {
            return Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                header,
                style: WinterArcTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }).toList(),
        ),
        ...swaps.map((swap) {
          return TableRow(
            children: swap.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  entry.value,
                  style: WinterArcTheme.bodyMedium.copyWith(
                    decoration: entry.key == 0 ? TextDecoration.lineThrough : null,
                    color: entry.key == 1 ? WinterArcTheme.iceBlue : null,
                    fontWeight: entry.key == 1 ? FontWeight.w700 : null,
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  // CHAPTER 4
  Widget _buildChapter4() {
    return _buildSection(
      index: 4,
      title: 'CHAPTER 4 — THE MIND OF THE SILENT WARRIOR',
      backgroundColor: WinterArcTheme.black,
      children: [
        _buildImagePlaceholder('Meditation / Contemplation scene'),

        _buildSubsection(
          'Silence as mental training',
          [
            _buildParagraph(
              'In a world saturated with noise and distractions, silence has become a luxury and, for the Seasonal Warrior, an essential tool for mental training. Silence is not the absence of sound, but the presence of clarity.',
            ),
            _buildPullQuote(
              'It is in silence that the mind can process thoughts, emotions, and experiences without constant external interruption.',
            ),
            _buildParagraph(
              'Dedicating time to silence, whether through meditation, contemplation, or simply turning off all devices, allows you to listen to your inner voice, identify thought patterns, and strengthen your ability to concentrate. It is a training for the mind to learn to be present, to observe without judgment, and to find calm amidst the storm.',
            ),
          ],
        ),

        _buildSubsection(
          'How to deal with loneliness, demotivation, and inertia',
          [
            _buildParagraph(
              'Winter can amplify feelings of loneliness, demotivation, and inertia. The Seasonal Warrior does not ignore these emotions but faces them with strategy:',
            ),
            const SizedBox(height: WinterArcTheme.spacingM),
            _buildBulletList([
              'Loneliness: Instead of fighting it, use loneliness as an opportunity for introspection and self-knowledge. Dedicate time to activities that nourish you, such as reading, writing, or learning something new.',
              'Demotivation: Motivation is volatile. Instead of waiting for it, focus on discipline. Create routines and stick to them, regardless of how you feel. Start with small daily victories to build momentum.',
              'Inertia: Inertia is the enemy of progress. The "3-Minute Rule" is a powerful tool to combat it. The simple act of starting a task, even for a short period, can break the cycle of inertia and lead you to continue.',
            ]),
          ],
        ),

        _buildSubsection(
          'Discipline vs. Motivation',
          [
            _buildParagraph(
              'Motivation is like a spark; it can ignite a fire, but it doesn\'t keep it burning. Discipline, on the other hand, is the fuel that continuously feeds the flame. Motivation is driven by emotions and external circumstances, making it inconsistent. Discipline is the consistent adherence to a set of rules and habits, regardless of your state of mind.',
            ),
            _buildPullQuote(
              'It is discipline that makes you train when you are tired, study when you would rather rest, or eat healthily when temptation is great.',
            ),
            _buildParagraph(
              'In the long run, it is discipline that builds character, achieves goals, and transforms lives. The Seasonal Warrior understands that motivation is a bonus, but discipline is the non-negotiable foundation of success.',
            ),
          ],
        ),

        _buildSubsection(
          'The 3-Minute Rule - Breaking the Cycle of Inertia',
          [
            _buildParagraph(
              'The hardest part of any task is starting. Once in motion, continuing becomes significantly easier. The 3-Minute Rule is a psychological tool to overcome this initial resistance.',
            ),
            _buildParagraph(
              'The principle is simple: commit to doing any task for just 3 minutes. No matter how unmotivated you feel, tell yourself you only need to do it for 3 minutes. Want to avoid the gym? Go for just 3 minutes. Can\'t start that project? Work on it for just 3 minutes. Don\'t feel like studying? Open the book for just 3 minutes.',
            ),
            _buildPullQuote(
              'What happens after 3 minutes is that inertia is broken. The task no longer seems insurmountable, and you\'ll often find yourself naturally continuing beyond the initial 3 minutes.',
            ),
            _buildParagraph(
              'This rule works because it eliminates the mental barrier of commitment. Three minutes feels manageable, even trivial. But it\'s enough to activate your momentum and shift from a state of inaction to action. Use the timer below to practice this powerful technique.',
            ),
          ],
        ),

        const SizedBox(height: WinterArcTheme.spacingXL),

        // 3-Minute Timer
        const TimerWidget(),

        const SizedBox(height: WinterArcTheme.spacingXL),

        _buildSubsection(
          '"Morning Reboot": 5-step morning routine',
          [
            _buildParagraph(
              'A powerful morning routine sets the tone for a productive and focused day:',
            ),
            const SizedBox(height: WinterArcTheme.spacingM),
            _buildNumberedList([
              'Wake Up Early: Before sunrise, if possible. This gives you a head start on the day and peaceful time before the world wakes up.',
              'Hydration: Drink a large glass of water with lemon. This rehydrates the body after sleep and stimulates metabolism.',
              'Movement: Do 10-15 minutes of light exercise, such as stretching, yoga, or a few push-ups and squats. This activates the body and mind.',
              'Silence and Purpose: Dedicate 10 minutes to your mental routine, focusing on your "Winter Mission Statement" and the day\'s goals.',
              'Nutrition: Eat a protein-rich and nutrient-dense breakfast to fuel your body and mind.',
            ]),
          ],
        ),

        _buildSubsection(
          'The 7-Day Monk Mode Challenge',
          [
            _buildParagraph(
              'Monk Mode is a period of extreme focus and discipline, where you eliminate all distractions and dedicate yourself entirely to your most important goals. This 7-day challenge is designed to reset your mind, break bad habits, and accelerate your progress.',
            ),
            const SizedBox(height: WinterArcTheme.spacingM),
            _buildParagraph(
              'Rules for 7-Day Monk Mode:',
            ),
            const SizedBox(height: WinterArcTheme.spacingS),
            _buildNumberedList([
              'No Social Media: Delete or disable all social media apps for the entire week. No scrolling, no checking, no exceptions.',
              'No Entertainment: No TV shows, movies, video games, or casual YouTube browsing. Reading for learning is allowed.',
              'Minimal Phone Use: Only essential calls and messages. Turn off all non-essential notifications.',
              'Early to Bed, Early to Rise: Sleep by 10 PM, wake up by 6 AM (or earlier). Consistent sleep schedule is crucial.',
              'Training Every Day: Some form of physical activity every single day. Even if brief, movement is non-negotiable.',
              'Clean Eating: No processed foods, no sugar, no alcohol. Only whole foods from your nutrition plan.',
              'Daily Reflection: Spend 20 minutes each evening journaling - what you accomplished, what you learned, how you felt.',
            ]),
            const SizedBox(height: WinterArcTheme.spacingM),
            _buildPullQuote(
              'Monk Mode is not about suffering - it\'s about clarity. By removing distractions, you create space for deep focus and meaningful progress.',
            ),
            _buildParagraph(
              'Complete this challenge once during your first month of Winter Arc. You\'ll emerge with renewed mental clarity, broken addictions to instant gratification, and proof that you can control your environment and choices.',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberedList(List<String> items) {
    final isMobile = WinterArcTheme.isMobile(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.asMap().entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: WinterArcTheme.spacingS),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 12),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: WinterArcTheme.iceBlue,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${entry.key + 1}',
                    style: const TextStyle(
                      color: WinterArcTheme.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  entry.value,
                  style: isMobile ? WinterArcTheme.bodyMediumMobile : WinterArcTheme.bodyMedium,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // CHAPTER 5
  Widget _buildChapter5() {
    return _buildSection(
      index: 5,
      title: 'CHAPTER 5 — THE WINTER ARC CODE',
      backgroundColor: WinterArcTheme.charcoal,
      children: [
        _buildImagePlaceholder('Warrior code / Ancient principles'),

        _buildSubsection(
          'The 7 principles of the Winter Arc',
          [
            _buildParagraph(
              'The Winter Arc Code is not a set of rules, but a guide of principles that, when internalized and consistently practiced, transform the individual into a Seasonal Warrior. These principles are the backbone of your transformation journey, forging character and resilience.',
            ),
            const SizedBox(height: WinterArcTheme.spacingM),
            _buildNumberedList([
              'Discipline: The ability to do what needs to be done, regardless of mood or circumstances. It is the bridge between goals and achievements.',
              'Clarity: Knowing your purpose, your values, and your goals. It is having a clear vision of what you want and what it takes to get there.',
              'Sacrifice: The willingness to give up immediate pleasure for long-term gain. It is understanding that growth requires giving up something less important.',
              'Consistency: The continuous and unwavering practice of your habits and commitments. It is repetition that transforms actions into results and results into character.',
              'Silence: The active search for moments of introspection and reflection, away from noise and distractions. It is where the mind strengthens and wisdom flourishes.',
              'Honor: Living according to your principles, maintaining integrity in all actions. It is respect for yourself and others, even when no one is watching.',
              'Overcoming: The incessant pursuit of going beyond your perceived limits, transforming challenges into opportunities for growth.',
            ]),
          ],
        ),

        _buildSubsection(
          'How to apply each principle daily',
          [
            _buildParagraph(
              'Understanding the principles is the first step. Living them daily is what creates transformation. Here\'s how to integrate each principle into your everyday life:',
            ),
            const SizedBox(height: WinterArcTheme.spacingM),
            _buildBulletList([
              'Discipline: Start your day by doing the hardest task first. When your alarm goes off, count down from 5 and immediately get up - no negotiation. This trains your mind that discipline is non-negotiable.',
              'Clarity: Write down your top 3 priorities each morning. Before making any decision, ask yourself: "Does this align with my Winter Mission?" If not, it\'s a distraction.',
              'Sacrifice: Identify one comfort you\'ll give up each day. It could be sleeping in, scrolling social media, or eating junk food. Each small sacrifice strengthens your will.',
              'Consistency: Focus on showing up, even when results aren\'t visible. Miss zero days of your core habits. The power is in the repetition, not the intensity of any single day.',
              'Silence: Protect 10 minutes of silence each day as fiercely as you\'d protect a meeting with your most important client. No phone, no music, no input - just you and your thoughts.',
              'Honor: Do the right thing when no one is watching. Put weights back at the gym. Keep your word to yourself before keeping it to others. Honor starts with self-respect.',
              'Overcoming: Each day, do one thing that scares you or makes you uncomfortable. Call it your "daily dragon" - and slay it before noon.',
            ]),
          ],
        ),

        const SizedBox(height: WinterArcTheme.spacingXL),

        _buildSubsection(
          'Daily Checklist',
          [
            const ChecklistWidget(
              title: 'Daily Winter Arc Checklist',
              items: [
                'Wake up early (before 6am/7am)',
                '10 minutes of silence and purpose',
                'Morning hydration (water with lemon)',
                'Workout (as per plan)',
                'Clean eating (all meals)',
                'Review of "Winter Mission Statement"',
                'Identify a small sacrifice made',
                'A moment of silence/introspection',
                'An act of honor (with yourself or others)',
                'A small overcoming (stepping out of comfort zone)',
              ],
            ),
          ],
        ),

        const SizedBox(height: WinterArcTheme.spacingL),

        _buildSubsection(
          'Weekly Checklist',
          [
            const ChecklistWidget(
              title: 'Weekly Winter Arc Checklist',
              items: [
                '3-4 full strength workouts',
                '2-3 cardio sessions (brisk walk, run)',
                'Meal prep for the week',
                'Progress review (weight, measurements, performance)',
                'Plan adjustment (if necessary)',
                'A period of "Monk Mode" (if applicable)',
                'Reflection on Winter Arc principles',
                'Planning for the next week',
              ],
            ),
          ],
        ),

        const SizedBox(height: WinterArcTheme.spacingXL),

        _buildSubsection(
          '60-day plan with monthly goals',
          [
            _buildParagraph(
              'This plan is a framework for your first two months in the Winter Arc. Adapt it to your specific needs and goals.',
            ),
            const SizedBox(height: WinterArcTheme.spacingL),

            _buildMonthPlan(
              'Month 1: Foundation and Discipline',
              [
                'Main Goal: Establish and solidify the daily routine (Morning Reboot, 10 minutes of silence, workouts, clean eating).',
                'Focus: Consistency in full-body training (Weeks 1-4 of the training plan). Learn to calculate and monitor calories and macros.',
                'Challenge: Complete the 7-day "Monk Mode."',
                'Expected Results: Increased energy, improved sleep, initial fat loss/strength gain, greater mental clarity.',
              ],
            ),

            const SizedBox(height: WinterArcTheme.spacingL),

            _buildMonthPlan(
              'Month 2: Intensification and Overcoming',
              [
                'Main Goal: Increase training intensity and deepen the application of Winter Arc principles.',
                'Focus: Training progression (Weeks 5-8 of the training plan, introduction of load). Nutrition optimization with the "Winter Cut" or "Winter Build" plan.',
                'Challenge: Overcome a personal limit in training (e.g., do one more repetition, increase weight).',
                'Expected Results: Visible gains in strength and muscle mass, greater definition, ingrained discipline, enhanced mental resilience.',
              ],
            ),
          ],
        ),

        const SizedBox(height: WinterArcTheme.spacingXXL),

        _buildSubsection(
          'Day-Closing Rituals - End Your Day Like a Warrior',
          [
            _buildParagraph(
              'How you end your day is just as important as how you start it. A proper day-closing ritual allows you to process the day, celebrate victories, learn from failures, and prepare for tomorrow. This ritual creates a psychological boundary between work and rest, ensuring better sleep and mental clarity.',
            ),
            const SizedBox(height: WinterArcTheme.spacingM),
            _buildParagraph(
              'The 5-Step Day-Closing Ritual:',
            ),
            const SizedBox(height: WinterArcTheme.spacingS),
            _buildNumberedList([
              'Review Your Daily Checklist: Go through your Winter Arc checklist. Acknowledge what you accomplished. Don\'t beat yourself up over what you missed - just note it for tomorrow.',
              'Identify Your Daily Victory: Write down one thing you\'re proud of from today. It doesn\'t have to be big - showing up when you didn\'t feel like it counts. This trains your brain to look for wins.',
              'Extract One Lesson: What did today teach you? What would you do differently? This isn\'t about dwelling on mistakes - it\'s about continuous improvement. One lesson per day compounds into wisdom.',
              'Prepare for Tomorrow: Lay out your workout clothes. Prep your breakfast. Write your top 3 priorities. This removes friction and decision fatigue from your morning.',
              'Digital Sunset: 60 minutes before bed, turn off all screens. Use this time for light reading, stretching, or quiet conversation. This signals your body it\'s time to wind down and dramatically improves sleep quality.',
            ]),
            const SizedBox(height: WinterArcTheme.spacingM),
            _buildPullQuote(
              'The day-closing ritual is your moment of accountability. It\'s where you face yourself honestly, celebrate progress, and commit to showing up again tomorrow.',
            ),
            _buildParagraph(
              'Consistency with this ritual will transform not just your days, but your entire relationship with time, progress, and self-discipline. Make it sacred.',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMonthPlan(String title, List<String> items) {
    final isMobile = WinterArcTheme.isMobile(context);

    return Container(
      padding: EdgeInsets.all(isMobile ? WinterArcTheme.spacingM : WinterArcTheme.spacingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            WinterArcTheme.iceBlue.withOpacity(0.15),
            WinterArcTheme.iceBlueLight.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(WinterArcTheme.radiusL),
        border: Border.all(
          color: WinterArcTheme.iceBlue.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: isMobile
                ? WinterArcTheme.subsectionTitleMobile
                : WinterArcTheme.subsectionTitle,
          ),
          const SizedBox(height: WinterArcTheme.spacingM),
          _buildBulletList(items),
        ],
      ),
    );
  }

  // CONCLUSION
  Widget _buildConclusionSection() {
    return _buildSection(
      index: 6,
      title: 'SPRING BELONGS ONLY TO THOSE WHO FOUGHT IN WINTER',
      backgroundColor: WinterArcTheme.black,
      children: [
        _buildImagePlaceholder('Transformation / Spring emerging'),

        _buildParagraph(
          'We have reached the end of your winter war plan, but the end of this guide is just the beginning of your continuous journey. Spring, with its promise of renewal and growth, is a gift for those who dared to face the rigor of winter.',
        ),

        _buildPullQuote(
          'It is not for those who hibernated, but for those who fought, who strengthened themselves, who used the cold and darkness as a furnace to forge their best version.',
        ),

        _buildParagraph(
          'The beauty of spring is amplified by the memory of battles fought and won in the most challenging months. Your resilience, your discipline, and your strength have been tested and proven. You not only survived winter; you conquered it.',
        ),

        const SizedBox(height: WinterArcTheme.spacingL),

        _buildSubsection(
          'How to maintain the winter mindset throughout the rest of the year',
          [
            _buildParagraph(
              'The Winter Arc mindset is not seasonal; it is a philosophy of life. The principles of discipline, clarity, sacrifice, consistency, silence, honor, and overcoming are universal and applicable in all seasons. To maintain this mindset:',
            ),
            const SizedBox(height: WinterArcTheme.spacingM),
            _buildBulletList([
              'Continue to Practice Voluntary Discomfort: Don\'t wait for the next winter to challenge yourself. Look for opportunities to step out of your comfort zone.',
              'Maintain Your Routines: Your morning routine, your workouts, and your clean eating should not be abandoned. Adapt them, if necessary, but maintain the structure that made you strong.',
              'Re-evaluate Your "Mission Statement": As you grow, your goals may evolve. Review your "Winter Mission Statement" and adapt it for the new seasons.',
              'Be an Example: Inspire others with your transformation. Share your journey and the principles that guided you. Leadership begins with example.',
            ]),
          ],
        ),

        const SizedBox(height: WinterArcTheme.spacingXXL),

        // Final message
        Container(
          padding: const EdgeInsets.all(WinterArcTheme.spacingXL),
          decoration: BoxDecoration(
            gradient: WinterArcTheme.accentGradient,
            borderRadius: BorderRadius.circular(WinterArcTheme.radiusL),
          ),
          child: Column(
            children: [
              Text(
                'May the strength you found in winter guide you through all seasons.',
                style: WinterArcTheme.sectionTitle.copyWith(
                  color: WinterArcTheme.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: WinterArcTheme.spacingM),
              Text(
                'May your discipline be your compass and your resilience, your armor. Spring is your reward, but the true victory lies in the person you have become.',
                style: WinterArcTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: WinterArcTheme.spacingXXL),

        // Back to top button
        Center(
          child: OutlinedButton.icon(
            onPressed: () {
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeInOut,
              );
            },
            icon: const Icon(Icons.arrow_upward),
            label: const Text('BACK TO TOP'),
            style: OutlinedButton.styleFrom(
              foregroundColor: WinterArcTheme.iceBlue,
              side: BorderSide(color: WinterArcTheme.iceBlue),
              padding: const EdgeInsets.symmetric(
                horizontal: WinterArcTheme.spacingL,
                vertical: WinterArcTheme.spacingM,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(WinterArcTheme.radiusM),
              ),
            ),
          ),
        ),

        const SizedBox(height: WinterArcTheme.spacingXXL),
      ],
    );
  }
}
