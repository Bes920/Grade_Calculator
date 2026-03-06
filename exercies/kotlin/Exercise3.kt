data class Person(val name: String, val age: Int)

fun main() {
    val people = listOf(
        Person("Alice", 25),
        Person("Bob", 30),
        Person("Charlie", 35),
        Person("Anna", 22),
        Person("Ben", 28)
    )

    // Filter people whose name starts with 'A' or 'B'
    val filteredPeople = people.filter { it.name.startsWith("A") || it.name.startsWith("B") }

    // Extract ages
    val ages = filteredPeople.map { it.age }

    // Calculate average
    val averageAge = if (ages.isNotEmpty()) ages.average() else 0.0

    // Format and print rounded to one decimal place
    println("Average age of people starting with A or B: ${String.format("%.1f", averageAge)}")
}
