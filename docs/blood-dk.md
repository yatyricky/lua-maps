# 血DK - 阿尔萨斯

- **灵感来源**：魔兽世界
- **视频链接**：https://www.bilibili.com/video/BV1xP411A7if/
- **WC3 基础单位**：`Udea`（恐惧魔王）
- **地图**：Echo Isles

---

## 死亡之握

![icon](../textures/spell_deathknight_strangulate.jpg)

运用笼罩万物的邪恶能量，将目标拉到死亡骑士面前来，并让其无法移动，并根据目标身上的瘟疫数量，延长持续时间。

| 等级 | 持续时间 | 英雄持续时间 | 每个瘟疫延长 |
|------|---------|-------------|-------------|
| 1 | 9秒 | 3秒 | 10% |
| 2 | 12秒 | 4秒 | 20% |
| 3 | 15秒 | 5秒 | 30% |

- **FourCC**：`A000`
- **WC3 Base**：Channel (`Ncl`)
- **实现文件**：`LuaProject/Ability/DeathGrip.lua`

---

## 灵界打击

![icon](../textures/spell_deathknight_butcher2.jpg)

致命的攻击，对目标造成一次伤害，并根据目标身上的瘟疫数量，每有一个便为死亡骑士恢复他最大生命值百分比的效果，并且会将目标身上的所有瘟疫传染给附近所有敌人。

| 等级 | 伤害 | 每个瘟疫恢复 |
|------|------|-------------|
| 1 | 80 | 8%最大生命值 |
| 2 | 120 | 12%最大生命值 |
| 3 | 160 | 16%最大生命值 |

- **FourCC**：`A001`
- **WC3 Base**：Channel (`Ncl`)
- **实现文件**：`LuaProject/Ability/DeathStrike.lua`

---

## 瘟疫打击【被动】

![icon](../textures/spell_deathknight_plaguestrike.jpg)

每次攻击都会依次给敌人造成鲜血瘟疫、冰霜瘟疫、邪恶瘟疫的效果。

- **鲜血瘟疫**：目标受到攻击时，受到最大生命值百分比伤害
- **冰霜瘟疫**：一段时间后，受到一次冰霜伤害，目标移动速度越低，受到伤害越高
- **邪恶瘟疫**：受到持续的伤害，生命值越低，受到伤害越高，可叠加持续时间

| 等级 | 鲜血瘟疫 | 冰霜瘟疫 | 邪恶瘟疫 |
|------|---------|---------|---------|
| 1 | 0.5%最大生命/受击，12秒 | 30伤害，6秒 | 6伤害/2秒，10秒 |
| 2 | 1%最大生命/受击，12秒 | 45伤害，6秒 | 11伤害/2秒，10秒 |
| 3 | 1.5%最大生命/受击，12秒 | 60伤害，6秒 | 16伤害/2秒，10秒 |

- **FourCC**：`A002`（瘟疫打击）、`A005`（鲜血）、`A006`（冰霜）、`A004`（邪恶）
- **WC3 Base**：Channel (`Ncl`) / Passive (`Agyv`)
- **实现文件**：`LuaProject/Ability/PlagueStrike.lua`、`BloodPlague.lua`、`FrostPlague.lua`、`UnholyPlague.lua`

---

## 亡者大军

![icon](../textures/spell_deathknight_armyofthedead.jpg)

召唤一支食尸鬼军团为你作战。食尸鬼会在你附近的区域横冲直撞，攻击一切它们可以攻击的目标。

- 1级 - 召唤6个食尸鬼，每个具有660点生命值

- **FourCC**：`A003`
- **WC3 Base**：Channel (`Ncl`, order=tranquility)
- **实现文件**：`LuaProject/Ability/ArmyOfTheDead.lua`

---

## 群体死亡之握

![icon](../textures/spell_deathknight_aoedeathgrip.jpg)

对周围所有敌人施放死亡之握，将其拉到死亡骑士身边并嘲讽。

- **FourCC**：`A01I`
- **实现文件**：`LuaProject/Ability/GorefiendsGrasp.lua`
