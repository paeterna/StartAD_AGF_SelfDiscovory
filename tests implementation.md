## tests to implement

## Tier 1 — 10-minute “Quick Read” (onboarding)

1. **Interests Screener (RIASEC mini)**
    - **Measures:** Realistic, Investigative, Artistic, Social, Enterprising, Conventional.
    - **Why:** The strongest early signal for career exploration and filtering options. Validated for education/career planning. [O*NET Resource Center+1](https://www.onetcenter.org/reports/IP_Manual.html?utm_source=chatgpt.com)
    - **UX:** 30–36 Likert items (or 6×5 forced-choice tiles).
    - **Output → Matching:** Normalize to 0–100; map to `interest_*` features; weight heavily in first-pass matching against O*NET clusters.
2. **Big-Five Short (IPIP-50 or IPIP-NEO-120 light)**
    - **Measures:** Extraversion, Agreeableness, Conscientiousness, Emotional Stability, Intellect/Openness; optional facet signals.
    - **Why:** Open, well-validated public-domain personality markers suitable for youth; predicts preference for work styles. [PMC+2IPIP+2](https://pmc.ncbi.nlm.nih.gov/articles/PMC4768534/?utm_source=chatgpt.com)
    - **UX:** 50 items (≈6–7 min) or staged 2×25.
    - **Output → Matching:** Map to `trait_*` (e.g., conscientiousness → grit proxy; openness → creativity/curiosity); inform work-style filters using O*NET “Work Styles.” [O*NET OnLine+1](https://www.onetonline.org/find/descriptor/browse/1.C?utm_source=chatgpt.com)
3. **Mindset & Grit Mini**
    - **Measures:** Growth mindset (Implicit Theories of Intelligence) + Grit (perseverance & consistency).
    - **Why:** Predicts persistence, response to challenge, and long-term engagement with learning paths. [Frontiers+2Gwern+2](https://www.frontiersin.org/journals/psychology/articles/10.3389/fpsyg.2021.593715/full?utm_source=chatgpt.com)
    - **UX:** 6-item Mindset + 8-item Short Grit (≈2–3 min).
    - **Output → Matching:** Map to `trait_grit`, `trait_adaptability`, `trait_curiosity`; use as boosters in ranking and in roadmap pacing.

---

## Tier 2 — 10–15-minute “Core Battery” (unlock after onboarding)

1. **Strengths Profile (VIA Youth short)**
    - **Measures:** Character strengths (e.g., kindness, creativity, leadership).
    - **Why:** Strengths-based guidance improves engagement and wellbeing; VIA has youth versions and clear usage guidance. [VIA Character+2VIA Character+2](https://www.viacharacter.org/pdf/2019VIASurveyQuestionsConsentForm.pdf?utm_source=chatgpt.com)
    - **UX:** 24–48 items; present as cards with relatable examples.
    - **Output → Matching:** Map creativity/leadership/communication to `trait_creativity/leadership/communication` and use for narrative feedback.
2. **Situational Judgment Test (SJT) — Collaboration & Communication**
    - **Measures:** Teamwork, conflict handling, help-seeking, persuasion.
    - **Why:** Low-stakes, realistic choices predict social style at work; complements self-report bias.
    - **UX:** 6–8 animated scenarios, choose “most/least effective.”
    - **Output → Matching:** Update `trait_collaboration`, `trait_communication`, `trait_emotional_intelligence`.
3. **Values & Work Preferences**
    - **Measures:** Autonomy vs. structure, people vs. data vs. things, indoor/outdoor, pace, risk tolerance.
    - **Why:** Filters out poor-fit careers even when skills/interests align.
    - **UX:** 12–18 slider items.
    - **Output → Matching:** Acts as a **hard filter** and tie-breaker in ranking and roadmap suggestions.

---

## Tier 3 — Skill “Micro-Games” (5–7 minutes total, snackable)

1. **Processing Speed & Attention**
    - **Measures:** Symbol search/tap targets; sustained attention.
    - **Why:** Foundational to learning curves; links to academic performance. [englelab.gatech.edu+1](https://englelab.gatech.edu/articles/2023/Mashburn%20et%20al.%20%282023%29_Accepted.pdf?utm_source=chatgpt.com)
    - **Output → Matching:** `cognition_attention`; informs pacing (shorter tasks if low; advanced paths if high).
2. **Working Memory (2-back or sequence recall)**
    - **Measures:** Updating/holding information.
    - **Output → Matching:** `cognition_memory`; boosts data-heavy careers.
3. **Spatial Reasoning (mental rotation)**
    - **Measures:** Spatial visualization.
    - **Output → Matching:** `cognition_spatial` (engineering, design). [englelab.gatech.edu](https://englelab.gatech.edu/articles/2023/Mashburn%20et%20al.%20%282023%29_Accepted.pdf?utm_source=chatgpt.com)
4. **Verbal & Quantitative Reasoning (mini)**
- **Measures:** Analogies/vocab; number series/word problems.
- **Output → Matching:** `cognition_verbal`, `cognition_quantitative`, `cognition_problem_solving`.
1. **Creativity Divergent Thinking**
- **Measures:** Alternate Uses (AU) task variant (fluency, originality).
- **Output → Matching:** `trait_creativity`, `interest_creative`; great for design/entrepreneurship.

---

## How it rolls up into your data model

- **From tests/games → features:** Each module emits **normalized 0–100** scores for specific `features.key` (your 22-D space).
- **Aggregation:** Use your existing **EMA** (`upsert_feature_ema`) with quality weights (short → lower weight; repeated plays → higher).
- **Completeness & Progress:** `get_profile_completeness(uid)` drives the dashboard ring.
- **Matching:** Convert user vector via `get_user_feature_vector(uid)` → cosine similarity vs. `careers.vector`; adjust by **Mindset/Grit** for confidence; enforce **Values** as filters.
- **Narrative feedback:** Pull **top_features** per matched career; reference O*NET descriptors for “why this fits.” [O*NET Resource Center+1](https://www.onetcenter.org/content.html?utm_source=chatgpt.com)

---

## Runtime & UX guidance

- **Onboarding (≤10 min):** RIASEC + Big-Five short + Mindset/Grit mini.
- **Week 1 (opt-in):** Strengths + SJT + 2 micro-games.
- **Ongoing:** Rotate micro-games for fresh telemetry; reward streaks; re-sample interests quarterly.

---

## Fairness, validity, and localization

- **Use public-domain inventories** where possible (IPIP, O*NET Interest Profiler). [IPIP+1](https://ipip.ori.org/A%20broad-bandwidth%20inventory.pdf?utm_source=chatgpt.com)
- **Youth-appropriate language**; Arabic/English parallel forms.
- **Bias controls:** Prefer **situational** and **behavioral** items over purely self-report; monitor subgroup performance drift.
- **Parental consent** logged in `consents`.

---

## What to build first (MVP order)

1. **RIASEC mini + Big-Five 50 + Mindset/Grit mini** (fast impact on matching). [Gwern+3O*NET Resource Center+3PMC+3](https://www.onetcenter.org/reports/IP_Manual.html?utm_source=chatgpt.com)
2. **Two micro-games** (Processing Speed, Spatial). [englelab.gatech.edu](https://englelab.gatech.edu/articles/2023/Mashburn%20et%20al.%20%282023%29_Accepted.pdf?utm_source=chatgpt.com)
3. **SJT for Collaboration** and **Values** filter.
4. **VIA strengths** as an enhancement for richer narratives. [VIA Character](https://www.viacharacter.org/pdf/2019VIASurveyQuestionsConsentForm.pdf?utm_source=chatgpt.com)

## where to get the tests and how to apply them

# What to implement (and where to get items)

## 1) Interests (RIASEC) — O*NET Interest Profiler

- **Source (public domain):** O*NET Interest Profiler (Mini-IP and full). Items + scoring are free to use. [O*NET Center+1](https://www.onetcenter.org/IP.html?utm_source=chatgpt.com)
- **Why:** Fast, validated signal for early career narrowing.
- **How to implement**
    1. **Seed items**: create a `quiz_items` batch for 6 scales (R, I, A, S, E, C).
    2. **UI**: Likert tiles (Very much / Not at all). 30–60 items depending on time budget.
    3. **Scoring**: sum (or mean) per scale → normalize to **0–100** → map to:
        - `interest_practical` (R), `interest_analytical` (I), `interest_creative` (A), `interest_social` (S), `interest_enterprising` (E), `interest_conventional` (C).
    4. **Persist**: write `assessments` + `assessment_items`; send per-feature batch means to your Edge Function → `user_feature_scores` via EMA.
    5. **Use in matching**: weight these features higher in first-pass ranking against `careers.vector`.
- **References:** O*NET official Interest Profiler resource center; O*NET OnLine content model for later mapping to occupations. [O*NET Center+2O*NET OnLine+2](https://www.onetcenter.org/IP.html?utm_source=chatgpt.com)

---

## 2) Personality (Big Five, short) — IPIP

- **Source (public domain):** IPIP official site; IPIP-50 and Mini-IPIP with scoring keys. **No permission or fee required** (copy/translate allowed). [IPIP+2IPIP+2](https://ipip.ori.org/?utm_source=chatgpt.com)
- **Why:** Stable, open-licensed work-style predictors.
- **How to implement**
    1. **Seed items**: import IPIP-50; mark reverse-keyed items in `quiz_items.direction = -1`.
    2. **UI**: 5-point Likert; show progress segments (10 items × 5 traits).
    3. **Scoring**: per trait (E, A, C, N*, O); transform to features:
        - `trait_conscientiousness`, `trait_emotional_intelligence` (from reversed Neuroticism), `trait_openness` (also feeds `trait_creativity` with a mapping weight), `trait_collaboration` (from Agreeableness), and `trait_communication` (blend of E + verbal cues).
    4. **Persist/aggregate**: same pipeline → normalize to 0–100 → EMA.

---

## 3) Grit + Growth Mindset (mini scales)

- **Grit**: items + scoring publicly posted by Duckworth; for **commercial uses**, review licensing or contact the lab. [Angela Duckworth+2McNair Scholars+2](https://angeladuckworth.com/grit-scale/?utm_source=chatgpt.com)
- **Growth Mindset**: short scales (3–8 items) published in open references (SPARQ summaries). Original materials by Dweck may require permissions for some uses; the SPARQ tools give youth-friendly wording. [SparqTools+1](https://sparqtools.org/mobility-measure/growth-mindset-scale/?utm_source=chatgpt.com)
- **How to implement**
    1. **Seed**: add 10–12 Grit and 3–8 Mindset items to `quiz_items`.
    2. **Scoring**: reverse-code specified items; average → 0–100.
    3. **Map**: `trait_grit`, `trait_adaptability`, `trait_curiosity`.
    4. **Use**: boost confidence in matches and pace in roadmaps.

> Licensing note: IPIP and O*NET are public domain (safe). For Grit and Dweck scales, confirm rights for commercial deployment. If in doubt, keep a “research/pilot only” toggle until cleared.
>

---

## 4) Values & Work Preferences (custom, but anchored to O*NET Work Styles)

- **Source:** Use O*NET “Work Styles” descriptors to author ~12 sliders (autonomy, persistence, cooperation, stress tolerance, leadership, etc.). [O*NET OnLine](https://www.onetonline.org/find/descriptor/browse/1.C?utm_source=chatgpt.com)
- **How to implement**
    1. Author neutral, youth-friendly items aligned to Work Styles.
    2. Score to 0–100; store as features: `trait_leadership`, `trait_communication`, `trait_conscientiousness`, etc.
    3. Use as **filters** (hard or soft) in the career results.

---

## 5) Skill Micro-games (open tasks)

- **Working Memory (n-back):** open-source implementations exist; adapt logic and scoring. [GitHub+2GitHub+2](https://github.com/iRB-Lab/N-Back?utm_source=chatgpt.com)
- **Spatial (mental rotation):** open libraries + open stimuli sets (e.g., PsyToolkit task, magpie mental rotation). [PsyToolkit+1](https://www.psytoolkit.org/experiment-library/mentalrotation.html?utm_source=chatgpt.com)
- **Attention/Processing Speed:** simple symbol search / go-no-go you author yourself (no license issues).
- **How to implement**
    1. **Telemetry**: capture accuracy, latency distributions, and level achieved.
    2. **Scoring**:
        - `accuracy = correct/total`,
        - `speed_norm = clamp(target_ms / user_ms, 0, 1)`,
        - `stability = 1 - (stdev(rt)/cap)`.
        - Compose per feature, e.g., `problem_solving = 0.5*accuracy + 0.3*speed_norm + 0.2*stability`.
    3. **Map**: `cognition_memory` (n-back), `cognition_spatial` (rotation), `cognition_attention` (speed/attention), `cognition_problem_solving`.
    4. **Normalize** to 0–100 using your `feature_cohort_stats` (z-score → scale) and upsert via EMA.

---

# Concrete implementation steps (code & data flow)

1. **Authoring/Seeding**
    - Create CSV/JSON seed files for each battery:
        - `riasec_en.json` / `riasec_ar.json`
        - `ipip50_en.json` / `ipip50_ar.json`
        - `grit_mini.json`, `mindset_mini.json`
        - `values_workstyles.json`
    - Write a one-off Dart or SQL loader that upserts into `quiz_items(item_id, feature_key, direction, weight, question_text)`.
2. **Flutter UI**
    - **Screens**: `/discover/tests/:slug` renders paged items (10 per page) with cached local state.
    - **Anti-fatigue**: show ETA + save/continue; shuffle within trait blocks; keep reverse-coded items mixed.
    - **Localization**: load `_ar.json` when `profiles.locale = 'ar'`.
3. **Client-side scoring**
    - After submission, compute **per-feature batch means (0–100)**.
    - Insert a row into `assessments` (type `quiz`), optionally batch insert `assessment_items` (for analytics).
    - Invoke Edge Function `update_profile_and_match` with:

        ```json
        {
          "user_id": "<uid>",
          "batch_features": [
            {"key":"interest_analytical","mean":72,"n":8,"quality":0.8},
            {"key":"trait_grit","mean":65,"n":10,"quality":0.7}
          ]
        }

        ```

        (You already have this contract in your pipeline.)

4. **Server-side aggregation + matching**
    - Edge Function calls `upsert_feature_ema` per feature; then `get_user_feature_vector(uid)`; compute cosine vs `careers.vector`; upsert `user_career_matches` with `top_features`.
    - Return `{ok:true, top:[...]}` for UI refresh.
5. **Dashboard & Careers**
    - **Progress ring** = `get_profile_completeness(uid)`.
    - **Top careers** = join `user_career_matches` + `careers`.
    - Show **Why this fits** = top 3 features (from `top_features` JSON).

---

# Item sourcing: exact links & guidance

- **O*NET Interest Profiler (Mini-IP + full, public domain)** — items & manuals live here; use My Next Move copy as wording reference. [O*NET Center+1](https://www.onetcenter.org/IP.html?utm_source=chatgpt.com)
- **IPIP (Big Five)** — official IPIP site; includes IPIP-50 questionnaire & scoring; explicitly **public domain** (copy/edit/translate allowed). [IPIP+1](https://ipip.ori.org/?utm_source=chatgpt.com)
- **Grit** — Duckworth’s Grit Scale text and scoring; verify licensing for commercial deployment. [Angela Duckworth+1](https://angeladuckworth.com/grit-scale/?utm_source=chatgpt.com)
- **Growth Mindset** — short youth-appropriate scales (SPARQ summaries). Check permissions if using verbatim wording from copyrighted sources. [SparqTools+1](https://sparqtools.org/mobility-measure/growth-mindset-scale/?utm_source=chatgpt.com)
- **Work Styles** — use O*NET Work Styles list to author your Values items; map directly to your features. [O*NET OnLine](https://www.onetonline.org/find/descriptor/browse/1.C?utm_source=chatgpt.com)
- **Skill games (open)** —
    - n-back: open implementations you can study/port. [GitHub+2GitHub+2](https://github.com/iRB-Lab/N-Back?utm_source=chatgpt.com)
    - mental rotation: task templates + stimulus sets. [PsyToolkit+1](https://www.psytoolkit.org/experiment-library/mentalrotation.html?utm_source=chatgpt.com)

---

# Scoring & normalization (copy/paste rules)

- **Likert item → feature delta**

    `item_score = weight * direction * (likert - 3) / 2`  // → [-1..1]

- **Batch feature mean (0–100)**

    Convert summed deltas to a 0–100 range per feature (min–max initially), then switch to **z-score** once `feature_cohort_stats.n_samples ≥ 200`:

    `z = (raw - mean) / std_dev` → `score_norm = clamp(50 + 10*z, 0, 100)`

- **EMA aggregation (server)**

    Call `upsert_feature_ema(uid, key, value=score_norm, weight=quality, n=items_count)`; alpha clamped [0.15..0.7].

- **Progress**

    `progress = mean_i( min(1, n_i/12) ) * 100`.


---

# Compliance & quality

- **Public-domain first**: IPIP & O*NET are safe for production. [IPIP+1](https://ipip.ori.org/?utm_source=chatgpt.com)
- **Permission-gated**: Grit/Mindset/VIA—great constructs, but check their terms (or paraphrase/author equivalents anchored on their constructs). [VIA Character+3Angela Duckworth+3SparqTools+3](https://angeladuckworth.com/grit-scale/?utm_source=chatgpt.com)
- **Bias control**: Prefer SJTs and game telemetry to offset self-report bias.
- **Localization**: Back-translate Arabic versions; pilot for reading level (grade 6–9).
- **Data privacy**: Keep raw `assessment_items` optional; store only feature aggregates for production if storage minimization is required.

---

## Fast path (what to ship this week)

1. **Mini-IP (RIASEC)** + **IPIP-50** (EN/AR) → full pipeline. [O*NET Center+1](https://www.onetcenter.org/IP.html?utm_source=chatgpt.com)
2. **2 micro-games** (n-back + mental rotation) with simple scoring and cohort z-scores. [GitHub+1](https://github.com/baljo/n-back?utm_source=chatgpt.com)
3. **Values (Work Styles)**: 12 sliders authored from O*NET descriptors; apply as filters. [O*NET OnLine](https://www.onetonline.org/find/descriptor/browse/1.C?utm_source=chatgpt.com)

## tests json implementations

# 1) JSON Seeds (put in `assets/assessments/`)

## 1.1 Mini-IP RIASEC (30 items total; 5 per scale × 6 scales)

### `assets/assessments/riasec_mini_en.json`

```json
{
  "meta": { "instrument": "Mini-IP RIASEC", "lang": "en", "version": "1.0", "likert": ["Not at all", "A little", "Somewhat", "Quite a bit", "Very much"] },
  "mapping": {
    "R": "interest_practical",
    "I": "interest_analytical",
    "A": "interest_creative",
    "S": "interest_social",
    "E": "interest_enterprising",
    "C": "interest_conventional"
  },
  "items": [
    { "id": "R1", "scale": "R", "text": "Fix or assemble mechanical things" },
    { "id": "R2", "scale": "R", "text": "Work with tools or equipment" },
    { "id": "R3", "scale": "R", "text": "Build or repair objects" },
    { "id": "R4", "scale": "R", "text": "Operate machines or gadgets" },
    { "id": "R5", "scale": "R", "text": "Do hands-on outdoor tasks" },

    { "id": "I1", "scale": "I", "text": "Solve science or math problems" },
    { "id": "I2", "scale": "I", "text": "Figure out how things work" },
    { "id": "I3", "scale": "I", "text": "Analyze patterns or data" },
    { "id": "I4", "scale": "I", "text": "Do experiments and test ideas" },
    { "id": "I5", "scale": "I", "text": "Learn deeply about a complex topic" },

    { "id": "A1", "scale": "A", "text": "Create art, music, or designs" },
    { "id": "A2", "scale": "A", "text": "Express ideas through writing or media" },
    { "id": "A3", "scale": "A", "text": "Imagine new concepts or stories" },
    { "id": "A4", "scale": "A", "text": "Take creative photos or videos" },
    { "id": "A5", "scale": "A", "text": "Experiment with styles and aesthetics" },

    { "id": "S1", "scale": "S", "text": "Help people learn or improve" },
    { "id": "S2", "scale": "S", "text": "Support others emotionally" },
    { "id": "S3", "scale": "S", "text": "Volunteer for community service" },
    { "id": "S4", "scale": "S", "text": "Coach, mentor, or tutor" },
    { "id": "S5", "scale": "S", "text": "Work closely with people" },

    { "id": "E1", "scale": "E", "text": "Start projects and lead teams" },
    { "id": "E2", "scale": "E", "text": "Sell, pitch, or persuade" },
    { "id": "E3", "scale": "E", "text": "Organize events or initiatives" },
    { "id": "E4", "scale": "E", "text": "Take calculated risks" },
    { "id": "E5", "scale": "E", "text": "Turn ideas into real ventures" },

    { "id": "C1", "scale": "C", "text": "Keep records neat and organized" },
    { "id": "C2", "scale": "C", "text": "Follow clear rules and procedures" },
    { "id": "C3", "scale": "C", "text": "Work with spreadsheets or forms" },
    { "id": "C4", "scale": "C", "text": "Pay attention to details" },
    { "id": "C5", "scale": "C", "text": "Plan routines and schedules" }
  ]
}

```

### `assets/assessments/riasec_mini_ar.json`

```json
{
  "meta": { "instrument": "Mini-IP RIASEC", "lang": "ar", "version": "1.0", "likert": ["أبدًا", "قليلًا", "إلى حد ما", "كثيرًا", "جداً"] },
  "mapping": {
    "R": "interest_practical",
    "I": "interest_analytical",
    "A": "interest_creative",
    "S": "interest_social",
    "E": "interest_enterprising",
    "C": "interest_conventional"
  },
  "items": [
    { "id": "R1", "scale": "R", "text": "إصلاح أو تركيب الأشياء الميكانيكية" },
    { "id": "R2", "scale": "R", "text": "العمل بالأدوات أو المعدات" },
    { "id": "R3", "scale": "R", "text": "بناء أو تصليح الأشياء" },
    { "id": "R4", "scale": "R", "text": "تشغيل الآلات أو الأجهزة" },
    { "id": "R5", "scale": "R", "text": "مهام عملية في الهواء الطلق" },

    { "id": "I1", "scale": "I", "text": "حل مسائل في العلوم أو الرياضيات" },
    { "id": "I2", "scale": "I", "text": "اكتشاف كيفية عمل الأشياء" },
    { "id": "I3", "scale": "I", "text": "تحليل الأنماط أو البيانات" },
    { "id": "I4", "scale": "I", "text": "إجراء تجارب واختبار أفكار" },
    { "id": "I5", "scale": "I", "text": "التعمّق في موضوع معقد" },

    { "id": "A1", "scale": "A", "text": "ابتكار فن أو موسيقى أو تصاميم" },
    { "id": "A2", "scale": "A", "text": "التعبير عن الأفكار بالكتابة أو الوسائط" },
    { "id": "A3", "scale": "A", "text": "تخيّل مفاهيم أو قصص جديدة" },
    { "id": "A4", "scale": "A", "text": "التصوير الإبداعي أو صناعة الفيديو" },
    { "id": "A5", "scale": "A", "text": "التجريب في الأسلوب والجماليات" },

    { "id": "S1", "scale": "S", "text": "مساعدة الآخرين على التعلّم أو التطور" },
    { "id": "S2", "scale": "S", "text": "دعم الآخرين عاطفيًا" },
    { "id": "S3", "scale": "S", "text": "التطوّع لخدمة المجتمع" },
    { "id": "S4", "scale": "S", "text": "التدريب أو الإرشاد أو الدروس الخصوصية" },
    { "id": "S5", "scale": "S", "text": "العمل عن قرب مع الناس" },

    { "id": "E1", "scale": "E", "text": "بدء المشاريع وقيادة الفرق" },
    { "id": "E2", "scale": "E", "text": "البيع أو العرض والإقناع" },
    { "id": "E3", "scale": "E", "text": "تنظيم الفعاليات والمبادرات" },
    { "id": "E4", "scale": "E", "text": "اتخاذ مخاطر محسوبة" },
    { "id": "E5", "scale": "E", "text": "تحويل الأفكار إلى مبادرات واقعية" },

    { "id": "C1", "scale": "C", "text": "حفظ السجلات بشكل منظم" },
    { "id": "C2", "scale": "C", "text": "اتباع قواعد وإجراءات واضحة" },
    { "id": "C3", "scale": "C", "text": "العمل على جداول البيانات أو النماذج" },
    { "id": "C4", "scale": "C", "text": "الانتباه للتفاصيل الدقيقة" },
    { "id": "C5", "scale": "C", "text": "تخطيط الروتين والجداول" }
  ]
}

```

---

## 1.2 IPIP-50 (10 items × 5 traits)

> Traits: Extraversion (E), Agreeableness (A), Conscientiousness (C), Emotional Stability (ES, i.e., reverse of Neuroticism), Intellect/Openness (O).
>
>
> `reverse: true` indicates reverse-keyed items.
>
> We’ll map traits → your features later in the scorer.
>

### `assets/assessments/ipip50_en.json`

```json
{
  "meta": { "instrument": "IPIP-50", "lang": "en", "version": "1.0", "likert": ["Very inaccurate", "Moderately inaccurate", "Neither", "Moderately accurate", "Very accurate"] },
  "items": [
    { "id": "E1", "trait": "E", "text": "Am the life of the party" },
    { "id": "E2", "trait": "E", "text": "Feel comfortable around people" },
    { "id": "E3", "trait": "E", "text": "Start conversations" },
    { "id": "E4", "trait": "E", "text": "Talk to a lot of different people at parties" },
    { "id": "E5", "trait": "E", "text": "Don't mind being the center of attention" },
    { "id": "E6", "trait": "E", "text": "Am quiet around strangers", "reverse": true },
    { "id": "E7", "trait": "E", "text": "Have little to say", "reverse": true },
    { "id": "E8", "trait": "E", "text": "Don't like to draw attention to myself", "reverse": true },
    { "id": "E9", "trait": "E", "text": "Keep in the background", "reverse": true },
    { "id": "E10", "trait": "E", "text": "Find it difficult to approach others", "reverse": true },

    { "id": "A1", "trait": "A", "text": "Have a soft heart" },
    { "id": "A2", "trait": "A", "text": "Am interested in people" },
    { "id": "A3", "trait": "A", "text": "Take time out for others" },
    { "id": "A4", "trait": "A", "text": "Feel others’ emotions" },
    { "id": "A5", "trait": "A", "text": "Make people feel at ease" },
    { "id": "A6", "trait": "A", "text": "Am not really interested in others", "reverse": true },
    { "id": "A7", "trait": "A", "text": "Insult people", "reverse": true },
    { "id": "A8", "trait": "A", "text": "Am not interested in other people’s problems", "reverse": true },
    { "id": "A9", "trait": "A", "text": "Feel little concern for others", "reverse": true },
    { "id": "A10", "trait": "A", "text": "Am hard to get to know", "reverse": true },

    { "id": "C1", "trait": "C", "text": "Am always prepared" },
    { "id": "C2", "trait": "C", "text": "Pay attention to details" },
    { "id": "C3", "trait": "C", "text": "Get chores done right away" },
    { "id": "C4", "trait": "C", "text": "Like order" },
    { "id": "C5", "trait": "C", "text": "Follow a schedule" },
    { "id": "C6", "trait": "C", "text": "Leave my belongings around", "reverse": true },
    { "id": "C7", "trait": "C", "text": "Make a mess of things", "reverse": true },
    { "id": "C8", "trait": "C", "text": "Often forget to put things back in their proper place", "reverse": true },
    { "id": "C9", "trait": "C", "text": "Shirk my duties", "reverse": true },
    { "id": "C10", "trait": "C", "text": "Waste my time", "reverse": true },

    { "id": "ES1", "trait": "ES", "text": "Am relaxed most of the time" },
    { "id": "ES2", "trait": "ES", "text": "Seldom feel blue" },
    { "id": "ES3", "trait": "ES", "text": "Feel secure, comfortable with myself" },
    { "id": "ES4", "trait": "ES", "text": "Rarely get irritated" },
    { "id": "ES5", "trait": "ES", "text": "Remain calm under pressure" },
    { "id": "ES6", "trait": "ES", "text": "Get stressed out easily", "reverse": true },
    { "id": "ES7", "trait": "ES", "text": "Often feel blue", "reverse": true },
    { "id": "ES8", "trait": "ES", "text": "Worry about things", "reverse": true },
    { "id": "ES9", "trait": "ES", "text": "Get upset easily", "reverse": true },
    { "id": "ES10", "trait": "ES", "text": "Change my mood a lot", "reverse": true },

    { "id": "O1", "trait": "O", "text": "Have a vivid imagination" },
    { "id": "O2", "trait": "O", "text": "Have excellent ideas" },
    { "id": "O3", "trait": "O", "text": "Am quick to understand things" },
    { "id": "O4", "trait": "O", "text": "Use difficult words" },
    { "id": "O5", "trait": "O", "text": "Spend time reflecting on things" },
    { "id": "O6", "trait": "O", "text": "Am not interested in abstract ideas", "reverse": true },
    { "id": "O7", "trait": "O", "text": "Do not have a good imagination", "reverse": true },
    { "id": "O8", "trait": "O", "text": "Have difficulty understanding abstract ideas", "reverse": true },
    { "id": "O9", "trait": "O", "text": "Avoid philosophical discussions", "reverse": true },
    { "id": "O10", "trait": "O", "text": "Am not interested in art", "reverse": true }
  ]
}

```

### `assets/assessments/ipip50_ar.json`

```json
{
  "meta": { "instrument": "IPIP-50", "lang": "ar", "version": "1.0", "likert": ["غير دقيق جدًا", "غير دقيق إلى حد ما", "محايد", "دقيق إلى حد ما", "دقيق جدًا"] },
  "items": [
    { "id": "E1", "trait": "E", "text": "أكون محور الاهتمام في المناسبات" },
    { "id": "E2", "trait": "E", "text": "أشعر بالراحة بين الناس" },
    { "id": "E3", "trait": "E", "text": "أبدأ المحادثات" },
    { "id": "E4", "trait": "E", "text": "أتحدث مع أشخاص كثيرين في التجمعات" },
    { "id": "E5", "trait": "E", "text": "لا أمانع أن أكون محط الأنظار" },
    { "id": "E6", "trait": "E", "text": "أكون هادئًا مع الغرباء", "reverse": true },
    { "id": "E7", "trait": "E", "text": "نادراً ما يكون لدي ما أقوله", "reverse": true },
    { "id": "E8", "trait": "E", "text": "لا أحب لفت الانتباه إليّ", "reverse": true },
    { "id": "E9", "trait": "E", "text": "أفضل البقاء في الخلفية", "reverse": true },
    { "id": "E10", "trait": "E", "text": "أجد صعوبة في الاقتراب من الآخرين", "reverse": true },

    { "id": "A1", "trait": "A", "text": "قلبي رقيق ومتفهّم" },
    { "id": "A2", "trait": "A", "text": "مهتم بالناس" },
    { "id": "A3", "trait": "A", "text": "أخصص وقتًا لمساعدة الآخرين" },
    { "id": "A4", "trait": "A", "text": "أشعر بمشاعر الآخرين" },
    { "id": "A5", "trait": "A", "text": "أجعل الناس يشعرون بالراحة" },
    { "id": "A6", "trait": "A", "text": "لست مهتمًا حقًا بالآخرين", "reverse": true },
    { "id": "A7", "trait": "A", "text": "أهين الناس", "reverse": true },
    { "id": "A8", "trait": "A", "text": "لست مهتمًا بمشاكل الآخرين", "reverse": true },
    { "id": "A9", "trait": "A", "text": "أشعر باهتمام قليل تجاه الآخرين", "reverse": true },
    { "id": "A10", "trait": "A", "text": "من الصعب التقرّب مني", "reverse": true },

    { "id": "C1", "trait": "C", "text": "أستعد دائمًا بشكل جيد" },
    { "id": "C2", "trait": "C", "text": "أنتبه للتفاصيل" },
    { "id": "C3", "trait": "C", "text": "أنجز المهام فورًا" },
    { "id": "C4", "trait": "C", "text": "أحب النظام والترتيب" },
    { "id": "C5", "trait": "C", "text": "أتبع جدولًا زمنيًا" },
    { "id": "C6", "trait": "C", "text": "أترك أغراضي مبعثرة", "reverse": true },
    { "id": "C7", "trait": "C", "text": "أفسد الأمور", "reverse": true },
    { "id": "C8", "trait": "C", "text": "كثيرًا ما أنسى إعادة الأشياء إلى مكانها", "reverse": true },
    { "id": "C9", "trait": "C", "text": "أتقاعس عن أداء واجباتي", "reverse": true },
    { "id": "C10", "trait": "C", "text": "أضيّع وقتي", "reverse": true },

    { "id": "ES1", "trait": "ES", "text": "أشعر بالاسترخاء معظم الوقت" },
    { "id": "ES2", "trait": "ES", "text": "نادرًا ما أشعر بالحزن" },
    { "id": "ES3", "trait": "ES", "text": "أشعر بالأمان والارتياح نحو نفسي" },
    { "id": "ES4", "trait": "ES", "text": "نادرًا ما أنزعج" },
    { "id": "ES5", "trait": "ES", "text": "أبقى هادئًا تحت الضغط" },
    { "id": "ES6", "trait": "ES", "text": "أتوتر بسهولة", "reverse": true },
    { "id": "ES7", "trait": "ES", "text": "أشعر بالحزن كثيرًا", "reverse": true },
    { "id": "ES8", "trait": "ES", "text": "أقلق بشأن الأمور", "reverse": true },
    { "id": "ES9", "trait": "ES", "text": "أنزعج بسهولة", "reverse": true },
    { "id": "ES10", "trait": "ES", "text": "يتغير مزاجي كثيرًا", "reverse": true },

    { "id": "O1", "trait": "O", "text": "خيالي واسع" },
    { "id": "O2", "trait": "O", "text": "أمتلك أفكارًا ممتازة" },
    { "id": "O3", "trait": "O", "text": "أفهم الأشياء بسرعة" },
    { "id": "O4", "trait": "O", "text": "أستخدم كلمات معقدة" },
    { "id": "O5", "trait": "O", "text": "أقضي وقتًا في التأمل والتفكير" },
    { "id": "O6", "trait": "O", "text": "لست مهتمًا بالأفكار المجردة", "reverse": true },
    { "id": "O7", "trait": "O", "text": "لا أمتلك خيالاً جيدًا", "reverse": true },
    { "id": "O8", "trait": "O", "text": "أجد صعوبة في فهم الأفكار المجردة", "reverse": true },
    { "id": "O9", "trait": "O", "text": "أتجنب النقاشات الفلسفية", "reverse": true },
    { "id": "O10", "trait": "O", "text": "لست مهتمًا بالفن", "reverse": true }
  ]
}

```

---

# 2) Dart Seeder (load JSON → upsert `quiz_items`)

> Add these files under lib/seed/. Ensure assets/assessments/* are listed in pubspec.yaml under flutter/assets:.
>

```dart
// lib/seed/quiz_item_seeder.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:supabase_flutter/supabase_flutter.dart';

class QuizItemSeeder {
  final SupabaseClient supa;
  QuizItemSeeder(this.supa);

  /// Load a Mini-IP RIASEC JSON and upsert into `quiz_items`
  Future<void> seedRiasec(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    final jsonMap = json.decode(raw) as Map<String, dynamic>;
    final mapping = Map<String, String>.from(jsonMap['mapping']);
    final items = List<Map<String, dynamic>>.from(jsonMap['items']);

    final rows = items.map((it) {
      final featureKey = mapping[it['scale']]!;
      return {
        'item_id': it['id'],
        'feature_key': featureKey,
        'direction': 1.0,
        'weight': 1.0,
        'question_text': it['text'],
        'metadata': {
          'instrument': 'Mini-IP RIASEC',
          'scale': it['scale'],
          'lang': jsonMap['meta']['lang']
        }
      };
    }).toList();

    await _bulkUpsert(rows);
  }

  /// Load IPIP-50 JSON and upsert into `quiz_items`
  Future<void> seedIpip50(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    final jsonMap = json.decode(raw) as Map<String, dynamic>;
    final items = List<Map<String, dynamic>>.from(jsonMap['items']);
    final lang = jsonMap['meta']['lang'];

    // Trait -> feature mappings (tweak weights later if desired)
    String featureForTrait(String t) {
      switch (t) {
        case 'E': return 'trait_communication';      // proxy for social/expressive
        case 'A': return 'trait_collaboration';
        case 'C': return 'trait_conscientiousness';
        case 'ES': return 'trait_emotional_intelligence'; // inverse of Neuroticism
        case 'O': return 'trait_openness';
        default: return 'trait_openness';
      }
    }

    final rows = items.map((it) {
      final reverse = (it['reverse'] == true);
      return {
        'item_id': it['id'],
        'feature_key': featureForTrait(it['trait']),
        'direction': reverse ? -1.0 : 1.0,
        'weight': 1.0,
        'question_text': it['text'],
        'metadata': {
          'instrument': 'IPIP-50',
          'trait': it['trait'],
          'reverse': reverse,
          'lang': lang
        }
      };
    }).toList();

    await _bulkUpsert(rows);
  }

  Future<void> _bulkUpsert(List<Map<String, dynamic>> rows) async {
    // Split into chunks to avoid payload limits
    const chunk = 200;
    for (int i = 0; i < rows.length; i += chunk) {
      final part = rows.sublist(i, i + chunk > rows.length ? rows.length : i + chunk);
      final res = await supa.from('quiz_items').upsert(part);
      if (res.error != null) {
        throw Exception('Seed upsert error: ${res.error!.message}');
      }
    }
  }
}

```

**Usage (one-time in a dev admin screen or debug menu):**

```dart
// somewhere in a debug/admin-only command
final seeder = QuizItemSeeder(Supabase.instance.client);
await seeder.seedRiasec('assets/assessments/riasec_mini_en.json');
await seeder.seedRiasec('assets/assessments/riasec_mini_ar.json');
await seeder.seedIpip50('assets/assessments/ipip50_en.json');
await seeder.seedIpip50('assets/assessments/ipip50_ar.json');

```

---

# 3) Dart Scoring Utilities

These helpers aggregate Likert answers into **feature batch means (0–100)** using your rule:

```
item_score = weight * direction * (likert - 3) / 2   // -> [-1..1]

```

Then min–max scale per feature for MVP (or plug your cohort z-scores when available).

```dart
// lib/scoring/quiz_scoring.dart
class QuizResponse {
  final String itemId;
  final String featureKey;  // resolved from quiz_items
  final double direction;   // +1 or -1
  final double weight;      // ≥ 0
  final int likert;         // 1..5
  QuizResponse({
    required this.itemId,
    required this.featureKey,
    required this.direction,
    required this.weight,
    required this.likert,
  });
}

class BatchFeatureScore {
  final String key;
  final double mean01; // 0..1
  final int n;
  final double quality; // 0..1
  BatchFeatureScore(this.key, this.mean01, this.n, this.quality);
}

class QuizScoring {
  /// Convert Likert answers to per-feature mean on [0..1]
  static List<BatchFeatureScore> computeBatch(List<QuizResponse> answers) {
    final sums = <String, double>{};
    final counts = <String, int>{};

    for (final r in answers) {
      final unit = (r.likert - 3) / 2.0;     // [-1..1]
      final score = r.weight * r.direction * unit; // weighted
      sums[r.featureKey] = (sums[r.featureKey] ?? 0) + score;
      counts[r.featureKey] = (counts[r.featureKey] ?? 0) + 1;
    }

    // MVP: min-max map from [-1..1] average → [0..1]
    // avg in [-1,1] -> (avg + 1)/2
    final out = <BatchFeatureScore>[];
    sums.forEach((key, sum) {
      final n = counts[key]!;
      final avg = sum / n;                // [-1..1]
      final mean01 = ((avg + 1.0) / 2.0).clamp(0.0, 1.0);
      // quality heuristic: more items => higher confidence (cap at 12)
      final quality = (n / 12.0).clamp(0.3, 1.0);
      out.add(BatchFeatureScore(key, mean01, n, quality));
    });
    return out;
  }

  /// Prepare payload for Edge Function (expects 0..100)
  static List<Map<String, dynamic>> toEdgePayload(List<BatchFeatureScore> batch) {
    return batch.map((b) => {
      'key': b.key,
      'mean': (b.mean01 * 100.0),
      'n': b.n,
      'quality': b.quality,
    }).toList();
  }
}

```

---

# 4) Submit to Edge Function after a test

```dart
// lib/scoring/submit_batch.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'quiz_scoring.dart';

class BatchSubmitter {
  final SupabaseClient supa;
  BatchSubmitter(this.supa);

  Future<void> submit(List<QuizResponse> answers) async {
    final uid = supa.auth.currentUser!.id;
    final batch = QuizScoring.computeBatch(answers);
    final payload = {
      'user_id': uid,
      'batch_features': QuizScoring.toEdgePayload(batch),
    };

    final res = await supa.functions.invoke('update_profile_and_match', body: payload);
    if (res.error != null) {
      throw Exception('Edge invoke error: ${res.error!.message}');
    }
  }
}

```

---

# 5) Example: Rendering a test + collecting answers

> Fetch items from quiz_items filtered by instrument and language stored in metadata.
>

```dart
// Pseudo-flow (e.g., in a Riverpod notifier or Controller)
Future<void> runRiasecEn() async {
  final supa = Supabase.instance.client;
  final resp = await supa
      .from('quiz_items')
      .select('item_id, feature_key, direction, weight, question_text, metadata')
      .contains('metadata', {'instrument': 'Mini-IP RIASEC', 'lang': 'en'})
      .limit(60);

  if (resp.error != null) throw Exception(resp.error!.message);

  // Render UI, collect likert responses (1..5) into QuizResponse list:
  final answers = <QuizResponse>[];
  // ... push from UI callbacks:
  // answers.add(QuizResponse(itemId: ..., featureKey: ..., direction: ..., weight: ..., likert: 4));

  // After submit:
  final submitter = BatchSubmitter(supa);
  await submitter.submit(answers);
}

```

---

# 6) Where each test maps to your features

- **RIASEC**

    R→`interest_practical`, I→`interest_analytical`, A→`interest_creative`, S→`interest_social`, E→`interest_enterprising`, C→`interest_conventional`.

- **IPIP-50**

    E→`trait_communication` (and indirectly boosts `trait_leadership` in future)

    A→`trait_collaboration`

    C→`trait_conscientiousness`

    ES→`trait_emotional_intelligence` (higher ES = better regulation)

    O→`trait_openness` (you can later blend some weight into `trait_creativity`)


You can tune the trait→feature mapping weights later in your Edge Function if you want a more nuanced combination.

---

# 7) Next steps (optional, but recommended)

- Add **values/work styles** sliders as a small JSON (12 items) and treat them as **filters** at the matching step.
- After you get **200+ users**, switch normalization to your cohort z-score: use `feature_cohort_stats` and convert raw means to standardized **0–100** before calling `upsert_feature_ema`.

---


1) Flutter — Paged Assessment Screen (generic for any instrument)

File: lib/presentation/features/assessments/assessment_page.dart
Depends on your earlier code: QuizResponse, BatchSubmitter, QuizScoring.
Assumes user is authenticated and you’ve listed JSON assets in pubspec.yaml (for earlier seeding).
Uses Material 3, supports EN/AR (RTL), keyboard, and small screens.

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../scoring/quiz_scoring.dart';     // QuizResponse, QuizScoring
import '../../../scoring/submit_batch.dart';     // BatchSubmitter

/// Generic assessment page that loads items from `quiz_items` by instrument + lang,
/// renders them in pages, collects Likert-scale answers, and submits a batch.
class AssessmentPage extends StatefulWidget {
  const AssessmentPage({
    super.key,
    required this.instrument,              // e.g., "Mini-IP RIASEC" or "IPIP-50"
    required this.lang,                    // "en" or "ar"
    this.itemsPerPage = 6,                 // tweak per instrument
    this.title,
    this.subtitle,
  });

  final String instrument;
  final String lang;
  final int itemsPerPage;
  final String? title;
  final String? subtitle;

  @override
  State<AssessmentPage> createState() => _AssessmentPageState();
}

class _AssessmentPageState extends State<AssessmentPage> {
  final _supa = Supabase.instance.client;

  bool _loading = true;
  String? _error;

  // Loaded rows from quiz_items (ordered, stable)
  late List<_QuizRow> _rows;

  // item_id -> 1..5 selected value
  final Map<String, int> _answers = {};

  // simple local persistence key (optional)
  String get _persistKey =>
      'selfmap:${_supa.auth.currentUser?.id}:${widget.instrument}:${widget.lang}';

  // page controller
  late final PageController _pageController;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      // Fetch quiz items for instrument+lang. We use metadata filter.
      final resp = await _supa
          .from('quiz_items')
          .select('item_id, feature_key, direction, weight, question_text, metadata')
          .eq('metadata->>instrument', widget.instrument)
          .eq('metadata->>lang', widget.lang)
          .order('item_id', ascending: true);

      if (resp.error != null) {
        throw Exception(resp.error!.message);
      }

      final list = (resp.data as List).cast<Map<String, dynamic>>();
      if (list.isEmpty) {
        throw Exception('No items found for ${widget.instrument} (${widget.lang}).');
      }

      _rows = list.map(_QuizRow.fromDb).toList();

      // Optional: restore last partial answers from local storage (left as a TODO).
      // You can wire SharedPreferences/Hive here if you want persistence across sessions.

      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  int get _pageCount => (_rows.length / widget.itemsPerPage).ceil();
  List<_QuizRow> _pageItems(int page) {
    final start = page * widget.itemsPerPage;
    final end = min(start + widget.itemsPerPage, _rows.length);
    return _rows.sublist(start, end);
  }

  double get _progress {
    final answered = _answers.length;
    final total = _rows.length;
    if (total == 0) return 0;
    return answered / total;
  }

  void _onLikert(String itemId, int value) {
    setState(() => _answers[itemId] = value);
  }

  Future<void> _onSubmit() async {
    // Validate all answered
    if (_answers.length < _rows.length) {
      final missing = _rows.length - _answers.length;
      _showSnack('Please answer all items ($missing remaining).');
      return;
    }

    // Build QuizResponse list
    final data = <QuizResponse>[];
    for (final r in _rows) {
      data.add(
        QuizResponse(
          itemId: r.itemId,
          featureKey: r.featureKey,
          direction: r.direction,
          weight: r.weight,
          likert: _answers[r.itemId]!, // safe due to check above
        ),
      );
    }

    try {
      _showSnack('Submitting…');
      final submitter = BatchSubmitter(_supa);
      await submitter.submit(data);

      if (mounted) {
        _showSnack('Saved! Your profile has been updated.');
        Navigator.of(context).maybePop(); // go back to previous screen
      }
    } catch (e) {
      _showSnack('Submit failed: $e');
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = widget.lang.toLowerCase() == 'ar';
    final dir = isRtl ? TextDirection.rtl : TextDirection.ltr;

    if (_loading) {
      return Directionality(
        textDirection: dir,
        child: Scaffold(
          appBar: AppBar(title: Text(widget.title ?? widget.instrument)),
          body: const Center(child: CircularProgressIndicator()),
        ),
      );
    }
    if (_error != null) {
      return Directionality(
        textDirection: dir,
        child: Scaffold(
          appBar: AppBar(title: Text(widget.title ?? widget.instrument)),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 40),
                const SizedBox(height: 12),
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(onPressed: _fetchItems, child: const Text('Retry')),
              ],
            ),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: dir,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title ?? widget.instrument),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text('${(_progress * 100).round()}%',
                    style: Theme.of(context).textTheme.labelLarge),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            if (widget.subtitle != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  widget.subtitle!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            LinearProgressIndicator(value: _progress, minHeight: 4),
            const SizedBox(height: 8),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const ClampingScrollPhysics(),
                onPageChanged: (i) => setState(() => _pageIndex = i),
                itemCount: _pageCount,
                itemBuilder: (_, page) {
                  final items = _pageItems(page);
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final q = items[i];
                      final val = _answers[q.itemId];
                      return _QuestionCard(
                        indexLabel:
                            '${page * widget.itemsPerPage + i + 1}/${_rows.length}',
                        text: q.questionText,
                        initial: val,
                        onChanged: (v) => _onLikert(q.itemId, v),
                        isRtl: isRtl,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.chevron_left),
                    label: Text(isRtl ? 'التالي' : 'Back'),
                    onPressed: _pageIndex == 0
                        ? null
                        : () => _pageController.previousPage(
                              duration: const Duration(milliseconds: 240),
                              curve: Curves.easeOut,
                            ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    icon: Icon(_pageIndex == _pageCount - 1
                        ? Icons.check
                        : Icons.chevron_right),
                    label: Text(_pageIndex == _pageCount - 1
                        ? (isRtl ? 'إرسال' : 'Submit')
                        : (isRtl ? 'السابق' : 'Next')),
                    onPressed: () {
                      if (_pageIndex == _pageCount - 1) {
                        _onSubmit();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOut,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// DB row → in-memory model
class _QuizRow {
  final String itemId;
  final String featureKey;
  final double direction;
  final double weight;
  final String questionText;

  _QuizRow({
    required this.itemId,
    required this.featureKey,
    required this.direction,
    required this.weight,
    required this.questionText,
  });

  factory _QuizRow.fromDb(Map<String, dynamic> m) {
    return _QuizRow(
      itemId: m['item_id'] as String,
      featureKey: m['feature_key'] as String,
      direction: (m['direction'] as num).toDouble(),
      weight: (m['weight'] as num).toDouble(),
      questionText: m['question_text'] as String,
    );
    // metadata is available if you want to show scale/trait badges
  }
}

/// One question + 5-point Likert bar
class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.indexLabel,
    required this.text,
    required this.onChanged,
    required this.isRtl,
    this.initial,
  });

  final String indexLabel;
  final String text;
  final int? initial; // 1..5
  final ValueChanged<int> onChanged;
  final bool isRtl;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final selected = initial ?? 0;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Column(
          crossAxisAlignment:
              isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(indexLabel, style: t.textTheme.labelSmall),
            const SizedBox(height: 6),
            Text(text, style: t.textTheme.titleMedium),
            const SizedBox(height: 12),
            _LikertBar(
              value: selected,
              onChanged: onChanged,
              isRtl: isRtl,
              labels: isRtl
                  ? const ['غير دقيق جدًا', 'غير دقيق', 'محايد', 'دقيق', 'دقيق جدًا']
                  : const ['Very inaccurate', 'Inaccurate', 'Neutral', 'Accurate', 'Very accurate'],
            ),
          ],
        ),
      ),
    );
  }
}

class _LikertBar extends StatelessWidget {
  const _LikertBar({
    required this.value,
    required this.onChanged,
    required this.isRtl,
    required this.labels,
  });

  final int value; // 0 (none) or 1..5
  final ValueChanged<int> onChanged;
  final bool isRtl;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final items = List.generate(5, (i) => i + 1);

    return Column(
      crossAxisAlignment:
          isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: isRtl ? WrapAlignment.end : WrapAlignment.start,
          children: items.map((i) {
            final selected = i == value;
            return ChoiceChip(
              label: Text(i.toString()),
              selected: selected,
              onSelected: (_) => onChanged(i),
            );
          }).toList(),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment:
              isRtl ? MainAxisAlignment.spaceBetween : MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: Text(labels.first, style: t.textTheme.labelSmall)),
            Flexible(child: Text(labels.last, style: t.textTheme.labelSmall, textAlign: TextAlign.end)),
          ],
        ),
      ],
    );
  }
}

How to use it

Route to the page with the desired instrument/lang:

// RIASEC (English)
Navigator.push(context, MaterialPageRoute(
  builder: (_) => const AssessmentPage(
    instrument: 'Mini-IP RIASEC',
    lang: 'en',
    title: 'Interests Check',
    subtitle: 'Tell us what sounds fun to you.',
    itemsPerPage: 6,
  ),
));

// IPIP-50 (Arabic)
Navigator.push(context, MaterialPageRoute(
  builder: (_) => const AssessmentPage(
    instrument: 'IPIP-50',
    lang: 'ar',
    title: 'الشخصية',
    subtitle: 'اختر الوصف الأقرب لك.',
    itemsPerPage: 5, // 10 pages x 5 items
  ),
));


The page will: fetch → render → compute per-feature batch → call your Edge Function → update matches and progress.

2) Supabase SQL — Verification & Integrity Toolkit

Paste into SQL Editor. These help you confirm you seeded items correctly and detect gaps before students see them.

A. Counts by instrument / language
-- Item counts by instrument + language
select
  metadata->>'instrument' as instrument,
  metadata->>'lang' as lang,
  count(*) as items
from public.quiz_items
group by 1,2
order by 1,2;

B. Feature coverage per instrument/lang
-- How many items contribute to each feature per instrument/lang
select
  metadata->>'instrument' as instrument,
  metadata->>'lang' as lang,
  feature_key,
  count(*) as item_count,
  round(avg(direction)::numeric, 2) as avg_dir
from public.quiz_items
group by 1,2,3
order by 1,2,3;

C. Reverse-key sanity (IPIP only)
-- Check reverse-key distribution for IPIP (should have both +1 and -1 directions)
select
  feature_key,
  sum(case when (metadata->>'reverse')::boolean is true then 1 else 0 end) as reversed_items,
  sum(case when (metadata->>'reverse')::boolean is not true then 1 else 0 end) as forward_items
from public.quiz_items
where metadata->>'instrument' = 'IPIP-50'
group by feature_key
order by feature_key;

D. Missing features vs your canonical feature list
-- Which features exist in `features` but have 0 items in a given instrument?
with f as (
  select key from public.features
),
qi as (
  select feature_key from public.quiz_items
  where metadata->>'instrument' = 'Mini-IP RIASEC' and metadata->>'lang' = 'en'
)
select f.key as feature_without_items
from f
left join qi on qi.feature_key = f.key
where qi.feature_key is null
order by 1;

E. Create a quick view to QA items
create or replace view public.v_quiz_items_overview as
select
  q.item_id,
  q.feature_key,
  q.direction,
  q.weight,
  q.question_text,
  q.metadata->>'instrument' as instrument,
  q.metadata->>'lang' as lang,
  q.metadata->>'trait' as trait,
  q.metadata->>'scale' as scale
from public.quiz_items q;

-- Example usage:
-- select * from public.v_quiz_items_overview where instrument='IPIP-50' and lang='ar' order by item_id;

F. Quick data health checks
-- Items with NULLs (should be none)
select * from public.quiz_items
where item_id is null or feature_key is null or direction is null or weight is null or question_text is null;

-- Items with invalid direction/weight
select * from public.quiz_items
where direction not in (-1, 1) or weight <= 0;

-- Duplicate item_id (should be unique)
select item_id, count(*) from public.quiz_items group by item_id having count(*) > 1;

Implementation notes / growth levers

Save & resume: wire SharedPreferences or Supabase kv to store _answers by _persistKey each time a Likert value changes; on init, restore it.

Accessibility: Semantics labels for Likert chips; support keyboard arrows to step selections.

Fairness: randomize item order within blocks on the client (and store the order in assessment_items.metadata if you capture raw responses).

Scoring evolution: once you hit ~200+ users, switch from min–max to z-score with feature_cohort_stats and keep the EMA pipeline unchanged.

Weighting: if you want a more nuanced IPIP mapping (e.g., Extraversion → 0.7 trait_communication + 0.3 trait_leadership), move that mapping to your Edge Function so you can iterate without a client release.


