import unittest
import nimlibmem
import strformat

const
  PROCESS_NAME = "firefox"
  MODULE_NAME = "libc.so.6"

var
  procBuf: lm_process_t
  exprocBuf: lm_process_t
  thrBuf: lm_thread_t
  modBuf: lm_module_t
  currentPid: lm_pid_t

proc testEchoProc(testName: string, p: lm_process_t) =
  echo fmt"{testName}: {p.pid} {p.getName()} {p.getPath()} {p.start_time}"

proc testEchoMod(testName: string, m: lm_module_t) =
  echo fmt"{testName}: {m.getName()} {m.getPath()} {m.base}-{m.`end`} ({m.size})"

test "LM_EnumProcesses":
  for p in LM_EnumProcesses():
    testEchoProc("LM_EnumProcesses", p)

test "LM_GetProcess":
  check LM_GetProcess(procBuf.addr) == LM_TRUE
  currentPid = procBuf.pid
  testEchoProc("LM_GetProcess", procBuf)

test "LM_GetProcessEx":
  check LM_GetProcessEx(currentPid, exprocBuf.addr) == LM_TRUE
  testEchoProc("LM_GetProcessEx", procBuf)

test "LM_FindProcess":
  check LM_FindProcess(PROCESS_NAME, exprocBuf.addr) == LM_TRUE
  testEchoProc("LM_FindProcess", procBuf)

test "LM_IsProcessAlive":
  check LM_IsProcessAlive(procBuf.addr) == LM_TRUE

test "LM_GetSystemBits":
  echo LM_GetSystemBits()

test "LM_EnumThreads":
  for t in LM_EnumThreads():
    echo t.tid

test "LM_EnumThreadsEx":
  for t in LM_EnumThreadsEx(exprocBuf.addr):
    echo t.tid

test "LM_GetThread":
  check LM_GetThread(thrBuf.addr) == LM_TRUE

test "LM_GetThreadEx":
  check LM_GetThreadEx(exprocBuf.addr, thrBuf.addr) == LM_TRUE

test "LM_GetThreadProcess":
  check LM_GetThreadProcess(thrBuf.addr, exprocBuf.addr) == LM_TRUE

test "LM_EnumModules":
  for m in LM_EnumModules():
    testEchoMod("LM_EnumModules", m)

test "LM_EnumModulesEx":
  for m in LM_EnumModulesEx(exprocBuf.addr):
    testEchoMod("LM_EnumModulesEx", m)

test "LM_FindModule":
  check LM_FindModule(MODULE_NAME, modBuf.addr) == LM_TRUE

test "LM_FindModuleEx":
  check LM_FindModuleEx(exprocBuf.addr, MODULE_NAME, modBuf.addr) == LM_TRUE

test "LM_ReadMemory":
  var myInt: int32 = 1337
  check LM_ReadMemory[int32](cast[uint](myInt.addr)) == 1337

test "LM_WriteMemory":
  var myInt: float = 1337.0
  check LM_WriteMemory(cast[uint](myInt.addr), 1338.0) != 0
  echo myInt