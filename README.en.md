# AI Engineering Agent (ai-engineering-agent)

> 中文版：[README.md](./README.md)
>
> **Status**: this kit is still being refined and **may contain undiscovered issues** —
> for example inconsistent wording across rules, broken command/skill references,
> artifact paths that disagree with the rules, or ambiguous phrasing.
> Read through `rules/` and the command you plan to use before relying on it.
> Problems and improvements are welcome (new stack profiles, extra rule clauses,
> fixed references, field-tested lessons learned). When reporting, include
> **file path + line number + observed symptom** — that helps most.

The kit packages the entire software engineering lifecycle into four layers — commands,
skills, agents and rules — and hands work off between stages through **artifact files**
rather than conversation context. It covers two tracks:

- **0→1 greenfield**: requirement analysis → PRD → HTML prototype → contract → backend & frontend implementation → test cases → changelog → consistency review
- **1+ brownfield**: source-code reverse engineering → PRD → HTML prototype → changelog (dual source: git history + requirement decisions) → consistency review

---

## 1. Quick Start

1. Copy the whole `.codebuddy/` directory from this bundle **into the target project root**
   (sibling of `.git`).
2. Open that project in CodeBuddy and **start a new session** — rules are only loaded at
   session start; an existing session will not pick them up.
3. Run the entry command that matches your situation:

| Situation | Command |
| --- | --- |
| Existing project (produce PRD & prototype from source) | `/ai-reverse-project` |
| Brand-new project (start from requirements) | `/ai-require-design` |
| Backend implementation (drafts & freezes the contract) | `/ai-dev-backend` |
| Frontend implementation (consumes the contract) | `/ai-dev-frontend` |
| Generate the three tiers of test cases (generate only, never run) | `/ai-test-design` |

4. The three development-side commands are **mutually independent**: run them in any order.
   They align only through the artifacts under `docs/dev/` plus the rules.
5. Not sure where to begin? Run `/ai-reverse-project <repo-dir>` (existing project) or
   `/ai-require-design <project-name>` (new project). The command echoes an execution plan
   first and only writes files after you confirm.

---

## 2. End-to-End Tutorial (worked example)

> This section walks through the full flow — from installation to an incremental feature —
> using the sample project `lab-booking`.

### 2.0 Scenario

`lab-booking` — a university "Lab Instrument Booking System". It was delivered three years
ago by an outsourcing vendor and has never had any documentation, only source code.
The team taking it over has two goals:

1. Turn the existing system into a reviewable PRD plus an interactive prototype;
2. Then add one new feature: **when an instrument's calibration expires, deactivate it
   automatically and stop accepting bookings**.

Repository location (example): `D:\work\lab-booking`

Current state detected by the reverse-engineering stage: frontend `vue 2.6.14` +
`element-ui 2.15`; backend Java 8 + Spring Boot 2.7.5; database MySQL 5.7.

### 2.1 Step 1 — Install

```text
D:\work\lab-booking\
├── .git\
├── .codebuddy\        ← copy this kit's .codebuddy here
├── src\
└── pom.xml
```

Open the directory in CodeBuddy and **start a new session** (critical: rules load only at
session start).

### 2.2 Step 2 — Reverse-engineer the existing system (entry point)

```text
/ai-reverse-project D:\work\lab-booking --out=docs/reverse-engineered --scope=reservation,instrument
```

The command first validates arguments and echoes an execution plan (mode `evolve`, scan
scope, output directory, stage list). It writes stage by stage after you confirm.
**Source code is read-only throughout** — no command ever mutates the repository.

Sample output tree:

```text
D:\work\lab-booking\docs\reverse-engineered\
├── _meta\
│   ├── project-profile.md      # tech stack, module inventory, how to run
│   ├── traverse-report.md      # traversal scope and hit counts
│   ├── open-questions.md       # Q-01 … Q-09, each with an owner
│   └── status.md               # stage status (the basis for resuming)
├── modules\
│   └── reservation.md          # per-domain analysis, every claim carries evidence
├── prd\
│   ├── F01-instrument-registry.md
│   ├── F02-booking-request.md
│   └── F03-booking-approval.md
├── prototype\
│   ├── index.html              # navigation page, opens directly in a browser
│   ├── F02-reservation.html
│   └── prototype-spec.md
├── dictionary\
│   ├── api-inventory.md        # endpoint inventory
│   ├── table-inventory.md      # table structures
│   └── field-dictionary.md     # field dictionary
├── permission-matrix.md
├── hidden-logic.md             # hidden logic and legacy quirks
├── changelog\
│   ├── CHANGELOG.md            # merged changelog
│   ├── _git-log.md             # source A: git commit history
│   └── _decisions.md           # source B: requirement decisions
└── review\
    └── consistency-report.md   # consistency review report
```

