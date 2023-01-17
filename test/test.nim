#[
  Issues:
    - LM_UnloadModule returns false and doesn't unloads the module (linux issue)
]#

import 
  ../libmem, 
  strutils, os

let
  testProcess: cstring = "Discord"
  currentProcess: cstring = splitPath(getAppFilename()).tail.cstring

# Test
if isMainModule:
  var 
    procbuf: lm_process_t
    modbuf: lm_module_t
    thrbuf: lm_thread_t

  # LM_EnumProcesses
  for p in LM_EnumProcesses():
    echo p.pid, "|", p.getName, "|", p.getPath

  # LM_GetProcess
  discard LM_GetProcess(procbuf.addr)
  echo procbuf.pid, " ", procbuf.getPath

  # LM_FindProcess
  if LM_FindProcess(testProcess, procbuf.addr) == LM_TRUE:
    echo procbuf.pid, " ", procbuf.getPath

  # LM_IsProcessAlive
  echo testProcess, " alive: ", LM_IsProcessAlive(procbuf.addr) == LM_TRUE

  # LM_GetSystemBits
  echo "Systembits: ", LM_GetSystemBits()

  # LM_EnumThreads
  for t in LM_EnumThreads():
    echo t

  # LM_EnumThreadsEx
  for t in LM_EnumThreadsEx(procbuf.addr):
    echo testProcess, " Thread: ", t

  # LM_GetThread
  discard LM_GetThread(thrbuf.addr)
  echo "Current Thread: ", thrbuf

  # LM_GetThreadEx
  discard LM_GetThreadEx(procbuf.addr, thrbuf.addr)
  echo testProcess, " ", thrbuf

  # LM_EnumModules
  for m in LM_EnumModules():
    echo m.getName, " ", m.base.toHex()

  # LM_EnumModulesEx
  echo testProcess, " Modules:"
  for m in LM_EnumModulesEx(procbuf.addr):
    echo "\t", m.getName, " ", m.base.toHex()

  # LM_FindModule
  if LM_FindModule("libmem.so", modbuf.addr) == LM_TRUE:
    echo modbuf.getName, ": ", modbuf.base.toHex()

  # LM_FindModuleEx
  if LM_FindModuleEx(procbuf.addr, "libc.so.6", modbuf.addr) == LM_TRUE:
    echo modbuf.getName, ": ", modbuf.base.toHex()

  # LM_LoadModul
  discard LM_LoadModule((getCurrentDir() & "/libtestlib.so").cstring, modbuf.addr)
  
  # LM_EnumSymbols
  discard LM_FindModule("libmem.so", modbuf.addr)
  for s in LM_EnumSymbols(modbuf.addr):
    echo s.name, " ", s.address.toHex()

  # LM_FindSymbolAddress
  echo LM_FindSymbolAddress(modbuf.addr, "LM_ReadMemoryEx").toHex()

  # LM_EnumPages
  for p in LM_EnumPages():
    echo p.base.toHex(), "-", p.`end`.toHex()

  # LM_EnumPagesEx
  for p in LM_EnumPagesEx(procbuf.addr):
    echo testProcess, ": ", p.base.toHex(), "-", p.`end`.toHex()

  var 
    myInt: int = 123123
    myFloat: float = 37.12
    myString: string = "hello"

    intAddr = cast[lm_address_t](myInt.addr)
    floatAddr = cast[lm_address_t](myFloat.addr)
    stringAddr = cast[lm_address_t](myString.addr)

  # LM_ReadMemory
  echo LM_ReadMemory[int](intAddr)
  echo LM_ReadMemory[float](floatAddr)
  echo LM_ReadMemory[string](stringAddr)

  # LM_ReadMemoryEx
  discard LM_FindProcess(currentProcess, procbuf.addr)
  echo LM_ReadMemoryEx[int](procbuf.addr, intAddr)
  echo LM_ReadMemoryEx[float](procbuf.addr, floatAddr)
  echo LM_ReadMemoryEx[string](procbuf.addr, stringAddr)

  # LM_WriteMemory
  LM_WriteMemory(intAddr, 1337)
  echo myInt
  LM_WriteMemory(floatAddr, 1337.1337)
  echo myFloat
  LM_WriteMemory(stringAddr, "foobar")
  echo myString

  # LM_WriteMemoryEx
  LM_WriteMemoryEx(procbuf.addr, intAddr, 123)
  echo myInt
  LM_WriteMemoryEx(procbuf.addr, floatAddr, 123.123)
  echo myFloat
  LM_WriteMemoryEx(procbuf.addr, stringAddr, "deadbeef")
  echo myString

  var 
    memBuf: array[0..3, byte]
    memBufAddr = cast[lm_address_t](membuf.addr)

  # LM_SetMemory
  discard LM_SetMemory(memBufAddr, 99, 4)
  echo memBuf

  # LM_SetMemoryEx
  discard LM_SetMemoryEx(procbuf.addr, memBufAddr, 11, 4)
  echo memBuf