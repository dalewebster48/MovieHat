# MovieHat

MovieHat is a family movie night app. Multiple users in a family can share a "hat" in which they enter the names of movies they want to watch. On movie night, the app draws a random movie name from the hat, removing it from the selection pool so the same movie isn't picked twice.

## Current State (MVP)

- Single user, all data stored locally in UserDefaults
- Single home screen where the user can add movies to the hat, see how many are in it, and draw a random movie

## Future Plans

- Multi-user support with shared hats across a family
- Remote server backend (the repository protocol layer is designed for this swap)

## Build

```
xcodebuild -project MovieHat.xcodeproj -scheme MovieHat -destination 'platform=iOS Simulator,name=iPhone 16' -quiet build
```
