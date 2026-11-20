import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../app/theme/app_colors.dart';
import '../app/theme/app_theme.dart';
import '../models/trait_score_model.dart';
import '../utils/constants.dart';
import 'motion/reveal.dart';

/// Half-ring gauge with the score in the middle, e.g. "62 out of 100".
///
/// The ring fills and the number counts up together, starting after
/// [delay]. Pass [countTo] (the real score) to count up; otherwise
/// [valueText] is shown as it is.
class ScoreGauge extends StatelessWidget {
  const ScoreGauge({
    super.key,
    required this.fraction,
    required this.valueText,
    required this.caption,
    this.countTo,
    this.size = 190,
    this.delay = Duration.zero,
    this.onComplete,
    this.assemble = false,
  });

  /// 0.0 to 1.0
  final double fraction;
  final String valueText;
  final String caption;
  final double? countTo;
  final double size;
  final Duration delay;

  /// Cinematic intro: a swarm of light particles swirls in during [delay]
  /// and settles exactly where the ring then fills.
  final bool assemble;

  /// Called once the count-up has finished.
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    final double target = fraction.clamp(0.0, 1.0);

    return Semantics(
      label: '$valueText $caption',
      excludeSemantics: true,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          _gauge(context, target),
          if (assemble)
            Positioned.fill(
              child: GaugeAssembly(fraction: target, arriveAfter: delay),
            ),
        ],
      ),
    );
  }

  Widget _gauge(BuildContext context, double target) {
    return DelayedProgress(
      delay: delay,
      duration: const Duration(milliseconds: 1400),
      onComplete: onComplete,
      builder: (BuildContext context, double progress) {
        final double? count = countTo;
        final String shown = count == null || progress >= 1
            ? valueText
            : (count * progress).round().toString();
        return SizedBox(
          width: size,
          height: size * 0.78,
          child: CustomPaint(
            painter: _GaugePainter(
              fraction: target * progress,
              track: context.colors.primary.withValues(alpha: 0.14),
            ),
            child: Padding(
              padding: EdgeInsets.only(top: size * 0.22),
              child: Column(
                children: <Widget>[
                  Text(
                    shown,
                    style: context.textStyles.displayMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1,
                      fontFeatures: const <FontFeature>[
                        FontFeature.tabularFigures(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(caption, style: context.textStyles.labelSmall),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A swarm of light particles that spirals in from around the card and
/// lands on the gauge ring at the moment it starts to fill ([arriveAfter]),
/// then melts into it.
class GaugeAssembly extends StatefulWidget {
  const GaugeAssembly({
    super.key,
    required this.fraction,
    required this.arriveAfter,
    this.count = 70,
  });

  final double fraction;
  final Duration arriveAfter;
  final int count;

  @override
  State<GaugeAssembly> createState() => _GaugeAssemblyState();
}

class _GaugeAssemblyState extends State<GaugeAssembly>
    with SingleTickerProviderStateMixin {
  static const Duration _melt = Duration(milliseconds: 450);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.arriveAfter + _melt,
  );
  final List<_Mote> _motes = <_Mote>[];
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (reduceMotionOf(context) || widget.arriveAfter == Duration.zero) return;
    final math.Random random = math.Random(11);
    for (int i = 0; i < widget.count; i++) {
      _motes.add(_Mote(
        startAngle: random.nextDouble() * math.pi * 2,
        startRadius: 1.0 + random.nextDouble() * 0.9,
        slot: random.nextDouble(),
        swirl: random.nextBool() ? 1 : -1,
        delay: random.nextDouble() * 0.25,
        size: 1.6 + random.nextDouble() * 2.4,
        colour: <Color>[
          Colors.white,
          AppColors.secondary,
          AppColors.primary,
          const Color(0xFFF6C4F3),
        ][i % 4],
      ));
    }
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_motes.isEmpty) return const SizedBox.shrink();
    final double arrive = widget.arriveAfter.inMilliseconds /
        (widget.arriveAfter + _melt).inMilliseconds;
    return IgnorePointer(
      child: CustomPaint(
        painter: _AssemblyPainter(
          animation: _controller,
          motes: _motes,
          fraction: widget.fraction,
          arrive: arrive,
        ),
      ),
    );
  }
}

class _Mote {
  const _Mote({
    required this.startAngle,
    required this.startRadius,
    required this.slot,
    required this.swirl,
    required this.delay,
    required this.size,
    required this.colour,
  });

  final double startAngle;

  /// Start distance, as a multiple of the gauge width.
  final double startRadius;

  /// Where on the filled part of the ring it lands (0 = start, 1 = end).
  final double slot;
  final int swirl;
  final double delay;
  final double size;
  final Color colour;
}

class _AssemblyPainter extends CustomPainter {
  _AssemblyPainter({
    required this.animation,
    required this.motes,
    required this.fraction,
    required this.arrive,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final List<_Mote> motes;
  final double fraction;

  /// Point in the animation (0–1) at which the motes reach the ring.
  final double arrive;

  @override
  void paint(Canvas canvas, Size size) {
    final double v = animation.value;
    if (v >= 1) return;
    final double w = size.width;
    final Offset centre = Offset(w / 2, w / 2);
    final double ring = w / 2 - w * 0.075;
    // Land on the part of the ring that will light up (at least a sliver).
    final double sweep = _GaugePainter._sweep * math.max(fraction, 0.08);

    for (final _Mote m in motes) {
      final double local =
          ((v / arrive - m.delay) / (1 - m.delay)).clamp(0.0, 1.0);
      final double e = Curves.easeInOutCubic.transform(local);
      final double targetAngle = _GaugePainter._start + sweep * m.slot;
      // Spiral in: the angle winds round once while the radius shrinks.
      final double angle = m.startAngle +
          (targetAngle - m.startAngle + m.swirl * math.pi * 2) * e;
      final double radius = m.startRadius * w * (1 - e) + ring * e;
      final Offset p = centre + Offset(math.cos(angle), math.sin(angle)) * radius;

      final double appear = (local * 4).clamp(0.0, 1.0);
      final double melt = v > arrive ? 1 - (v - arrive) / (1 - arrive) : 1;
      final double alpha = (appear * melt).clamp(0.0, 1.0);
      if (alpha <= 0) continue;

      canvas.drawCircle(
        p,
        m.size * 2.2,
        Paint()
          ..color = m.colour.withValues(alpha: 0.35 * alpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawCircle(
        p,
        m.size * (0.6 + 0.4 * (1 - e)),
        Paint()..color = m.colour.withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(_AssemblyPainter old) => old.fraction != fraction;
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({required this.fraction, required this.track});

  final double fraction;
  final Color track;

  // The arc covers 240 degrees, open at the bottom.
  static const double _start = math.pi * 5 / 6;
  static const double _sweep = math.pi * 4 / 3;

  @override
  void paint(Canvas canvas, Size size) {
    final double stroke = size.width * 0.075;
    final Rect rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.width / 2),
      radius: size.width / 2 - stroke,
    );

    canvas.drawArc(
      rect,
      _start,
      _sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = track,
    );

    if (fraction <= 0) return;
    canvas.drawArc(
      rect,
      _start,
      _sweep * fraction,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = const SweepGradient(
          startAngle: _start,
          endAngle: _start + _sweep,
          colors: <Color>[AppColors.secondary, AppColors.primary],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) =>
      oldDelegate.fraction != fraction || oldDelegate.track != track;
}

/// Two-ended spectrum with a marker, e.g. Introvert ◄──●──► Extrovert.
class SpectrumBar extends StatelessWidget {
  const SpectrumBar({
    super.key,
    required this.fraction,
    required this.leftLabel,
    required this.rightLabel,
  });

  final double fraction;
  final String leftLabel;
  final String rightLabel;

  @override
  Widget build(BuildContext context) {
    final double clamped = fraction.clamp(0.0, 1.0);

    return Semantics(
      label: '${(clamped * 100).round()} percent towards $rightLabel',
      excludeSemantics: true,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 34,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.5, end: clamped),
                  duration: const Duration(milliseconds: 1100),
                  curve: Curves.easeOutCubic,
                  builder: (BuildContext context, double value, _) {
                    const double marker = 30;
                    final double left =
                        value * (constraints.maxWidth - marker);
                    return Stack(
                      alignment: Alignment.centerLeft,
                      children: <Widget>[
                        Container(
                          height: 12,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(AppRadius.pill),
                            gradient: const LinearGradient(
                              colors: <Color>[
                                Color(0xFFA5B8FA),
                                AppColors.secondary,
                                AppColors.primary,
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: left,
                          child: Container(
                            width: marker,
                            height: marker,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color: AppColors.primary,
                                width: 4,
                              ),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: <Widget>[
              Text(leftLabel, style: context.textStyles.labelMedium),
              const Spacer(),
              Text(rightLabel, style: context.textStyles.labelMedium),
            ],
          ),
        ],
      ),
    );
  }
}

/// One horizontal bar for a trait: name, level and score.
///
/// The bar fills and its number counts up after [delay], so a list of bars
/// with growing delays fills one by one.
class TraitBar extends StatelessWidget {
  const TraitBar({
    super.key,
    required this.name,
    required this.percent,
    required this.levelLabel,
    this.delay = Duration.zero,
  });

  final String name;

  /// 0–100
  final double percent;
  final String levelLabel;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final double fraction = (percent / 100).clamp(0.0, 1.0);

    return Semantics(
      label: '$name: $levelLabel, ${percent.round()} out of 100',
      excludeSemantics: true,
      child: DelayedProgress(
        delay: delay,
        duration: const Duration(milliseconds: 900),
        builder: (BuildContext context, double progress) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(name, style: context.textStyles.titleSmall),
                ),
                Text(levelLabel, style: context.textStyles.labelSmall),
                const SizedBox(width: AppSpacing.sm),
                SizedBox(
                  width: 30,
                  child: Text(
                    '${(percent * progress).round()}',
                    textAlign: TextAlign.end,
                    style: context.textStyles.labelLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: fraction * progress,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      gradient: const LinearGradient(
                        colors: <Color>[
                          AppColors.secondary,
                          AppColors.primary,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Radar ("spider") chart of all trait scores, using fl_chart.
/// Needs at least 3 traits.
class TraitRadarChart extends StatelessWidget {
  const TraitRadarChart({super.key, required this.traits, this.height = 260});

  final List<TraitScore> traits;
  final double height;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;
    final Color grid = colors.onSurfaceVariant.withValues(alpha: 0.25);
    final int count = traits.length;

    // Two invisible data sets fix the scale to 0–100, so the shape does not
    // stretch to fill the chart when all scores are low or high.
    RadarDataSet anchor(double value) => RadarDataSet(
          dataEntries: List<RadarEntry>.generate(
            count,
            (_) => RadarEntry(value: value),
          ),
          fillColor: Colors.transparent,
          borderColor: Colors.transparent,
          borderWidth: 0,
          entryRadius: 0,
        );

    return Semantics(
      label: 'Radar chart of ${traits.map((TraitScore t) => '${t.name} '
          '${t.percent.round()}').join(', ')}',
      excludeSemantics: true,
      child: SizedBox(
        height: height,
        child: RadarChart(
          RadarChartData(
            radarShape: RadarShape.polygon,
            dataSets: <RadarDataSet>[
              anchor(0),
              anchor(100),
              RadarDataSet(
                dataEntries: <RadarEntry>[
                  for (final TraitScore trait in traits)
                    RadarEntry(value: trait.percent),
                ],
                fillColor: colors.primary.withValues(alpha: 0.22),
                borderColor: colors.primary,
                borderWidth: 2.4,
                entryRadius: 3.5,
              ),
            ],
            radarBackgroundColor: Colors.transparent,
            borderData: FlBorderData(show: false),
            radarBorderData: BorderSide(color: grid),
            gridBorderData: BorderSide(color: grid),
            tickBorderData: BorderSide(color: grid),
            tickCount: 4,
            ticksTextStyle: const TextStyle(
              color: Colors.transparent,
              fontSize: 1,
            ),
            titlePositionPercentageOffset: 0.16,
            titleTextStyle: context.textStyles.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            getTitle: (int index, double angle) =>
                RadarChartTitle(text: _shortName(traits[index].name)),
          ),
        ),
      ),
    );
  }

  /// Keeps chart labels short so they don't overlap.
  static String _shortName(String name) {
    const Map<String, String> short = <String, String>{
      'Emotional stability': 'Stability',
      'Conscientiousness': 'Conscient.',
      'Social communication': 'Social comm.',
      'Social interaction': 'Social',
      'Sensory experiences': 'Sensory',
      'Repetitive patterns': 'Repetition',
      'Communication preferences': 'Communication',
      'Sensitivity to criticism': 'Criticism',
      'Recognition-seeking': 'Recognition',
      'Attention-seeking': 'Attention',
      'Need for admiration': 'Admiration',
      'Worry & overthinking': 'Worry',
      'Difficulty relaxing': 'Relaxing',
      'Fear & apprehension': 'Apprehension',
      'Physical tension': 'Tension',
      'Stress response': 'Stress',
    };
    return short[name] ?? name;
  }
}

/// Line chart of scores over several attempts (oldest on the left).
class TrendChart extends StatelessWidget {
  const TrendChart({
    super.key,
    required this.values,
    required this.maxY,
    this.height = 140,
  });

  final List<double> values;
  final double maxY;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (values.length < 2) return const SizedBox.shrink();
    final ColorScheme colors = context.colors;
    final Color grid = colors.onSurfaceVariant.withValues(alpha: 0.15);

    return Semantics(
      label: 'Scores over time: ${values.map((double v) => v.round()).join(', ')}',
      excludeSemantics: true,
      child: SizedBox(
        height: height,
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: (values.length - 1).toDouble(),
            minY: 0,
            maxY: maxY,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxY / 4,
              getDrawingHorizontalLine: (double value) =>
                  FlLine(color: grid, strokeWidth: 1),
            ),
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineTouchData: LineTouchData(enabled: false),
            lineBarsData: <LineChartBarData>[
              LineChartBarData(
                spots: <FlSpot>[
                  for (int i = 0; i < values.length; i++)
                    FlSpot(i.toDouble(), values[i]),
                ],
                isCurved: true,
                curveSmoothness: 0.3,
                color: colors.primary,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: colors.primary.withValues(alpha: 0.12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
