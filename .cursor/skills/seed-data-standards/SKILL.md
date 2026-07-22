---
name: seed-data-standards
description: Defines development seed data quality standards for new modules and entities. Use when implementing a new module, adding database entities, writing or updating seed scripts, reseeding the database, or preparing data for UI, API, or end-to-end testing.
---

# Seed Data Standards

Whenever implementing a new module:

1. Create realistic development data.

2. Include relationships between entities.

3. Create enough records to realistically test the UI.

4. Use meaningful names instead of placeholder values.

5. Include edge cases.

6. Include optional fields.

7. Include inactive data where applicable.

8. Include empty-state scenarios.

9. Include validation edge cases where appropriate.

10. Ensure repeated execution produces the same dataset.

## Checklist

Copy and track while seeding a module:

```
Seed Progress:
- [ ] Realistic development data
- [ ] Entity relationships
- [ ] Enough records for UI testing
- [ ] Meaningful names (no placeholders)
- [ ] Edge cases
- [ ] Optional fields populated where useful
- [ ] Inactive data (if applicable)
- [ ] Empty-state scenarios
- [ ] Validation edge cases (if appropriate)
- [ ] Idempotent / deterministic re-run
```

## Project alignment

Also follow `.cursor/rules/Development-Seed-Data.mdc`: organize seeds by module/domain, keep referential integrity, never run development seeds in production, and keep seeds synchronized with schema changes.
