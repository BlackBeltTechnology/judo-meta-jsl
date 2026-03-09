# judo-meta-jsl — Project Documentation

## Project Overview


**Repository:** BlackBeltTechnology/judo-meta-jsl
**License:** Eclipse Public License 2.0 (EPL-2.0)
**Java Version:** 21
**Build System:** Maven 3.9.4 with Tycho 4.0.13

1. **JSL (JUDO Specification Language)** is an XText-based domain-specific language for defining data models, business logic, and UI specifications on the JUDO platform.
2. The repository provides the full language toolchain: grammar definition, parser, scope resolver, validator, code formatter, and error message generator.
3. A Handlebars-based code generation engine transforms validated JSL models into output code using YAML-controlled template descriptors.
4. Eclipse IDE integration (editor, content assist, PlantUML preview) and Language Server Protocol servers (embedded fat JAR and web-based Monaco editor) provide developer tooling.
5. OSGi bundle packaging enables deployment into standard OSGi containers (Apache Karaf) for use in transformation pipelines.

## Code Instructions

1. First think through the problem, read the codebase for relevant files.
2. Before you make any major changes, check in with me and I will verify the plan.
3. Please every step of the way just give me a high level explanation of what changes you made.
4. Make every task and code change you do as simple as possible. We want to avoid making any massive or complex changes. Every change should impact as little code as possible. Everything is about simplicity.
5. Maintain a documentation file that describes how the architecture of the app works inside and out.
6. Never speculate about code you have not opened. If the user references a specific file, you MUST read the file before answering. Make sure to investigate and read relevant files BEFORE answering questions about the codebase. Never make any claims about code before investigating unless you are certain of the correct answer - give grounded and hallucination-free answers.
7. For implementation use TDD (Test-Driven Development): write or update tests first to define the expected behaviour, verify they fail, then write the minimal implementation to make them pass.
8. Use DRY (Don't Repeat Yourself): extract reusable logic into separate classes, utilities, or components. If the same pattern appears in multiple places, refactor it into a shared helper.

## Directory Structure

```
judo-meta-jsl/
├── model/                    # XText grammar, scoping, validation, formatting
├── model-test/               # JUnit 5 parser and model loading tests
├── generator-engine/         # Handlebars template-based code generation engine
├── generator-maven-plugin/   # Maven plugin wrapping the generator engine
├── generator-maven-plugin-test/ # Integration tests for the Maven plugin
├── ide/                      # Eclipse IDE support (parent module)
│   ├── ide-common/           # Content assist and shared IDE features
│   ├── ui/                   # Eclipse editor plugin
│   ├── preview-plantuml/     # PlantUML diagram preview
│   └── feature/              # Eclipse feature packaging
├── osgi/                     # OSGi bundle repackaging for non-Eclipse containers
├── osgi-itest/               # Karaf-based OSGi integration smoke tests
├── server-embedded/          # Standalone LSP fat JAR (Maven Shade)
├── server-web/               # Web-based Monaco editor with WebSocket LSP
├── feature/                  # Eclipse feature repository
├── site/                     # Eclipse P2 update site
├── docs/                     # AsciiDoc language documentation pages
└── images/                   # Diagrams and images
```

## Core Modules

### Language Definition

| Module | Type | Purpose |
|--------|------|---------|
| `model/` | eclipse-plugin | XText grammar (`JslDsl.xtext`), scoping providers, `JslDslValidator.xtend` (~99KB), formatting rules, error messages, and runtime support (`JslParser`, `TypeInfo`, `JslTerminalConverters`) |
| `model-test/` | jar | JUnit 5 tests for parsing (`JslDslParserTest`) and model loading (`JslDslModelLoaderTest`) using XText testing framework |

### Code Generation

| Module | Type | Purpose |
|--------|------|---------|
| `generator-engine/` | bundle (OSGi) | `JslDslGenerator` drives Handlebars templating with SpEL expressions. Loads YAML descriptors defining template-to-output mappings. Supports parallel processing. |
| `generator-maven-plugin/` | maven-plugin | Maven plugin wrapping the generator engine with `generate` goal. Supports layered template URIs, helper classes, and `@TemplateHelper`/`@ContextAccessor` annotation scanning. |
| `generator-maven-plugin-test/` | jar | Integration tests for the Maven plugin |

### Eclipse IDE

| Module | Type | Purpose |
|--------|------|---------|
| `ide/ide-common/` | eclipse-plugin | Content assist proposals and shared IDE functionality |
| `ide/ui/` | eclipse-plugin | Eclipse editor plugin with syntax highlighting |
| `ide/preview-plantuml/` | eclipse-plugin | PlantUML diagram generation from JSL models |
| `ide/feature/` | eclipse-feature | Packages IDE plugins as an installable Eclipse feature |

### OSGi & Distribution

| Module | Type | Purpose |
|--------|------|---------|
| `osgi/` | bundle | Repackages model for OSGi containers. `JslDslModelBundleTracker` tracks model bundles. |
| `osgi-itest/` | jar | Karaf smoke tests (Pax Exam) verifying OSGi deployability |
| `feature/` | eclipse-feature | Eclipse feature repository |
| `site/` | eclipse-repository | P2 update site with version-specific URLs |

### LSP Servers

| Module | Type | Purpose |
|--------|------|---------|
| `server-embedded/` | jar (fat JAR) | Standalone LSP server via Maven Shade. Main class: `org.eclipse.xtext.ide.server.ServerLauncher` |
| `server-web/` | jar (fat JAR) | WebSocket LSP server + Monaco editor frontend. Configurable host, port, context path, and WebSocket path. |

## Technology Stack

### Core Technologies

- **XText 2.39.0** — Language framework (grammar, parser, scoping, validation, serialization, LSP)
- **Xtend** — JVM language used for scoping, validation, and formatting implementations (compiles to Java)
- **Eclipse Modeling Framework (EMF)** — Ecore metamodel infrastructure for the JSL model
- **MWE2** (emf-mwe2-launch 2.15.0) — Model workflow engine that generates XText infrastructure from grammar

### Generation & Runtime

- **Handlebars** — Template engine for code generation
- **Spring 6.2.7 / SpEL** — Expression language for template parameter evaluation
- **Jackson 2.17.2** — JSON processing
- **SLF4J 2.0.16 / Logback 1.5.12** — Logging
- **Lombok 1.18.34** — Used in non-Eclipse modules only (Tycho incompatible)

### Build & Quality

- **Maven 3.9.4** with Maven Wrapper (`./mvnw`)
- **Tycho 4.0.13** — Maven-Eclipse bridge for OSGi/plugin builds
- **Surefire 3.5.1** — Test runner
- **JUnit 5.9.1** (Jupiter + Vintage engines)
- **Apache Karaf 4.4.7 / Pax Exam** — OSGi integration testing
- **Google Guice 5.1.0** — Dependency injection (XText runtime)

## Build Commands

```bash
# Full build and install (uses Maven Wrapper)
./mvnw clean install

# Run all tests
./mvnw clean test

# Run a single test class
./mvnw -pl model-test test -Dtest=JslDslParserTest

# Run a single test method
./mvnw -pl model-test test -Dtest=JslDslParserTest#testSpecificMethod

# Build a specific module
./mvnw -pl generator-engine clean install

# Update Eclipse P2 site category versions
./mvnw clean install -P update-category-versions -f site/pom.xml

# Set version across all modules (Maven + Eclipse)
./mvnw versions:set -DnewVersion=<VERSION>
./mvnw tycho-versions:update-eclipse-metadata
```

### Maven Profiles

| Profile | Purpose |
|---------|---------|
| `modules` | Default active profile; includes all submodules |
| `sign-artifacts` | GPG-sign artifacts for release |
| `release-dummy` | Deploy to local dummy repository (testing) |
| `release-judong` | Deploy to JUDO Nexus repository |
| `release-central` | Deploy to Maven Central with Nexus staging |
| `generate-github-asciidoc-diagrams` | Generate PlantUML diagrams for GitHub rendering |
| `update-source-code-license` | Update license headers in source files |

## Key Configuration Files

| File | Purpose |
|------|---------|
| `pom.xml` | Root POM defining all modules, dependency versions, and build profiles |
| `model/src/main/java/.../JslDsl.xtext` | The complete JSL grammar definition (~43KB) |
| `model/src/main/java/.../validation/JslDslValidator.xtend` | All language validation rules (~99KB) |
| `model/src/workflow/generateModel.mwe2` | MWE2 workflow for regenerating XText infrastructure |
| `logback-test.xml` | Shared test logging configuration (console appender, INFO level) |
| `Generate JSL.launch` | Eclipse launcher: regenerate language model |
| `Launch JSL.launch` | Eclipse launcher: test JSL in Eclipse runtime |

## Development Environment

**Required:**
- Java 21 JDK
- Maven 3.9.4+ (or use `./mvnw`)

**Eclipse IDE (for language development):**
- m2e (Maven integration)
- Modeling Tools (EMF)
- XText, Xtend, MWE, MWE2 features

**Regenerating language infrastructure after grammar changes:**
1. In Eclipse: run `Generate JSL.launch`
2. Or run MWE2 workflow: `hu.blackbelt.judo.meta.jsl.model project src/workflow/generateModel.mwe2`
3. Generated code goes to `src/main/xtext-gen/`, `src/main/xtend-gen/`, `model/generated/` — do not edit manually

## Git Workflow

- **Main Branch:** `develop`
- **Release Branch:** `master` (latest released version)
- **Versioning:** `1.0.3-SNAPSHOT` (current), uses semantic versioning
- **Branching Model:** GitFlow — see [CIFLOW.md](.github/CIFLOW.md) for details
- **CI/CD:** GitHub Actions (`build.yml` → `merge-pr-tagged.yml` → `create-release-on-master.yml`)
- **Commit Rule:** Every commit must reference a JIRA ticket (`JNG-xxx`)

## Important Notes

1. **No Lombok in Eclipse/Tycho modules.** Tycho does not support Lombok generation. Only non-Eclipse modules (generator-engine, osgi-itest) may use Lombok.
2. **Version duality.** Maven `1.0.0-SNAPSHOT` equals Eclipse `1.0.0.qualifier`. The Tycho Versions Plugin synchronizes these during builds.
3. **Generated code is extensive.** `src/main/xtext-gen/`, `src/main/xtend-gen/`, and `model/generated/` are all generated. Never edit these directories — they are regenerated by the MWE2 workflow.
4. **The validator is the largest file.** `JslDslValidator.xtend` at ~99KB contains all semantic validation rules. Changes here require careful testing.
5. **Template layering.** The generator engine supports layered template URIs — later URIs override earlier ones. Templates can be replaced, decorated (via `.override.hbs`), or excluded.
6. **P2 update sites are version-specific.** Each version gets its own update site URL at `https://nexus.judo.technology/repository/p2/judo-meta-jsl/{version}`.
7. **OSGi integration tests** use Karaf + Pax Exam and require a full `install` phase before running.

## Related Documentation

- [README.md](README.md) — Project introduction and quick start
- [CONTRIBUTING.md](CONTRIBUTING.md) — Development setup, code structure, and submission guidelines
- [.github/CIFLOW.md](.github/CIFLOW.md) — Branch strategy, version policy, and CI/CD workflow details
- [generator-maven-plugin/README.md](generator-maven-plugin/README.md) — Generator plugin configuration reference
- [server-web/README.md](server-web/README.md) — Web editor setup and parameters
- [docs/pages/](docs/pages/) — JSL language reference documentation (AsciiDoc)