Excerpt from `modules/reservation.md` — every conclusion must cite evidence, never guess:

```markdown
- Conflict detection compares time ranges only and **never compares room numbers**,
  so two different rooms in the same time slot are wrongly reported as conflicting.
  Evidence: `ReservationServiceImpl#checkConflict`
            (`src/main/java/.../ReservationServiceImpl.java:118-146`)
  Confidence: high (read directly from code)
```

Excerpt from `prd/F03-booking-approval.md`:

```markdown
### F03 Booking approval

- Precondition: only the instrument's responsible person may approve bookings for it
- Rule 3.2: at most one "approved" booking may exist for a given instrument and time slot
- Rule 3.4: once approved, the time cannot be edited directly — withdraw and resubmit

- AC-03-2: submit with a rejection reason → status becomes "rejected" and an in-app
  notification carrying the full reason is sent to the requester;
  reasons longer than 200 characters trigger a truncation notice
```

Excerpt from `_meta/open-questions.md` (each item has an owner and does not block the
already-confirmed parts):

```markdown
| ID | Question | Owner | Impact |
| --- | --- | --- | --- |
| Q-07 | Is there a hard cap on a single booking's duration? No check found in code | Registrar - Wang | F02 rule 2.5 |
```

At this point all five stages are `done` in `_meta/status.md` and the documents are ready
for review.

### 2.3 Step 3 — When your stack differs from the kit default

The kit default is React 18 + Java 17 + Spring Boot 3.2, while this example is
Vue 2.6 + Java 8 + Spring Boot 2.7. **You must declare it**, otherwise later commands will:
detect `vue@2.6`, match no registered profile (`frontend-vue3` requires vue ≥ 3) and
therefore **stop and ask**.

Two options, pick one:

**Option A (recommended; affects only this project)** — write an override file inside the
project:

```text
D:\work\lab-booking\docs\dev\_meta\tech-stack.md
```

State Vue 2.6 + Element UI on the frontend and Java 8 + Spring Boot 2.7 on the backend, and
reference the existing backend profile `tech-stacks/backend-java-springboot.md`.
Runtime precedence: project-level file > kit default > feature detection > stop and ask.

**Option B (add a profile; reusable across projects)** — follow `tech-stacks/README.md` §4:

1. Copy `tech-stacks/frontend-vue3.md` to `tech-stacks/frontend-vue2.md`;
2. Rewrite the 8 required sections (metadata / detection signals / directory skeleton /
   layer responsibilities / dependency list / naming conventions / build & test commands /
   referenced rules);
3. Register it in `tech-stacks/README.md` §3;
4. Afterwards pass `--stack=frontend-vue2` explicitly.

### 2.4 Step 4 — Contract first (the "stage 0" of development)

Use one shared output root for all development-side commands so artifacts align:
`--out=docs/dev`.

```text
/ai-dev-backend D:\work\lab-booking --out=docs/dev --contract-only --stack=backend-java-springboot
```

`--contract-only` performs "draft + freeze the contract" only and **writes no business
code** — ideal before frontend and backend run in parallel:

```text
D:\work\lab-booking\docs\dev\
├── contract\
│   ├── README.md        # status: frozen, version: v1.0
│   ├── api.yaml         # machine-readable contract (API-01 …)
│   ├── api.md           # human-readable API reference
│   ├── data-model.md
│   ├── enums.md
│   └── error-codes.md
└── _meta\
    ├── status.md
    ├── traceability.md      # requirements traceability matrix
    └── change-requests.md   # append-only change requests against others' artifacts
