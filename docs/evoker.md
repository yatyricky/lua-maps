# 唤魔师

- **灵感来源**：龙希尔唤魔师 / 《黑暗之魂3》吞噬黑暗的米狄尔
- **视频链接**：https://www.bilibili.com/video/BV1qv4y1S72P/
- **地图**：Moonglade

---

## 红龙 - 火焰吐息

![icon](../textures/ability_evoker_firebreath.jpg)

> AOE直接伤害/治疗，常规技能

深吸一口气然后喷出，造成前方锥形龙息并击飞的效果，对敌军造成伤害并在接下来的6秒内每2秒灼烧目标，或者治疗友军单位。每蓄力1秒可以使效果增幅15%，最多3秒。

- 法力消耗：25点
- 冷却时间：4秒
- 1级 - 造成80点基础伤害，10点持续伤害，160点治疗

- **FourCC**：`A01D`
- **WC3 Base**：Channel (`Ncl`)
- **实现文件**：`LuaProject/Ability/FireBreath.lua`

---

## 蓝龙 - 瓦解射线

![icon](../textures/ability_evoker_disintegrate.jpg)

> 单体（直线）伤害，CC

聚焦法术能量射向目标，3秒内每秒造成伤害并使其移动速度降低30%，路径上的敌人也会受到影响。

- 法力消耗：100点
- 冷却时间：8秒
- 1级 - 造成150点伤害

- **FourCC**：`A01E`
- **WC3 Base**：Channel (`Ncl`)
- **实现文件**：`LuaProject/Ability/Disintegrate.lua`

---

## 绿龙 - 梦游

![icon](../textures/ability_xavius_dreamsimulacrum.jpg)

> CC，能量恢复

让一名敌人沉睡并在睡梦中朝你缓慢走过来，目标无法被唤醒并每移动100码为你恢复35点法力值。

- 1级 - 持续10秒

- **FourCC**：`A01F`
- **实现文件**：`LuaProject/Ability/SleepWalk.lua`

---

## 青铜龙 - 时光倒流

![icon](../textures/spell_shadow_unstableafllictions.jpg)

> 特殊、CC、治疗

使目标范围内的所有单位回到5秒前的位置。友军的生命值和法力值也会倒流。

- 冷却时间：20秒
- 1级 - 600范围

- **FourCC**：`A01G`
- **实现文件**：`LuaProject/Ability/TimeWarp.lua`

---

## 黑龙 - 灭世光波

![icon](../textures/inv_misc_head_dragon_black.jpg)

> AOE

朝目标方向蓄力后发射毁灭性的光波，对路径上的敌人造成伤害，随后会引爆毁灭力量，对路径上的敌人再次造成一次高额伤害。灭世光波不受控制，如果远处仍有敌人，会继续指向该目标方向发射一次。

- 法力消耗：150点
- 冷却时间：12秒
- 1级 - 造成100点光波伤害，500点毁灭伤害

- **FourCC**：`A01H`
- **实现文件**：`LuaProject/Ability/MagmaBreath.lua`
