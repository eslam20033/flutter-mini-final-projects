import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../widgets/splash_background.dart';
import '../widgets/splash_branding.dart';

/// Introduces the app while the router restores the provider session.
class SplashPage extends StatefulWidget {
  const SplashPage({
    required this.onFinished,
    this.isRestoring = false,
    this.errorMessage,
    this.onRetry,
    super.key,
  });

  final VoidCallback onFinished;
  final bool isRestoring;
  final String? errorMessage;
  final VoidCallback? onRetry;
  static const introDuration = Duration(milliseconds: 1200);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  bool _started = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: SplashPage.introDuration)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) _finish();
          });
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.45, curve: Curves.easeOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (reduceMotion) {
        _finish();
      } else {
        _controller.forward();
      }
    });
  }

  void _finish() {
    if (!mounted || _finished) return;
    _finished = true;
    widget.onFinished();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.errorMessage != null) {
      return Scaffold(
        body: SafeArea(
          child: AppErrorState(
            message: widget.errorMessage,
            onRetry: widget.onRetry,
          ),
        ),
      );
    }
    final size = MediaQuery.sizeOf(context);
    final insets = MediaQuery.viewPaddingOf(context);
    final largeText = MediaQuery.textScalerOf(context).scale(14) > 19;
    final top = size.height >= 700 && !largeText
        ? math.max(24.0, math.min(214.0, size.height * 214 / 844) - insets.top)
        : 24.0;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            const ExcludeSemantics(child: SplashBackground()),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                            26,
                            top,
                            26,
                            24,
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 390),
                              child: FadeTransition(
                                opacity: _fade,
                                child: const SplashBranding(),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                            25,
                            0,
                            25,
                            math.max(24, 48 - insets.bottom),
                          ),
                          child: Column(
                            children: [
                              Semantics(
                                label: context.l10n.splashProgressLabel,
                                child: ExcludeSemantics(
                                  child: SizedBox(
                                    width: 74,
                                    height: 6,
                                    child: AnimatedBuilder(
                                      animation: _controller,
                                      builder: (context, child) =>
                                          LinearProgressIndicator(
                                            value: widget.isRestoring
                                                ? null
                                                : _controller.value,
                                            color: Colors.white,
                                            backgroundColor: const Color(
                                              0xFF94CAFF,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                              // Preserve the progress indicator's vertical position.
                              const SizedBox(height: 85),
                            ],
                          ),
                        ),
                      ],
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
