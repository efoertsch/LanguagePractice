import 'package:flutter/material.dart';
import 'package:language_practice/test_data/sample_word.dart';
import 'package:language_practice/language_classes/word.dart';


// ─── Main Screen ─────────────────────────────────────────────────────────────

class DisplayWordScreen extends StatefulWidget {
  final Word word;
  const DisplayWordScreen({super.key, required this.word});

  @override
  State<DisplayWordScreen> createState() => _DisplayWordScreenState();
}

class _DisplayWordScreenState extends State<DisplayWordScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  int _expandedTenseIndex = 0;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.word;
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(w),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    if (w.english != null) _buildEnglishSection(w.english!),
                    const SizedBox(height: 24),
                    _buildMetaRow(w),
                    const SizedBox(height: 24),
                    if (w.type != null) _buildTypeChips(w.type!),
                    const SizedBox(height: 32),
                    if (w.tenses != null && w.tenses!.isNotEmpty) _buildTensesSection(w.tenses!),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(Word w) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      //backgroundColor: const Color(0xFF0D0D1A),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            // gradient: LinearGradient(
            //   begin: Alignment.topLeft,
            //   end: Alignment.bottomRight,
            //   colors: [Color(0xFF1A1A3E), Color(0xFF0D0D1A)],
            // ),
          ),
          child: Stack(
            children: [
              // Decorative circle
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 180,
                  height: 180,
                  // decoration: BoxDecoration(
                  //   shape: BoxShape.circle,
                  //   border: Border.all(color: const Color(0xFF4A4AFF).withOpacity(0.15), width: 1),
                  // ),
                ),
              ),
              Positioned(
                top: 20,
                right: 40,
                child: Container(
                  width: 80,
                  height: 80,
                  // decoration: BoxDecoration(
                  //   shape: BoxShape.circle,
                  //   border: Border.all(color: const Color(0xFF4A4AFF).withOpacity(0.1), width: 1),
                  // ),
                ),
              ),
              // Word title
              Positioned(
                bottom: 24,
                left: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      w.word ?? '—',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -1,
                        height: 1,
                      ),
                    ),
                    if (w.gender != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: _genderColor(w.gender!).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _genderColor(w.gender!).withOpacity(0.5)),
                          ),
                          child: Text(
                            w.gender!.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _genderColor(w.gender!),
                              letterSpacing: 1.5,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        title: Text(
          w.word ?? '',
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
        collapseMode: CollapseMode.none,   // .fade
      ),
    );
  }

  Widget _buildEnglishSection(List<String> english) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: 'TRANSLATIONS'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: english.asMap().entries.map((e) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              // decoration: BoxDecoration(
              //   color: const Color(0xFF1E1E3A),
              //   borderRadius: BorderRadius.circular(8),
              //   border: Border.all(color: const Color(0xFF3A3A5C)),
              // ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${e.key + 1}.',
                    style: const TextStyle(
                      color: Color(0xFF6B6B9B),
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    e.value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMetaRow(Word w) {
    return Row(
      children: [
        if (w.plural != null)
          Expanded(
            child: _MetaCard(
              icon: Icons.copy_rounded,
              label: 'PLURAL',
              value: w.plural!,
            ),
          ),
      ],
    );
  }

  Widget _buildTypeChips(List<String> types) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: 'WORD TYPE'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: types
              .map((t) => _TypeChip(label: t))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildTensesSection(List<Tense> tenses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: 'CONJUGATION'),
        const SizedBox(height: 12),
        // Tense selector tabs
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: tenses.asMap().entries.map((e) {
              final selected = e.key == _expandedTenseIndex;
              return GestureDetector(
                onTap: () => setState(() => _expandedTenseIndex = e.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFF4A4AFF) : const Color(0xFF1E1E3A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selected ? const Color(0xFF4A4AFF) : const Color(0xFF3A3A5C),
                    ),
                  ),
                  child: Text(
                    e.value.tense ?? 'Tense ${e.key + 1}',
                    style: TextStyle(
                      color: selected ? Colors.white : const Color(0xFF9999CC),
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        _TenseTable(tense: tenses[_expandedTenseIndex]),
      ],
    );
  }

  Color _genderColor(String gender) {
    switch (gender.toLowerCase()) {
      case 'masculine':
      case 'male':
        return const Color(0xFF5B9BFF);
      case 'feminine':
      case 'female':
        return const Color(0xFFFF6B9B);
      case 'neutral':
      case 'neuter':
        return const Color(0xFF9B7BFF);
      default:
        return const Color(0xFF9999CC);
    }
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: Color(0xFF4A4AFF),
        letterSpacing: 2.5,
        fontFamily: 'monospace',
      ),
    );
  }
}

