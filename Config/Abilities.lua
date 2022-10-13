local cls = {}

cls.DeathGrip = {
    ID = FourCC("A000"),
    Duration = { 4, 5, 6 },
    DurationHero = { 2, 3, 4 },
}

cls.DeathStrike = {
    ID = FourCC("A001"),
    Damage = { 80, 120, 160 },
    Heal = { 0.08, 0.12, 0.16 },
    AOE = { 400, 500, 600 },
}

cls.PlagueStrike = {
    ID = FourCC("A002"),
    BloodPlagueDuration = { 12, 12, 12 },
    BloodPlagueData = { 0.005, 0.01, 0.015 },
    FrostPlagueDuration = { 6, 6, 6 },
    FrostPlagueData = { 30, 45, 60 },
    UnholyPlagueDuration = { 10.2, 10.2, 10.2 },
    UnholyPlagueInterval = { 2, 2, 2 },
    UnholyPlagueData = { 6, 11, 16 },
}

cls.ArmyOfTheDead = {
    ID = FourCC("A003")
}

return cls
