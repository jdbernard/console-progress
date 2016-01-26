import strutils, times, math

type Progress* = ref object of RootObj
  sout: File
  lastStep, width, maxSteps: int
  startTime: float
  lastInfo: string
  maxValue: BiggestInt

proc getMax*(pd: Progress): BiggestInt =
  return pd.maxValue

proc setMax*(pd: Progress, maxValue: BiggestInt) =
  pd.maxValue = max(maxValue, 1)

proc newProgress*(sout: File, maxValue: BiggestInt): Progress =
  return Progress(sout: sout,
    startTime: cpuTime(),
    lastStep: 0,
    maxValue: maxValue,
    width: 79,
    maxSteps: 35)

proc updateProgress*(pd: Progress, newValue: BiggestInt, info: string): void =

  # Calculate progress
  let value = min(newValue, pd.maxValue)
  let curStep = floor((value.BiggestFloat / pd.maxValue.BiggestFloat) * pd.maxSteps.float).int
  let curPercent = value.BiggestFloat / pd.maxValue.BiggestFloat

  if info == pd.lastInfo and curStep == pd.lastStep: return

  let curDuration = cpuTime() - pd.startTime
  let remTime = ((curDuration / curPercent) - curDuration)
  let displayedSteps = max(curStep - 1, 0)

  pd.lastInfo = info
  var displayedInfo = info
  if displayedInfo.len > 16: displayedInfo = info[0..15]
  if displayedInfo.len < 16:
    displayedInfo = displayedInfo & ' '.repeat(16 - displayedInfo.len)

  pd.sout.write('\b'.repeat(pd.width))

  var line =
    '='.repeat(displayedSteps) & (if curStep > 0: "0" else: "") &
    '-'.repeat(pd.maxSteps - curStep) & " " &
    displayedInfo & " -- (" &
    (curPercent * 100).formatFloat(ffDecimal, 2) & "%" 

  if curPercent > 0.05:
    line &= ", "
    if remTime > 60:
      line &= $floor(remTime / 60).int & "m "
    line &= $ceil(remTime mod 60) & "s"

  line &= ")"
  line &= spaces(max(pd.width - line.len, 0))

  pd.sout.write(line)
  pd.lastStep = curStep

  pd.sout.flushFile

proc erase*(pd: Progress): void =
  pd.sout.write('\b'.repeat(pd.width))
  pd.sout.write(' '.repeat(pd.width))
  pd.sout.write('\b'.repeat(pd.width))
