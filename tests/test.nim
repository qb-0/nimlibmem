import unittest
import nimlibmem
import strformat

const
  PROCESS_NAME = "Discord"

var
  procBuf: lm_process_t
  currentPid: lm_pid_t

proc testEcho(testName: string, p: lm_process_t) =
  echo fmt"{testName}: {p.pid} {p.getName()} {p.getPath()} {p.start_time}"

test "LM_EnumProcesses":
  for p in LM_EnumProcesses():
    testEcho("LM_EnumProcesses", p)

test "LM_GetProcess":
  check LM_GetProcess(procBuf.addr) == LM_TRUE
  currentPid = procBuf.pid
  testEcho("LM_GetProcess", procBuf)

test "LM_GetProcessEx":
  check LM_GetProcessEx(currentPid, procBuf.addr) == LM_TRUE
  testEcho("LM_GetProcessEx", procBuf)

test "LM_FindProcess":
  check LM_FindProcess(PROCESS_NAME, procBuf.addr) == LM_TRUE
  testEcho("LM_FindProcess", procBuf)
