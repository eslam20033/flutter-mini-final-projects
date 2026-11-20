import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/assets/intro_assets.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../app_settings/presentation/widgets/app_settings_button.dart';
import '../models/onboarding_step.dart';
import '../widgets/onboarding_indicators.dart';
import '../widgets/onboarding_slide.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({required this.onCompleted, super.key});

  final VoidCallback onCompleted;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _currentPage = 0;
  bool _moving = false;
  bool _completed = false;

  bool get _isLast => _currentPage == OnboardingStep.values.length - 1;

  Future<void> _showPage(int index) async {
    if (_moving || _completed) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.jumpToPage(index);
      return;
    }
    setState(() => _moving = true);
    try {
      await _controller.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } finally {
      if (mounted) setState(() => _moving = false);
    }
  }

  void _complete() {
    if (_completed) return;
    _completed = true;
    widget.onCompleted();
  }

  void _next() {
    if (_isLast) {
      _complete();
    } else {
      _showPage(_currentPage + 1);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final insets = MediaQuery.viewPaddingOf(context);
    final compact = MediaQuery.sizeOf(context).height < 700;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final overlay = theme.brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;

    return PopScope(
      canPop: _currentPage == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentPage > 0) _showPage(_currentPage - 1);
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlay.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: theme.scaffoldBackgroundColor,
        ),
        child: Scaffold(
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                        AppSpacing.page,
                        compact ? 8 : math.max(8, 51 - insets.top),
                        AppSpacing.page,
                        0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: TextButton(
                              key: const ValueKey('onboarding_skip'),
                              onPressed: _complete,
                              style: TextButton.styleFrom(
                                alignment: AlignmentDirectional.centerStart,
                                minimumSize: const Size(48, 48),
                                padding: const EdgeInsetsDirectional.symmetric(
                                  horizontal: 6,
                                ),
                                textStyle: theme.textTheme.labelMedium
                                    ?.copyWith(fontSize: 13),
                              ),
                              child: Text(context.l10n.onboardingSkip),
                            ),
                          ),
                          const AppSettingsButton(),
                        ],
                      ),
                    ),
                    Expanded(
                      child: PageView.builder(
                        key: const ValueKey('onboarding_pages'),
                        controller: _controller,
                        itemCount: OnboardingStep.values.length,
                        onPageChanged: (page) =>
                            setState(() => _currentPage = page),
                        itemBuilder: (context, index) =>
                            OnboardingSlide(step: OnboardingStep.values[index]),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                        AppSpacing.page,
                        0,
                        AppSpacing.page,
                        compact ? 16 : math.max(16, 39 - insets.bottom),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          OnboardingIndicators(
                            currentPage: _currentPage,
                            pageCount: OnboardingStep.values.length,
                          ),
                          SizedBox(height: compact ? 24 : 44),
                          SizedBox(
                            width: double.infinity,
                            child: AppButton(
                              key: ValueKey(
                                _isLast
                                    ? 'onboarding_get_started'
                                    : 'onboarding_next',
                              ),
                              label: _isLast
                                  ? context.l10n.onboardingGetStarted
                                  : context.l10n.onboardingContinue,
                              onPressed: _moving ? null : _next,
                              trailing: Transform.flip(
                                flipX: rtl,
                                child: SvgPicture.asset(
                                  IntroAssets.arrowForward,
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
            ),
          ),
        ),
      ),
    );
  }
}
