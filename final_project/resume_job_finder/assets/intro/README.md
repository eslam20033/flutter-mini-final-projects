# Intro artwork provenance

Original vectors were downloaded from the supplied Figma file through its design-context asset URLs. Files are bundled locally and render through `flutter_svg`; runtime does not contact Figma.

Source: [design](https://www.figma.com/design/RuoomB3smpG0FQS5cHnKer/Untitled).

| File | Canvas | Source frame |
| --- | --- | --- |
| splash_circle_large.svg | 300 × 300 | English light Splash, 1:2183 |
| splash_circle_small.svg | 244 × 244 | English light Splash, 1:2183 |
| spark_blue.svg | 47 × 47 | English light Splash, 1:2183 |
| illustration_circle.svg | 260 × 260 | English light AI Analysis, 1:2222 |
| analysis_ring.svg | 170 × 170 | English light AI Analysis, 1:2222 |
| analysis_core.svg | 106 × 106 | English light AI Analysis, 1:2222 |
| spark_white.svg | 47 × 47 | English light AI Analysis, 1:2222 |
| indicator_inactive.svg | 8 × 8 | English light AI Analysis, 1:2222 |
| indicator_active.svg | 8 × 8 | English light AI Analysis, 1:2222 |
| arrow_forward.svg | 20 × 20 | English light AI Analysis, 1:2222 |

SVG files retain their exported geometry. Widgets tint selected decorative fills for the existing dark palette and mirror the navigation arrow in RTL.

The original segmented match-ring export was replaced by a native continuous circular indicator at the user's request. Cards, localized labels, resume lines, and badges are real Flutter widgets. The resume person icon uses the Material outline icon because its original export was unavailable. The opportunity uses a neutral briefcase icon instead of the source's illustrative company initial.

See [ONBOARDING.md](../../ONBOARDING.md) for source coverage, deliberate content changes, and remaining reference gaps.
