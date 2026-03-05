# Grade Calculator Monorepo

This repository is a collection of various grade calculator projects developed in different languages and environments. It is structured to keep multiple independent projects organized within a single repository.

## Repository Structure

The repository is organized into the following subfolders:

*   **`kotlin_calculator/`**: An enhanced Android/Kotlin console application with CSV import/export features.
*   **`dart_calculator/`**: A simple Dart console application for grade calculation.

---

## 1. Kotlin Calculator (`kotlin_calculator/`)

A powerful Kotlin-based console application. It uses a `Student` data class to encapsulate data and logic, providing a clean object-oriented design.

### Features
*   **Interactive Menu:** Choose between manual entry and CSV file processing.
*   **CSV Import/Export:** Batch process grades from files and save detailed reports.
*   **Input Validation:** Robust handling of non-numeric and negative inputs.

### How to Run (Kotlin)
1.  Navigate to the `kotlin_calculator` directory:
    ```bash
    cd kotlin_calculator
    ```
2.  Run the application using the Gradle wrapper:
    ```bash
    ./gradlew :app:runKotlin --console=plain
    ```
    *(Note: The `--console=plain` flag is required for proper interactive input).*

---

## 2. Dart Calculator (`dart_calculator/`)

A straightforward Dart implementation of the grade calculator logic.

### How to Run (Dart)
1.  Navigate to the `dart_calculator` directory:
    ```bash
    cd dart_calculator
    ```
2.  Run the application using the Dart VM:
    ```bash
    dart main.dart
    ```

---

## Shared Grading Logic

Both applications use the following grading scale:

| Average Score | Grade | Status |
| :--- | :--- | :--- |
| 90.0 - 100.0 | A | Pass |
| 80.0 - 89.9 | B | Pass |
| 70.0 - 79.9 | C | Pass |
| 60.0 - 69.9 | D | Pass |
| Below 60.0 | F | Fail |

## Repository Information

*   **Remote URL:** `git@github.com:Bes920/Grade_Calculator.git`
