package com.jdbernard.util

/**
 * Controls a console-based progress bar.
 * This bar has two totals, an overall process total and an individual file
 * total. The overall total is 0-based because the current value is incomplete
 * (the file counter is the partial completion of the current step). The file
 * counter is 1-based because the current step is complete for this counter.
 * @author Jonathan Bernard (jdbernard@gmail.com)
 */
public class ConsoleProgressBar {
  int WIDTH = 79
  int MAX_STEP = 35

  long max = 10
  def out = System.out
  private int lastStepAmount = -1
  private String lastInfo = ""
  private long startTime

  public void setMax(long max) {
    this.max = Math.max(max, 1) }

  public void update(long value, String info) {
    if (value == 0 || startTime == 0)
        startTime = System.currentTimeMillis()

    def curStep
    def curPercent
    def curTime
    def remTime

    value = Math.min(value, max)

    curStep = Math.floor((value/max) * MAX_STEP)
    curPercent  = ((double) value / (double) max)

    if (info != lastInfo || curStep != lastStepAmount) {
      // time so far
      curTime = System.currentTimeMillis() - startTime
      // estimate total time based on how far we are
      remTime = (curTime / curPercent) - curTime
      remTime /= 1000

      def numEq = Math.max(curStep - 1, 0)
      def remMin = curPercent < 0.05 ? '?' : (long) (remTime / 60)
      def remSec = curPercent < 0.05 ? '?' : (long) (((remTime / 60.0) - remMin) * 60)

      lastInfo = info
      if (info.length() > 16) info = info[0..<16]
      if (info.length() < 16) info = info.padRight(16)

      out.print '\b' * WIDTH
      def line = = '=' * numEq + (curStep > 0 ? "0" : "") + '-' * (MAX_STEP - curStep)
      line += " ${info} -- (" +
        "${String.format('%5.2f', curPercent * 100)}%, ${remMin ? remMin + 'm ' : ''}${remSec}s)       "
      out.print line.padRight(WIDTH)
      lastStepAmount = curStep;
    }
    out.flush()
  }

  public void erase() {
      out.print ('\b' * WIDTH) + (' ' * WIDTH) + ('\b' * WIDTH)
  }
}
