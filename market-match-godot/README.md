# Market Match / Ad Street

A standalone Godot 4.6.2 Standard project. Import project.godot and press F5.

Choose independent student play or the optional paced expert demo. Match transactions, launch campaigns, inspect shoppers, compare policies and explain your evidence. All twenty profiles and all numerical rules are fictional teaching assumptions.

- scripts/market.gd: pure deterministic matching and outcome model.
- scripts/game.gd: student/demo flow, controls, profile dossiers and report export.
- scripts/street.gd: original vector marketplace artwork and animation, mouse/touch selection.
- tests/market_test.gd and tests/ui_test.gd: model and interface action checks.
- teacher-guide.md: learning targets, chapter links and simplifications.

Run tests from this project folder:

    godot --headless --path . --script tests/market_test.gd
    godot --headless --path . --script tests/ui_test.gd

Native reports use a save-file dialog. Web reports download through the browser. Work is held in memory; export a report before reloading or starting fresh. Do not enter names or personal information. Play in landscape on a phone. The canvas does not offer the semantic screen-reader controls of the previous HTML prototype.

Live play: https://ctwadden.github.io/Godot_GAME/market-match/

Web export uses Godot 4.6.2 export templates, with threading disabled. The preset publishes to ../market-match/index.html in this repository; use an existing local web server to test. Do not double-click the exported HTML file. No extra plugins or packages are required.
