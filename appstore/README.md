# App Store listing

Metadata for the Off-hours App Store record (App Store Connect app ID 6831322487), kept here so it can be
reviewed and reused. App Store Connect has the live version.

| Field | Source |
| --- | --- |
| Name | Off-hours |
| Subtitle | `subtitle.txt` |
| Promotional text | `promotional-text.txt` |
| Description | `description.txt` |
| Keywords | `keywords.txt` |
| Support URL | `support-url.txt` (page on off-hours.tueftli.com, one per language) |
| Privacy policy URL | `privacy-policy-url.txt` (page on off-hours.tueftli.com, one per language) |
| Copyright | `copyright.txt` |
| App Review notes | `review-notes.txt` |
| Category | Productivity, secondary Utilities |
| iPhone screenshots (1206×2622, "iPhone with Dynamic Island") | `../screenshots/appstore/` (`npm run screenshots`) |
| Header (3840×1646) | `marketing/header-3840x1646.png` |
| Search results (1920×1280) | `marketing/search-results-1920x1280.png` |

The header and search-results backgrounds in `marketing/source/` were generated with OpenAI gpt-image-2;
`marketing/compose.py` adds the icon, text and the real app screenshot (needs Pillow).

`upload/` (ignored by git) collects all images for drag and drop into App Store Connect: run
`npm run appstore:upload-folder`.
