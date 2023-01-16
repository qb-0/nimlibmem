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

  # LM_LoadModule / LM_UnloadModule
  discard LM_LoadModule((getCurrentDir() & "/libtestlib.so").cstring, modbuf.addr)
  echo "Unload: ", LM_UnloadModule(modbuf.addr) == LM_TRUE