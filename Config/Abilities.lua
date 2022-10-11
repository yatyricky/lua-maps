local cls = {}

cls.DeathGrip = {
    ID = FourCC("A000")
}
cls.DeathStrike = {
    ID = FourCC("A001"),
    Damage = { 80, 120, 160, 200 },
    Heal = { 0.01, 0.02, 0.03, 0.04 },
    AOE = { 400, 500, 600, 700 }
}
cls.PlagueStrike = {
    ID = FourCC("A002"),
    BloodPlagueDuration = { 12, 12, 12, 12 },
    BloodPlagueData = { 0.04, 0.08, 0.12, 0.16 },
    FrostPlagueDuration = { 6, 6, 6, 6 },
    FrostPlagueData = { 10, 15, 20, 25 },
    UnholyPlagueDuration = { 10, 10, 10, 10 },
    UnholyPlagueInterval = { 2, 2, 2, 2 },
    UnholyPlagueData = { 2, 4, 6, 8 },
}

return cls
