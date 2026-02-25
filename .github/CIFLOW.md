# Development Version and Branch Handling

This document describes the branching strategy, version numbering policy, and CI/CD workflow automation used across JUDO NG modules.

## Branching Strategy

The project follows a **GitFlow-based** branching model. Each branch type serves a specific purpose in the development and release lifecycle:

| Branch Pattern | Purpose | Based On |
|---------------|---------|----------|
| `develop` | Active development of the latest version | — |
| `feature/JNG-<number>_<summary>` | New feature work | `develop` |
| `(release/)<version>` | Release stabilization and testing | `develop` |
| `bugfix/JNG-<number>_<summary>` | Bug fixes during release testing | Release branch |
| `support/JNG-<number>_<summary>` | Minor changes to a previous release | Release branch |
| `hotfix/JNG-<number>_<summary>` | Urgent fixes for production | `master` |
| `master` | Latest released sources | Merged from release |

```mermaid
gitGraph
    commit id: "initial"
    branch develop
    checkout develop
    commit id: "dev-1"
    branch feature/JNG-1
    checkout feature/JNG-1
    commit id: "feat-1"
    commit id: "feat-2"
    checkout develop
    merge feature/JNG-1 id: "merge-feat-1"
    branch feature/JNG-2
    checkout feature/JNG-2
    commit id: "feat-3"
    checkout develop
    merge feature/JNG-2 id: "merge-feat-2"
    branch release/1.0-beta1
    checkout release/1.0-beta1
    commit id: "stabilize"
    branch bugfix/JNG-3
    checkout bugfix/JNG-3
    commit id: "fix-1"
    checkout release/1.0-beta1
    merge bugfix/JNG-3 id: "merge-fix"
    checkout develop
    merge release/1.0-beta1 id: "back-merge"
    checkout main
    merge release/1.0-beta1 id: "release-1.0"
```

## Version Numbers

Versions follow **semantic versioning** with these rules:

| Event | Version Change | Example |
|-------|---------------|---------|
| Start a feature branch | No change | Inherits from `develop` |
| Start a release branch | Bump 2nd number on `develop` | `1.1.0-SNAPSHOT` → `1.2.0-SNAPSHOT` |
| Start a bugfix branch | No change | Inherits from release branch |
| Start a support branch | Bump 3rd number | `1.0.0` → `1.0.1` |
| Start a hotfix branch | Bump 4th number | `1.0.0` → `1.0.0.1` |

## GitHub Actions CI/CD Workflows

The project uses a chain of GitHub Actions workflows that trigger each other. Here is how they connect:

### build.yml — Main Build Pipeline

This is the primary workflow, triggered on pushes to `develop` or pull requests targeting `develop`, `master`, `increment/*`, or `release/*` branches.

```mermaid
flowchart TD
    trigger["Push on develop<br/>or PR on develop/master/increment/release"]
    branch_check{"Base branch type?"}
    version_release["Set version from pom.xml<br/>(without -SNAPSHOT)"]
    version_dev["Set version<br/>major.minor.qualifier.date_commitId_branch"]
    build["Build and deploy to Nexus"]
    tag["Create git tag v&lt;version&gt;"]
    is_release{"increment/* or<br/>release/* branch?"}
    merge_tag["Create tag merge-pr/&lt;version&gt;"]
    trigger_merge["Trigger merge-pr-tagged.yml"]
    is_develop{"develop branch?"}
    changelog["Build changelog"]
    gh_release["Create GitHub prerelease"]
    done["Done"]

    trigger --> branch_check
    branch_check -->|master, release/*| version_release
    branch_check -->|develop, increment/*| version_dev
    version_release --> build
    version_dev --> build
    build --> tag
    tag --> is_release
    is_release -->|Yes| merge_tag
    merge_tag --> trigger_merge
    is_release -->|No| is_develop
    trigger_merge --> is_develop
    is_develop -->|Yes| changelog
    changelog --> gh_release
    gh_release --> done
    is_develop -->|No| done
```

### merge-pr-tagged.yml — PR Merge Automation

Triggered when a `merge-pr/*` tag is pushed. Routes the merge based on version format:

```mermaid
flowchart TD
    trigger["Push on merge-pr/* tag"]
    extract["Extract version from tag"]
    check{"Version format?"}
    merge_master["Merge PR to master"]
    trigger_release["Trigger create-release-on-master.yml"]
    squash_develop["Squash PR to develop"]
    trigger_build["Trigger build.yml"]
    cleanup["Delete merge-pr/* tag"]

    trigger --> extract
    extract --> check
    check -->|"major.minor.qualifier<br/>(release format)"| merge_master
    merge_master --> trigger_release
    check -->|"other format<br/>(dev snapshot)"| squash_develop
    squash_develop --> trigger_build
    trigger_release --> cleanup
    trigger_build --> cleanup
```

### create-release-on-master.yml — Release Finalization

Triggered on pushes to `master`. Creates a final GitHub release with a generated changelog.

### release.yml — Manual Release Trigger

Manually triggered with a version parameter (or `auto` to use the pom.xml version):

```mermaid
flowchart TD
    trigger["Manual trigger with version"]
    check{"Version = 'auto'?"}
    from_pom["Read version from pom.xml<br/>(strip -SNAPSHOT)"]
    use_given["Use given version"]
    calc_next["Calculate next version<br/>(qualifier + 1)"]
    pr_master["Create PR on master<br/>with release version"]
    pr_develop["Create PR on develop<br/>with next version"]
    build1["Trigger build.yml"]
    build2["Trigger build.yml"]

    trigger --> check
    check -->|Yes| from_pom
    check -->|No| use_given
    from_pom --> calc_next
    use_given --> calc_next
    calc_next --> pr_master
    calc_next --> pr_develop
    pr_master --> build1
    pr_develop --> build2
```

### Complete Workflow Chain

```mermaid
graph LR
    build["build.yml<br/><i>Build & Deploy</i>"]
    merge["merge-pr-tagged.yml<br/><i>PR Merge Router</i>"]
    release_master["create-release-on-master.yml<br/><i>Final Release</i>"]
    release_manual["release.yml<br/><i>Manual Release</i>"]

    build -->|"creates merge-pr/* tag"| merge
    merge -->|"merges to master"| release_master
    merge -->|"squashes to develop"| build
    release_manual -->|"creates PRs"| build
```

## Development Rules

> **Important:** There is no commit without a ticket number. Every pull request and commit must reference a JIRA ticket in the format `JNG-xxx`.

Issue tracking is managed through [JIRA](https://blackbelt.atlassian.net/jira/dashboards).
