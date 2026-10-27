# Nova / Global Launch

## Worker or robot? — standalone explainer

[Open the interactive explainer](https://ctwadden.github.io/Godot_GAME/worker-robot-explainer/). Compare the same job, worker wages, paid robot supervision, output, costs and cumulative business profit under editable fictional assumptions. No campaign is required. Source, transparent model and calculation tests are in `worker-robot-explainer/`.

A playable Godot 4.6.2 classroom management simulation about global sourcing, digital business records, work arrangements and stakeholder trade-offs. Original vector icons and a bundled Natural Earth coastline map work offline. The firms, financial values and event effects are fictional teaching assumptions.

## Start with these two versions

- Expert demo: https://ctwadden.github.io/Godot_GAME/site/play/?mode=demo
- Guided student practice: https://ctwadden.github.io/Godot_GAME/site/play/?mode=student
- Optional advanced campaign: https://ctwadden.github.io/Godot_GAME/site/play/?mode=campaign

The native project starts at a mode chooser. The expert is an authored operations coach, not an online AI service. Eleven worked steps run real simulation actions and explain before/after states. Students then start a fresh ten-day company ($28,000; 80 chips, 10 screens, 80 batteries), with eight tasks, optional contextual advice, manual day advance and a post-run review. Assembly, delivery trucks and customer payments are automatic; buying parts and choosing expertise are player decisions. Demand increases from 20 to 30 on day 6. The practice event is a duplicate screen scan after 80 deliveries; the full campaign retains transport/random events.

The 150-delivery target is a challenge, not a grade. Slower initial sea freight saves money but exposes the small screen buffer and can miss the target; a review and retry remain available. Replenish parts before they run out, considering cargo already ordered. A $500 practice contingency guard and an explicit review route prevent the audit stage from trapping a depleted company. The illustrative reference policy uses the same starting state and elapsed days, with near-supplier replenishment and training; it is not asserted to be optimal.

Student practice saves to `user://student-practice.json`; the advanced campaign uses `user://campaign.json`. Demo actions do not touch those saves. Stage progress and answer fields survive student Save/Load. New-company controls intentionally start afresh; switching away saves the existing student attempt first. The advanced campaign remains available with its original controls and targets.

New checks: `tests/coaching_test.gd` runs both freight choices and all three expertise choices through debrief; `tests/coached_ui_test.gd` exercises mode selection, actual guided controls, duplicate-purchase prevention, receipt gates, cash recovery and correct exported prompts. `tests/capture_modes.gd` renders mode previews.

## Share and download

Student game: https://ctwadden.github.io/Godot_GAME/

Portable editable project: https://ctwadden.github.io/Godot_GAME/site/downloads/Nova-Global-Launch-Godot.zip

The website includes a single-threaded browser build. Browser Report export downloads a text file; Save stays in that browser/device. Extract the ZIP on a school computer and import `project.godot` in Godot 4.6.2 Standard, then press F5. No export templates are needed for editor play. The ZIP excludes caches, player saves, textbook/lesson source files and Git history. Read `START-HERE.txt`.

## Start

Open `project.godot` in Godot and press **F5**. For the advanced campaign, start with **Learn**: the seven-step introduction includes two real actions (place an order, advance a day). You can skip or revisit the guide. Mouse wheel scrolls the right panel. Buttons support keyboard focus. The logical 1440×900 canvas scales with the window; 1280×800 or larger is recommended. Space pauses; **+ Day** advances once; play advances automatically every 2.5 seconds at 1×. Learn and Report pause time automatically.

Deliver 900 phones by day 30, with at least 65 trust, 60 wellbeing and nonnegative cash. Game outcome is separate from understanding. Complete practice checks in Learn, write individual explanations in Report, and export evidence for teacher review. The teacher guide maps eight local “I can” targets to sources, mechanics, checks, feedback and transfer.

## Panels

- **Supply:** physical and recorded inventories, per-component alert rule, part orders, mode costs, active cargo and stock audit. Each phone needs one chip, screen and battery.
- **People:** relevant work samples, specialist hiring and training existing staff. Hiring alone is not an insourcing transition.
- **Develop:** independently choose internal/external R&D and Canada/Portugal location. Changing external work to existing internal staff insources; moving overseas work home reshores. Employee salaries continue in external mode. Internal research uses trained staff/engineer; external research uses the contracted rate. The leased overseas lab has a fictional equipment bonus, not a country skill assumption. Complete 100 research points for a higher-value phone. Add assembly capacity, tracking or overtime.
- **Learn:** guided introduction, eight checks with feedback and retry, and local learning targets. Quiz attempts persist; practice scores are not automatic grades.
- **Report:** write three explanations, inspect daily records and decisions, export a local report. It remains possible to visit Learn after the campaign ends.

## Goods, data and money

Orders cost cash immediately but do not create stock. Overseas cargo travels by sea/air, waits one day for border clearance, then enters physical inventory. The Montréal supplier uses domestic trucks and no import stage. Assembly consumes parts and sends phones into a one-day domestic delivery stage. Customer receipt, rather than assembly, generates revenue. The sale price is fixed at dispatch. Phones still in delivery after day 30 do not count toward the mission.

Recorded screens can differ from physical stock after a duplicate-scan event. Each component's alert reads its record and triggers below 80. Assembly uses physical counts. A $500 audit corrects records without manufacturing parts. Tracking provides a one-day advance transport-risk briefing based on the scenario; it cannot remove physical constraints. Written explanations should trace record → rule → output → decision → customer consequence.

## Scenario modes

Choose in introduction step 1 before advancing. **Classroom** has fixed comparable events: storm on day 9, border inspection on day 16, duplicate scan on day 22. Demand rises on days 6 and 21. **Random** samples three distinct bounded events (storm, inspection, record error, recall, extra demand) in windows 7–10, 14–17, 21–24. Use the same displayed seed to reproduce the event plan and compare strategies. Different decisions still cause different outcomes.

Storms add two days to relevant existing sea cargo and new sea orders within their active window. Inspections delay existing border cargo and arriving overseas lots. Each event explains its consequences and pauses automatic play after that day's processing so players can plan their next decision. Disruptions are teaching scenarios, not statistical forecasts.

## Save and evidence

Save/Load preserve campaign state, event plan, tutorial progress, check attempts and written responses. Version 2 saves use `user://campaign.json`; earlier prototype saves are rejected with a message. Report exports human-readable answers, attempts, events, decision log and daily numerical records to `user://nova-report.txt`, and shows the absolute path. No names, accounts, analytics, network API or LMS connection are used. Save/export before closing. Re-exporting replaces the prior report; copy exported reports if retaining multiple runs.

## Verification

macOS commands (adapt the Godot executable path on another system):

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script tests/simulation_test.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script tests/ui_test.gd
```

Simulation tests cover staged logistics, money versus stock, independent provider/location transitions, actual event effects, repeatable seeds, full classroom/random campaigns, record audit, saving in-transit data and individual explanations, budget checks and overtime. UI tests invoke the actual controls for tutorial gates, quiz answers, paused writing, post-game Learn access, export and disruption pause. They use test-prefixed save/report files and do not overwrite player saves or reports.

Latest tested strategy results: classroom 1,340 deliveries, $149,300 cash, 100 trust and 70 wellbeing; random seeds 101/202/303 also completed all 30 days. These demonstrate feasible play, not optimal balancing or classroom learning. All tabs and the introduction were rendered in Godot; additional visual captures test quiz feedback and late-game evidence. Independent pedagogical desk review informed the targets and corrected post-game navigation and timed-writing issues. No student trial has established pacing or comprehension yet.

`tests/capture.gd` renders preview images. `preview.png` shows the revised map and Supply panel. The map is a geographic basemap with schematic transport routes, not navigation data. Source attribution is in `assets/ATTRIBUTION.md`.

## Structure and scope

- `scripts/simulation.gd`: campaign transactions, sourcing transitions, events and persistence.
- `scripts/game.gd`: interface, map projection, transport display and evidence export.
- `scripts/learning.gd`: source-aligned introduction, targets, checks and reflection prompts.
- `teaching-guide.md`: teacher-facing learning contract, source mapping and coverage limits.
- `assets/`: offline coastline data and original transport icons.

This is a teaching prototype. Hiring and capacity installation are immediate; no full labour market or construction schedule exists. Country costs/rates are fictional scenario contracts. There is no causal model of automated hiring bias, IP/knowledge transfer, actual robot automation, cryptocurrency, gig work, targeted advertising or global consumer markets. Diversification is discussed and checked but not a full playable system. No audio or standalone app export is included. The Web export preset includes `assets/*.geojson`. Install the standard 4.6.2 web export template to rebuild, then run `godot --headless --path . --export-release Web site/play/index.html`. `tools/package_project.py` refreshes the source ZIP. GitHub Pages serves the root of main; `index.html` links to the browser build and source ZIP.


## Market Match / Ad Street — second Godot game

The separate `market-match-godot/project.godot` project replaces the earlier HTML prototype with a Godot 4.6.2 game. It has an animated marketplace, five transaction/role checks, three ad policies, twenty inspectable synthetic shoppers, optional advice and a seven-step expert demo. Reproducible campaign outcomes and reports support explanation rather than click-score grading.

- Play: https://ctwadden.github.io/Godot_GAME/market-match/
- Source ZIP: https://ctwadden.github.io/Godot_GAME/site/downloads/Market-Match-Godot.zip
- Import that project's `project.godot` in Godot and press F5.
- Tests live in `market-match-godot/tests/`; packaging uses `python3 tools/package_market_match.py`.

The existing demo/student URLs and old `Market-Match.zip` download now point to the Godot edition. Nova remains a separate project at the repository root.
