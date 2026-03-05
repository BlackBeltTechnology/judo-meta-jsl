# model Specification

## Purpose

Defines the JUDO Specification Language (JSL) using XText, providing grammar definition, parsing, name resolution (scoping), semantic validation, code formatting, error messaging, and runtime support for loading and analyzing JSL models.

## Architecture

The model module is an Eclipse plugin (`eclipse-plugin` packaging) containing:

- **Grammar** (`JslDsl.xtext`) — The complete JSL syntax definition covering model declarations, imports, types, entities, transfers, actors, views, queries, expressions, and annotations.
- **Scoping** — `JslDslScopeProvider`, `JslDslGlobalScopeProvider`, `JudoFunctionsProvider`, `JudoTypesProvider`, and supporting classes (`JslDslIndex`, `JslDslQualifiedNameConverter`, `JslDslImportNormalizer`, `JslResourceDescriptionStrategy`, `ResourceDescriptionsWrapper`) that resolve cross-references between model elements.
- **Validation** — `JslDslValidator.xtend` (~99KB) contains all semantic validation rules for the language.
- **Formatting** — Formatting rules in `formatting2/` for consistent JSL code style.
- **Error Messages** — Custom error message generation in `errormessages/`.
- **Runtime** — `JslParser` (standalone parser API), `TypeInfo` (type system analysis), `JslTerminalConverters` (terminal value converters), `JslStreamSource` (input abstraction), `JslParseException` (error reporting).
- **Generated Code** — Ecore metamodel and XText infrastructure generated via MWE2 workflow (`src/workflow/generateModel.mwe2`) into `src/main/xtext-gen/`, `src/main/xtend-gen/`, and `model/generated/`.

## Requirements

### Requirement: JSL source parsing

The module SHALL parse JSL source files from files, strings, or input streams into an XText resource set.

#### Scenario: Parse JSL from files
- **GIVEN** one or more `.jsl` files on the filesystem
- **WHEN** `JslParser.loadJslFromFile(Collection<File>)` is called
- **THEN** an `XtextResourceSet` is returned containing parsed model declarations

#### Scenario: Parse JSL from strings
- **GIVEN** one or more JSL source strings
- **WHEN** `JslParser.loadJslFromString(Collection<String>)` is called
- **THEN** an `XtextResourceSet` is returned containing parsed model declarations

#### Scenario: Parse JSL from input streams
- **GIVEN** one or more `JslStreamSource` instances with streams and resource URIs
- **WHEN** `JslParser.loadJslFromStream(Collection<JslStreamSource>)` is called
- **THEN** an `XtextResourceSet` is returned with parsed model declarations, including validation

### Requirement: Model declaration retrieval

The module SHALL retrieve named model declarations from a parsed resource set.

#### Scenario: Get specific model by name
- **GIVEN** a parsed `XtextResourceSet` containing multiple model declarations
- **WHEN** `JslParser.getModelDeclarationFromXtextResourceSet(name, resourceSet)` is called
- **THEN** an `Optional<ModelDeclaration>` is returned matching the given name

#### Scenario: Get all model declarations
- **GIVEN** a parsed `XtextResourceSet`
- **WHEN** `JslParser.getAllModelDeclarationFromXtextResourceSet(resourceSet)` is called
- **THEN** all `ModelDeclaration` instances in the resource set are returned

### Requirement: Internal model imports

The module SHALL automatically include built-in `judo::types` and `judo::functions` model declarations as internal imports.

#### Scenario: Internal imports available
- **WHEN** `JslParser.getInternalModelDeclarations()` is called
- **THEN** a collection containing `judo::types` and `judo::functions` model declarations is returned

### Requirement: Type system analysis

`TypeInfo` SHALL determine the type of any JSL expression, feature, or declaration and support type compatibility checks.

#### Scenario: Determine expression type
- **GIVEN** a JSL `Expression` AST node
- **WHEN** `TypeInfo.getTargetType(expression)` is called
- **THEN** a `TypeInfo` is returned with correct `BaseType`, `TypeModifier`, and associated entity/datatype

#### Scenario: Type compatibility check
- **GIVEN** two `TypeInfo` instances
- **WHEN** `isCompatible(other)` is called on one
- **THEN** it returns `true` if the types are assignment-compatible (considering primitives, entities, collections, and inheritance)

### Requirement: Cross-reference resolution (scoping)

The scoping providers SHALL resolve cross-references between model elements across files and imports.

#### Scenario: Resolve imported model references
- **GIVEN** a JSL file importing another model via `import` declaration
- **WHEN** a cross-reference to an entity from the imported model is encountered
- **THEN** `JslDslScopeProvider` resolves it to the correct `EntityDeclaration` in the imported model

### Requirement: Semantic validation

`JslDslValidator` SHALL enforce all semantic rules of the JSL language beyond what the grammar can express.

#### Scenario: Validation errors reported
- **GIVEN** a JSL source containing semantic errors (e.g., duplicate field names, type mismatches)
- **WHEN** the model is parsed and validated
- **THEN** appropriate `Issue` objects are created with error codes, messages, and source locations

### Requirement: Parse error reporting

`JslParseException` SHALL provide detailed error context when parsing fails.

#### Scenario: Parse error with details
- **GIVEN** JSL source with syntax errors
- **WHEN** parsing fails and a `JslParseException` is thrown
- **THEN** `getErrors()` returns a map of `IParseResult` to `Collection<Issue>` with line/column information

### Requirement: Terminal value conversion

`JslTerminalConverters` SHALL convert between grammar terminal tokens and Java values for identifiers, strings, dates, times, timestamps, and measure names.

#### Scenario: Backtick-escaped identifiers
- **GIVEN** a JSL identifier wrapped in backticks (e.g., `` `class` ``)
- **WHEN** the terminal converter processes it
- **THEN** the backticks are stripped, yielding the raw identifier name
