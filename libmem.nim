const 
  libName = when defined(linux): "libmem.so" elif defined(windows): "libmem.dll"

type
  lm_bool_t* = int32
  lm_char_t* = uint8
  lm_cchar_t* = uint8
  lm_pid_t* = uint32
  lm_tid_t* = uint32
  lm_size_t* = uint
  lm_address_t* = uint
  lm_byte_t* = uint8
  lm_void_t* = void
  lm_string_t* = cstring

const
  LM_FALSE*: lm_bool_t = 0
  LM_TRUE*: lm_bool_t = 1
  LM_ADDRESS_BAD*: lm_address_t = 0
  LM_PATH_MAX*: lm_size_t = 512
  LM_INST_SIZE*: uint = 16

type
  lm_process_t* = object
    pid*: lm_pid_t
    ppid*: lm_pid_t
    bits*: lm_size_t
    path*: array[LM_PATH_MAX, lm_char_t]
    name*: array[LM_PATH_MAX, lm_char_t]

  lm_module_t* = object
    base*: lm_address_t
    `end`*: lm_address_t
    size*: lm_size_t
    path*: array[LM_PATH_MAX, lm_char_t]
    name*: array[LM_PATH_MAX, lm_char_t]

proc getName*(p: lm_process_t | lm_module_t): string = $cast[cstring](p.name[0].unsafeAddr)
proc getPath*(p: lm_process_t | lm_module_t): string = $cast[cstring](p.path[0].unsafeAddr)

var 
  processList: seq[lm_process_t]
  moduleList: seq[lm_module_t]
  threadIdList: seq[lm_tid_t]

{.push dynlib: libName, cdecl, importc.}
proc LM_EnumProcesses*(callback: proc(pproc: lm_process_t, arg: pointer): lm_bool_t, arg: pointer): lm_bool_t
proc LM_GetProcess*(procbuf: ptr lm_process_t): lm_bool_t
proc LM_FindProcess*(procstr: lm_string_t, procbuf: ptr lm_process_t): lm_bool_t
proc LM_IsProcessAlive*(pproc: ptr lm_process_t): lm_bool_t
proc LM_GetSystemBits*: lm_size_t
proc LM_EnumThreadIds*(callback: proc(tid: lm_tid_t, arg: pointer): lm_bool_t, arg: pointer): lm_bool_t
proc LM_EnumThreadIdsEx*(pproc: ptr lm_process_t, callback: proc(tid: lm_tid_t, arg: pointer): lm_bool_t, arg: pointer): lm_bool_t
proc LM_GetThreadId*: lm_tid_t
proc LM_GetThreadIdEx*(pproc: ptr lm_process_t): lm_tid_t
proc LM_EnumModules*(callback: proc(pmod: lm_module_t, arg: pointer): lm_bool_t, arg: pointer): lm_bool_t
proc LM_EnumModulesEx*(pproc: ptr lm_process_t, callback: proc(pmod: lm_module_t, arg: pointer): lm_bool_t, arg: pointer): lm_bool_t
proc LM_FindModule*(name: lm_string_t, modbuf: ptr lm_module_t): lm_bool_t
proc LM_FindModuleEx*(pproc: ptr lm_process_t, name: lm_string_t, modbuf: ptr lm_module_t): lm_bool_t
proc LM_LoadModule*(path: lm_string_t, modbuf: ptr lm_module_t): lm_bool_t
proc LM_LoadModuleEx*(pproc: ptr lm_process_t, path: lm_string_t, modbuf: ptr lm_module_t): lm_module_t
proc LM_UnloadModule*(pmod: ptr lm_module_t): lm_bool_t
proc LM_UnloadModuleEx*(pmod: ptr lm_module_t): lm_bool_t
{.pop.}

# Callbacks / Iterators helpers

proc enumProcessCallback(pproc: lm_process_t, arg: pointer): lm_bool_t =
  processList.add(pproc)
  result = LM_TRUE

proc enumThreadIdsCallback(tid: lm_tid_t, arg: pointer): lm_bool_t =
  threadIdList.add(tid)
  result = LM_TRUE

proc enumModulesCallback(pmod: lm_module_t, arg: pointer): lm_bool_t =
  moduleList.add(pmod)
  result = LM_TRUE

iterator LM_EnumProcesses*: lm_process_t =
  processList.setLen(0)
  if LM_EnumProcesses(enumProcessCallback, nil) == LM_TRUE:
    for p in processList:
      yield p

iterator LM_EnumThreadIds*: lm_tid_t =
  threadIdList.setLen(0)
  if LM_EnumThreadIds(enumThreadIdsCallback, nil) == LM_TRUE:
    for t in threadIdList:
      yield t

iterator LM_EnumThreadIdsEx*(pproc: ptr lm_process_t): lm_tid_t =
  threadIdList.setLen(0)
  if LM_EnumThreadIdsEx(pproc, enumThreadIdsCallback, nil) == LM_TRUE:
    for t in threadIdList:
      yield t

iterator LM_EnumModules*: lm_module_t =
  moduleList.setLen(0)
  if LM_EnumModules(enumModulesCallback, nil) == LM_TRUE:
    for m in moduleList:
      yield m

iterator LM_EnumModulesEx*(pproc: ptr lm_process_t): lm_module_t =
  moduleList.setLen(0)
  if LM_EnumModulesEx(pproc, enumModulesCallback, nil) == LM_TRUE:
    for m in moduleList:
      yield m