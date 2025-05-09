# CMS Helper Text Feature – Todo Checklist

> Use this file as a living checklist. Tick each box (`[x]`) when the task is complete, and feel free to add notes / links to PRs.

---

## Iteration 1 – Data Model Support
- [ ] Generate migration on `cms_fields` adding `helper_text:string`, `limit: 240`
- [ ] Run migration in development & test DBs
- [ ] Update `Cms::Field` model
  - [ ] `validates :helper_text, length: { maximum: 240 }`
  - [ ] `before_validation :truncate_helper_text`
- [ ] Create `HelperTextTruncator` service (app/services)
- [ ] Unit specs (minitest)
  - [ ] Truncator behaviour (≤240, ellipsis added)
  - [ ] Model validation & callback
- [ ] Ensure RuboCop passes (`bundle exec rubocop`)

## Iteration 2 – Parser Upgrade
### 2A – Spec (RED)
- [ ] Add failing parser spec for `helper_text:"..."` parameter extraction

### 2B – Implementation (GREEN)
- [ ] Extend `LayoutParser#parse_tag` to capture `helper` parameter
- [ ] Ensure backwards compatibility with existing params
- [ ] Run parser spec suite to green
- [ ] RuboCop clean

## Iteration 3 – Save Workflow Integration
- [ ] Permit `helper_text` param in controller / service layer
- [ ] Invoke `HelperTextTruncator` in `FieldValueService`
- [ ] Persist `helper_text` to DB
- [ ] Request spec: create + update with helper param; assert truncated value saved

## Iteration 4 – Admin View Rendering
- [ ] Create `_field_helper_text.html.erb` partial (`<p class="text-muted">…</p>`) 
- [ ] Render partial in admin form when `helper_text.present?`
- [ ] System spec (Capybara): helper text visible in admin edit interface
- [ ] Verify public site does NOT render helper text

## Iteration 5 – Edge Case Tests
- [ ] Service spec: exactly 240 chars (no ellipsis)
- [ ] 241+ chars (truncates & ellipsis)
- [ ] Very large (>1k) input

## Iteration 6 – Logging & Polish
- [ ] Add `ActiveSupport::Notifications` event `cms.helper_text.truncated`
- [ ] Spec: subscriber receives event only when truncation occurs
- [ ] Run RuboCop -A, Brakeman, annotate models
- [ ] Update `CHANGELOG.md` and docs

---

## House-Keeping
- [ ] All new/updated code covered by specs (>90% coverage)
- [ ] CI pipeline green (minitest, RuboCop, Brakeman)
- [ ] Merge feature branch into `main` after approval

---

**Legend:**
- ✅/☑ – done
- ⚠️ – blocked / needs attention
