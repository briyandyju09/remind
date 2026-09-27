# ReMind

> A Flutter app that curbs over-consumption by tracking what you already own.

## Stack

- **Framework:** Flutter (Dart, SDK `>=3.0.0 <4.0.0`)
- **State management:** `provider`
- **Local storage:** [Hive](https://pub.dev/packages/hive) (`hive`, `hive_flutter`)
- **Utilities:** `uuid`, `intl`, `shared_preferences`

## Description

ReMind is a Flutter mobile app designed to help users track their purchased items, manage their
inventory, and reduce over-consumption. By giving a clear overview of what they already own,
users can make more informed purchasing decisions, avoid buying duplicates, and be more mindful
of their consumption habits.

## Features

- **Inventory Management:** keep a digital record of all your items.
- **Receipt Scanner:** add items by scanning shopping receipts.
- **Grocery List Checker:** check a shopping list against your inventory to avoid rebuying things you already have.
- **Search & Filter:** quickly find items with search and filtering.
- **Smart Sorting:** sort by name, category, date added, or items running low.
- **Local Storage:** data is stored on-device (Hive).

> **Prototype note:** the **receipt OCR**, **suggestions**, and **analytics** are currently
> **simulated** (backed by mock services). The data flow and UI are in place, but real OCR and
> analytics are not wired up yet.

## How to Build / Run

### Dependencies

- Flutter SDK (`>=3.0.0 <4.0.0`)
- Android Studio or VS Code with a connected device/emulator

### Steps

```bash
git clone https://github.com/briyandyju09/remind.git
cd remind
flutter pub get
flutter run
```

## Version History

- **1.0.0** — Initial release

## License

Released under the [MIT License](LICENSE).
