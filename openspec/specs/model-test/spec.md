# model-test Specification

## Purpose

Provides JUnit 5 tests that verify the JSL parser, model loader, and PlantUML diagram generator work correctly against representative JSL source files.

## Architecture

The test module uses the XText testing framework with a custom `JslDslInjectorProvider` that configures the Guice injector for standalone (non-Eclipse) usage. Tests load `.jsl` resource files and verify parsing, model structure, and diagram output.

Key classes:
- `JslDslParserTest` — Tests parsing of all JSL language constructs
- `JslDslModelLoaderTest` — Tests loading pre-built XMI model files
- `JslDslDefaultPlantumlDiagramTest` — Tests PlantUML diagram generation
- `JslDslInjectorProvider` — Implements `IInjectorProvider` and `IRegistryConfigurator` for XText test DI setup

## Requirements

### Requirement: Parser correctness

The parser tests SHALL verify that all JSL language constructs parse correctly into the expected AST structure.

#### Scenario: Parse model declarations and imports
- **GIVEN** JSL source with `model` and `import` declarations
- **WHEN** `JslDslParserTest.testModelDeclaration()` runs
- **THEN** the parsed model contains the expected model name and import references

#### Scenario: Parse type declarations
- **GIVEN** JSL source with numeric, string, date, time, and timestamp type declarations
- **WHEN** `JslDslParserTest.testTypes()` runs
- **THEN** each type declaration is parsed with correct precision, scale, and constraints

#### Scenario: Parse entity declarations
- **GIVEN** JSL source with entity declarations containing fields and relations
- **WHEN** `JslDslParserTest.testEntities()` runs
- **THEN** entities contain the expected fields, relations, and their types

#### Scenario: Parse queries, functions, expressions, and annotations
- **WHEN** the respective test methods run (`testQueries`, `testFunctions`, `testExpressions`, `testAnnotations`)
- **THEN** each construct is parsed into the correct AST node type with expected properties

### Requirement: Model loading from XMI

The model loader SHALL load pre-serialized JSL models from XMI format.

#### Scenario: Load XMI model
- **GIVEN** an XMI file containing a serialized JSL model
- **WHEN** `JslDslModelLoaderTest.loadJslModel()` runs
- **THEN** the model is loaded into memory with all elements intact

### Requirement: PlantUML diagram generation

The diagram generator SHALL produce valid PlantUML output from parsed JSL models.

#### Scenario: Generate default PlantUML diagram
- **GIVEN** a parsed JSL model
- **WHEN** `JslDslDefaultPlantumlDiagramTest.generatesDefaultPlantUMLDiagram()` runs
- **THEN** a PlantUML diagram string is generated representing the model's entities and relationships

### Requirement: Test dependency injection

`JslDslInjectorProvider` SHALL provide a working Guice injector for standalone XText tests.

#### Scenario: Injector creation
- **WHEN** `JslDslInjectorProvider.getInjector()` is called
- **THEN** a singleton Guice injector is returned with `JslDslRuntimeModule` bindings
- **AND** the XText global registry is configured for JSL
