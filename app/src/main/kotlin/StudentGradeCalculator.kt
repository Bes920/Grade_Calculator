import java.io.File
import java.util.Scanner
import java.util.Locale
import kotlin.system.exitProcess

// Data class to hold all student-related information
data class Student(
    val name: String,
    val scores: List<Double>
) {
    val average: Double = if (scores.isNotEmpty()) scores.average() else 0.0
    val grade: Char = Companion.calculateGrade(average)
    val status: String = if (grade == 'F') "Fail" else "Pass"

    fun generateReport(): String {
        return """
        --- Grade Report ---
        Student: $name
        Scores: ${scores.joinToString()}
        Average Score: ${String.format(Locale.US, "%.2f", average)}
        Grade: $grade
        Status: $status
        --------------------
        """.trimIndent()
    }
    
    // For CSV export
    fun toCsvRow(): String {
        // Format: name,average,grade,status,score1,score2,...
        return "$name,${String.format(Locale.US, "%.2f", average)},$grade,$status,${scores.joinToString(",")}"
    }

    companion object {
        fun calculateGrade(average: Double): Char {
            return when {
                average >= 90.0 -> 'A'
                average >= 80.0 -> 'B'
                average >= 70.0 -> 'C'
                average >= 60.0 -> 'D'
                else -> 'F'
            }
        }
    }
}

fun main() {
    val scanner = Scanner(System.`in`).useLocale(Locale.US)

    while (true) {
        println("\n--- Grade Calculator Menu ---")
        println("1. Enter grades manually")
        println("2. Import grades from a CSV file")
        println("3. Exit")
        print("Choose an option (1-3): ")

        val choice = scanner.nextLine().trim()
        val students = mutableListOf<Student>()

        when (choice) {
            "1" -> {
                val student = enterGradesManually(scanner)
                if (student != null) {
                    students.add(student)
                }
            }
            "2" -> {
                print("Enter the path to the CSV file to import: ")
                val filePath = scanner.nextLine().trim()
                students.addAll(importFromCsv(filePath))
            }
            "3" -> {
                println("Exiting application.")
                exitProcess(0)
            }
            else -> {
                println("Invalid option. Please try again.")
                continue
            }
        }

        if (students.isNotEmpty()) {
            println("\n--- Processing Complete ---")
            students.forEach { println(it.generateReport()) }
            
            print("\nDo you want to export these results to a CSV file? (y/n): ")
            val exportChoice = scanner.nextLine().trim()
            if (exportChoice.equals("y", ignoreCase = true)) {
                print("Enter the path for the export CSV file: ")
                val exportPath = scanner.nextLine().trim()
                exportToCsv(students, exportPath)
            }
        } else {
            println("No student data was processed.")
        }
    }
}

fun enterGradesManually(scanner: Scanner): Student? {
    print("Enter student's name: ")
    val name = scanner.nextLine().trim().takeIf { it.isNotEmpty() } ?: "Unknown"

    val scores = mutableListOf<Double>()
    while (true) {
        print("Enter a score (or 'done' to finish): ")
        val input = scanner.nextLine().trim()
        if (input.equals("done", ignoreCase = true)) break
        if (input.isEmpty()) continue

        val score = input.toDoubleOrNull()
        if (score != null && score >= 0) {
            scores.add(score)
        } else {
            println("Invalid input. Please enter a non-negative number or 'done'.")
        }
    }
    return if (scores.isNotEmpty()) Student(name, scores) else null
}

fun importFromCsv(filePath: String): List<Student> {
    val file = File(filePath)
    if (!file.exists()) {
        println("Error: File not found at '$filePath'")
        return emptyList()
    }

    val students = mutableListOf<Student>()
    try {
        file.forEachLine { line ->
            // Format: name,score1,score2,...
            val parts = line.split(',')
            if (parts.size >= 2) {
                val name = parts[0].trim()
                val scores = parts.drop(1).mapNotNull { it.trim().toDoubleOrNull() }
                if (scores.isNotEmpty()) {
                    students.add(Student(name, scores))
                }
            }
        }
        println("Successfully imported data for ${students.size} students.")
    } catch (e: Exception) {
        println("An error occurred while reading the file: ${e.message}")
    }
    return students
}

fun exportToCsv(students: List<Student>, filePath: String) {
    val file = File(filePath)
    try {
        file.printWriter().use { out ->
            // Write header
            out.println("Name,Average Score,Grade,Status,Scores...")
            students.forEach { student ->
                out.println(student.toCsvRow())
            }
        }
        println("Successfully exported results to '$filePath'")
    } catch (e: Exception) {
        println("An error occurred while writing to the file: ${e.message}")
    }
}
