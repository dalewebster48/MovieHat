# MovieHat

MovieHat is a family movie night app. Multiple users in a family can share a "hat" in which they enter the names of movies they want to watch. On movie night, the app draws a random movie name from the hat, removing it from the selection pool so the same movie isn't picked twice.

## Current State (MVP)

- Single user, all data stored locally in SQLite
- Home screen shows movies in the hat with poster images, and allows drawing a random movie
- Add movie screen searches IMDB and tapping a result adds it to the hat

## Architecture Notes

- `Networking/` — `NetworkClient` protocol and `URLSessionNetworkClient`. Infrastructure layer created in `AppContext` and passed to `DataAccessContainer`. IMDB-specific endpoints and request types live in their respective repository files.
- `DataAccess/DatabaseProvider.swift` — Owns the SQLite connection (via SQLite.swift SPM package), creates the database file, and runs schema migrations.
- `Movie` is the single domain model (consolidated from the former `Movie` and `MovieMetadata` types). Contains IMDB id, title, year, runtime, genres, plot, rating, and poster URL.
- `MovieSearchRepository` / `IMDBMovieSearchRepository` — searches IMDB API, returns `[Movie]`.
- `MovieHatRepository` / `SQLiteMovieHatRepository` — persists hat movies in SQLite.
- `MovieSearchService` / `MovieSearchServiceImpl` — search service layer.
- `MovieHatService` / `MovieHatServiceImpl` — hat operations (add, list, draw random).

## Future Plans

- Multi-user support with shared hats across a family
- Remote server backend (the repository protocol layer is designed for this swap)

## Build

```
xcodebuild -project MovieHat.xcodeproj -scheme MovieHat -destination 'platform=iOS Simulator,name=iPhone 17' -quiet build
```
