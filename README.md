# Grade Calculator Console Application

A simple Kotlin-based console application designed to calculate student grades based on multiple score inputs. This project is integrated into an Android project structure and can be run directly from the terminal using Gradle.

## Features

*   **Interactive Input:** Prompts for student name and multiple scores.
*   **Input Validation:** Handles non-numeric and negative inputs gracefully.
*   **Automatic Calculation:** Calculates the average score, assigns a letter grade (A-F), and determines the pass/fail status.
*   **Formatted Output:** Displays a clean grade report in the terminal.

## Grading Logic

| Average Score | Grade | Status |
| :--- | :--- | :--- |
| 90.0 - 100.0 | A | Pass |
| 80.0 - 89.9 | B | Pass |
| 70.0 - 71.9 | C | Pass |
| 60.0 - 69.9 | D | Pass |
| Below 60.0 | F | Fail |

## Prerequisites

*   **JDK 11 or higher** (The project is configured for compatibility with Java 11).
*   **Gradle** (Included via the Gradle Wrapper `./gradlew`).

## How to Run

To run the application, open your terminal in the project root directory and execute the following command:

```bash
./gradlew :app:runKotlin --console=plain
```

### Why use `--console=plain`?
The `--console=plain` flag is required to disable Gradle's rich output (progress bars, etc.), allowing the application to correctly capture your keyboard input for the student's name and scores.

## Repository Information

*   **Remote URL:** `git@github.com:Bes920/Grade_Calculator.git`
