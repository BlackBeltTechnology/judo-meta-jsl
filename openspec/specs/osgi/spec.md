# osgi Specification

## Purpose

Repackages the JSL model module as an OSGi bundle and provides automatic discovery and registration of JSL models from deployed OSGi bundles, enabling use in transformation pipelines running in standard OSGi containers (Apache Karaf).

## Architecture

The module contains a single key class:

- `JslDslModelBundleTracker` — An OSGi Declarative Services component (`@Component(immediate = true)`) that tracks bundles declaring JSL models via the `JslDsl-Models` manifest header. Uses `BundleTrackerManager` to monitor bundle lifecycle and registers discovered models as OSGi services.

Inner classes:
- `JslDslBundlePredicate` — Tests if a bundle's manifest contains the `JslDsl-Models` header.
- `JslDslRegisterCallback` — Parses JSL files from matched bundles and registers `JslDslModel` as an OSGi service.
- `JslDslUnregisterCallback` — Unregisters `JslDslModel` services when bundles are stopped.

## Requirements

### Requirement: Bundle tracking activation

`JslDslModelBundleTracker` SHALL start tracking OSGi bundles on component activation and stop on deactivation.

#### Scenario: Activate tracker
- **GIVEN** the OSGi container starts the component
- **WHEN** `activate(ComponentContext)` is called
- **THEN** a `BundleTrackerManager` is started, scanning for bundles with `JslDsl-Models` headers

#### Scenario: Deactivate tracker
- **GIVEN** the tracker is active
- **WHEN** `deactivate(ComponentContext)` is called
- **THEN** all tracked model registrations are cleaned up

### Requirement: JSL model discovery

The tracker SHALL detect bundles containing JSL models based on the `JslDsl-Models` manifest header.

#### Scenario: Bundle with JSL models deployed
- **GIVEN** an OSGi bundle with `JslDsl-Models` manifest header pointing to `.jsl` resources
- **WHEN** the bundle enters the `ACTIVE` state
- **THEN** `JslDslBundlePredicate` matches the bundle and `JslDslRegisterCallback` processes it

### Requirement: Model registration as OSGi service

Discovered JSL models SHALL be registered as `JslDslModel` OSGi services.

#### Scenario: Register model
- **GIVEN** a bundle containing valid `.jsl` files referenced by its manifest
- **WHEN** the register callback processes the bundle
- **THEN** the JSL files are parsed using `JslParser` and a `JslDslModel` service registration is created

#### Scenario: Unregister model on bundle stop
- **GIVEN** a bundle with a registered `JslDslModel` service
- **WHEN** the bundle is stopped
- **THEN** the `JslDslModel` service registration is unregistered and removed from the cache
