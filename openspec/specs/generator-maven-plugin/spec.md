# generator-maven-plugin Specification

## Purpose

Provides Maven plugin goals for executing JSL code generation, cleaning generated output, managing file checksums, and synchronizing `.gitignore` files — wrapping the `generator-engine` for use in Maven build lifecycles.

## Architecture

The plugin contains several Maven Mojos sharing a common base:

- `AbstractJslDslProjectMojo` — Base class handling Maven project context, repository resolution, JSL model source loading (from files, Maven artifacts, or scanned dependencies), and model name filtering.
- `JslDslProjectGenerateMojo` (`generate` goal, `GENERATE_RESOURCES` phase) — Main generation Mojo with configuration for template URIs, helper classes, template parameters, context accessor, output destination, and dependency scanning.
- `JslDslProjectCleanMojo` (`clean` goal) — Cleans previously generated files.
- `JslDslProjectCalculateChecksumMojo` — Calculates checksums for generated files.
- `JslDslProjectResetChecksumMojo` — Resets checksums to allow full regeneration.
- `JslDslProjectSynchronizeGitignoreMojo` — Synchronizes `.gitignore` with generated artifacts.
- `ArtifactResolver` — Resolves Maven artifacts from repositories and converts them to URLs for template loading.
- `ResourceList` — Pattern-based resource discovery across directories and JAR files.

## Requirements

### Requirement: Code generation via Maven

The `generate` goal SHALL parse JSL models and generate output files using Handlebars templates in the `GENERATE_RESOURCES` phase.

#### Scenario: Generate from JSL model artifact
- **GIVEN** a `<jslModel>` URI pointing to a Maven artifact (e.g., `mvn:group:artifact:version!path/model`)
- **WHEN** the `generate` goal executes
- **THEN** the model is resolved from the repository, parsed, and templates are applied to produce output at `<destination>`

#### Scenario: Generate from source files
- **GIVEN** `<sources>` URIs pointing to directories containing `.jsl` files
- **WHEN** the `generate` goal executes with `<scanSources>true</scanSources>`
- **THEN** all `.jsl` files are discovered, parsed, and processed through templates

#### Scenario: Filter by model name
- **GIVEN** `<modelNames>` containing a comma-separated list of model names
- **WHEN** the `generate` goal executes
- **THEN** only models matching the listed names are processed

### Requirement: Layered template resolution

The plugin SHALL support multiple template URIs that are resolved in reverse order (last takes priority).

#### Scenario: Template override
- **GIVEN** two `<uri>` entries — a base template package and an override package
- **WHEN** both contain a template with the same name
- **THEN** the override template (later URI) takes precedence over the base

### Requirement: Helper and context accessor scanning

The plugin SHALL discover `@TemplateHelper` and `@ContextAccessor` annotated classes from the classpath when `scanDependencies` is enabled.

#### Scenario: Auto-discover helpers
- **GIVEN** `<scanDependencies>true</scanDependencies>` and a dependency containing `@TemplateHelper` annotated classes
- **WHEN** the `generate` goal executes
- **THEN** the annotated classes are loaded and registered as Handlebars helpers and SpEL helpers

#### Scenario: Auto-discover context accessor
- **GIVEN** `<scanDependencies>true</scanDependencies>` and a dependency containing a `@ContextAccessor` annotated class
- **WHEN** the `generate` goal executes
- **THEN** the context accessor is registered for binding Handlebars/SpEL/parameter contexts
- **AND** if multiple `@ContextAccessor` classes are found, an error is thrown

### Requirement: Template parameters

Template parameters defined in `<templateParameters>` SHALL be accessible in both SpEL expressions and Handlebars templates.

#### Scenario: Pass parameters to templates
- **GIVEN** `<templateParameters>` with key `judoPlatformVersion` and a value
- **WHEN** a Handlebars template references `{{judoPlatformVersion}}`
- **THEN** the value is substituted in the generated output

### Requirement: Artifact resolution

`ArtifactResolver` SHALL resolve Maven artifact coordinates to local file URLs.

#### Scenario: Resolve artifact
- **GIVEN** a Maven artifact coordinate
- **WHEN** `getArtifactFile(artifact)` is called
- **THEN** the artifact is resolved from configured repositories and a URL to the local file is returned

### Requirement: Generated file lifecycle

The plugin SHALL provide goals for managing the lifecycle of generated files.

#### Scenario: Clean generated files
- **WHEN** the `clean` goal executes
- **THEN** previously generated files are removed from the output directory

#### Scenario: Synchronize gitignore
- **WHEN** the synchronize-gitignore goal executes
- **THEN** `.gitignore` is updated to include patterns for all generated files
