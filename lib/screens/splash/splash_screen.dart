import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';
import '../../providers/storage_provider.dart';
import '../../utils/app_strings.dart';
import '../../utils/constants.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/mind_background.dart';
import '../../widgets/motion/reveal.dart';

/// The launch intro. In about 3.6 seconds:
///
///  1. a ring of lavender light draws itself in a smooth circle
///  2. inside it the MC mark opens up like an iris, coming into focus
///  3. the mark "ignites" with a soft bloom and ripple rings, and a gentle
///     vibration, while the ring folds into it
///  4. the mark glides into place on the left while the "mindcurio" name
///     sweeps in beside it, coming into focus
///  5. a glossy highlight glides across the logo, and the tagline settles in
///
/// Then it opens onboarding (first launch) or Home. With reduce motion on it
/// simply shows the logo and moves on.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const Duration _total = Duration(milliseconds: 3600);

  late final AnimationController _controller =
      AnimationController(vsync: this, duration: _total);

  _SplashArt? _art;
  bool _failed = false;
  bool _started = false;
  bool _left = false;
  bool _buzzed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (reduceMotionOf(context)) {
      // Calm version: static logo, then move on.
      Timer(const Duration(milliseconds: 1400), _goNext);
      return;
    }
    _controller.addListener(_onTick);
    _controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) _goNext();
    });
    unawaited(_loadArt());
  }

  Future<void> _loadArt() async {
    try {
      final _SplashArt art = await _SplashArt.load();
      if (!mounted) return;
      setState(() => _art = art);
      _controller.forward();
    } catch (_) {
      // If the pictures cannot be decoded, fall back to the plain logo.
      if (!mounted) return;
      setState(() => _failed = true);
      Timer(const Duration(milliseconds: 1400), _goNext);
    }
  }

  void _onTick() {
    // A soft "thump" as the mark ignites.
    if (!_buzzed && _controller.value * _total.inMilliseconds >= 1450) {
      _buzzed = true;
      HapticFeedback.lightImpact();
    }
  }

  void _goNext() {
    if (!mounted || _left) return;
    _left = true;
    final bool onboarded =
        ref.read(storageServiceProvider).isOnboardingComplete;
    context.go(onboarded ? AppRoutes.home : AppRoutes.onboarding);
  }

  @override
  void dispose() {
    _controller.dispose();
    _art?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _SplashArt? art = _art;
    final bool calm = reduceMotionOf(context);

    return Scaffold(
      body: MindBackground(
        child: Semantics(
          label: AppStrings.appName,
          child: calm || _failed
              ? const _StaticLogo()
              : art == null
                  ? const SizedBox.expand()
                  : LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints box) {
                        return Stack(
                          children: <Widget>[
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _IntroPainter(
                                  animation: _controller,
                                  art: art,
                                  total: _total,
                                  dark: context.isDarkMode,
                                ),
                              ),
                            ),
                            _Tagline(
                              animation: _controller,
                              total: _total,
                              top: _Layout.of(box.biggest).centre.dy +
                                  _Layout.of(box.biggest).finalHeight / 2 +
                                  AppSpacing.xl,
                            ),
                          ],
                        );
                      },
                    ),
        ),
      ),
    );
  }
}

/// Plain logo for reduce motion (and as a fallback).
class _StaticLogo extends StatelessWidget {
  const _StaticLogo();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const BrandLogo(width: 280),
          const SizedBox(height: AppSpacing.xl),
          Text(
            AppStrings.tagline,
            textAlign: TextAlign.center,
            style: context.textStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}

/// The tagline: fades in while its letters draw closer together.
class _Tagline extends StatelessWidget {
  const _Tagline({
    required this.animation,
    required this.total,
    required this.top,
  });

  final Animation<double> animation;
  final Duration total;
  final double top;

