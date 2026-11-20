# Bundled design fonts

These unmodified variable fonts implement the families identified in the Figma reference. Downloaded on 2026-11-17 from the Google Fonts repository and verified against fresh upstream downloads on 2026-11-19.

| Local file | Upstream source | License |
| --- | --- | --- |
| Inter.ttf | [Inter](https://github.com/google/fonts/tree/main/ofl/inter), Inter[opsz,wght].ttf | Inter-OFL.txt |
| NotoSansArabic.ttf | [Noto Sans Arabic](https://github.com/google/fonts/tree/main/ofl/notosansarabic), NotoSansArabic[wdth,wght].ttf | NotoSansArabic-OFL.txt |

The files are registered in pubspec.yaml and bundled with the application. No runtime fetching is needed. Retain both license files when redistributing these assets. Figma identifies font families but does not supply the exact upstream font build used in the design.

Both assets match their original upstream bytes. Inter was restored after an unnecessary binary repacking; Noto Sans Arabic was never modified. Keep trusted font binaries intact rather than altering incidental byte sequences during text cleanup.

| Asset | SHA-256 |
| --- | --- |
| Inter.ttf | `29160a80ff49ddcab2c97711247e08b1fab27a484a329ce8b813d820dc559031` |
| NotoSansArabic.ttf | `63111b5b2e074dd48cc67692e0a2726d86ee94c1c37fe8598257b7b4e87e869e` |
