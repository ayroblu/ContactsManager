Contacts Manager
================

App to manage contacts

TODO
----

1. Sync from google / local contacts
2. Manage contacts with tags
  - Checkbox - add tag
  - Query language - filter by multiple tags, no tags

### Fundamentals

- Init
  - If not setup - setup contacts sync
  - If setup go to contacts listview
- Contacts listview
  - rows of contact information
- Right Sidebar
  - Add filter to contacts by query language
- Settings
  - Display settings?
  - Configure sync
- Contacts full view
  - editable details

Development
-----------
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

Reference
---------

https://icons8.com/icons/set/contacts

<a target="_blank" href="https://icons8.com/icon/T5URFachnKRD/contacts">Contacts</a> icon by <a target="_blank" href="https://icons8.com">Icons8</a>
