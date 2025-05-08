# CMS Helper Text Feature Specification

## Overview
This document details the specifications for implementing a helper text feature in the CMS. The feature allows site administrators and content managers to add inline helper text to each CMS field when part of a layout.

## Features
- **Inline Declaration**: Field declarations include a `helper` parameter.
  - Example: `{{ cms:text headline helper:"Helper text here" }}`
- **Supported Field Types**: All field types (text, textarea, image, etc.) are supported.

## Presentation in CMS Edit Interface
- Helper text should appear beneath the CMS input field.
- Utilize Bootstrap 4 helper classes (e.g., `text-muted`) to style the text in a small, gray font.
  - Example Markup: `<p class="text-muted">Helper text here</p>` or `<div class="text-muted">Helper text here</div>`.
- The helper text is exclusively for the CMS edit interface, not for the published front end of the site.

## Validation & Data Handling
- **Character Limit**: Helper text must not exceed 240 characters.
  - If the helper text exceeds 240 characters, it should be truncated on the server side.
  - An ellipsis (`…`) is appended to indicate truncation.
- **Server-Side Processing**: The truncation logic is executed server side when saving the field value, ensuring consistent data handling.
- The helper text is stored as metadata associated with the corresponding CMS field.

## Architecture & Implementation
- **CMS Parser Enhancements**: Update the layout parser to recognize and process the inline `helper` parameter.
- **Server-Side Save Logic**: Incorporate truncation logic within the CMS field processing workflow during save operations.
  - Ensure that helper texts for all field types follow the 240-character limit, adding an ellipsis when necessary.
- **Styling in the CMS Edit Interface**: Render helper text using appropriate Bootstrap 4 classes to achieve the desired appearance.

## Error Handling Strategies
- Automatically truncate any helper text exceeding 240 characters and append an ellipsis without blocking the save operation.
- Log a warning message (if applicable) for instances of truncation for further review by developers, but do not interrupt user workflow.
- Ensure that any errors related to helper text processing do not impact the handling of other CMS fields.

## Testing Plan
### Unit Tests
- Verify that the layout parser correctly extracts the helper text parameter from inline declarations.
- Test that helper text longer than 240 characters is properly truncated with an ellipsis appended.

### Integration Tests
- Confirm that the CMS edit interface displays the helper text using the correct styling (Bootstrap 4 `text-muted`) beneath the field input.
- Verify that the helper text does not appear on the public-facing front end.

### Edge Cases
- Test with helper text exactly at 240 characters.
- Test with helper text exceeding 240 characters by just a few characters and by a large margin.

### Manual UI Testing
- Perform manual tests in the CMS to ensure content managers see the helper text as expected when adding or editing content fields.
- Validate that the truncation is applied correctly and that the UI displays the ellipsis where appropriate.

## Summary
This specification outlines the implementation of a helper text feature that provides inline guidance to content managers in the CMS. The approach includes an inline declaration format, server-side truncation logic, dedicated styling using Bootstrap, and comprehensive error handling and testing strategies. This document should serve as a clear blueprint for developers to begin implementing and integrating this feature into the CMS.
