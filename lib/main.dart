import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'data.dart';
import 'ui.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Career pathways (prototype)', debugShowCheckedModeBanner: false, theme: buildTheme(),
        builder: (c, child) => Container(color: g100, child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 480), child: ClipRect(child: child)))),
        home: const Shell(),
      );
}

class AppState extends ChangeNotifier {
  int tradeIdx = 0;
  final stageIdx = <String, int>{'Electrician': 1, 'Carpenter': 1, 'Plumber / Pipefitter': 1, 'Welder': 1};
  final have = <String, Set<String>>{
    'Electrician': {'hs', 'osha10', 'apprentice'},
    'Carpenter': {'hs', 'osha10'},
    'Plumber / Pipefitter': {'hs'},
    'Welder': {'hs'},
  };
  Trade get trade => trades[tradeIdx];
  int get stage => stageIdx[trade.name]!;
  Set<String> get mine => have[trade.name]!;
  void setTrade(int i) { tradeIdx = i; notifyListeners(); }
  void setStage(int i) { stageIdx[trade.name] = i; notifyListeners(); }
  void toggle(String k) { mine.contains(k) ? mine.remove(k) : mine.add(k); notifyListeners(); }
}

final app = AppState();
String money(int v) => '\$${(v / 1000).toStringAsFixed(v % 1000 == 0 ? 0 : 1)}k'.replaceAll('.0k', 'k');
Future<void> open(String u) => launchUrl(Uri.parse(u));

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int tab = 0;
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(child: Column(children: [demoBanner(), Expanded(child: ListenableBuilder(listenable: app, builder: (c, _) => [PathTab(), PayTab(), ResearchTab()][tab]))])),
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab, onDestinationSelected: (i) => setState(() => tab = i), backgroundColor: Colors.white, indicatorColor: Colors.transparent, height: 64,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.stairs_outlined), selectedIcon: Icon(Icons.stairs, color: orange), label: 'My path'),
            NavigationDestination(icon: Icon(Icons.payments_outlined), selectedIcon: Icon(Icons.payments, color: orange), label: 'Pay'),
            NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book, color: orange), label: 'Research'),
          ],
        ),
      );
}

class PathTab extends StatelessWidget {
  const PathTab({super.key});
  @override
  Widget build(BuildContext context) {
    final t = app.trade;
    final cur = app.stage;
    final next = cur + 1 < t.stages.length ? t.stages[cur + 1] : null;
    return ListView(padding: const EdgeInsets.only(bottom: 24), children: [
      Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 4), child: const Text('My path', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800))),
      Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 12), child: const Text('Where you are, and what the next step really takes.', style: TextStyle(color: g500, fontSize: 15))),
      SizedBox(height: 44, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 20), children: [
        for (var i = 0; i < trades.length; i++) Padding(padding: const EdgeInsets.only(right: 8), child: Pill('${trades[i].emoji}  ${trades[i].name}', on: app.tradeIdx == i, onTap: () => app.setTrade(i))),
      ])),
      Padding(padding: const EdgeInsets.fromLTRB(20, 14, 20, 0), child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFFFF4ED), borderRadius: BorderRadius.circular(12)), child: const Text('Illustrative US ladder. No state chosen, so this is not an exact licensing path. Requirements vary by state, union and employer. Check your state board.', style: TextStyle(fontSize: 12.5, height: 1.4, color: Color(0xFF475467))))),
      Padding(padding: const EdgeInsets.fromLTRB(20, 18, 20, 8), child: const Text('Where I am now', style: TextStyle(fontWeight: FontWeight.w700))),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Wrap(spacing: 8, runSpacing: 8, children: [for (var i = 0; i < t.stages.length; i++) Pill(t.stages[i].title, on: cur == i, onTap: () => app.setStage(i))])),
      if (next != null) NextCard(next) else const Padding(padding: EdgeInsets.fromLTRB(20, 20, 20, 0), child: Text('You are at the top step shown for this trade. Pay and licence rules beyond this point depend on your state.', style: TextStyle(color: g600))),
      sectionTitle('The whole path', sub: 'Tap a step to see what it takes. Tap an item you already have.'),
      for (var i = 0; i < t.stages.length; i++) StageTile(i, t.stages[i], i < cur ? 0 : (i == cur ? 1 : 2), i == t.stages.length - 1),
    ]);
  }
}

