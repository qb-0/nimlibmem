#[
  Issues:
    - Can't find a solution to get the address of a nim function for hooking
]#

const 
  libName = when defined(linux): "liblibmem.so" elif defined(windows): "libmem.dll"

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
  lm_prot_t* = uint32
  lm_bytearr_t* = ptr lm_byte_t
  lm_uint_t* = uint
  lm_uint64_t* = uint64
  lm_uint16_t* = uint16
  lm_uint8_t* = uint8
  lm_time_t* = uint64

const
  LM_FALSE*: lm_bool_t = 0
  LM_TRUE*: lm_bool_t = 1
  LM_ADDRESS_BAD*: lm_address_t = 0
  LM_PATH_MAX*: lm_size_t = 512
  LM_INST_SIZE*: uint = 16
  LM_PROT_NONE*: lm_prot_t = 0
  LM_PROT_X*: lm_prot_t = 1 shl 0
  LM_PROT_R*: lm_prot_t = 1 shl 1
  LM_PROT_W*: lm_prot_t = 1 shl 2
  LM_PROT_XR*: lm_prot_t = LM_PROT_X or LM_PROT_R
  LM_PROT_XW*: lm_prot_t = LM_PROT_X or LM_PROT_W
  LM_PROT_RW*: lm_prot_t = LM_PROT_R or LM_PROT_W
  LM_PROT_XRW*: lm_prot_t = LM_PROT_X or LM_PROT_R or LM_PROT_W

type
  lm_process_t* = object
    pid*: lm_pid_t
    ppid*: lm_pid_t
    bits*: lm_size_t
    start_time*: lm_time_t
    path*: array[LM_PATH_MAX, lm_char_t]
    name*: array[LM_PATH_MAX, lm_char_t]

  lm_module_t* = object
    base*: lm_address_t
    `end`*: lm_address_t
    size*: lm_size_t
    path*: array[LM_PATH_MAX, lm_char_t]
    name*: array[LM_PATH_MAX, lm_char_t]

  lm_thread_t* {.byref.} = object
    tid*: lm_tid_t

  lm_symbol_t* = object
    name*: cstring
    address*: lm_address_t

  lm_page_t* = object
    base*: lm_address_t
    `end`*: lm_address_t
    size*: lm_size_t
    prot*: lm_prot_t

  lm_inst_t* = object
    id*: lm_uint_t
    address*: lm_uint64_t
    size*: lm_uint16_t
    bytes*: array[LM_INST_SIZE, lm_uint8_t]
    mnemonic*: array[32, lm_cchar_t]
    opStr*: array[160, lm_cchar_t]
    detail*: ptr pointer

proc getName*(p: lm_process_t | lm_module_t): string = $cast[cstring](p.name[0].unsafeAddr)
proc getPath*(p: lm_process_t | lm_module_t): string = $cast[cstring](p.path[0].unsafeAddr)

var 
  processList: seq[lm_process_t]
  moduleList: seq[lm_module_t]
  threadList: seq[lm_thread_t]
  symbolList: seq[lm_symbol_t]
  pageList: seq[lm_page_t]

