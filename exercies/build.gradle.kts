plugins {
    alias(libs.plugins.kotlin.jvm)
}

sourceSets {
    getByName("main") {
        kotlin.setSrcDirs(listOf("."))
    }
}

dependencies {
    implementation(kotlin("stdlib"))
}

tasks.register<JavaExec>("runExercise1") {
    mainClass.set("Exercise1Kt")
    classpath = sourceSets.main.get().runtimeClasspath
}

tasks.register<JavaExec>("runExercise2") {
    mainClass.set("Exercise2Kt")
    classpath = sourceSets.main.get().runtimeClasspath
}

tasks.register<JavaExec>("runExercise3") {
    mainClass.set("Exercise3Kt")
    classpath = sourceSets.main.get().runtimeClasspath
}