class NextCard extends StatelessWidget {
  final Stage s;
  const NextCard(this.s, {super.key});
  @override
  Widget build(BuildContext context) {
    final core = s.reqs.where((r) => !r.optional).toList();
    final missing = core.where((r) => !app.mine.contains(r.key)).toList();
    final ready = core.length - missing.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: slate, borderRadius: BorderRadius.circular(20)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('YOUR NEXT STEP', style: TextStyle(color: Color(0xFFB8C9DA), fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1)),
          const SizedBox(height: 6),
          Text(s.title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
          Text(s.time, style: const TextStyle(color: Color(0xFFD6E0EB), fontSize: 14)),
          const SizedBox(height: 12),
          if (core.isNotEmpty) ...[
            ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: ready / core.length, minHeight: 8, color: const Color(0xFF3CF5B0), backgroundColor: const Color(0x33FFFFFF))),
            const SizedBox(height: 8),
            Text(missing.isEmpty ? 'Listed items checked. This is not an eligibility check.' : '$ready of ${core.length} ready. Still needed: ${missing.map((r) => r.label).join('; ')}.', style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4)),
          ] else
            Text(s.summary, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4)),
          const SizedBox(height: 14),
          FilledButton(style: FilledButton.styleFrom(backgroundColor: orange), onPressed: () => showPlan(context, s), child: const Text('Plan this step')),
        ]),
      ),
    );
  }
}

void showPlan(BuildContext context, Stage s) => showModalBottomSheet(
      context: context, isScrollControlled: true, showDragHandle: true,
      builder: (c) => DraggableScrollableSheet(
        expand: false, initialChildSize: .8, maxChildSize: .95,
        builder: (c, sc) => ListenableBuilder(listenable: app, builder: (c, _) => ListView(controller: sc, padding: const EdgeInsets.fromLTRB(20, 0, 20, 28), children: [
          Text('Plan: ${s.title}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(s.summary, style: const TextStyle(color: g600, height: 1.4)),
          const SizedBox(height: 14),
          for (final r in s.reqs) ReqRow(r),
          if (s.reqs.isEmpty) const Text('No single credential is listed for this step in the sources used here.', style: TextStyle(color: g500)),
          const SizedBox(height: 14),
          const Text('Where to start', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 6),
          LinkRow('Find a registered apprenticeship (Apprenticeship.gov)', apprenticeshipFinder),
          LinkRow('BLS: how to become - ${app.trade.blsName}', app.trade.blsUrl),
          const SizedBox(height: 10),
          const Text('Demo: nothing is booked or enrolled from here. These open public websites.', style: TextStyle(color: g500, fontSize: 12)),
        ])),
      ),
    );

class ReqRow extends StatelessWidget {
  final Req r;
  const ReqRow(this.r, {super.key});
  @override
  Widget build(BuildContext context) {
    final on = app.mine.contains(r.key);
    return Container(
      margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: on ? green : g200), color: on ? greenBg : Colors.white),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        InkWell(onTap: () => app.toggle(r.key), child: Row(children: [
          Icon(on ? Icons.check_circle : Icons.radio_button_unchecked, color: on ? green : g500),
          const SizedBox(width: 10),
          Expanded(child: Text(r.label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
          Text(on ? 'I have it' : 'Not yet', style: TextStyle(color: on ? green : g500, fontSize: 12, fontWeight: FontWeight.w600)),
        ])),
        const SizedBox(height: 6),
        Padding(padding: const EdgeInsets.only(left: 34), child: Text(r.detail, style: const TextStyle(color: g600, fontSize: 13, height: 1.4))),
        if (r.url != null) Padding(padding: const EdgeInsets.only(left: 34, top: 4), child: LinkRow('Source / where to start', r.url!)),
      ]),
    );
  }
}

