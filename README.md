# Grade Calculator Console Application

A simple but powerful Kotlin-based console application to calculate student grades. It is integrated into an Android project structure and can be run directly from the terminal using Gradle.

This enhanced version supports both manual grade entry and batch processing through CSV file import/export.

## Features

*   **Object-Oriented Design:** Uses a `Student` data class to cleanly encapsulate all student-related data and logic.
*   **Interactive Menu:** A user-friendly menu to choose between manual input and CSV import.
*   **Manual Entry:** Prompts for a student's name and multiple scores.
*   **CSV Import:** Batch process multiple students by importing data from a `.csv` file.
*   **CSV Export:** Save a detailed grade report for one or more students to a `.csv` file.
*   **Input Validation:** Gracefully handles invalid, non-numeric, and negative inputs.
*   **Automatic Calculation:** Calculates the average score, assigns a letter grade (A-F), and determines the pass/fail status.

## How to Run

1.  Open your terminal in the project root directory.
2.  Execute the following command:

```bash
./gradlew :app:runKotlin --console=plain
```

3.  Once the application starts, you will see the main menu. Follow the on-screen prompts.

> **Note:** The `--console=plain` flag is required to disable Gradle's rich output, allowing the application to correctly capture your keyboard input.

## Using the Import/Export Features

### CSV Import Format

To import grades, create a `.csv` file where each line represents one student. The format must be:

`Student Name,Score1,Score2,Score3,...`

**Example (`grades-to-import.csv`):**
```csv
Alice Smith,92,88,95
Bob Johnson,78,65,72
Charlie Brown,55,61,58
```

When prompted, provide the **full, absolute path** to this file.

### CSV Export Format

After processing, you can export the results. The generated file will contain a header and detailed information for each student:

`Name,Average Score,Grade,Status,Scores...`

**Example (`grades-report.csv`):**
```csv
Name,Average Score,Grade,Status,Scores...
Alice Smith,91.67,A,Pass,92.0,88.0,95.0
Bob Johnson,71.67,C,Pass,78.0,65.0,72.0
Charlie Brown,58.00,F,Fail,55.0,61.0,58.0
```

When prompted, provide a **full, absolute path and filename** for the export file (e.g., `/path/to/your/folder/report.csv`).

## Grading Logic

| Average Score | Grade | Status |
| :--- | :--- | :--- |
| 90.0 - 100.0 | A | Pass |
| 80.0 - 89.9 | B | Pass |
| 70.0 - 79.9 | C | Pass |
| 60.0 - 69.9 | D | Pass |
| Below 60.0 | F | Fail |

## Repository Information

*   **Remote URL:** `git@github.com:Bes920/Grade_Calculator.git`
