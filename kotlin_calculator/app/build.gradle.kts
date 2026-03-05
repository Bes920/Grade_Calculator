plugins {
    alias(libs.plugins.android.application)
}

android {
    namespace = "com.example.gradecalculatorconsole"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.example.gradecalculatorconsole"
        minSdk = 24
        targetSdk = 36
        versionCode = 1
        versionName = "1.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
}

dependencies {
    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.appcompat)
    implementation(libs.material)
    testImplementation(libs.junit)
    androidTestImplementation(libs.androidx.junit)
    androidTestImplementation(libs.androidx.espresso.core)
}

// Custom task to run the Kotlin console app
tasks.register<JavaExec>("runKotlin") {
    group = "application"
    mainClass.set("StudentGradeCalculatorKt")
    
    val compileKotlin = tasks.named("compileDebugKotlin", org.jetbrains.kotlin.gradle.tasks.KotlinCompile::class.java)
    dependsOn(compileKotlin)
    
    classpath = files(
        compileKotlin.map { it.destinationDirectory },
        configurations.getByName("debugRuntimeClasspath")
    )
    standardInput = System.`in`
}
