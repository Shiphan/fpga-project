```sh
iverilog -W all -g 2001 -o <file> <file>.v <file>-tb.v
vvp <file>
gtkwave <module>_tb.vcd
```

```sh
verilator --binary -Wall --default-language 1364-2001 <file>.v
```
