# Training Tracker website

GitHub Pages site of the [Training Tracker](https://apps.apple.com/app/id6752959007) iOS app, served from `main` at https://vybgss.github.io/training-tracker-docs/.

| Page | App Store Connect field |
| --- | --- |
| [marketing.html](https://vybgss.github.io/training-tracker-docs/marketing.html) | Marketing URL |
| [support.html](https://vybgss.github.io/training-tracker-docs/support.html) | Support URL |
| [privacy-policy.html](https://vybgss.github.io/training-tracker-docs/privacy-policy.html) | Privacy Policy URL |

`index.html` redirects to the marketing page.

## Languages

Every page holds all seven app languages (en, de, fr, uk, es, ja, pt) as `<article lang>` blocks, and the navigation labels as `<span lang>` alternatives inside `.l10n` elements. `assets/site.js` picks the language from `?lang=`, the language picker (remembered in the browser) or the browser language, falling back to English; `assets/style.css` hides the other languages. A change to the text goes into every language. UI labels quoted on the pages match the app's String Catalog. In the privacy policy the English version prevails.

## Design

`assets/style.css` follows the app's `DesignSystem.swift`: the indigo accent and its dark variant, iOS grouped surfaces, Settings-style icon tiles, the expanded display face for titles and the hero gradient as the only large color field. Icons are drawn in `assets/icons.svg` (no SF Symbols, their license doesn't allow use on the web). The app icon in `assets/` is exported from the app's asset catalog.

## Screenshots

`assets/screens/<lang>/{home,detail,log}-{light,dark}.jpg` are captures of the Release build on an iPhone 18 Pro simulator with the demo log from the app repo's `Design/AppStore/demo_data.py`, exercise names translated with its String Catalog. `tools/capture-screens.sh` takes them; its header lists the steps. Retake them when those screens change.
