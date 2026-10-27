# Payments & Tokens — One Idea at a Time

Godot 4.6.2 Standard demonstration. Import project.godot and press F5.

This replaces the earlier dashboard lab with a linear explanatory lesson. Eleven ideas each have three narrated parts: what happens, why it happens, and the impact. There are 33 bundled synthetic voice recordings, about seven minutes in total; no live speech or AI service is required. Captions match the narration. Each idea waits for the learner before continuing. An optional question appears after the impact narration, with an explanation and no score. Silent reading is available from the start.

Controls: Start with narration / Read without sound; Pause/Resume; Replay; Sound on/off; Back; Next part; Next idea. Questions can always be skipped. Browser audio starts only after the learner presses Start. Check the device volume if narration is silent. Keyboard focus follows normal Godot controls. Desktop/projector recommended; canvas rendering is not a complete semantic screen-reader interface. TRANSCRIPT.md provides the complete text alternative.

The visuals are simplified explanations, not a financial model. All credits, register identifiers and licence terms are fictional. There are no purchases, random-reward draws, wallets, market predictions, account logins or student-data fields. The e-trading scene is historical source analysis. No financial, legal or tax advice is provided. The fictional L1 card is instructional evidence, not the licence for these project files.

Content: currency/payment methods; cash; central account records; shared ledgers; cryptocurrency; file versus token; licence permissions; broken media link; cashless access; cumulative small purchases; e-trading access/power/risk.

Source JSON: assets/lessons.json. Audio: assets/narration/. The transcript hashes in its manifest detect caption/audio drift. Narration was generated locally with macOS's installed Samantha voice at 155 words/minute. tools/render_narration.py regenerates it on a Mac with that voice installed. Playback elsewhere requires only the bundled WAV files, not macOS or that voice.

Test after Godot asset import:

    godot --headless --path . --script tests/lesson_test.gd

Export Web with the preset into ../payment-token-lab/index.html in the classroom repository. Serve over HTTP, not file://. The source ZIP is for Godot editor play. The web export is the same Godot lesson.

Technical playback, transcript matching, watch-before-question flow and rendered layouts are checked. Student comprehension and classroom pacing remain untested. Read teaching-guide.md for source boundaries and a short classroom plan.
