# 邪DK - 霜邪男爵

- **灵感来源**：魔兽世界
- **视频链接**：https://www.bilibili.com/video/BV1qG4y1h7mc
- **WC3 基础单位**：`Udea`（死亡骑士）
- **地图**：Turtle Rock

---

## 【自带被动】溃烂之伤

![icon](../textures/spell_yorsahj_bloodboil_purpleoil.jpg)

> 回蓝技能

死亡骑士的普通攻击会导致目标身上的一层溃烂之伤爆发，造成15点额外伤害并为死亡骑士恢复3点法力值。

- **FourCC**：`A00A`
- **WC3 Base**：Item (`Aweb`)
- **实现文件**：`LuaProject/Ability/FesteringWound.lua`

---

## 死亡缠绕

![icon](../textures/spell_shadow_deathcoil.jpg)

> 主要能量消耗技能，叠debuff

释放邪恶的能量，对一个敌对目标造成点伤害，或者为一个友方亡灵目标恢复生命值。目标身上的每层溃烂之伤会为死亡缠绕增幅5%。并叠加溃烂之伤。普通攻击时，目标身上的每层溃烂之伤提供5%的几率立即冷却死亡缠绕并且不消耗法力值。

| 等级 | 恢复生命 | 伤害 | 叠加层数 |
|------|---------|------|---------|
| 1 | 40% | 100 | 3层 |
| 2 | 60% | 200 | 5层 |
| 3 | 80% | 300 | 7层 |

- **FourCC**：`A015`
- **WC3 Base**：Evasion (`AEev`)
- **实现文件**：`LuaProject/Ability/DeathCoil.lua`

---

## 亵渎

![icon](../textures/spell_deathknight_defile.jpg)

> AOE刮痧，快速叠debuff

亵渎死亡骑士指定的一片土地，每秒对所有敌人造成伤害并叠加一层溃烂之伤，持续10秒。当你站在自己的亵渎范围内时，你的普通攻击会击中目标附近的其他敌人。如果有任意敌人站在被亵渎的土地上，亵渎面积会扩大，伤害每秒都会提高10%。

| 等级 | 每秒伤害 | 击中敌人数 |
|------|---------|-----------|
| 1 | 5 | 2 |
| 2 | 10 | 4 |
| 3 | 15 | 6 |

- **FourCC**：`A008`
- **WC3 Base**：Channel (`Ncl`, order=deathanddecay)
- **实现文件**：`LuaProject/Ability/Defile.lua`

---

## 天启

![icon](../textures/artifactability_unholydeathknight_deathsembrace.jpg)

> 单体，大量回蓝，CC

引爆目标身上的所有溃烂之伤，造成一次攻击伤害，并召唤一只永久的具有100点生命值、10点攻击力、麻痹毒液攻击的邪恶石像鬼进入战场，每层溃烂之伤可以为石像鬼提供额外属性。

| 等级 | 伤害倍率 | 每层额外生命 | 每层额外攻击 |
|------|---------|-------------|-------------|
| 1 | 1.2x | 30 | 1 |
| 2 | 1.8x | 40 | 2 |
| 3 | 2.5x | 50 | 3 |

- **FourCC**：`A011`
- **WC3 Base**：Channel (`Ncl`, order=thunderbolt)
- **实现文件**：`LuaProject/Ability/Apocalypse.lua`

---

## 【邪恶石像鬼】麻痹毒液

![icon](../textures/spell_nature_nullifydisease.jpg)

攻击使目标减速33%。

---

## 黑暗突变

![icon](../textures/achievement_boss_festergutrotface.jpg)

学习此技能后，你的食尸鬼和石像鬼部队永久获得+10攻击力和+100生命值。

对一个食尸鬼施展，可以将其永久转化为一个拥有1800生命值的憎恶，并获得4个全新的强力技能。

- **FourCC**：`A007`
- **WC3 Base**：Channel (`Ncl`, order=channel)
- **实现文件**：`LuaProject/Ability/DarkTransformation.lua`

---

## 【憎恶】【被动】横扫爪击

![icon](../textures/spell_deathknight_thrash_ghoul.jpg)

60%的顺劈斩。

- **FourCC**：`A012`

---

## 【憎恶】蛮兽打击

![icon](../textures/spell_frost_stun.jpg)

一次野蛮的攻击，对目标造成150点伤害并使其昏迷2秒。

- **FourCC**：`A00B`
- **WC3 Base**：Channel (`Ncl`, order=thunderbolt)
- **实现文件**：`LuaProject/Ability/MonstrousBlow.lua`

---

## 【憎恶】蹒跚冲锋

![icon](../textures/spell_shadow_skull.jpg)

向敌人冲锋，打断其正在施放的法术并使其不能移动，持续6秒。

- **FourCC**：`A013`
- **WC3 Base**：Channel (`Ncl`, order=sleep)
- **实现文件**：`LuaProject/Ability/ShamblingRush.lua`

---

## 【憎恶】腐臭壁垒

![icon](../textures/spell_shadow_raisedead.jpg)

发出固守咆哮，受到的所有伤害降低50%，持续10秒。

- **FourCC**：`A014`
- **WC3 Base**：Channel (`Ncl`, order=tranquility)
- **实现文件**：`LuaProject/Ability/PutridBulwark.lua`
