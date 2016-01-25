# Console Progress Bar

Simple progress bar for long-running operations.

## Java/Groovy

Build with gradle:

    gradle assemble


Example usage:

```java
import com.jdbernard.util.ConsoleProgressBar

// ...

ConsoleProgressBar progressBar = new ConsoleProgressBar()
progressBar.setOut(System.out) // optional
progressBar.setMax(100)

for (int i = 0; i <= 100; i++) {
  progressBar.update(i, "Message for " + i);
  Thread.sleep(500);
}
```

## Nim

Install the library using nimble:

    nimble install

Example usage:

```nim
import os, console_progress

var progress = newProgress(sout = stdout, maxValue = 100)

for i in 0..100:
  progress.updateProgress(i, "Message for " & i)
  sleep(500)
```
