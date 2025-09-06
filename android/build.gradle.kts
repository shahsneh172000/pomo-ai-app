
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // Set NDK version for all subprojects if needed
    project.extensions.findByName("android")?.let { ext ->
        ext as org.gradle.api.plugins.ExtensionAware
        ext.extensions.extraProperties["ndkVersion"] = "29.0.13846066" // <-- Set your installed NDK version here
    }

}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
