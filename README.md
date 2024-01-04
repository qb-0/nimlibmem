[libmem](https://github.com/rdbo/libmem) bindings for the [Nim Programming Language](https://nim-lang.org/)


To install these bindings, clone this repository and run `nimble install`. Tests can be run with `nimble test`.

```nim
import nimlibmem

var 
  myFloat: float = 123.0
  myFloatAddr: uint = cast[lm_address_t](myFloat.addr)

doAssert LM_ReadMemory[float](myFloatAddr) == 123.0
doAssert LM_WriteMemory(myFloatAddr, 1337.0) == 8
doAssert LM_ReadMemory[float](myFloatAddr) == 1337.0
```