```

> `/ai-dev-backend` is the **single writer** of `contract/`. When frontend or test design
> finds a gap, it does not invent a field — it records a contract change request in
> `contract/_requests.md` (append-only). Requests against other artifacts go into
> `_meta/change-requests.md`. The backend arbitrates both.

### 2.5 Step 5 — Frontend and test cases (can run in parallel)

Once the contract is frozen, these two commands are independent and may run concurrently:

```text
/ai-dev-frontend D:\work\lab-booking --out=docs/dev --stack=frontend-vue2
/ai-test-design   D:\work\lab-booking --out=docs/dev
```

Artifacts:

```text
docs\dev\frontend\_meta\{probe.md,page-impl-report.md,api-binding-report.md,contract-gaps.md,status.md}
docs\dev\test\
├── _meta\{test-plan.md,coverage-matrix.md,status.md}
├── unit\TC-U01-....md          # unit test cases
├── integration\TC-I01-....md   # integration test cases
└── uat\TC-A01-....md           # UAT cases
```

The frontend must align **verbatim** with the contract (paths, methods, field names, types,
error codes), and pages map to prototype page IDs `P01…`. Test design **generates cases
only, never executes them** — execution is left to humans or external tools.

### 2.6 Step 6 — Incremental feature development

Taking goal 2 from §2.0, add `F08-calibration-expiry-auto-deactivate`:

```text
/ai-dev-backend D:\work\lab-booking --out=docs/dev --scope=F08
```

Because `F08` is not yet reflected in the contract, the command goes through the
**contract change flow**:

- `contract/version` moves `v1.0` → `v1.1`, status `frozen` → `changed` → `frozen` again;
- a contract change request is appended to `contract/_requests.md` (who asked, which
  `API-xx` are affected, the decision);
- after implementation, the `API` and `Backend implementation` columns of
  `_meta/traceability.md` are filled in.

Traceability matrix sample (column ownership: the defining command writes it, others read):

```markdown
| Feature | Source | API | Page | Backend | Test cases |
| --- | --- | --- | --- | --- | --- |
| F03 Booking approval | prd/F03 §3.2 | API-07@v1.0 | P04 | ReservationApprovalServiceImpl | TC-U03 / TC-I02 |
| F08 Calibration expiry | prd/F08 | API-19@v1.1 | P11 | CalibrationGuardTask | TC-U11 / TC-A04 |
```

### 2.7 Step 7 — Interruptions and resuming

After any interruption (closed session, lost network, changed requirements), simply
**re-run the same command**: it reads `_meta/status.md` in each output root, skips stages
already `done`, and continues from `in_progress`. A `blocked` stage explicitly reports what
is missing (for example, "cannot freeze the contract: `prd/F08` has no acceptance criteria").

`--scope` also lets you narrow a re-run, e.g. `--scope=reservation`.

### 2.8 Summary of the example

```text
/ai-reverse-project   → docs/reverse-engineered/   (PRD, prototype, dictionaries, changelog, review)
/ai-dev-backend       → docs/dev/contract/ + backend/
/ai-dev-frontend      → docs/dev/frontend/
/ai-test-design       → docs/dev/test/
                       ↑ all three share --out=docs/dev and align via artifacts only
