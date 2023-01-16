#[
  Issues:
    - LM_EnumThreadsEx returns wrong id's since it switched from LM_EnumThreadIds
    - LM_UnloadModule returns false and doesn't unloads the module
]#

import 
  ../libmem, 
  strutils, os

const testProcess: cstring = "Discord"

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

  # LM_LoadModulE
  discard LM_LoadModule((getCurrentDir() & "/libtestlib.so").cstring, modbuf.addr)
  
  #[ 
  Unloading currently doesn't works on linux
  
  echo "Unload: ", LM_UnloadModule(modbuf.addr) == LM_TRUE
  var currentProcess: lm_process_t
  discard LM_FindProcess("test", currentProcess.addr)
  echo LM_UnloadModuleEx(currentProcess.addr, modbuf.addr) == LM_TRUE
  ]#
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
