# Adding a feature

Keep related screens together by capability. Agree the feature names and screen ownership before implementing the Figma screens; no business feature has been scaffolded prematurely.

Create only the layers that have real responsibilities:

```text
<feature>/
  presentation/
    pages/
    widgets/
    cubit/
  domain/
    entities/
    repositories/
  data/
    models/
    datasources/
    repositories/
```

Presentation depends on domain contracts. Data implements those contracts. Domain stays pure Dart. App composition registers implementations and supplies Cubits at route boundaries.

Do not read repositories or SDKs from widgets. Constructor-inject repository interfaces into Cubits so an agreed mock implementation can later be replaced by Firebase through DI.

See [ARCHITECTURE.md](../../ARCHITECTURE.md) for route registration, naming, localization, dependency ownership, tests, and the team handover.