  @override
  Widget build(BuildContext context) {
    final TextStyle? base = context.textStyles.bodyMedium;
    return Positioned(
      left: AppSpacing.screen,
      right: AppSpacing.screen,
      top: top,
      child: AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, _) {
          final double ms = animation.value * total.inMilliseconds;
          final double p =
              Curves.easeOutCubic.transform(_phase(ms, 2550, 3250));
          return Opacity(
            opacity: p,
            child: Transform.translate(
              offset: Offset(0, 10 * (1 - p)),
              child: Text(
                AppStrings.tagline,
                textAlign: TextAlign.center,
                style: base?.copyWith(letterSpacing: 0.2 + 5 * (1 - p)),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 0 before [from] ms, 1 after [to] ms, and a straight line in between.
double _phase(double ms, double from, double to) =>
    ((ms - from) / (to - from)).clamp(0.0, 1.0);

/// Where everything sits on screen.
class _Layout {
  _Layout._(this.size);

  factory _Layout.of(Size size) => _Layout._(size);

  final Size size;

  // Proportions of the logo files (see docs/brand).
  static const double _logoAspect = 1843 / 399;
  static const double _markAspect = 1083 / 998;
  static const double _wordAspect = 1307 / 216;
  static const double _wordToMark = 216 / 399; // name height / mark height
  static const double _gap = 0.26; // gap, as a share of the mark height

  Offset get centre => Offset(size.width / 2, size.height / 2 - 20);

  double get finalWidth => math.min(size.width * 0.8, 340);
  double get finalHeight => finalWidth / _logoAspect;

  /// The big mark at the start, centred on screen.
  Rect get bigMark {
    final double h = math.min(size.width * 0.42, 170);
    return Rect.fromCenter(center: centre, width: h * _markAspect, height: h);
  }

  /// The mark in its final place, left of the name.
  Rect get finalMark {
    final double h = finalHeight;
    return Rect.fromLTWH(
      centre.dx - finalWidth / 2,
      centre.dy - h / 2,
      h * _markAspect,
      h,
    );
  }

  Rect get word {
    final double h = finalHeight * _wordToMark;
    final Rect m = finalMark;
    return Rect.fromLTWH(
      m.right + finalHeight * _gap,
      centre.dy - h / 2,
      h * _wordAspect,
      h,
    );
  }
}

/// The decoded logo pictures.
class _SplashArt {
  _SplashArt._(this.mark, this.word);

  final ui.Image mark;
  final ui.Image word;

  static Future<ui.Image> _decode(String path) async {
    final ByteData data = await rootBundle.load(path);
    final ui.Codec codec =
        await ui.instantiateImageCodec(data.buffer.asUint8List());
    final ui.FrameInfo frame = await codec.getNextFrame();
    codec.dispose();
    return frame.image;
  }

  static Future<_SplashArt> load() async {
    final ui.Image mark = await _decode('assets/images/3.0x/logo_mark.png');
    final ui.Image word = await _decode('assets/images/3.0x/wordmark.png');

    return _SplashArt._(mark, word);
  }

  void dispose() {
    mark.dispose();
    word.dispose();
  }
}

class _IntroPainter extends CustomPainter {
  _IntroPainter({
    required this.animation,
    required this.art,
    required this.total,
    required this.dark,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final _SplashArt art;
  final Duration total;
  final bool dark;

  Paint _imagePaint({double opacity = 1, Color? tint, double blur = 0}) {
    final Paint paint = Paint()..filterQuality = FilterQuality.high;
    final Color? colour = tint ?? (dark ? const Color(0xFFC9C2FF) : null);
    if (colour == null) {
      paint.color = Colors.white.withValues(alpha: opacity.clamp(0.0, 1.0));
    } else {
      paint.colorFilter = ColorFilter.mode(
        colour.withValues(alpha: opacity.clamp(0.0, 1.0)),
        BlendMode.srcIn,
      );
    }
    if (blur > 0.1) {
      paint.imageFilter = ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur);
    }
    return paint;
  }

  void _drawImage(Canvas canvas, ui.Image image, Rect dst, Paint paint) {
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      dst,
      paint,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double ms = animation.value * total.inMilliseconds;
    final _Layout layout = _Layout.of(size);
    final Offset c = layout.centre;

    // Where the mark is now: big and centred, then settling into the logo.
    final double settle =
        Curves.easeInOutCubic.transform(_phase(ms, 1800, 2550));
    final Rect mark = Rect.lerp(layout.bigMark, layout.finalMark, settle)!;
    // Gentle exit zoom at the very end.
    final double exit = Curves.easeIn.transform(_phase(ms, 3300, 3600));
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.scale(1 + 0.05 * exit);
    canvas.translate(-c.dx, -c.dy);

    _drawRing(canvas, ms, layout);
    _drawMark(canvas, ms, mark);
    _drawShockwave(canvas, ms, layout);
    _drawWord(canvas, ms, layout);
    _drawShimmer(canvas, ms, mark, layout);

    canvas.restore();
  }

  /// A ring of lavender light draws itself around the centre, turning
  /// slowly, then folds into the mark as it ignites.
  void _drawRing(Canvas canvas, double ms, _Layout layout) {
    final double draw = Curves.easeInOutCubic.transform(_phase(ms, 100, 1150));
    final double fold = Curves.easeInCubic.transform(_phase(ms, 1350, 1850));
    if (draw <= 0 || fold >= 1) return;
    final Rect big = layout.bigMark;
    final double radius = big.height * (0.78 - 0.2 * fold);
    final Rect circle = Rect.fromCircle(center: big.center, radius: radius);
    final double turn = ms / 1000 * 1.4; // slow rotation, in radians
    final double alpha = 1 - fold;

    final Paint stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: <Color>[
          AppColors.secondary.withValues(alpha: 0),
          AppColors.secondary.withValues(alpha: alpha),
          AppColors.primary.withValues(alpha: alpha),
          const Color(0xFFE9A6D8).withValues(alpha: alpha),
          AppColors.secondary.withValues(alpha: alpha),
        ],
        stops: const <double>[0, 0.08, 0.45, 0.8, 1],
        transform: GradientRotation(turn - math.pi / 2),
      ).createShader(circle);

    // Soft glow under the line, then the crisp line.
    canvas.drawArc(
      circle,
      turn - math.pi / 2,
      math.pi * 2 * draw,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = big.height * 0.06
        ..color = AppColors.secondary.withValues(alpha: 0.18 * alpha)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, big.height * 0.05),
    );
    canvas.drawArc(
      circle,
      turn - math.pi / 2,
      math.pi * 2 * draw,
      false,
      stroke..strokeWidth = big.height * 0.022,
    );
  }

  /// The mark opens up like an iris from the centre, coming into focus,
  /// then flares with a soft bloom as it ignites.
  void _drawMark(Canvas canvas, double ms, Rect mark) {
    final double open = Curves.easeOutCubic.transform(_phase(ms, 550, 1500));
    if (open <= 0) return;

    // Bloom: a blurred, glowing copy that flares up and fades.
    final double bloom = math.sin(_phase(ms, 1350, 2150) * math.pi);
    if (bloom > 0.01) {
      _drawImage(
        canvas,
        art.mark,
        mark.inflate(mark.height * 0.06),
        _imagePaint(
          opacity: 0.85 * bloom,
          tint: const Color(0xFFE6DFFF),
          blur: mark.height * 0.12,
        ),
      );
    }

    final double grow = 0.86 + 0.14 * open;
    final Rect r = Rect.fromCenter(
      center: mark.center,
      width: mark.width * grow,
      height: mark.height * grow,
    );
    if (open >= 1) {
      _drawImage(canvas, art.mark, r, _imagePaint());
      return;
    }
    // Iris: a soft-edged circle that widens from the centre.
    final Rect area = r.inflate(r.height * 0.2);
    canvas.saveLayer(area, Paint());
    _drawImage(canvas, art.mark, r, _imagePaint(blur: 9 * (1 - open)));
    final double reach = r.longestSide * 0.85 * open;
    canvas.drawRect(
      area,
      Paint()
        ..blendMode = BlendMode.dstIn
        ..shader = ui.Gradient.radial(
          r.center,
          math.max(reach, 0.01),
          <Color>[
            Colors.white,
            Colors.white,
            Colors.white.withValues(alpha: 0),
          ],
          <double>[0, 0.7, 1],
        ),
    );
    canvas.restore();
  }

  /// Two rings of light rush outwards when the mark ignites.
  void _drawShockwave(Canvas canvas, double ms, _Layout layout) {
    final Rect big = layout.bigMark;
    for (final (double start, double strength) in <(double, double)>[
      (1450, 1.0),
      (1600, 0.55),
    ]) {
      final double p = _phase(ms, start, start + 700);
      if (p <= 0 || p >= 1) continue;
      final double e = Curves.easeOutCubic.transform(p);
      canvas.drawCircle(
        big.center,
        big.height * (0.55 + 1.9 * e),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = big.height * 0.03 * (1 - p)
          ..color = (dark ? AppColors.secondary : AppColors.primary)
              .withValues(alpha: 0.55 * strength * (1 - p))
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2 + 6 * e),
      );
    }
  }

  /// The name sweeps in from the left edge, coming into focus.
  void _drawWord(Canvas canvas, double ms, _Layout layout) {
    final double p = Curves.easeOutCubic.transform(_phase(ms, 2000, 2750));
    if (p <= 0) return;
    final Rect word = layout.word.shift(Offset(-14 * (1 - p), 0));
    final Rect area = word.inflate(word.height);
    canvas.saveLayer(area, Paint());
    _drawImage(canvas, art.word, word, _imagePaint(blur: 7 * (1 - p)));
    // Soft-edged reveal from left to right.
    final double edge = word.left - word.height + (word.width + word.height * 2) * p;
    canvas.drawRect(
      area,
      Paint()
        ..blendMode = BlendMode.dstIn
        ..shader = ui.Gradient.linear(
          Offset(edge - word.height * 1.2, 0),
          Offset(edge, 0),
          <Color>[Colors.white, Colors.white.withValues(alpha: 0)],
        ),
    );
    canvas.restore();
  }

  /// A glossy diagonal highlight glides across the finished logo.
  void _drawShimmer(Canvas canvas, double ms, Rect mark, _Layout layout) {
    final double p = Curves.easeInOutSine.transform(_phase(ms, 2650, 3300));
    if (p <= 0 || p >= 1) return;
    final Rect all = mark.expandToInclude(layout.word).inflate(4);
    canvas.saveLayer(all, Paint());
    final Paint white = _imagePaint(tint: Colors.white);
    _drawImage(canvas, art.mark, mark, white);
    _drawImage(canvas, art.word, layout.word, white);
    final double x = all.left - all.width * 0.4 + all.width * 1.8 * p;
    canvas.drawRect(
      all,
      Paint()
        ..blendMode = BlendMode.dstIn
        ..shader = ui.Gradient.linear(
          Offset(x - all.height, all.top),
          Offset(x + all.height, all.bottom),
          <Color>[
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: 0.75),
            Colors.white.withValues(alpha: 0),
          ],
          <double>[0.3, 0.5, 0.7],
        ),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_IntroPainter old) =>
      old.art != art || old.dark != dark;
}