class LinkRow extends StatelessWidget {
  final String t, u;
  const LinkRow(this.t, this.u, {super.key});
  @override
  Widget build(BuildContext context) => InkWell(onTap: () => open(u), child: Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(children: [const Icon(Icons.open_in_new, size: 15, color: slate), const SizedBox(width: 6), Expanded(child: Text(t, style: const TextStyle(color: slate, fontSize: 13, decoration: TextDecoration.underline)))])));
}

class StageTile extends StatefulWidget {
  final int i, state; // 0 done 1 current 2 later
  final Stage s; final bool last;
  const StageTile(this.i, this.s, this.state, this.last, {super.key});
  @override
  State<StageTile> createState() => _StageTileState();
}

class _StageTileState extends State<StageTile> {
  bool open = false;
  @override
  Widget build(BuildContext context) {
    final st = widget.state;
    final color = st == 0 ? green : (st == 1 ? orange : g300);
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(width: 56, child: Column(children: [
          const SizedBox(height: 14),
          Container(width: 26, height: 26, decoration: BoxDecoration(shape: BoxShape.circle, color: st == 2 ? Colors.white : color, border: Border.all(color: color, width: 2)), child: st == 0 ? const Icon(Icons.check, size: 16, color: Colors.white) : (st == 1 ? const Icon(Icons.circle, size: 10, color: Colors.white) : null)),
          if (!widget.last) Expanded(child: Container(width: 2, color: st == 0 ? green : g200)),
        ])),
        Expanded(child: Padding(
          padding: const EdgeInsets.only(right: 16, bottom: 10, top: 6),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => open = !open),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: st == 1 ? orange : g200, width: st == 1 ? 1.5 : 1)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(widget.s.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
                  if (st == 1) const Tag('You are here', orange, Color(0xFFFFF1EC)),
                  Icon(open ? Icons.expand_less : Icons.expand_more, color: g500),
                ]),
                Text(widget.s.time, style: const TextStyle(color: g500, fontSize: 13)),
                if (open) ...[
                  const SizedBox(height: 8),
                  Text(widget.s.summary, style: const TextStyle(color: g600, fontSize: 14, height: 1.4)),
                  const SizedBox(height: 10),
                  for (final r in widget.s.reqs) ReqRow(r),
                ],
              ]),
            ),
          ),
        )),
      ]),
    );
  }
}

