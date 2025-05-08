# Helper Text Feature – LLM Prompt Plan

Below is a series of test-first prompts to incrementally implement the CMS helper text purely via layout parsing. Each step builds on the previous, includes tests, and keeps RuboCop clean.

Prompt 1 – Layout Spec (RED)
Write a failing Minitest spec for `Comfy::Cms::Layout#content_tokens`:
- Given content `'a {{cms:text body helper:"Tip"}} b'`,
  when calling `layout.content_tokens`, expect tokens to include:
  `{ tag_class: 'text', tag_params: 'body', helper_text: 'Tip', source: '{{cms:text body helper:"Tip"}}' }`.
- Add a spec for truncation: helper text > 240 chars yields 237 chars plus `…`.

Prompt 2 – Layout Implementation
In `app/models/comfy/cms/layout.rb` (method `content_tokens`):
- Extend tag parser to recognise `helper:"…"` parameter.
- Add `helper_text` key to each token hash.
- Truncate >240 chars to 237 + `…`.
- Preserve existing `tag_class`, `tag_params`, `source` keys and behavior.
- Run tests and ensure RuboCop passes.

Prompt 3 – Admin UI Spec (RED)
Write a failing system/integration Minitest spec for the Comfy admin edit form:
- Given a page whose layout `content` includes `{{cms:text body helper:"Tip"}}`,
  when visiting the admin edit page, within the fragment field for `body`, assert:
  `%p.text-muted` with text "Tip" appears immediately below the input.
- Visit the public show page and assert no helper text (`<p class="text-muted">`) is rendered.

Prompt 4 – Admin UI Implementation
In `app/views/comfy/admin/cms/fragments/_form_fragments.html.haml` or
`ComfortableMediaSurfer::FormBuilder#fragment_field`:
- Update to accept and render a `helper_text` attribute from tokens.
- Render `%p.text-muted= helper_text` under the input when present.
- Preserve all existing form builder behavior and HTML structure.
- Run integration tests and ensure RuboCop passes.

Prompt 5 – Edge Case Testing
Add tests for helper text boundaries:
- Exactly 240 chars yields the full string with no ellipsis.
- 241+ chars yields the first 237 chars plus an ellipsis (`…`).
- No `helper` parameter yields no helper paragraph in the form.

Prompt 6 – Warning Log on Truncation
In the layout parser (`content_tokens`):
- When truncating a helper string, call `Rails.logger.warn`
  including the layout identifier and original length.
- Write a unit test capturing logger output, verifying the warning
  logs only on truncation and not on shorter strings.

Prompt 7 – Final Cleanup & Docs
- Run `bundle exec rubocop -A`, fix offenses.
- Ensure full test suite (`bin/rails test`) passes.
- Update `CHANGELOG.md` with a clear entry for helper text support.