class _MetaCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _MetaCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E3A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF3A3A5C)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4A4AFF), size: 18),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF6B6B9B), letterSpacing: 1.5)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  const _TypeChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1E3A),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF5A3A7C)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Color(0xFFBB88EE), fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _TenseTable extends StatelessWidget {
  final Tense tense;
  const _TenseTable({required this.tense});

  @override
  Widget build(BuildContext context) {
    final rows = [
      if (tense.s1stPersonSingular != null) _ConjRow(person: '1st', number: 'Singular', form: tense.s1stPersonSingular!),
      if (tense.s2ndPersonSingular != null) _ConjRow(person: '2nd', number: 'Singular', form: tense.s2ndPersonSingular!),
      if (tense.s3rdPersonSingular != null) _ConjRow(person: '3rd', number: 'Singular', form: tense.s3rdPersonSingular!),
      if (tense.s1stPersonPlural != null) _ConjRow(person: '1st', number: 'Plural', form: tense.s1stPersonPlural!),
      if (tense.s2ndPersonPlural != null) _ConjRow(person: '2nd', number: 'Plural', form: tense.s2ndPersonPlural!),
      if (tense.s3rdPersonPlural != null) _ConjRow(person: '3rd', number: 'Plural', form: tense.s3rdPersonPlural!),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Conjugation table
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF3A3A5C)),
          ),
          child: Column(
            children: rows.asMap().entries.map((e) {
              final isLast = e.key == rows.length - 1;
              return _ConjugationRow(row: e.value, isLast: isLast);
            }).toList(),
          ),
        ),
        // Formal forms
        // Helper verb & past participle
        if (tense.helperVerb != null || tense.pastParticiple != null) ...[
          const SizedBox(height: 16),
          const _SectionLabel(label: 'AUXILIARY'),
          const SizedBox(height: 10),
          Row(
            children: [
              if (tense.helperVerb != null)
                Expanded(child: _AuxCard(label: 'Helper Verb', value: tense.helperVerb!)),
              if (tense.helperVerb != null && tense.pastParticiple != null)
                const SizedBox(width: 10),
              if (tense.pastParticiple != null)
                Expanded(child: _AuxCard(label: 'Past Participle', value: tense.pastParticiple!)),
            ],
          ),
        ],
      ],
    );
  }
}

class _ConjRow {
  final String person;
  final String number;
  final String form;
  const _ConjRow({required this.person, required this.number, required this.form});
}

class _ConjugationRow extends StatelessWidget {
  final _ConjRow row;
  final bool isLast;
  const _ConjugationRow({required this.row, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFF2A2A45))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              row.person,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF4A4AFF),
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            child: Text(
              row.number,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B6B9B)),
            ),
          ),
          Text(
            row.form,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _FormalCard extends StatelessWidget {
  final String label;
  final String value;
  const _FormalCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2A1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF3A5C3A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF5C9B5C), letterSpacing: 1.5)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}

class _AuxCard extends StatelessWidget {
  final String label;
  final String value;
  const _AuxCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1A2A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF5A3A7C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF9B5CBB), letterSpacing: 1.5)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}