class PayTab extends StatelessWidget {
  const PayTab({super.key});
  @override
  Widget build(BuildContext context) {
    const maxV = 115000.0;
    return ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 28), children: [
      const Text('What the trade pays', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
      const SizedBox(height: 4),
      const Text('One range per trade across the whole U.S., May 2025. Not a wage for each step.', style: TextStyle(color: g500, fontSize: 15)),
      const SizedBox(height: 20),
      for (var i = 0; i < trades.length; i++) ...[
        InkWell(onTap: () => app.setTrade(i), child: Container(
          margin: const EdgeInsets.only(bottom: 14), padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: app.tradeIdx == i ? orange : g200, width: app.tradeIdx == i ? 1.5 : 1)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Expanded(child: Text('${trades[i].emoji}  ${trades[i].name}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))), Text('median ${money(trades[i].median)} a year', style: const TextStyle(fontWeight: FontWeight.w700, color: slate))]),
            const SizedBox(height: 12),
            LayoutBuilder(builder: (c, cs) {
              final w = cs.maxWidth;
              double x(int v) => v / maxV * w;
              return SizedBox(height: 26, child: Stack(children: [
                Positioned(left: 0, right: 0, top: 11, child: Container(height: 4, decoration: BoxDecoration(color: g200, borderRadius: BorderRadius.circular(2)))),
                Positioned(left: x(trades[i].p10), width: x(trades[i].p90) - x(trades[i].p10), top: 8, child: Container(height: 10, decoration: BoxDecoration(color: const Color(0xFFB8C9DA), borderRadius: BorderRadius.circular(5)))),
                Positioned(left: x(trades[i].median) - 6, top: 5, child: Container(width: 16, height: 16, decoration: BoxDecoration(color: orange, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)))),
              ]));
            }),
            const SizedBox(height: 4),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Lowest 10% earn under ${money(trades[i].p10)}', style: const TextStyle(color: g500, fontSize: 12)), Text('Top 10% earn over ${money(trades[i].p90)}', style: const TextStyle(color: g500, fontSize: 12))]),
          ]),
        )),
      ],
      const Text('Each bar is the spread of pay for the whole trade. It does not predict pay at any career stage. Source: BLS Occupational Employment and Wage Statistics, reference period May 2025 (as shown on each BLS Handbook page).', style: TextStyle(color: g500, fontSize: 12, height: 1.4)),
    ]);
  }
}

class ResearchTab extends StatelessWidget {
  const ResearchTab({super.key});
  Widget h(String t) => Padding(padding: const EdgeInsets.only(top: 14, bottom: 8), child: Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)));
  Widget b(String t) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Padding(padding: EdgeInsets.only(top: 7, right: 10), child: Icon(Icons.circle, size: 6, color: g500)), Expanded(child: Text(t, style: const TextStyle(fontSize: 14, height: 1.4)))]));
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 32), children: [
        const Text('Why this flow', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        b('A credential wallet shows what you hold. It does not show what comes next. In these trades the next step is usually a named thing: an apprenticeship, a licence, a test.'),
        b('Each trade has its own steps. They come from the U.S. Bureau of Labor Statistics "How to become" pages, the NCCER craft catalog, OSHA and AWS.'),
        b('Every requirement shows its source. Tap an item you already have and the progress bar moves.'),
        h('What is simulated or left out'),
        b('The starting point (Marcus, a fictional electrician apprentice with an OSHA 10 card) is made up. Tapping "I have it" is stored in this tab only.'),
        b('Licence rules differ by state. The app says so and sends you to the licensing board instead of guessing.'),
        b('Pay is the trade-wide national range for May 2025. There is no per-step wage.'),
        b('NCCER hours are listed for Electrical only, the one craft checked. Other crafts and many regional programs also exist.'),
        h('Not validated yet'),
        b('No worker interviews. Hypotheses to test: (1) workers will use a "next step" card more than a list of credentials; (2) seeing the real hours and requirements makes the step feel doable; (3) a progress bar toward the next step brings people back.'),
        h('Sources'),
        for (final t in trades) LinkRow('BLS Occupational Outlook Handbook - ${t.blsName}', t.blsUrl),
        const LinkRow('BLS Career Outlook - apprenticeship hours', 'https://www.bls.gov/careeroutlook/2013/summer/art01.pdf'),
        const LinkRow('Apprenticeship.gov - find an apprenticeship', apprenticeshipFinder),
        const LinkRow('NCCER - Electrical curriculum', nccerElectrical),
        const LinkRow('OSHA Outreach Training Program (10- and 30-hour cards)', osha),
        const LinkRow('AWS Certified Welder program', 'https://www.aws.org/certification-and-education/professional-certification/certified-welder-program/'),
        const LinkRow('AWS Certified Welding Inspector', 'https://www.aws.org/certification-and-education/professional-certification/certified-welding-inspector/'),
        const LinkRow('CareerOneStop - find certifications', 'https://www.careeronestop.org/Toolkit/Training/find-certifications.aspx'),
      ]);
}
