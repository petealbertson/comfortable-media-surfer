Prompt 1 – Migration & Model
You are working in a Rails 7 CMS.  
Task: introduce helper_text support.

1. Generate migration on `comfy_cms_fragments`:
   • helper_text :string, limit: 240
2. In `comfy_cms_fragments` model:
   • validates :helper_text, length: { maximum: 240 }
   • before_validation :truncate_helper_text (truncates helper_text to 240 and adds ellipsis if necessary)
3. Add unit tests (minitest) for model.
4. Keep rubocop clean.

Write tests first, then code until all green.

Prompt 2 – Fragment Test (RED)
Write a failing minitest unit test for the `Comfy::Cms::WithFragments` concern:

• Given a model instance including `Comfy::Cms::WithFragments`, when calling
  `fragments_attributes=` with a hash:
    { identifier: 'headline', content: 'Title', helper_text: 'Helper text here' }
  expect the built fragment to have `helper_text` set to 'Helper text here'.

No implementation change yet; make spec fail.

Prompt 3 – Implement helper_text assignment in fragments_attributes=

Update the `fragments_attributes=` method in the `Comfy::Cms::WithFragments` concern so that when a hash or array of hashes is passed in, if a `helper_text` key is present, it is assigned to the corresponding fragment's `helper_text` attribute.

• Ensure that this does not break existing fragment assignment logic or parameter handling.
• Update or add tests to verify that `helper_text` is correctly set on the fragment when provided.
• Run the entire test suite and ensure RuboCop passes.

Prompt 4 – Permit & Persist helper_text through controller
Ensure `helper_text` flows into `fragments_attributes=` and is persisted:
• In `Comfy::Admin::Cms::LayoutsController#layout_params`, permit `fragments_attributes: [:identifier, :content, :helper_text, ...]`.
• Confirm `fragments_attributes=` assigns and truncates `helper_text` correctly via existing callback in `Comfy::Cms::Fragment`.
• Write a Rails request spec that creates/updates a layout with one fragment including `helper_text`, then assert the saved fragment’s `helper_text` matches (truncated if needed).

Prompt 5 – Admin Partial
Create/modify `_field_helper_text.html.erb` partial:

<p class="text-muted"><%= field.helper_text %></p>

Render this partial in admin form builder when helper_text present.  
Add system spec (Capybara) visiting admin edit page for a page with helper text → expects visible text.  
Verify public site view does NOT include helper text.

Rubocop + i18n lint clean.

Prompt 6 – Boundary Edge Tests
Add spec covering:
• exactly 240 chars (no ellipsis)
• 241 chars (truncate + ellipsis)
• huge (>1k) input

Confirm service handles all. Run suite.

Prompt 7 – Logging
Add ActiveSupport::Notifications instrument:
'cms.helper_text.truncated' with payload { field_id:, original_length: }  
Unit test with `subscriber` that event fires only on truncation.

Prompt 8 – Final Cleanup
Run rubocop -A, brakeman, annotate models.  
Update CHANGELOG with Helper Text feature entry.  
Ensure `bin/minitest` and `bin/rails test` pass.