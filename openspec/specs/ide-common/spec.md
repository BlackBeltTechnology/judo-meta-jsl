# ide-common Specification

## Purpose

Provides shared IDE functionality for JSL, primarily intelligent content assist (code completion) proposals for use in the Eclipse editor and LSP-based editors.

## Architecture

Key class:

- `JslDslIdeContentProposalProvider` — Extends XText's `IdeContentProposalProvider` to generate context-aware code completion proposals for JSL. Filters inappropriate keywords and terminals based on editing context. Uses injected `JslDslGrammarAccess` for grammar rules and `JslDslModelExtension` for model utilities.

Filtered keywords include `lambda` and `function` (internal constructs not directly authored). Filtered terminals include brackets, operators, and other syntactic elements that should not appear as completion proposals.

## Requirements

### Requirement: Context-aware code completion

`JslDslIdeContentProposalProvider` SHALL provide intelligent code completion proposals based on the current editing context.

#### Scenario: Propose valid keywords
- **GIVEN** the cursor is at a position where keywords are valid
- **WHEN** code completion is triggered
- **THEN** proposals include valid JSL keywords for that context, excluding internal keywords like `lambda` and `function`

#### Scenario: Exclude self outside entities
- **GIVEN** the cursor is at a position outside an entity declaration body
- **WHEN** code completion is triggered
- **THEN** the `self` keyword is NOT included in proposals

#### Scenario: Propose references
- **GIVEN** the cursor is at a position expecting a type reference or entity reference
- **WHEN** code completion is triggered via a `RuleCall`
- **THEN** proposals include valid cross-references resolved by the scoping providers

### Requirement: Terminal filtering

The provider SHALL filter out syntactic terminals (brackets, operators) from completion proposals.

#### Scenario: No operator proposals
- **GIVEN** the cursor is at any position
- **WHEN** code completion is triggered
- **THEN** terminals like `(`, `)`, `[`, `]`, `:`, `.`, `,` are not offered as proposals
