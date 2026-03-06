fun main() {
    val words = listOf("apple", "cat", "banana", "dog", "elephant")
    
    // Create a map where keys are strings and values are their lengths
    val wordLengths = words.associateWith { it.length }
    
    // Filter for lengths greater than 4 and print
    wordLengths.filter { it.value > 4 }
        .forEach { (word, length) ->
            println("$word has length $length")
        }
}
