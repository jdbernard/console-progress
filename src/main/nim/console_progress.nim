import strutils, times, math

type Progress* = ref object of RootObj
  sout: File
  lastStep, maxSteps: int
  startTime: float
  lastLinePrinted, lastInfo: string
  maxValue: BiggestInt

proc getMax*(pd: Progress): BiggestInt =
  return pd.maxValue

proc setMax*(pd: Progress, maxValue: BiggestInt) =
  pd.maxValue = max(maxValue, 1)

proc newProgress*(sout: File, maxValue: BiggestInt): Progress =
  return Progress(sout: sout,
    startTime: cpuTime(),
    lastStep: 0,
    lastLinePrinted: "",
    maxValue: maxValue,
    maxSteps: 30)

proc updateProgress*(pd: Progress, newValue: BiggestInt, info: string): void =

  # Calculate progress
  let value = min(newValue, pd.maxValue)
  let curStep = floor((value.BiggestFloat / pd.maxValue.BiggestFloat) * pd.maxSteps.float).int
  let curPercent = value.BiggestFloat / pd.maxValue.BiggestFloat

  if info == pd.lastInfo and curStep == pd.lastStep: return

  let curTime = cpuTime()
  let remTime = ((curTime / curPercent) - curTime) * 1000
  let displayedSteps = max(curStep - 1, 0)

  pd.lastInfo = info
  var displayedInfo = info
  if displayedInfo.len > 16: displayedInfo = info[0..15]
  if displayedInfo.len < 16:
    displayedInfo = displayedInfo & ' '.repeat(16 - displayedInfo.len)

  pd.sout.write('\b'.repeat(pd.lastLinePrinted.len))

  pd.lastLinePrinted =
    '='.repeat(displayedSteps) & (if curStep > 0: "0" else: "") &
    '-'.repeat(pd.maxSteps - curStep) & " " &
    displayedInfo & " -- (" &
    (curPercent * 100).formatFloat(ffDecimal, 2) & "%" 

  if curPercent > 0.05:
    pd.lastLinePrinted &= ", "
    if remTime > 60:
      pd.lastLinePrinted &= $floor(remTime / 60).int & "m "
    pd.lastLinePrinted &= $ceil(remTime mod 60) & "s"

  pd.lastLinePrinted &= ")"

  pd.sout.write(pd.lastLinePrinted)
  pd.lastStep = curStep

  pd.sout.flushFile

proc erase*(pd: Progress): void =
  pd.sout.write('\b'.repeat(pd.lastLinePrinted.len))
  pd.sout.write(' '.repeat(pd.lastLinePrinted.len))
  pd.sout.write('\b'.repeat(pd.lastLinePrinted.len))
  pd.lastLinePrinted = ""
