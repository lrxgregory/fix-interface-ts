# fix-interface-ts.sh

A bash script to enforce clean code practices for TypeScript interfaces in your codebase.

## Purpose

This script analyzes your TypeScript project to help you:
- Detect interfaces that are declared but never used (suggests removal)
- Detect interfaces that are exported but only used/imported in a single file (suggests making them local)
- Detect interfaces declared in multiple files (suggests centralization)

## Features
- Ignores test files, mocks, and fixtures for accurate results
- Uses strict matching to avoid false positives (e.g., does not confuse `MyInterface` with `MyInterfaceData`)
- Outputs actionable suggestions only for interfaces that violate clean code rules

## How it works
- Scans all exported interfaces in your `src/` directory
- For each interface, checks:
  - If it is declared in more than one file
  - If it is never used/imported
  - If it is only used/imported in a single file
- Only reports interfaces that need attention, so you can focus on real clean code issues

## Usage

```bash
bash check-interfaces.sh
```

## Example Output

```
🔹 MyInterface : used/imported in only one file (can be made local)
    Declared in: src/models/interfaces/my.types.ts
    Imported in:
      → src/services/my.service.ts

🔸 AnotherInterface : declared in multiple files (2), should be centralized
    Declared in: src/models/interfaces/a.types.ts
    Declared in: src/models/interfaces/b.types.ts

❌ UnusedInterface : declared but never used (can be removed)
    Declared in: src/models/interfaces/unused.types.ts
```

## Why use it?
- Keep your codebase clean, maintainable, and DRY
- Instantly spot and fix interface duplication or unnecessary centralization
- Enforce best practices for TypeScript interface management

