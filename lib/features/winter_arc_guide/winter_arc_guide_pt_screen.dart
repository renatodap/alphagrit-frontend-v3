import 'package:flutter/material.dart';
import 'winter_arc_theme.dart';
import 'widgets/hero_section.dart';
import 'widgets/chapter_navigation.dart';
import 'widgets/macro_calculator.dart';
import 'widgets/mission_builder.dart';
import 'widgets/timer_widget.dart';
import 'widgets/checklist_widget.dart';

class WinterArcGuidePtScreen extends StatefulWidget {
  const WinterArcGuidePtScreen({super.key});

  @override
  State<WinterArcGuidePtScreen> createState() => _WinterArcGuidePtScreenState();
}

class _WinterArcGuidePtScreenState extends State<WinterArcGuidePtScreen> {
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
      title: 'INTRODUÇÃO',
      backgroundColor: WinterArcTheme.black,
      children: [
        _buildSubsection(
          'O Inverno Não É Um Inimigo. É Um Convite.',
          [
            _buildParagraph(
              'O inverno, para muitos, é sinónimo de recolhimento, de uma pausa forçada, de dias mais curtos e frios que convidam à inércia. É a estação em que a maioria das pessoas desacelera, em que os objetivos de ano novo começam a desvanecer-se e a motivação parece hibernar. No entanto, o que a maioria vê como um obstáculo, o verdadeiro guerreiro vê como uma oportunidade.',
            ),
            _buildPullQuote(
              'O frio expõe. Ele não perdoa fraquezas, mas, ao mesmo tempo, revela a resiliência.',
            ),
            _buildParagraph(
              'Este e-book não é apenas um guia; é o seu plano de guerra. É a sua estratégia para transformar o inverno, tradicionalmente visto como uma estação de estagnação, na sua versão mais forte. Enquanto o mundo exterior se abriga do frio, você será convidado a mergulhar profundamente em si mesmo, a reconstruir, a fortalecer e a emergir mais robusto, mais focado e mais preparado para os desafios que virão.',
            ),
            _buildParagraph(
              'Prepare-se para acelerar enquanto a maioria desacelera. Prepare-se para usar o rigor do inverno como o catalisador para a sua melhor versão. Bem-vindo ao Winter Arc. A sua jornada começa agora.',
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
      title: 'CAPÍTULO 1 — O INVERNO COMO TESTE',
      backgroundColor: WinterArcTheme.charcoal,
      children: [
        _buildImagePlaceholder('Paisagem de inverno / Guerreiro na neve'),

        _buildSubsection(
          'Por que a maioria "morre no inverno" (mentalmente e fisicamente)',
          [
            _buildParagraph(
              'O inverno é, metaforicamente, um campo de provas. A redução da luz solar, as temperaturas mais baixas e a tendência natural do corpo para conservar energia criam um ambiente propício à letargia. A maioria das pessoas sucumbe a este estado, não por falta de vontade, mas por falta de uma estratégia consciente para o combater.',
            ),
            _buildParagraph(
              'Mentalmente, a ausência de estímulos externos e a menor interação social podem levar a sentimentos de isolamento e desmotivação. Fisicamente, a combinação de uma dieta mais calórica e a diminuição da atividade física resulta frequentemente em ganho de peso e perda de condição física. É um ciclo vicioso: a inércia física alimenta a apatia mental, e vice-versa.',
            ),
            _buildPullQuote(
              '"Morrer no inverno" é, na verdade, permitir que as circunstâncias externas ditem o seu estado interno, uma rendição silenciosa que compromete o potencial de crescimento.',
            ),
          ],
        ),

        _buildSubsection(
          'O conceito do "Seasonal Warrior": usar o inverno para renascer',
          [
            _buildParagraph(
              'O Guerreiro Sazonal (Seasonal Warrior) é aquele que inverte esta lógica. Em vez de ver o inverno como um período de sobrevivência, ele o encara como uma fase de intensa preparação e renascimento. É a oportunidade de se focar no que pode ser controlado: o corpo, a mente e o espírito.',
            ),
            _buildParagraph(
              'Enquanto a natureza adormece, o Guerreiro Sazonal desperta. Ele utiliza o isolamento para a introspeção, o frio para testar a sua resiliência e a escuridão para acender a sua própria luz interior. Este conceito baseia-se na ideia de que as estações de maior dificuldade são, na verdade, as que oferecem o maior potencial de transformação.',
            ),
          ],
        ),

        _buildSubsection(
          'O poder psicológico do desconforto',
          [
            _buildParagraph(
              'O ser humano é biologicamente programado para procurar o conforto e evitar o desconforto. No entanto, é precisamente no desconforto que reside o crescimento. Abraçar o frio de uma manhã de inverno para treinar, resistir à tentação de alimentos pouco saudáveis ou dedicar tempo ao silêncio em vez de à distração digital são atos de rebelião contra a nossa própria natureza.',
            ),
            _buildParagraph(
              'Cada vez que você escolhe o caminho mais difícil, fortalece a sua disciplina e a sua autoconfiança. O desconforto voluntário funciona como uma vacina psicológica: ao expor-se a pequenas doses de adversidade controlada, você torna-se mais resistente a desafios maiores e imprevistos.',
            ),
          ],
        ),

        _buildSubsection(
          'Rotina mental: 10 minutos de silêncio e propósito diário',
          [
            _buildParagraph(
              'No meio do ruído constante do mundo moderno, o silêncio é uma ferramenta poderosa. Dedicar apenas 10 minutos do seu dia ao silêncio absoluto pode ter um impacto transformador. Esta não é uma prática de meditação complexa, mas sim um exercício de presença e intenção.',
            ),
            _buildParagraph(
              'Ao acordar, antes de pegar no telemóvel ou se deixar levar pela agitação do dia, sente-se em silêncio. Use este tempo para se conectar com o seu propósito. Pergunte a si mesmo: "Qual é a minha missão para hoje? O que preciso de fazer para me aproximar da pessoa que quero ser?"',
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
      title: 'CAPÍTULO 2 — O CORPO COMO FORTALEZA',
      backgroundColor: WinterArcTheme.black,
      children: [
        _buildImagePlaceholder('Físico forte / Cena de treino'),

        _buildSubsection(
          'Entendendo que força física é força emocional',
          [
            _buildParagraph(
              'A conexão entre o corpo e a mente é inegável. Um corpo forte não é apenas uma questão de estética ou capacidade atlética; é a base sobre a qual a resiliência emocional é construída. O ato de se submeter a um treino físico rigoroso, de superar a dor e o cansaço, ensina a mente a perseverar diante da adversidade.',
            ),
            _buildPullQuote(
              'Cada repetição, cada série, cada gota de suor é uma lição de disciplina e superação.',
            ),
            _buildParagraph(
              'Quando você se prova capaz de empurrar os seus limites físicos, essa confiança transborda para outras áreas da sua vida. A força física torna-se uma metáfora para a força emocional: a capacidade de suportar o peso dos desafios, de se manter firme sob pressão e de se levantar mais forte após cada queda.',
            ),
          ],
        ),

        _buildSubsection(
          'Por que o corpo é a base da confiança e da liderança',
          [
            _buildParagraph(
              'A sua postura, a sua energia e a forma como você se move no mundo são reflexos diretos da sua condição física. Um corpo treinado projeta confiança. Não se trata de arrogância, mas de uma segurança silenciosa que emana de quem sabe que tem o controlo sobre si mesmo.',
            ),
            _buildParagraph(
              'A liderança, em sua essência, começa com a autoliderança. Como pode liderar os outros se não consegue liderar a si mesmo para fora da cama numa manhã fria para treinar? O compromisso com a saúde e a força física demonstra responsabilidade, disciplina e uma mentalidade orientada para a excelência – qualidades que inspiram respeito e confiança nos outros.',
            ),
          ],
        ),

        _buildSubsection(
          'Como treinar no inverno — estratégias para energia e consistência',
          [
            _buildBulletList([
              'Aquecimento Dinâmico Prolongado: O frio aumenta o risco de lesões. Comece cada treino com 10-15 minutos de aquecimento dinâmico, incluindo polichinelos, saltos à corda, rotações de articulações e movimentos específicos para os grupos musculares que irá treinar.',
              'Treine no Início do Dia: Se possível, treine de manhã. Isso não só garante que o treino seja feito antes que as desculpas do dia se acumulem, mas também aumenta os seus níveis de energia e melhora o seu humor para o resto do dia.',
              'Tenha um Plano B: Haverá dias em que ir ao ginásio ou treinar ao ar livre será impossível. Tenha um plano de treino em casa, rápido e eficaz, que possa ser executado com o mínimo de equipamento.',
              'Foque-se na Performance: Em vez de se focar apenas na estética, estabeleça metas de performance: aumentar a carga, fazer mais uma repetição, diminuir o tempo de descanso.',
            ]),
          ],
        ),

        _buildSubsection(
          'Plano de treino do zero (iniciante)',
          [
            _buildParagraph(
              'Este plano de 12 semanas foi desenhado para o levar do zero à performance, construindo uma base sólida de força e resistência.',
            ),

            const SizedBox(height: WinterArcTheme.spacingM),

            _buildTrainingPhase(
              'Semana 1–4: Corpo inteiro com peso corporal (Full Body)',
              'Treine 3 vezes por semana, em dias não consecutivos (ex: segunda, quarta e sexta).',
              [
                ['Agachamento', '3', '15-20', '60 sec'],
                ['Flexões (joelhos no chão se necessário)', '3', 'Até à falha', '60 sec'],
                ['Prancha', '3', '30-60 sec', '60 sec'],
                ['Lunges (Afundos)', '3', '10-12 (cada perna)', '60 sec'],
                ['Remada Invertida', '3', '10-15', '60 sec'],
                ['Elevação de Gémeos', '3', '20-25', '45 sec'],
              ],
            ),

            const SizedBox(height: WinterArcTheme.spacingL),

            // Full example workout details
            _buildParagraph(
              'Treino de exemplo completo - Semana 1-4:',
            ),
            const SizedBox(height: WinterArcTheme.spacingS),
            _buildBulletList([
              'Agachamento: De pé, com os pés à largura dos ombros. Desça como se fosse sentar-se numa cadeira, mantendo as costas direitas e o peito aberto. Desça até que as coxas fiquem paralelas ao chão e depois suba de volta à posição inicial.',
              'Push-ups: Com as mãos ligeiramente mais afastadas que a largura dos ombros, desça o corpo até que o peito quase toque no chão. Mantenha o corpo em linha reta. Empurre de volta à posição inicial. (Modificar com joelhos no chão se necessário)',
              'Prancha: Hold a push-up position with forearms on the ground, keeping your body in a straight line from head to heels. Engage your core and don\'t let your hips sag.',
              'Lunges (Afundos): Dê um passo à frente com uma perna e desça o corpo até que ambos os joelhos formem um ângulo de 90 graus. Volte à posição inicial e repita com a outra perna.',
              'Remada Invertida: Deite-se debaixo de uma mesa resistente, agarre a borda com as duas mãos e puxe o peito em direção à mesa, mantendo o corpo reto.',
            ]),

            const SizedBox(height: WinterArcTheme.spacingL),

            _buildTrainingPhase(
              'Semana 5–8: Resistência + Carga',
              'Treine 4 vezes por semana (ex: segunda, terça, quinta, sexta). Introduza carga externa (halteres, kettlebells ou mochila com peso).',
              [
                ['Supino com Halteres', '4', '8-12', '90 sec'],
                ['Remada Curvada com Halteres', '4', '8-12', '90 sec'],
                ['Agachamento com Peso (Goblet Squat)', '4', '8-12', '90 sec'],
                ['Peso Morto Romeno com Halteres', '4', '8-12', '90 sec'],
              ],
            ),

            const SizedBox(height: WinterArcTheme.spacingL),

            _buildParagraph(
              'Semana 9–12: Performance e Estética - Aumente a intensidade com progressão de carga, drop sets e superséries para maximizar os ganhos de força e a definição muscular.',
            ),
          ],
        ),

        _buildSubsection(
          'Rotina rápida para quem só tem 20 minutos por dia',
          [
            _buildParagraph(
              'Execute o seguinte circuito o máximo de vezes possível em 20 minutos, com o mínimo de descanso entre os exercícios:',
            ),
            _buildBulletList([
              'Burpees: 10 repetições',
              'Jump Agachamento: 15 repetições',
              'Push-ups: 10 repetições',
              'Alpinistas (Mountain Climbers): 30 segundos',
              'Prancha: 30 segundos',
            ]),
          ],
        ),

        _buildSubsection(
          'Versão adaptada para mulheres',
          [
            _buildParagraph(
              'A estrutura do treino é a mesma, pois os princípios da força são universais. No entanto, as mulheres podem querer dar uma ênfase ligeiramente maior aos membros inferiores e glúteos. Podem ser adicionados os seguintes exercícios ao treino de parte inferior:',
            ),
            const SizedBox(height: WinterArcTheme.spacingM),
            _buildBulletList([
              'Abdução de Anca com Banda: 3 séries de 20-25 repetições.',
              'Elevação Pélvica Unilateral: 3 séries de 12-15 repetições por perna.',
              'O mais importante é focar-se na progressão de carga e na técnica perfeita, independentemente do género.',
            ]),
            const SizedBox(height: WinterArcTheme.spacingM),
            _buildParagraph(
              'O mais importante é focar-se na progressão de carga e na técnica perfeita, independentemente do género.',
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

          // Exercício table
          if (!isMobile)
            _buildExercícioTable(exercises)
          else
            _buildExercícioCards(exercises),
        ],
      ),
    );
  }

  Widget _buildExercícioTable(List<List<String>> exercises) {
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
          children: ['Exercício', 'Séries', 'Repetições', 'Descanso'].map((header) {
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

  Widget _buildExercícioCards(List<List<String>> exercises) {
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
                'Descanso: ${exercise[3]}',
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
      title: 'CAPÍTULO 3 — NUTRIÇÃO E ESTRATÉGIA',
      backgroundColor: WinterArcTheme.charcoal,
      children: [
        _buildImagePlaceholder('Alimentação saudável / Preparação de refeições'),

        _buildSubsection(
          'Por que você ganha gordura no inverno (e como reverter isso)',
          [
            _buildParagraph(
              'O inverno é uma estação desafiadora para a manutenção do peso corporal. The body\'s natural tendency is to accumulate fat reserves to protect itself from the cold and to compensate for the historically lower availability of food. Furthermore, decreased sun exposure affects vitamin D production, which is linked to metabolism and mood, and reduced physical activity, combined with increased intake of calorie-rich comfort foods, creates the perfect scenario for fat gain.',
            ),
            _buildParagraph(
              'Para reverter isso, é crucial uma abordagem consciente e estratégica. It\'s not about deprivation, but about smart choices and optimizing metabolism.',
            ),
          ],
        ),

        const SizedBox(height: WinterArcTheme.spacingXL),

        // Macro Calculator
        const MacroCalculator(),

        const SizedBox(height: WinterArcTheme.spacingXL),

        _buildSubsection(
          'Estratégia simples de alimentação limpa e prática',
          [
            _buildParagraph(
              'Clean eating doesn\'t have to be complicated. O foco deve ser em alimentos integrais, minimamente processados:',
            ),
            _buildBulletList([
              'Fontes de Proteína: Peito de frango, peru, peixe (salmão, bacalhau), ovos, carne vermelha magra, leguminosas (lentilhas, grão de bico), tofu.',
              'Fontes de Carboidratos Complexos: Batata doce, arroz integral, aveia, quinoa, pão integral, vegetais (brócolos, espinafres, couve-flor).',
              'Fontes de Gorduras Saudáveis: Abacate, azeite extra virgem, frutos secos (amêndoas, walfrutos secos), sementes (chia, linhaça).',
              'Hidratação: Beba bastante água ao longo do dia. Chás sem açúcar também são uma excelente opção no inverno.',
            ]),
            const SizedBox(height: WinterArcTheme.spacingM),
            _buildPullQuote(
              'Prepare as suas refeições com antecedência. Cozinhe grandes quantidades de proteína e carboidratos no fim de semana para ter refeições prontas durante a semana.',
            ),
          ],
        ),

        _buildSubsection(
          'Tabela de trocas alimentares',
          [
            _buildParagraph(
              'Para facilitar a adesão a uma alimentação limpa, aqui está uma tabela de trocas inteligentes:',
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
              'Breakfast: 3 scrambled ovos with espinafres + 1 slice whole-wheat toast + black coffee',
              'Mid-Morning Snack: Greek yogurt (200g) with berries',
              'Lunch: Grilled chicken breast (150g) + large salad with olive oil dressing + sweet potato (150g)',
              'Pre-Workout Snack: Apple + handful of amêndoas',
              'Post-Workout Dinner: Baked salmão (150g) + steamed brócolos + quinoa (100g cooked)',
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
              'Breakfast: 4 whole ovos + oatmeal (80g dry) with banana and honey',
              'Mid-Morning Snack: Protein shake with milk + peanut butter',
              'Lunch: Lean beef (180g) + arroz integral (150g cooked) + mixed vegetais',
              'Pre-Workout Snack: Rice cakes with almond butter + banana',
              'Post-Workout: Protein shake + white rice (100g cooked)',
              'Dinner: Chicken thighs (200g) + sweet potato (200g) + green beans',
              'Evening Snack: Cottage cheese (200g) + walfrutos secos',
            ]),
          ],
        ),

        _buildSubsection(
          'Protocols for focus and energy',
          [
            _buildBulletList([
              'Protein-Rich Breakfast: Start your day with ovos, Greek yogurt, or a protein shake. This stabilizes blood sugar levels and provides sustained energy.',
              'Smart Snacks: Avoid sugar spikes. Opt for snacks that combine protein and healthy fat (e.g., a handful of amêndoas, cottage cheese).',
              'Strategic Caffeine: Use coffee or green tea for an energy boost, but avoid excessive consumption, especially in the afternoon, to avoid disrupting sleep.',
              'Constant Hidratação: Mild dehydration can cause fatigue and lack of concentration. Keep a water bottle nearby.',
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
      title: 'CAPÍTULO 4 — A MENTE DO GUERREIRO SILENCIOSO',
      backgroundColor: WinterArcTheme.black,
      children: [
        _buildImagePlaceholder('Meditação / Contemplação'),

        _buildSubsection(
          'O silêncio como treino mental',
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
              'Hidratação: Drink a large glass of water with lemon. This rehydrates the body after sleep and stimulates metabolism.',
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
      title: 'CAPÍTULO 5 — O CÓDIGO WINTER ARC',
      backgroundColor: WinterArcTheme.charcoal,
      children: [
        _buildImagePlaceholder('Código guerreiro / Princípios antigos'),

        _buildSubsection(
          'Os 7 princípios do Winter Arc',
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
      title: 'A PRIMAVERA SÓ PERTENCE A QUEM LUTOU NO INVERNO',
      backgroundColor: WinterArcTheme.black,
      children: [
        _buildImagePlaceholder('Transformação / Primavera emergindo'),

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
          'Como manter a mentalidade do inverno durante o resto do ano',
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
                duration: const Duration(millisegundos: 1000),
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
