Contacts Manager
================

App to manage contacts

TODO
----

- Localize for different languages
- Tests + UI Tests
- App Store submission
- Capture logging and crashes

### Long term todos

- Fuzzy search
- Master detail view - render all contacts
- Search - include contacts in group search at bottom
  - Performance?
- (maybe) Sort by members etc
  - Stateful

Development
-----------
### Of note

- Setup permissions
  - https://developer.apple.com/documentation/contacts/requesting_authorization_to_access_contacts
  - https://useyourloaf.com/blog/xcode-13-missing-info.plist/
- Random warnings when running in mac target
  - https://stackoverflow.com/questions/70985060/im-trying-to-run-an-app-but-im-getting-an-error-which-says-could-not-find-trans
- CoreData basics:
  - https://blckbirds.com/post/core-data-and-swiftui/
- Swifty Contacts lib reference code
  - https://github.com/SwiftyContacts/SwiftyContacts/blob/master/Sources/SwiftyContacts/SwiftyContacts.swift
- Learn to iOS, swift ui with Stanford CS193P
  - https://www.youtube.com/watch?v=oWZOFSYS5GE&list=PLpGHT1n4-mAsxuRxVPv7kj4-dQYoC3VVu&index=9
- Fuzzy Search tutorial
  - https://www.objc.io/blog/2020/08/18/fuzzy-search/

### Reference docs to supplement Apple docs

- Swift UI text sizes:
  - https://sarunw.com/posts/how-to-change-swiftui-font-size/
- Swipe Actions for Lists:
  - https://peterfriese.dev/posts/swiftui-listview-part4/
  - https://www.hackingwithswift.com/quick-start/swiftui/how-to-add-custom-swipe-action-buttons-to-a-list-row
- String format specifiers Apple
  - https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Strings/Articles/formatSpecifiers.html

### Swift Format

Setup:

```sh
brew install swift-format
swift-format -m dump-configuration > swift-format-configuration.json
```

In Project -> Target -> Build Phases, add a `Run Script - swift-format`. Add the following script

```sh
if which swift-format >/dev/null; then
    swift-format -m format -i -r --configuration swift-format-configuration.json ${PROJECT_DIR}
else
    echo "error: swift-format not installed"
    exit 1
fi
```

### Swift Lint

Setup:

```sh
brew install swiftlint
```

In Project -> Target -> Build Phases, add a `Run Script - swift-lint`. Add the following script

```sh
if which swiftlint >/dev/null; then
    # Relative path from the .xcodeproj which contains this script
    swiftlint lint –config swiftlint.yml
else
    echo "error: SwiftLint not installed"
    exit 1
fi
```

### Keyboard shortcuts

- ⌘⌥⌃/ - Search Documentation for Selected Text (Help Menu)

Reference
---------

https://icons8.com/icons/set/contacts

<a target="_blank" href="https://icons8.com/icon/T5URFachnKRD/contacts">Contacts</a> icon by <a target="_blank" href="https://icons8.com">Icons8</a>
