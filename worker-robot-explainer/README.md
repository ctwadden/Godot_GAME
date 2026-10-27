# Worker or robot? — standalone interactive explainer

Compare one worker with a robot plus paid supervision making the same product. Change production speed, wages, demand, selling price, materials, robot purchase price, daily running cost and the working-day horizon. Follow completed units, sales, business costs, employee pay, cumulative business profit and the robot's catch-up point.

**Open the explainer:** https://ctwadden.github.io/Godot_GAME/worker-robot-explainer/

Run comparison, or drag the timeline to inspect a particular day. Use the three example jobs to investigate high demand, low demand and an expensive robot. Changing assumptions pauses and rewinds the comparison. Static images preserve the model without continuous task motion. All controls are native keyboard-operable browser controls. No audio.

## Money and production rules

All values are fictional teaching assumptions, not estimates or financial advice. Units/day = min(daily demand, floor(shift hours × production rate)). Only completed whole units count. Each completed unit up to demand is sold immediately at the shared price and incurs the shared materials cost.

Worker business cost = materials + scheduled shift wages. Robot business cost = materials + scheduled supervisor wages + daily running cost + upfront purchase price. Employee pay is shown separately from business profit; it is already included in business costs. The robot earns no wages. Scheduled pay and daily running costs continue during idle time. For partial working days, those fixed daily costs accrue proportionally; production stops once that day's demand is filled.

Business profit = revenue − all model costs. Purchase is fully charged at time zero. No borrowing, depreciation, tax, resale, breakdown, learning period, defective units or other overheads are included. Catch-up is the first complete working day when robot-scenario cumulative profit reaches the worker-scenario result; this is a relative comparison and can occur while both are losing money. If robot daily profit is not higher, no catch-up is asserted.

Default example, at 30 working days: worker 1,440 units, $25,920 business profit, $5,760 employee wages; robot scenario 2,400 units, $32,160 business profit, $1,440 supervisor wages after charging the $18,000 purchase. The extra upfront cost is recovered relative to the worker by working day 23. With daily demand20, both sell20/day; worker profit $7,440 and robot profit −$7,440 at30 days. Catch-up moves beyond that horizon.

## Visuals and time

The realistic worker and robot clips depict the same battery-placement method. One visual cycle illustrates the day's batch; counters are calculated by the model, not counted from visible hand movements. The shared timeline advances one fictional working day per four seconds. Footage follows that day's production progress, pauses with the comparison, and stays idle for zero demand or zero capacity. Static mode shows start/finished images instead.

The clips are AI-created artwork, assembled from consistent rendered poses with motion interpolation, not footage of a real identified person or measured industrial cycle times. Minor interpolation artefacts can remain. Battery placement is one task, not a full-phone manufacturing instruction. Both required MP4 assets are included locally, with no external media service or runtime calls.

## Learner response

The writing field stays in page memory. Download creates a local text file with assumptions, selected-time results, horizon results, catch-up explanation and the learner's writing. It does not send anything to a teacher or grade the writing. Students submit that file through the usual classroom method. Reloading or closing loses writing that has not been downloaded. No identity, accounts, analytics, storage service, API key or external AI grading.

## Run locally / check the model

Keep the whole folder together and serve it with any static HTTP server. For example:

```sh
python3 -m http.server 8769 --bind 127.0.0.1
```

Then open http://127.0.0.1:8769/ . ES modules require HTTP; opening index.html as a local file is not supported.

Calculation checks (Node.js):

```sh
node tests/model.test.mjs
```

See QA.md for recorded tests and limits. This is a standalone explainer; it has no suppliers, shipping, hiring menus or campaign state.