{.push dynlib: libName, cdecl, importc.}
proc LM_EnumProcesses*(callback: proc(pproc: ptr lm_process_t, arg: pointer): lm_bool_t, arg: pointer): lm_bool_t
proc LM_GetProcess*(procbuf: ptr lm_process_t): lm_bool_t
proc LM_GetProcessEx*(pid: lm_pid_t, procbuf: ptr lm_process_t): lm_bool_t
proc LM_FindProcess*(procstr: lm_string_t, procbuf: ptr lm_process_t): lm_bool_t
proc LM_IsProcessAlive*(pproc: ptr lm_process_t): lm_bool_t
proc LM_GetSystemBits*: lm_size_t
proc LM_EnumThreads*(callback: proc(pthr: ptr lm_thread_t, arg: pointer): lm_bool_t, arg: pointer): lm_bool_t
proc LM_EnumThreadsEx*(pproc: ptr lm_process_t, callback: proc(pthr: ptr lm_thread_t, arg: pointer): lm_bool_t, arg: pointer): lm_bool_t
proc LM_GetThread*(thrbuf: ptr lm_thread_t): lm_bool_t
proc LM_GetThreadEx*(pproc: ptr lm_process_t, thrbuf: ptr lm_thread_t): lm_bool_t
proc LM_GetThreadProcess*(pthr: ptr lm_thread_t, procbuf: ptr lm_process_t): lm_bool_t
proc LM_EnumModules*(callback: proc(pmod: ptr lm_module_t, arg: pointer): lm_bool_t, arg: pointer): lm_bool_t
proc LM_EnumModulesEx*(pproc: ptr lm_process_t, callback: proc(pmod: ptr lm_module_t, arg: pointer): lm_bool_t, arg: pointer): lm_bool_t
proc LM_FindModule*(name: lm_string_t, modbuf: ptr lm_module_t): lm_bool_t
proc LM_FindModuleEx*(pproc: ptr lm_process_t, name: lm_string_t, modbuf: ptr lm_module_t): lm_bool_t
proc LM_LoadModule*(path: lm_string_t, modbuf: ptr lm_module_t): lm_bool_t
proc LM_LoadModuleEx*(pproc: ptr lm_process_t, path: lm_string_t, modbuf: ptr lm_module_t): lm_module_t
proc LM_UnloadModule*(pmod: ptr lm_module_t): lm_bool_t
proc LM_UnloadModuleEx*(pproc: ptr lm_process_t, pmod: ptr lm_module_t): lm_bool_t
proc LM_EnumSymbols*(pmod: ptr lm_module_t, callback: proc(psymbol: ptr lm_symbol_t, arg: pointer): lm_bool_t, arg: pointer): lm_bool_t
proc LM_FindSymbolAddress*(pmod: ptr lm_module_t, name: cstring): lm_address_t
proc LM_EnumPages*(callback: proc(ppage: ptr lm_page_t, arg: pointer): lm_bool_t, arg: pointer): lm_bool_t
proc LM_EnumPagesEx*(pproc: ptr lm_process_t, callback: proc(ppage: ptr lm_page_t, arg: pointer): lm_bool_t, arg: pointer): lm_bool_t
proc LM_GetPage*(`addr`: lm_address_t, pagebuf: ptr lm_page_t): lm_bool_t
proc LM_GetPageEx*(pproc: ptr lm_process_t, `addr`: lm_address_t, pagebuf: ptr lm_page_t): lm_bool_t
proc LM_ReadMemory*(src: lm_address_t, dst: ptr lm_byte_t, size: lm_size_t): lm_size_t
proc LM_ReadMemoryEx*(pproc: ptr lm_process_t, src: lm_address_t, dst: ptr lm_byte_t, size: lm_size_t): lm_size_t
proc LM_WriteMemory*(dst: lm_address_t, src: lm_bytearr_t, size: lm_size_t): lm_size_t
proc LM_WriteMemoryEx*(pproc: ptr lm_process_t, dst: lm_address_t, src: lm_bytearr_t, size: lm_size_t): lm_size_t
proc LM_SetMemory*(dst: lm_address_t, `byte`: lm_byte_t, size: lm_size_t): lm_size_t
proc LM_SetMemoryEx*(pproc: ptr lm_process_t, dst: lm_address_t, `byte`: lm_byte_t, size: lm_size_t): lm_size_t
proc LM_ProtMemory*(`addr`: lm_address_t, size: lm_size_t, prot: lm_prot_t, oldprot: ptr lm_prot_t): lm_bool_t
proc LM_ProtMemoryEx*(pproc: ptr lm_process_t, `addr`: lm_address_t, size: lm_size_t, prot: lm_prot_t, oldprot: ptr lm_prot_t): lm_bool_t
proc LM_AllocMemory*(size: lm_size_t, prot: lm_prot_t): lm_address_t
proc LM_AllocMemoryEx*(pproc: ptr lm_process_t, size: lm_size_t, prot: lm_prot_t): lm_address_t
proc LM_FreeMemory*(alloc: lm_address_t, size: lm_size_t): lm_bool_t
proc LM_FreeMemoryEx*(pproc: ptr lm_process_t, alloc: lm_address_t, size: lm_size_t): lm_bool_t
proc LM_DataScan*(data: lm_bytearr_t, size: lm_size_t, `addr`: lm_address_t, scansize: lm_size_t): lm_address_t
proc LM_DataScanEx*(pproc: ptr lm_process_t, data: lm_bytearr_t, size: lm_size_t, `addr`: lm_address_t, scansize: lm_size_t): lm_address_t
proc LM_PatternScan*(pattern: lm_bytearr_t, mask: lm_string_t, `addr`: lm_address_t, scansize: lm_size_t): lm_address_t
proc LM_PatternScanEx*(pproc: ptr lm_process_t, pattern: lm_bytearr_t, mask: lm_string_t, `addr`: lm_address_t, scansize: lm_size_t): lm_address_t
proc LM_SigScan*(sig: lm_string_t, `addr`: lm_address_t, scansize: lm_size_t): lm_address_t
proc LM_SigScanEx*(pproc: ptr lm_process_t, sig: lm_string_t, `addr`: lm_address_t, scansize: lm_size_t): lm_address_t
proc LM_HookCode*(`from`, to: lm_address_t, ptrampoline: ptr lm_address_t): lm_size_t
proc LM_HookCodeEx*(pproc: ptr lm_process_t, `from`, to: lm_address_t, ptrampoline: ptr lm_address_t): lm_size_t
proc LM_UnhookCode*(`from`, trampoline: lm_address_t, size: lm_size_t): lm_bool_t
proc LM_UnhookCodeEx*(pproc: ptr lm_process_t, `from`, trampoline: lm_address_t, size: lm_size_t): lm_bool_t
proc LM_Assemble*(code: lm_string_t, inst: ptr lm_inst_t): lm_bool_t
{.pop.}

