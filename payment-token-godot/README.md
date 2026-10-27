# Payment & Token Lab

Standalone Godot 4.6.2 Standard classroom demonstration. Import project.godot and press F5. The editable project requires no plugins. Approximately two 15-minute modes, not yet timed with students.

- Mode A: cash / central mobile ledger / simplified shared ledger; four customer situations; shop policy, explicit outage and accessible-terminal assumptions; transfer traces and separate access/fee/work results.
- Mode B: actual original SVG bytes copied between three virtual in-memory folders; one collection/token record; control transfer; explicit fictional licence; simulated broken external media host; evidence matching.
- Static discussion: five $2 items total $10 in fake worksheet dollars; fixed versus random-reward disclosure; paraphrased historical chapter case about e-trading access, restrictions and risk. No purchase, draw or trade controls.
- Optional paced demos, independent exploration, three exit questions and local text report export.

All balances, fees, times, access provisions, consensus rules and licence terms are fictional teaching assumptions. No value, wallet integration, keys, real identities or financial service calls. The `.invalid` media address is text only; it is never requested. Normal web hosting loads static Godot files; no live financial network is used. This is conceptual teaching, not investment, tax or legal advice.

The onscreen L1 licence is a fictional evidence card, not the licence governing this source project. The original SVG was created for this lab and can be adapted for teaching. No textbook pages or third-party financial images are bundled.

Desktop/projector recommended. Mouse/touch and normal Godot keyboard controls are supported; the canvas is not a full semantic screen-reader UI. DESIGN-BRIEF.md contains an equivalent text sample round. Two 15-minute lesson estimates and student comprehension remain untested.

Run tests inside this project:

    godot --headless --path . --script tests/model_test.gd
    godot --headless --path . --script tests/ui_test.gd

Rendering check: `godot --path . --script tests/capture.gd`.

Web export preset targets ../payment-token-lab/index.html in the classroom repository. It includes the raw SVG bytes as harbour-source.txt (identical to harbour.svg) as well as the imported texture, so the byte-copy and fingerprint exercise works in the exported build. Test the export over HTTP; do not double-click its HTML. The source ZIP is for Godot editor play, not a standalone browser folder.

Read teaching-guide.md for source distinctions, lesson sequence, limitations and initial pilot checks.
