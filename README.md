```sh
iverilog -W all -g 2001 -o <file> <file>.v <file>-tb.v
vvp <file>
gtkwave <module>_tb.vcd
```

```sh
verilator --binary -Wall --default-language 1364-2001 <file>.v
```

## 貪吃蛇介紹

### 操作方法

- PS1: 向上
- PS2: 向下
- PS3: 向左
- PS4: 向右
- UP: 重製
- DOWN: 作弊(直接勝利)
- SW8: 音樂開關

### 特色

優雅的音樂
得分動畫
可穿牆增加遊戲操作上限
逐漸增加的速度
勝利與死亡的結算畫面 (包含遊戲進行時間與得分)

