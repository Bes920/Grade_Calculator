import java.util.Scanner
import java.util.Locale

fun main() {
    val scanner = Scanner(System.`in`).useLocale(Locale.US)

    println("Enter student's name:")
    val name = if (scanner.hasNextLine()) scanner.nextLine() else "Unknown"

    val scores = mutableListOf<Double>()
    
    while (true) {
        println("Enter a score (or 'done' to finish):")
        if (!scanner.hasNextLine()) break
        
        val input = scanner.nextLine().trim()
        
        if (input.equals("done", ignoreCase = true)) {
            break
        }
        
        if (input.isEmpty()) continue

        val score = input.toDoubleOrNull()
        if (score != null) {
            if (score >= 0) {
                scores.add(score)
            } else {
                println("Please enter a non-negative score.")
            }
        } else {
            println("Invalid input. Please enter a number or 'done'.")
        }
    }

    if (scores.isNotEmpty()) {
        val average = scores.average()
        val grade = calculateGrade(average)
        val status = if (grade == 'F') "Fail" else "Pass"

        println("\n--- Grade Report ---")
        println("Student: $name")
        println("Average Score: ${String.format(Locale.US, "%.2f", average)}")
        println("Grade: $grade")
        println("Status: $status")
        println("--------------------")
    } else {
        println("No scores entered. Cannot calculate grade.")
    }
}

fun calculateGrade(average: Double): Char {
    return when {
        average >= 90.0 -> 'A'
        average >= 80.0 -> 'B'
        average >= 70.0 -> 'C'
        average >= 60.0 -> 'D'
        else -> 'F'
    }
}
