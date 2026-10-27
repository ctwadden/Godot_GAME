# Payment & Token Lab — design brief

Stage: designed; teacher's explicit Godot build prompt authorizes this prototype. Two approximately 15-minute modes, timing untested. Teacher-led demonstration is the default; optional exploration and an individual evidence report support formative use. Godot 4.6.2 Standard; desktop/projector preferred, landscape tablet secondary. Not a complete treatment of pp.223–225: additive manufacturing and investment mechanics are excluded.

## Learning targets

1. I can distinguish payment route, fictional currency and transaction record by tracing verification, recorded information and infrastructure.
2. I can recommend a shop payment policy using evidence about different customers, handling work and named outage conditions.
3. I can distinguish possessing image bytes, recorded token control and permissions in an explicit fictional licence, including media-link failure.

Prior knowledge: buyer/seller, balance and transfer. Misconceptions: digital equals cryptocurrency; distributed means always available or anonymous; unique token means uncopiable image or automatic copyright; flat phone means every electronic payment stops.

## Decision and evidence map

| Target | Decision | Visible consequence | Individual evidence | Transfer |
|---|---|---|---|---|
| Payment systems | Select cash-only/digital-only/mixed and one digital route | Four independently reset customer cases; route-specific transfer verifier and ledger fields | Trace payment method / currency / record | Would a physical card or offline terminal change this phone-dependent model? |
| Access/resilience | Predict who can pay; change one outage or terminal-interface assumption | Access, handling steps, assumed fee/time and infrastructure shown separately | Recommendation naming shop, customers and infrastructure provider | A customer has no cash and a different access need |
| Token/licence | Copy local image, transfer token control, break simulated media host | Three equal files, one unchanged collection+token identifier, unchanged licence and missing remote preview | Four evidence-source matches and a rights explanation | What if a different explicit licence permitted commercial reproduction? |

## Sample A

All prices 10 FC (fictional credits). Same currency for all routes. Central mobile ledger chosen, digital-only shop, normal connectivity, accessible terminal. P01 banked/charged connects; P02 no central account cannot; P03 phone flat cannot use this model's mobile route; P04 needs keyboard/large text, has an account and charged phone but no cash, succeeds with the accessible terminal. Result: 2/4 access. Central provider verifies credentials and balance; customer loses 10 FC, shop receives 9.90 FC and provider fee 0.10 FC. No real transaction occurs.

Change only central connection to down: 0/4 on this route, no debits or fees. Shared connection is still up; cash remains usable for the three who carried it. Change shop to mixed: 3/4 pay cash; P04 still cannot during that central outage. Restore connection: mixed serves all four but adds cash handling and setup work. This is a conditional recommendation, not a universal winner.

## Sample B

Folder A initially holds original illustration bytes. Copy creates equal local image bytes in A/B/C. Collection CLASS-LAB and token 0001 identify exactly one registry entry controlled by Alias A. Transfer to Alias B updates control and history, not the identifier or licence. Licence permits all three classroom users to hold copies and display with credit, retains creator copyright and does not permit commercial reproduction. Break the simulated external media link: remote preview fails, local copies and token register remain. Reasoning must cite the relevant evidence, not assume control means every right.

## Scope and safeguards

All fees, durations, customer possessions, accessibility needs, balances and outage rules are authored assumptions. Shared ledger uses a deliberately simplified 2-of-3 validation rule, not production consensus, security, mining or real signatures. Pseudonyms are linkable labels, not anonymity. Private central records use aliases; the optional class display is a sanitized model trace, not publication of private customer details. All credentials are boolean toy inputs; no keys, wallet address, account data or live financial connections.

Microtransaction worksheet is static: 5 × $2 = $10 in fake worksheet dollars. Fixed item and random-reward description have no purchase/open/spin controls or rewards. E-trading is a short paraphrased chapter-case source exercise, clearly not a market model or current recommendation. No investment, tax or legal advice. The licence is fictional instructional evidence.

## Support, test and pilot

Paced demos reveal before/after model state; exploration can be selected independently. Demo controls are locked, help and rules remain accessible, and reset is explicit. Keyboard controls and readable text supplement route diagrams and colour. Canvas accessibility is limited; provide the equivalent text-based teacher round if needed.

Test record/balance invariants, per-route failures, shared quorum, privacy field lists, copy/token distinction, unchanged licence, local-copy persistence, no live requests, and actual UI/export. Ask a small initial student group to predict, explain an unexpected result and answer a changed case. Keep technical test status separate from classroom evidence. No timer or score is an academic grade.
