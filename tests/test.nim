import unittest
import nimlibmem
import strformat

test "LM_EnumProcesses":
  for p in LM_EnumProcesses():
    echo fmt"Pid: {p.pid} Name: {p.getName()} Path: {p.getPath()} Time: {p.start_time}"