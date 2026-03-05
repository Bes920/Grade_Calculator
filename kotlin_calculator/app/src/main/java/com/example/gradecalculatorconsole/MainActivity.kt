package com.example.gradecalculatorconsole

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.TextFieldValue
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import java.util.Locale

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MaterialTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    GradeCalculatorScreen()
                }
            }
        }
    }
}

@Composable
fun GradeCalculatorScreen() {
    var studentName by remember { mutableStateOf(TextFieldValue("")) }
    var currentScore by remember { mutableStateOf(TextFieldValue("")) }
    val scores = remember { mutableStateListOf<Double>() }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(text = "Grade Calculator", fontSize = 24.sp, modifier = Modifier.padding(bottom = 16.dp))

        OutlinedTextField(
            value = studentName,
            onValueChange = { studentName = it },
            label = { Text("Student Name") },
            modifier = Modifier.fillMaxWidth()
        )

        Spacer(modifier = Modifier.height(8.dp))

        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            OutlinedTextField(
                value = currentScore,
                onValueChange = { currentScore = it },
                label = { Text("Enter Score") },
                modifier = Modifier.weight(1f)
            )
            Button(
                onClick = {
                    currentScore.text.toDoubleOrNull()?.let {
                        if (it in 0.0..100.0) {
                            scores.add(it)
                            currentScore = TextFieldValue("")
                        }
                    }
                },
                modifier = Modifier.padding(start = 8.dp)
            ) {
                Text("Add")
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        Text(text = "Scores added: ${scores.size}", fontSize = 16.sp)

        LazyColumn(
            modifier = Modifier
                .weight(1f)
                .fillMaxWidth()
                .padding(vertical = 8.dp)
        ) {
            items(scores) { score ->
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 4.dp)
                ) {
                    Text(text = score.toString(), modifier = Modifier.padding(8.dp))
                }
            }
        }

        if (scores.isNotEmpty()) {
            val average = scores.average()
            val grade = calculateGrade(average)
            
            Card(
                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.primaryContainer),
                modifier = Modifier.fillMaxWidth()
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text(text = "Results for ${studentName.text.ifEmpty { "Unknown" }}", fontSize = 18.sp)
                    Text(text = "Average: ${String.format(Locale.US, "%.2f", average)}", fontSize = 16.sp)
                    Text(text = "Grade: $grade", fontSize = 16.sp)
                    Text(text = "Status: ${if (grade == 'F') "Fail" else "Pass"}", fontSize = 16.sp)
                }
            }
        }

        Button(
            onClick = {
                studentName = TextFieldValue("")
                currentScore = TextFieldValue("")
                scores.clear()
            },
            modifier = Modifier.padding(top = 16.dp),
            colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.error)
        ) {
            Text("Reset All")
        }
    }
}

fun calculateGrade(average: Double): Char = when {
    average >= 90.0 -> 'A'
    average >= 80.0 -> 'B'
    average >= 70.0 -> 'C'
    average >= 60.0 -> 'D'
    else -> 'F'
}