```

The full path is: **reverse-engineer or clarify requirements → produce PRD and prototype →
freeze the contract → implement frontend and backend in parallel → generate test cases →
fill in the traceability matrix.** You can interrupt and resume at any point, and new
requirements go through the contract change flow.

---

## 3. Directory Layout

| Path | Content | Notes |
| --- | --- | --- |
| `.codebuddy/tech-stack.md` | System default tech stack | The **single** source of the default; read this first |
| `.codebuddy/tech-stacks/` | Stack profile library (5 files) | Java+SB2 / Java+SB3+JDK17 / Vue3 / React, plus the registry README |
| `.codebuddy/rules/` | Rules (9 + 5 Java + 1 glossary) | Reverse-engineering, PRD, prototype, changelog, workflow, dev contract, frontend/backend/test standards |
| `.codebuddy/agents/` | Sub-agents (9) | Requirement analysis, PRD, prototype, source analysis, changelog, frontend/backend dev, test design, consistency review |
| `.codebuddy/commands/` | Slash commands (5) | See the Quick Start table |
| `.codebuddy/skills/` | Skills (8) | Each has `SKILL.md`; some ship `references/`, `templates/`, `assets/` |

---

## 4. Prerequisites

| Dependency | Required? | Notes |
| --- | --- | --- |
| `code-explorer` sub-agent | Required | Built into CodeBuddy; reverse engineering relies on it for semantic navigation |
| `git` | Required | Changelog source A (only **read-only** commands such as `log` / `show`) |
| `docx` / `pdf` skills | Optional | Install when you need to import Word / PDF requirement docs |
| `security-sensitive-filter` skill | Optional | If absent, redaction follows `rules/se-workflow.mdc` §18 manually (same rule: keys, passwords, connection strings, real domains, internal addresses and PII all become placeholders) |

---

## 5. Default Tech Stack and How to Override It

Defaults (see `tech-stack.md`): frontend React 18 + Vite + TypeScript + Arco Design;
backend Java 17 + Spring Boot 3.2.x + MyBatis + Maven; MySQL 8 + Redis 7; deployment as a
Maven fat jar uploaded manually, with **no Docker / K8s / CI / config center / gateway**
by default.

Runtime precedence (first match wins):

1. `--stack=<profile-id>` on the `/ai-dev-*` command
2. Project-level `<project>/docs/dev/_meta/tech-stack.md` (**recommended**; keeps this kit untouched)
3. `.codebuddy/tech-stack.md` (this kit's default)
4. Feature detection (reads `pom.xml` / `package.json` etc.)
5. No match → **stop and ask**; never guess

Adding a stack profile means adding one file and registering it in
`tech-stacks/README.md` §3 — **no changes to commands, agents or rules**. See §4 of that file.

---

## 6. Activation and Troubleshooting

- **Rules are loaded only when a session starts.** After editing rules, open a new session;
  the current one will not pick up changes.
- Rule files all use the **`.mdc`** extension (matching the official convention) and live
  flat in `rules/` and `rules/java/`. The single exception is `rules/java/java-glossary.md`,
  a terminology reference with no frontmatter that is not loaded as a rule.
- If a new session does not load the rules (ask the assistant "which rules are currently
  applied?"), try renaming `rules/*.mdc` back to `rules/*.md` — tolerance for the extension
  varies across versions. Whichever naming you choose, update every `rules/<name>`
  reference across the bundle as well, otherwise you end up with dangling references
  (all references in this bundle already point to `.mdc`).
- Command missing from the slash menu: verify the frontmatter of
  `.codebuddy/commands/*.md` is complete (`description` / `argument-hint` / `allowed-tools`).
- Rules with `alwaysApply: true` stay **resident in context**. This kit has two of them
  (`java-coding-basics.mdc`, `java-oop-collection.mdc`, about 50 KB combined). If context is
  tight, flip them to `false` for on-demand loading — at the cost of no longer being
  guaranteed to apply whenever Java is written.
- A sub-agent's callable skills are listed in its "Callable Skills" section, referenced as
  `[skill:xxx]` or in backticks (e.g. `[skill:docx]`, `` `security-sensitive-filter` ``).
  If a skill is not installed, that step degrades or is skipped.

---

## 7. Where Artifacts Are Written

All artifacts go **inside the target project**, never into this kit's directory:

| Mode | Location | Content |
| --- | --- | --- |
| 0→1 | `<project>/docs/forward-engineered/` | `_meta/`, `prd/`, `prototype/`, `changelog/`, `review/` |
| 1+ | `<repo>/docs/reverse-engineered/` | As above plus `modules/`, `dictionary/`, `permission-matrix.md`, `hidden-logic.md` |
| Development side | `<project>/docs/dev/` | `contract/`, `_meta/` (traceability matrix etc.), `backend/`, `frontend/`, `test/` |

Any location can be overridden with `--out=<dir>`. Stage status is written to
`_meta/status.md` in each output root, which is how an interrupted run **resumes** and skips
stages already marked `done`.

---

## 8. Operating Discipline (Rule Highlights)

- **Redaction**: before writing to disk, filter out keys, tokens, passwords, database
  connection strings, real domains, internal addresses and personal data — all become
  placeholders.
- **Read-only**: in reverse-engineering mode, never run a command that modifies the target
  source or repository state.
- **Append-only**: the changelog never overwrites or deletes history; corrections are new
  entries.
- **Contract first**: freeze the contract before implementing. A PRD describes *what*;
  everything implementation-level comes from `contract/`. Gaps are logged, never invented.
- **Traceable**: reverse-engineered conclusions must cite file path + line number, never be
  invented, and carry one of three confidence levels.