# Helper functions

proc enumProcessCallback(pproc: ptr lm_process_t, arg: pointer): lm_bool_t =
  processList.add(pproc[])
  result = LM_TRUE

proc enumThreadsCallback(pthr: ptr lm_thread_t, arg: pointer): lm_bool_t =
  threadList.add(pthr[])
  result = LM_TRUE

proc enumModulesCallback(pmod: ptr lm_module_t, arg: pointer): lm_bool_t =
  moduleList.add(pmod[])
  result = LM_TRUE

proc enumSymbolsCallback(psymbol: ptr lm_symbol_t, arg: pointer): lm_bool_t =
  symbolList.add(psymbol[])
  result = LM_TRUE

proc enumPagesCallback(ppage: ptr lm_page_t, arg: pointer): lm_bool_t =
  pageList.add(ppage[])
  result = LM_TRUE

iterator LM_EnumProcesses*: lm_process_t =
  processList.setLen(0)
  if LM_EnumProcesses(enumProcessCallback, nil) == LM_TRUE:
    for p in processList:
      yield p

iterator LM_EnumThreads*: lm_thread_t =
  threadList.setLen(0)
  if LM_EnumThreads(enumThreadsCallback, nil) == LM_TRUE:
    for t in threadList:
      yield t

iterator LM_EnumThreadsEx*(pproc: ptr lm_process_t): lm_thread_t =
  threadList.setLen(0)
  if LM_EnumThreadsEx(pproc, enumThreadsCallback, nil) == LM_TRUE:
    for t in threadList:
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

iterator LM_EnumSymbols*(pmod: ptr lm_module_t): lm_symbol_t =
  symbolList.setLen(0)
  if LM_EnumSymbols(pmod, enumSymbolsCallback, nil) == LM_TRUE:
    for s in symbolList:
      yield s

iterator LM_EnumPages*: lm_page_t =
  pageList.setLen(0)
  if LM_EnumPages(enumPagesCallback, nil) == LM_TRUE:
    for p in pageList:
      yield p

iterator LM_EnumPagesEx*(pproc: ptr lm_process_t): lm_page_t =
  pageList.setLen(0)
  if LM_EnumPagesEx(pproc, enumPagesCallback, nil) == LM_TRUE:
    for p in pageList:
      yield p

# RWM helper functions

proc LM_ReadMemory*[T](src: lm_address_t): T =
  var
    size = sizeof(T).lm_size_t
    dstSeq = newSeq[lm_byte_t](size)
  doAssert LM_ReadMemory(src, dstSeq[0].addr, size) == size
  copyMem(result.addr, dstSeq[0].addr, size)

proc LM_ReadMemoryEx*[T](pproc: ptr lm_process_t, src: lm_address_t): T =
  var
    size = sizeof(T).lm_size_t
    dstSeq = newSeq[lm_byte_t](size)
  doAssert LM_ReadMemoryEx(pproc, src, dstSeq[0].addr, size) == size
  copyMem(result.addr, dstSeq[0].addr, size)

proc LM_WriteMemory*(dst: lm_address_t, src: auto): lm_size_t {.discardable.} =
  var
    c = src
    size = sizeof(src).lm_size_t
    srcSeq = newSeq[lm_byte_t](size)
  copyMem(srcSeq[0].addr, c.addr, size)
  LM_WriteMemory(dst, srcSeq[0].addr, size)

proc LM_WriteMemoryEx*(pproc: ptr lm_process_t, dst: lm_address_t, src: auto): lm_size_t {.discardable.} =
  var
    c = src
    size = sizeof(src).lm_size_t
    srcSeq = newSeq[lm_byte_t](size)
  copyMem(srcSeq[0].addr, c.addr, size)
  LM_WriteMemoryEx(pproc, dst, srcSeq[0].addr, size)

proc LM_DataScan*(data: openArray[lm_byte_t], `addr`: lm_address_t, scanSize: lm_size_t): lm_address_t =
  LM_DataScan(data[0].unsafeAddr, data.len.lm_size_t, `addr`, scanSize)

proc LM_DataScanEx*(pproc: ptr lm_process_t, data: openArray[lm_byte_t], `addr`: lm_address_t, scanSize: lm_size_t): lm_address_t =
  LM_DataScanEx(pproc, data[0].unsafeAddr, data.len.lm_size_t, `addr`, scanSize)

proc LM_PatternScan*(pattern: openArray[lm_byte_t], mask: lm_string_t, `addr`: lm_address_t, scanSize: lm_size_t): lm_address_t =
  LM_PatternScan(pattern[0].unsafeAddr, mask, `addr`, scanSize)

proc LM_PatternScanEx*(pproc: ptr lm_process_t, pattern: openArray[lm_byte_t], mask: lm_string_t, `addr`: lm_address_t, scanSize: lm_size_t): lm_address_t =
  LM_PatternScanEx(pproc, pattern[0].unsafeAddr, mask, `addr`, scanSize)