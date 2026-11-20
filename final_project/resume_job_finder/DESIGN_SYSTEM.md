# Design system

The implementation builds on the existing app theme, settings Cubit, localization, and shared widgets. The design-system setup itself added no package or product screen. Screens 01/02 now reuse it; their assets, SVG dependency, and intentional departures are documented in [ONBOARDING.md](ONBOARDING.md).

## Verified references

The supplied [Arabic dark page](https://www.figma.com/design/RuoomB3smpG0FQS5cHnKer/Untitled?node-id=1-1092) contains the product references. The file also has a [Design System & Components page](https://www.figma.com/design/RuoomB3smpG0FQS5cHnKer/Untitled?node-id=1-4362).

Inspected design context and rendered references:

| Reference | Node | Applied detail |
| --- | --- | --- |
| Primary / Light | 1:4413 | 52px height, 14px corners, 20px horizontal / 10px vertical padding, 14px bold Inter |
| Secondary / Light | 1:4415 | White surface, outline, ink label, same button geometry |
| Primary / Dark | 1:4417 | Dark primary and gradient end tone; same geometry |
| Input / Default / Light | 1:4423 | 54px height, 13px corners, 18px horizontal inset, 13px text |
| Typography note | 1:4428 | Inter for English; Noto Sans Arabic or Cairo for Arabic |
| Arabic dark login | 1:1184 | Noto Sans Arabic, persistent field labels, dark ink/muted/outline colors |
| Dark card reference | 1:1165 | 18px corners, surface fill, 1px outline |

Use the reusable component's 14px button radius; the login frame uses 15px. Card styling follows the inspected card reference rather than assuming every product card is identical.

The 390×844 reference frame is not a fixed app viewport. Buttons use a minimum height of 52 and fields a minimum of 54, allowing translated content, validation messages, and enlarged text to grow.

## Colors and contrast

`AppColors` holds source colors. Read semantic colors from `Theme.of(context).colorScheme` in ordinary widgets.

| Role | Light | Dark |
| --- | --- | --- |
| Primary | #1769E8 | #2563EB |
| Page background | #F6F9FD | #090B0F |
| Card / input surface | #FFFFFF | #14171D |
| Main text / ink | #0F172A | #F7F9FD |
| Source muted text | #6B7890 | #A1AAB9 |
| Source outline | #E2E9F4 | #2B313C |
| Gradient end / secondary accent | #5BA5FA | #3D7EF1 |

The six brief colors are used exactly. Surface tint and card elevation are disabled so Material does not shift card colors.

There are deliberate readability departures from Figma:

- Primary actions use a **solid primary fill**. The source gradients end at #5BA5FA / #3D7EF1, where white text has approximately 2.56:1 / 3.85:1 contrast. The solid brand fills support white labels above 4.5:1.
- Light muted text uses **#626F86**, while preserving the source #6B7890 token for reference. The source tone is approximately 4.22:1 against the page background.
- Dark text actions and input cursors use Material's generated lighter `onPrimaryContainer` tone. The required dark primary stays unchanged for fills and focus borders; small blue text on the dark card surface would be only approximately 3.47:1.

Tests check normal text against page/card surfaces at 4.5:1, white primary labels at 4.5:1, and focused outlines at 3:1. Disabled states keep Material's native behavior. These component checks are not an accessibility audit of future screens.

## Typography

The app bundles unmodified variable font files for **Inter** and **Noto Sans Arabic**, with their SIL Open Font Licenses under `assets/fonts/`. Upstream verification hashes are recorded in `assets/fonts/README.md`. There are no runtime font downloads and no font package dependency.

Inter is the default family; Noto Sans Arabic is the explicit Arabic glyph fallback. This keeps mixed English/Arabic content readable in both directions. Latin characters in mixed strings use Inter.

The confirmed component roles are 14px bold action labels, 13px input/body text, and 12px bold field labels. Other Material 3 text roles remain available for screen authors. Exact font build versions and a complete semantic type scale were not supplied by Figma; see the remaining details below.

## Components and usage

- `AppButton`: themed filled primary action, optional leading icon or trailing adornment, disabled/loading behavior, growing height for large text. Standard `OutlinedButton` uses the shared secondary surface/outline style; `TextButton` uses a readable action tone.
- `AppTextField`: persistent label above the border, tied to the editable field's semantics; existing Form validation, controllers, password, autofill, and direction APIs are retained. Auth adds optional autocorrect/suggestion overrides so revealed passwords never enable them; validation messages can wrap.
- `AppCard`: themed surface plus default 16px directional content padding. Parents own the gap between cards; pass a different `padding` when a specific card's reference requires it.
- Existing loading/error/empty states use the shared theme and spacing without screen-specific data.

```dart
AppCard(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      AppTextField(label: localizedLabel, hint: localizedHint),
      const SizedBox(height: AppSpacing.medium),
      AppButton(label: localizedAction, onPressed: onSubmit),
    ],
  ),
)
```

`AppSpacing` exposes the observed page inset (22), button padding (20/10), and input horizontal inset (18). Its small/medium/large values (8/16/24), card content padding (16), and label gap (8) are retained implementation defaults, not claimed universal Figma tokens.

Use directional padding/alignment and translated strings. Do not force a whole page's direction for an email field; use the field's optional `textDirection` locally. The existing settings Cubit continues to control runtime locale and theme changes.

## Details still requiring design decisions

- Figma does not provide a complete responsive/breakpoint specification beyond the reference mobile frames.
- Explicit focus, pressed, hover, disabled, validation-error, and loading variants were not present in the inspected reusable components. Material behavior and theme-derived state colors remain in use.
- The exact font build/version used in Figma and a complete semantic typography/line-height scale are not available. The bundled upstream families match the observed names, not a verified font binary from Figma.
- Shared spacing/card-padding rules are incomplete; confirm them for each real screen. The component and login button radii differ by 1px as noted above.
- Screens 01/02 use the available original Figma vectors. Remaining screens' illustrations are deferred. See ONBOARDING.md for unavailable intro details and the user-requested career-neutral examples and continuous score arc.

This is a design-system implementation with documented accessibility adjustments, not a claim of pixel-perfect screen parity. Screens 01–04 reuse these components. See [AUTH.md](AUTH.md) for Login/Sign Up and their unavailable Figma references.
