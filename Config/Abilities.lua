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
    BloodPlagueData = { 0.004, 0.008, 0.012, 0.016 },
    FrostPlagueDuration = { 6, 6, 6, 6 },
    FrostPlagueData = { 20, 35, 50, 65 },
    UnholyPlagueDuration = { 10.2, 10.2, 10.2, 10.2 },
    UnholyPlagueInterval = { 2, 2, 2, 2 },
    UnholyPlagueData = { 4, 8, 12, 16 },
}
cls.ArmyOfTheDead = {
    ID = FourCC("A003")
}

return cls
