# generator-engine Specification

## Purpose

Provides the core code generation engine that transforms validated JSL models into output files using Handlebars templates controlled by YAML descriptors and Spring Expression Language (SpEL) for path and factory expressions.

## Architecture

The engine is packaged as an OSGi bundle. Key classes:

- `JslDslGenerator` — Static entry point for code generation. Maps JSL-specific parameters to generic `GeneratorParameter`, executes Handlebars templates against model elements, and manages output file lifecycle (checksums, gitignore sync).
- `JslDslGeneratorParameter` — Lombok `@Builder` configuration object holding the JSL model, generator context, actor type predicates, target directory resolvers, extra context variables, and checksum validation flag.
- `BufferedSlf4jLogger` — Thread-safe SLF4J logger wrapper that buffers log entries in memory and flushes them on demand.
- `LogLevel` — Enum (ERROR, WARN, INFO, DEBUG, TRACE) with utility methods for log level detection and filtering.

Generation pipeline: JSL model → `JslDslGeneratorParameter` → `JslDslGenerator.execute()` → Handlebars templates + SpEL → generated files with checksum tracking.

## Requirements

### Requirement: Code generation execution

`JslDslGenerator` SHALL generate output files from a JSL model using the configured templates and parameters.

#### Scenario: Execute generation with builder
- **GIVEN** a `JslDslGeneratorParameter.JslDslGeneratorParameterBuilder` with a valid JSL model and generator context
- **WHEN** `JslDslGenerator.execute(builder)` is called
- **THEN** a `GeneratorResult<ActorDeclaration>` is returned containing the generated file entries

#### Scenario: Generate to directory
- **GIVEN** a `JslDslGeneratorParameter` with a target directory resolver
- **WHEN** `JslDslGenerator.generateToDirectory(parameter)` is called
- **THEN** generated files are written to the resolved directory structure

### Requirement: Actor-type based generation

The engine SHALL support generating output per actor type, with each actor receiving its own output directory.

#### Scenario: Per-actor generation
- **GIVEN** a JSL model with multiple `ActorDeclaration` instances and an `actorTypePredicate`
- **WHEN** generation executes with `actorTypeTargetDirectoryResolver` configured
- **THEN** each matching actor type's output is written to its own directory

### Requirement: Checksum management

The engine SHALL track file checksums to detect manual modifications and support regeneration lifecycle.

#### Scenario: Reset checksums
- **GIVEN** a directory with previously generated files and checksum data
- **WHEN** `JslDslGenerator.resetChecksumsInDirectory(parameter)` is called
- **THEN** all file checksums are reset, allowing full regeneration

#### Scenario: Clean generated files by checksum
- **GIVEN** a directory with generated files tracked by checksums
- **WHEN** `JslDslGenerator.cleanGeneratedFromChecksumInDirectory(parameter)` is called
- **THEN** only files matching their original checksums (unmodified) are deleted

#### Scenario: Recalculate checksums
- **GIVEN** a directory with generated files
- **WHEN** `JslDslGenerator.recalculateChecksumForDirectory(parameter)` is called
- **THEN** checksums are recalculated based on current file contents

### Requirement: Gitignore synchronization

The engine SHALL synchronize `.gitignore` files with the set of generated artifacts.

#### Scenario: Sync gitignore
- **GIVEN** a generation output directory and a collection of generated file paths
- **WHEN** `JslDslGenerator.synchronizeGitignoreInDirectory(parameter, paths)` is called
- **THEN** the `.gitignore` file is updated to include generated file patterns

### Requirement: File ignore pattern matching

The engine SHALL support glob-pattern-based file ignore lists (`.generator-ignore` format).

#### Scenario: Match ignore patterns
- **GIVEN** a collection of glob patterns (e.g., `**/*.bak`, `temp/`)
- **WHEN** `JslDslGenerator.getIgnoredFileMatcher(patterns)` is called
- **THEN** a `Function<String, Boolean>` is returned that matches file paths against the patterns

### Requirement: Name normalization

The engine SHALL provide utility methods for converting identifiers between naming conventions.

#### Scenario: Generalize name to camelCase
- **GIVEN** a string in various formats (snake_case, kebab-case, PascalCase)
- **WHEN** `JslDslGenerator.generalizeName(name)` is called
- **THEN** the name is converted to camelCase

### Requirement: Buffered logging

`BufferedSlf4jLogger` SHALL buffer log entries and flush them to an underlying SLF4J logger on demand.

#### Scenario: Buffer and flush logs
- **GIVEN** a `BufferedSlf4jLogger` wrapping an existing logger
- **WHEN** multiple log methods (info, warn, error) are called followed by `flush()`
- **THEN** all buffered entries are sent to the underlying logger in order
