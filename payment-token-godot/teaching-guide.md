# Payment & Token Lab — teaching guide

Status: Godot model and interface checks completed; initial student pilot pending. The approximately 15-minute modes include discussion and individual explanation; timing is an estimate.

## Targets and source scope

- I can distinguish payment method, currency and transaction record by tracing verifier, fields and infrastructure.
- I can recommend a payment policy conditionally, using evidence about the shop, different customers and infrastructure providers.
- I can distinguish file possession, token control, licence permission and creator copyright; a persistent record does not guarantee persistent linked media.

Teacher-supplied chapter: *4.2 Economic*, 4.2C pp.223–225, read from Economics.pdf. Page 223 introduces cryptocurrency, NFTs, cashless society and microtransactions; p.224 discusses random-reward purchases and also additive manufacturing (outside this lab); p.225 provides a historical GameStop/e-trading case. The discussion is a paraphrase for source analysis, not verification or endorsement of all claims in that case. No book pages are redistributed.

Disciplinary clarifications: digital payment does not imply cryptocurrency; consensus need not be proof of work; pseudonyms do not guarantee anonymity; NFT control is distinct from copyright and licence rights. No generalized legal conclusions about a particular real token are offered. L1 is explicit fictional instructional evidence.

Primary background sources consulted 27 October 2026:

- NIST IR 8202, *Blockchain Technology Overview* (2018): https://csrc.nist.gov/pubs/ir/8202/final — distributed records and varied consensus mechanisms. This lab's 2-of-3 toy rule does not implement production consensus, cryptographic authorization, mining or security.
- NIST's privacy-enhancing distributed-ledger project: https://csrc.nist.gov/projects/privacy-enhancing-lw-distributed-ledger-technology — permissioned designs can use other validation approaches; no universal proof-of-work assumption.
- Creative Commons, *FAQ: CC and NFTs*: https://creativecommons.org/cc-and-nfts/ — separates token ownership from copyright/licensing. The lab uses its own fictional licence, not a CC licence; commercial permissions follow L1 in this case only.

## A / Access and resilience (~15 minutes)

Introduce method / currency / record. Same FC unit, 10 FC per independent case. Predict access for digital-only central payments, reveal, then inspect one successful and one blocked case. Ask what a phone provides versus an account. Advance a named outage and change only shop acceptance to examine cash fallback. Restore connectivity, then inspect one-node and two-node shared failures.

Independent exploration: change only one condition and predict the result; compare actual access, fees and handling. State a recommendation with a condition that could reverse it. Mixed has better access in the selected examples but adds cash infrastructure and handling. A different shop or customer population could justify a different policy.

All successful fees/time/work are shown as assumptions: cash 0 FC/18 s/2 handling steps; central 0.10 FC/4 s/1; shared 0.20 FC/7 s/1. Setup units are 1/2/3 for cash/digital/mixed. Totals are sums over successful independent cases, not throughput, empirical efficiency or complete business costs. Failed attempts have no charge here. Cash is not cost-free merely because its transaction fee is zero.

P02 is explicitly provisioned for the shared toy route independently of a central account; this is not a claim that all unbanked customers have such access. P03's phone dependence applies only to these mobile routes; physical cards and offline terminals could alter the outcome. P04's lack of cash and interface needs are separate facts. Terminal accessibility is a fictional scenario control and does not disable the lab's own keyboard UI. Cash assumes usable change, staff support and safe handling.

Records use synthetic aliases, amount, sequence and acceptance status. The central provider's private account linkage is explained but not exposed; classroom traces are sanitized. Shared demo records go to authorized nodes, not automatically every class member. Alias-linked patterns can still identify people in real settings.

## B / Token and licence (~15 minutes)

Show a local copy in A, then copy equal SVG bytes into A/B/C. Compare byte counts and SHA-256 fingerprints with the single registry ID. Transfer control to B and inspect the unchanged identifier, history and L1. Read L1 before drawing conclusions about rights. Break the simulated media link: the remote preview fails while local files and register persist. No network request or real token is made.

Match the four claims to the relevant evidence source, then ask for an individual explanation. Neither possessing the image nor controlling the registry token silently confers commercial reproduction rights. The identifier is unique within this collection, not proof of authentic authorship in the world. A different explicit licence could permit different uses.

## Discussion and exit evidence

Use the static five-item $2 worksheet to connect small unit cost to cumulative $10. The random-reward offer remains a description, with no animation, random draw, purchase or reward loop. Discuss contents/probabilities, duplicates, cost controls and terms. Do not infer legal status or safe spending thresholds.

For the chapter's historical e-trading case, distinguish access, platform restrictions and risk. Ask what dated primary sources would be needed to evaluate the case fairly. There is no simulated price pattern or lesson in trading strategy.

The local report asks for a payment recommendation, a token/licence/media explanation and a cost/source-analysis response. Game feedback is formative, not a grade. Systems, power, values/ethics and identity should appear in causal explanations, naming shop, different customers, creator/recipient and infrastructure providers.

## Initial pilot and limitations

Observe whether students can name the failed dependency before changing settings, cite the appropriate evidence for a right and transfer their reasoning to a physical-card scenario or different explicit licence. Ask for an individual response after any pair discussion. Track where help is needed. Informal pilot responses are design evidence, not proof of causal learning gains.

No student identities, accounts or financial data are requested. Text answers remain in memory until export; web downloads and native Save dialogs create local reports. Reloading or starting a new mode resets its scenario, not existing report text; restarting the app clears the session. Hosting providers may process ordinary static-file requests. Desktop/projector preferred; provide the text round in DESIGN-BRIEF.md where canvas access is unsuitable. Keyboard focus does not establish full screen-reader accessibility.
