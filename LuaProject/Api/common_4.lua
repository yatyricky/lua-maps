---@diagnostic disable

---@param whichUnit unit
---@param weaponIndex integer
---@return integer
function BlzGetUnitDiceSides(whichUnit, weaponIndex) end

---@param whichUnit unit
---@param diceSides integer
---@param weaponIndex integer
---@return nothing
function BlzSetUnitDiceSides(whichUnit, diceSides, weaponIndex) end

---@param whichUnit unit
---@param weaponIndex integer
---@return real
function BlzGetUnitAttackCooldown(whichUnit, weaponIndex) end

---@param whichUnit unit
---@param cooldown real
---@param weaponIndex integer
---@return nothing
function BlzSetUnitAttackCooldown(whichUnit, cooldown, weaponIndex) end

---@param whichEffect effect
---@param whichPlayer player
---@return nothing
function BlzSetSpecialEffectColorByPlayer(whichEffect, whichPlayer) end

---@param whichEffect effect
---@param r integer
---@param g integer
---@param b integer
---@return nothing
function BlzSetSpecialEffectColor(whichEffect, r, g, b) end

---@param whichEffect effect
---@param alpha integer
---@return nothing
function BlzSetSpecialEffectAlpha(whichEffect, alpha) end

---@param whichEffect effect
---@param scale real
---@return nothing
function BlzSetSpecialEffectScale(whichEffect, scale) end

---@param whichEffect effect
---@param x real
---@param y real
---@param z real
---@return nothing
function BlzSetSpecialEffectPosition(whichEffect, x, y, z) end

---@param whichEffect effect
---@param height real
---@return nothing
function BlzSetSpecialEffectHeight(whichEffect, height) end

---@param whichEffect effect
---@param timeScale real
---@return nothing
function BlzSetSpecialEffectTimeScale(whichEffect, timeScale) end

---@param whichEffect effect
---@param time real
---@return nothing
function BlzSetSpecialEffectTime(whichEffect, time) end

---@param whichEffect effect
---@param yaw real
---@param pitch real
---@param roll real
---@return nothing
function BlzSetSpecialEffectOrientation(whichEffect, yaw, pitch, roll) end

---@param whichEffect effect
---@param yaw real
---@return nothing
function BlzSetSpecialEffectYaw(whichEffect, yaw) end

---@param whichEffect effect
---@param pitch real
---@return nothing
function BlzSetSpecialEffectPitch(whichEffect, pitch) end

---@param whichEffect effect
---@param roll real
---@return nothing
function BlzSetSpecialEffectRoll(whichEffect, roll) end

---@param whichEffect effect
---@param x real
---@return nothing
function BlzSetSpecialEffectX(whichEffect, x) end

---@param whichEffect effect
---@param y real
---@return nothing
function BlzSetSpecialEffectY(whichEffect, y) end

---@param whichEffect effect
---@param z real
---@return nothing
function BlzSetSpecialEffectZ(whichEffect, z) end

---@param whichEffect effect
---@param loc location
---@return nothing
function BlzSetSpecialEffectPositionLoc(whichEffect, loc) end

---@param whichEffect effect
---@return real
function BlzGetLocalSpecialEffectX(whichEffect) end

---@param whichEffect effect
---@return real
function BlzGetLocalSpecialEffectY(whichEffect) end

---@param whichEffect effect
---@return real
function BlzGetLocalSpecialEffectZ(whichEffect) end

---@param whichEffect effect
---@return nothing
function BlzSpecialEffectClearSubAnimations(whichEffect) end

---@param whichEffect effect
---@param whichSubAnim subanimtype
---@return nothing
function BlzSpecialEffectRemoveSubAnimation(whichEffect, whichSubAnim) end

---@param whichEffect effect
---@param whichSubAnim subanimtype
---@return nothing
function BlzSpecialEffectAddSubAnimation(whichEffect, whichSubAnim) end

---@param whichEffect effect
---@param whichAnim animtype
---@return nothing
function BlzPlaySpecialEffect(whichEffect, whichAnim) end

---@param whichEffect effect
---@param whichAnim animtype
---@param timeScale real
---@return nothing
function BlzPlaySpecialEffectWithTimeScale(whichEffect, whichAnim, timeScale) end

---@param whichAnim animtype
---@return string
function BlzGetAnimName(whichAnim) end

---@param whichUnit unit
---@return real
function BlzGetUnitArmor(whichUnit) end

---@param whichUnit unit
---@param armorAmount real
---@return nothing
function BlzSetUnitArmor(whichUnit, armorAmount) end

---@param whichUnit unit
---@param abilId integer
---@param flag boolean
---@return nothing
function BlzUnitHideAbility(whichUnit, abilId, flag) end

---@param whichUnit unit
---@param abilId integer
---@param flag boolean
---@param hideUI boolean
---@return nothing
function BlzUnitDisableAbility(whichUnit, abilId, flag, hideUI) end

---@param whichUnit unit
---@return nothing
function BlzUnitCancelTimedLife(whichUnit) end

---@param whichUnit unit
---@return boolean
function BlzIsUnitSelectable(whichUnit) end

---@param whichUnit unit
---@return boolean
function BlzIsUnitInvulnerable(whichUnit) end

---@param whichUnit unit
---@return nothing
function BlzUnitInterruptAttack(whichUnit) end

---@param whichUnit unit
---@return real
function BlzGetUnitCollisionSize(whichUnit) end

---@param abilId integer
---@param level integer
---@return integer
function BlzGetAbilityManaCost(abilId, level) end

---@param abilId integer
---@param level integer
---@return real
function BlzGetAbilityCooldown(abilId, level) end

---@param whichUnit unit
---@param abilId integer
---@param level integer
---@param cooldown real
---@return nothing
function BlzSetUnitAbilityCooldown(whichUnit, abilId, level, cooldown) end

---@param whichUnit unit
---@param abilId integer
---@param level integer
---@return real
function BlzGetUnitAbilityCooldown(whichUnit, abilId, level) end

---@param whichUnit unit
---@param abilId integer
---@return real
function BlzGetUnitAbilityCooldownRemaining(whichUnit, abilId) end

---@param whichUnit unit
---@param abilCode integer
---@return nothing
function BlzEndUnitAbilityCooldown(whichUnit, abilCode) end

---@param whichUnit unit
---@param abilCode integer
---@param cooldown real
---@return nothing
function BlzStartUnitAbilityCooldown(whichUnit, abilCode, cooldown) end

---@param whichUnit unit
---@param abilId integer
---@param level integer
---@return integer
function BlzGetUnitAbilityManaCost(whichUnit, abilId, level) end

---@param whichUnit unit
---@param abilId integer
---@param level integer
---@param manaCost integer
---@return nothing
function BlzSetUnitAbilityManaCost(whichUnit, abilId, level, manaCost) end

---@param whichUnit unit
---@return real
function BlzGetLocalUnitZ(whichUnit) end

---@param whichPlayer player
---@param techid integer
---@param levels integer
---@return nothing
function BlzDecPlayerTechResearched(whichPlayer, techid, levels) end

---@param damage real
---@return nothing
function BlzSetEventDamage(damage) end

---@return unit
function BlzGetEventDamageTarget() end

---@return attacktype
function BlzGetEventAttackType() end

---@return damagetype
function BlzGetEventDamageType() end

---@return weapontype
function BlzGetEventWeaponType() end

---@param attackType attacktype
---@return boolean
function BlzSetEventAttackType(attackType) end

---@param damageType damagetype
---@return boolean
function BlzSetEventDamageType(damageType) end

---@param weaponType weapontype
---@return boolean
function BlzSetEventWeaponType(weaponType) end

---@return boolean
function BlzGetEventIsAttack() end

---@param dataType integer
---@param whichPlayer player
---@param param1 string
---@param param2 string
---@param param3 boolean
---@param param4 integer
---@param param5 integer
---@param param6 integer
---@return integer
function RequestExtraIntegerData(dataType, whichPlayer, param1, param2, param3, param4, param5, param6) end

---@param dataType integer
---@param whichPlayer player
---@param param1 string
---@param param2 string
---@param param3 boolean
---@param param4 integer
---@param param5 integer
---@param param6 integer
---@return boolean
function RequestExtraBooleanData(dataType, whichPlayer, param1, param2, param3, param4, param5, param6) end

---@param dataType integer
---@param whichPlayer player
---@param param1 string
---@param param2 string
---@param param3 boolean
---@param param4 integer
---@param param5 integer
---@param param6 integer
---@return string
function RequestExtraStringData(dataType, whichPlayer, param1, param2, param3, param4, param5, param6) end

---@param dataType integer
---@param whichPlayer player
---@param param1 string
---@param param2 string
---@param param3 boolean
---@param param4 integer
---@param param5 integer
---@param param6 integer
---@return real
function RequestExtraRealData(dataType, whichPlayer, param1, param2, param3, param4, param5, param6) end

---@param whichUnit unit
---@return real
function BlzGetUnitZ(whichUnit) end

---@param enableSelection boolean
---@param enableSelectionCircle boolean
---@return nothing
function BlzEnableSelections(enableSelection, enableSelectionCircle) end

---@return boolean
function BlzIsSelectionEnabled() end

---@return boolean
function BlzIsSelectionCircleEnabled() end

---@param whichSetup camerasetup
---@param doPan boolean
---@param forcedDuration real
---@param easeInDuration real
---@param easeOutDuration real
---@param smoothFactor real
---@return nothing
function BlzCameraSetupApplyForceDurationSmooth(whichSetup, doPan, forcedDuration, easeInDuration, easeOutDuration, smoothFactor) end

---@param enable boolean
---@return nothing
function BlzEnableTargetIndicator(enable) end

---@return boolean
function BlzIsTargetIndicatorEnabled() end

---@param show boolean
---@return nothing
function BlzShowTerrain(show) end

---@param show boolean
---@return nothing
function BlzShowSkyBox(show) end

---@param fps integer
---@return nothing
function BlzStartRecording(fps) end

---@return nothing
function BlzEndRecording() end

---@param whichUnit unit
---@param show boolean
---@return nothing
function BlzShowUnitTeamGlow(whichUnit, show) end

---@param frameType originframetype
---@param index integer
---@return framehandle
function BlzGetOriginFrame(frameType, index) end

---@param enable boolean
---@return nothing
function BlzEnableUIAutoPosition(enable) end

---@param enable boolean
---@return nothing
function BlzHideOriginFrames(enable) end

---@param a integer
---@param r integer
---@param g integer
---@param b integer
---@return integer
function BlzConvertColor(a, r, g, b) end

---@param TOCFile string
---@return boolean
function BlzLoadTOCFile(TOCFile) end

---@param name string
---@param owner framehandle
---@param priority integer
---@param createContext integer
---@return framehandle
function BlzCreateFrame(name, owner, priority, createContext) end

---@param name string
---@param owner framehandle
---@param createContext integer
---@return framehandle
function BlzCreateSimpleFrame(name, owner, createContext) end

---@param typeName string
---@param name string
---@param owner framehandle
---@param inherits string
---@param createContext integer
---@return framehandle
function BlzCreateFrameByType(typeName, name, owner, inherits, createContext) end

---@param frame framehandle
---@return nothing
function BlzDestroyFrame(frame) end

---@param frame framehandle
---@param point framepointtype
---@param relative framehandle
---@param relativePoint framepointtype
---@param x real
---@param y real
---@return nothing
function BlzFrameSetPoint(frame, point, relative, relativePoint, x, y) end

---@param frame framehandle
---@param point framepointtype
---@param x real
---@param y real
---@return nothing
function BlzFrameSetAbsPoint(frame, point, x, y) end

---@param frame framehandle
---@return nothing
function BlzFrameClearAllPoints(frame) end

---@param frame framehandle
---@param relative framehandle
---@return nothing
function BlzFrameSetAllPoints(frame, relative) end

---@param frame framehandle
---@param visible boolean
---@return nothing
function BlzFrameSetVisible(frame, visible) end

---@param frame framehandle
---@return boolean
function BlzFrameIsVisible(frame) end

---@param name string
---@param createContext integer
---@return framehandle
function BlzGetFrameByName(name, createContext) end

---@param frame framehandle
---@return string
function BlzFrameGetName(frame) end

---@param frame framehandle
---@return nothing
function BlzFrameClick(frame) end

---@param frame framehandle
---@param text string
---@return nothing
function BlzFrameSetText(frame, text) end

---@param frame framehandle
---@return string
function BlzFrameGetText(frame) end

---@param frame framehandle
---@param text string
---@return nothing
function BlzFrameAddText(frame, text) end

---@param frame framehandle
---@param size integer
---@return nothing
function BlzFrameSetTextSizeLimit(frame, size) end

---@param frame framehandle
---@return integer
function BlzFrameGetTextSizeLimit(frame) end

---@param frame framehandle
---@param color integer
---@return nothing
function BlzFrameSetTextColor(frame, color) end

---@param frame framehandle
---@param flag boolean
---@return nothing
function BlzFrameSetFocus(frame, flag) end

---@param frame framehandle
---@param modelFile string
---@param cameraIndex integer
---@return nothing
function BlzFrameSetModel(frame, modelFile, cameraIndex) end

---@param frame framehandle
---@param enabled boolean
---@return nothing
function BlzFrameSetEnable(frame, enabled) end

---@param frame framehandle
---@return boolean
function BlzFrameGetEnable(frame) end

---@param frame framehandle
---@param alpha integer
---@return nothing
function BlzFrameSetAlpha(frame, alpha) end

---@param frame framehandle
---@return integer
function BlzFrameGetAlpha(frame) end

---@param frame framehandle
---@param primaryProp integer
---@param flags integer
---@return nothing
function BlzFrameSetSpriteAnimate(frame, primaryProp, flags) end

---@param frame framehandle
---@param texFile string
---@param flag integer
---@param blend boolean
---@return nothing
function BlzFrameSetTexture(frame, texFile, flag, blend) end

---@param frame framehandle
---@param scale real
---@return nothing
function BlzFrameSetScale(frame, scale) end

---@param frame framehandle
---@param tooltip framehandle
---@return nothing
function BlzFrameSetTooltip(frame, tooltip) end

---@param frame framehandle
---@param enable boolean
---@return nothing
function BlzFrameCageMouse(frame, enable) end

---@param frame framehandle
---@param value real
---@return nothing
function BlzFrameSetValue(frame, value) end

---@param frame framehandle
---@return real
function BlzFrameGetValue(frame) end

---@param frame framehandle
---@param minValue real
---@param maxValue real
---@return nothing
function BlzFrameSetMinMaxValue(frame, minValue, maxValue) end

---@param frame framehandle
---@param stepSize real
---@return nothing
function BlzFrameSetStepSize(frame, stepSize) end

---@param frame framehandle
---@param width real
---@param height real
---@return nothing
function BlzFrameSetSize(frame, width, height) end

---@param frame framehandle
---@param color integer
---@return nothing
function BlzFrameSetVertexColor(frame, color) end

---@param frame framehandle
---@param level integer
---@return nothing
function BlzFrameSetLevel(frame, level) end

---@param frame framehandle
---@param parent framehandle
---@return nothing
function BlzFrameSetParent(frame, parent) end

---@param frame framehandle
---@return framehandle
function BlzFrameGetParent(frame) end

---@param frame framehandle
---@return real
function BlzFrameGetHeight(frame) end

---@param frame framehandle
---@return real
function BlzFrameGetWidth(frame) end

---@param frame framehandle
---@param fileName string
---@param height real
---@param flags integer
---@return nothing
function BlzFrameSetFont(frame, fileName, height, flags) end

---@param frame framehandle
---@param vert textaligntype
---@param horz textaligntype
---@return nothing
function BlzFrameSetTextAlignment(frame, vert, horz) end

---@param frame framehandle
---@return integer
function BlzFrameGetChildrenCount(frame) end

---@param frame framehandle
---@param index integer
---@return framehandle
function BlzFrameGetChild(frame, index) end

---@param whichTrigger trigger
---@param frame framehandle
---@param eventId frameeventtype
---@return event
function BlzTriggerRegisterFrameEvent(whichTrigger, frame, eventId) end

---@return framehandle
function BlzGetTriggerFrame() end

---@return frameeventtype
function BlzGetTriggerFrameEvent() end

---@return real
function BlzGetTriggerFrameValue() end

---@return string
function BlzGetTriggerFrameText() end

---@param whichTrigger trigger
---@param whichPlayer player
---@param prefix string
---@param fromServer boolean
---@return event
function BlzTriggerRegisterPlayerSyncEvent(whichTrigger, whichPlayer, prefix, fromServer) end

---@param prefix string
---@param data string
---@return boolean
function BlzSendSyncData(prefix, data) end

---@return string
function BlzGetTriggerSyncPrefix() end

---@return string
function BlzGetTriggerSyncData() end

---@param whichTrigger trigger
---@param whichPlayer player
---@param key oskeytype
---@param metaKey integer
---@param keyDown boolean
---@return event
function BlzTriggerRegisterPlayerKeyEvent(whichTrigger, whichPlayer, key, metaKey, keyDown) end

---@return oskeytype
function BlzGetTriggerPlayerKey() end

---@return integer
function BlzGetTriggerPlayerMetaKey() end

---@return boolean
function BlzGetTriggerPlayerIsKeyDown() end

---@param enable boolean
---@return nothing
function BlzEnableCursor(enable) end

---@param x integer
---@param y integer
---@return nothing
function BlzSetMousePos(x, y) end

---@return integer
function BlzGetLocalClientWidth() end

---@return integer
function BlzGetLocalClientHeight() end

---@return boolean
function BlzIsLocalClientActive() end

---@return unit
function BlzGetMouseFocusUnit() end

---@param texFile string
---@return boolean
function BlzChangeMinimapTerrainTex(texFile) end

---@return string
function BlzGetLocale() end

---@param whichEffect effect
---@return real
function BlzGetSpecialEffectScale(whichEffect) end

---@param whichEffect effect
---@param x real
---@param y real
---@param z real
---@return nothing
function BlzSetSpecialEffectMatrixScale(whichEffect, x, y, z) end

---@param whichEffect effect
---@return nothing
function BlzResetSpecialEffectMatrix(whichEffect) end

---@param whichUnit unit
---@param abilId integer
---@return ability
function BlzGetUnitAbility(whichUnit, abilId) end

---@param whichUnit unit
---@param index integer
---@return ability
function BlzGetUnitAbilityByIndex(whichUnit, index) end

---@param whichAbility ability
---@return integer
function BlzGetAbilityId(whichAbility) end

---@param whichPlayer player
---@param recipient integer
---@param message string
---@return nothing
function BlzDisplayChatMessage(whichPlayer, recipient, message) end

---@param whichUnit unit
---@param flag boolean
---@return nothing
function BlzPauseUnitEx(whichUnit, flag) end

---@param whichUnit unit
---@param facingAngle real
---@return nothing
function BlzSetUnitFacingEx(whichUnit, facingAngle) end

---@param abilityId integer
---@param order string
---@return commandbuttoneffect
function CreateCommandButtonEffect(abilityId, order) end

---@param whichUprgade integer
---@return commandbuttoneffect
function CreateUpgradeCommandButtonEffect(whichUprgade) end

---@param abilityId integer
---@return commandbuttoneffect
function CreateLearnCommandButtonEffect(abilityId) end

---@param whichEffect commandbuttoneffect
---@return nothing
function DestroyCommandButtonEffect(whichEffect) end

---@param x integer
---@param y integer
---@return integer
function BlzBitOr(x, y) end

---@param x integer
---@param y integer
---@return integer
function BlzBitAnd(x, y) end

---@param x integer
---@param y integer
---@return integer
function BlzBitXor(x, y) end

---@param whichAbility ability
---@param whichField abilitybooleanfield
---@return boolean
function BlzGetAbilityBooleanField(whichAbility, whichField) end

---@param whichAbility ability
---@param whichField abilityintegerfield
---@return integer
function BlzGetAbilityIntegerField(whichAbility, whichField) end

---@param whichAbility ability
---@param whichField abilityrealfield
---@return real
function BlzGetAbilityRealField(whichAbility, whichField) end

---@param whichAbility ability
---@param whichField abilitystringfield
---@return string
function BlzGetAbilityStringField(whichAbility, whichField) end

---@param whichAbility ability
---@param whichField abilitybooleanlevelfield
---@param level integer
---@return boolean
function BlzGetAbilityBooleanLevelField(whichAbility, whichField, level) end

---@param whichAbility ability
---@param whichField abilityintegerlevelfield
---@param level integer
---@return integer
function BlzGetAbilityIntegerLevelField(whichAbility, whichField, level) end

---@param whichAbility ability
---@param whichField abilityreallevelfield
---@param level integer
---@return real
function BlzGetAbilityRealLevelField(whichAbility, whichField, level) end

---@param whichAbility ability
---@param whichField abilitystringlevelfield
---@param level integer
---@return string
function BlzGetAbilityStringLevelField(whichAbility, whichField, level) end

---@param whichAbility ability
---@param whichField abilitybooleanlevelarrayfield
---@param level integer
---@param index integer
---@return boolean
function BlzGetAbilityBooleanLevelArrayField(whichAbility, whichField, level, index) end

---@param whichAbility ability
---@param whichField abilityintegerlevelarrayfield
---@param level integer
---@param index integer
---@return integer
function BlzGetAbilityIntegerLevelArrayField(whichAbility, whichField, level, index) end

---@param whichAbility ability
---@param whichField abilityreallevelarrayfield
---@param level integer
---@param index integer
---@return real
function BlzGetAbilityRealLevelArrayField(whichAbility, whichField, level, index) end

---@param whichAbility ability
---@param whichField abilitystringlevelarrayfield
---@param level integer
---@param index integer
---@return string
function BlzGetAbilityStringLevelArrayField(whichAbility, whichField, level, index) end

---@param whichAbility ability
---@param whichField abilitybooleanfield
---@param value boolean
---@return boolean
function BlzSetAbilityBooleanField(whichAbility, whichField, value) end

---@param whichAbility ability
---@param whichField abilityintegerfield
---@param value integer
---@return boolean
function BlzSetAbilityIntegerField(whichAbility, whichField, value) end

---@param whichAbility ability
---@param whichField abilityrealfield
---@param value real
---@return boolean
function BlzSetAbilityRealField(whichAbility, whichField, value) end

---@param whichAbility ability
---@param whichField abilitystringfield
---@param value string
---@return boolean
function BlzSetAbilityStringField(whichAbility, whichField, value) end

---@param whichAbility ability
---@param whichField abilitybooleanlevelfield
---@param level integer
---@param value boolean
---@return boolean
function BlzSetAbilityBooleanLevelField(whichAbility, whichField, level, value) end

---@param whichAbility ability
---@param whichField abilityintegerlevelfield
---@param level integer
---@param value integer
---@return boolean
function BlzSetAbilityIntegerLevelField(whichAbility, whichField, level, value) end

---@param whichAbility ability
---@param whichField abilityreallevelfield
---@param level integer
---@param value real
---@return boolean
function BlzSetAbilityRealLevelField(whichAbility, whichField, level, value) end

---@param whichAbility ability
---@param whichField abilitystringlevelfield
---@param level integer
---@param value string
---@return boolean
function BlzSetAbilityStringLevelField(whichAbility, whichField, level, value) end

---@param whichAbility ability
---@param whichField abilitybooleanlevelarrayfield
---@param level integer
---@param index integer
---@param value boolean
---@return boolean
function BlzSetAbilityBooleanLevelArrayField(whichAbility, whichField, level, index, value) end

---@param whichAbility ability
---@param whichField abilityintegerlevelarrayfield
---@param level integer
---@param index integer
---@param value integer
---@return boolean
function BlzSetAbilityIntegerLevelArrayField(whichAbility, whichField, level, index, value) end

---@param whichAbility ability
---@param whichField abilityreallevelarrayfield
---@param level integer
---@param index integer
---@param value real
---@return boolean
function BlzSetAbilityRealLevelArrayField(whichAbility, whichField, level, index, value) end

---@param whichAbility ability
---@param whichField abilitystringlevelarrayfield
---@param level integer
---@param index integer
---@param value string
---@return boolean
function BlzSetAbilityStringLevelArrayField(whichAbility, whichField, level, index, value) end

---@param whichAbility ability
---@param whichField abilitybooleanlevelarrayfield
---@param level integer
---@param value boolean
---@return boolean
function BlzAddAbilityBooleanLevelArrayField(whichAbility, whichField, level, value) end

---@param whichAbility ability
---@param whichField abilityintegerlevelarrayfield
---@param level integer
---@param value integer
---@return boolean
function BlzAddAbilityIntegerLevelArrayField(whichAbility, whichField, level, value) end

---@param whichAbility ability
---@param whichField abilityreallevelarrayfield
---@param level integer
---@param value real
---@return boolean
function BlzAddAbilityRealLevelArrayField(whichAbility, whichField, level, value) end

---@param whichAbility ability
---@param whichField abilitystringlevelarrayfield
---@param level integer
---@param value string
---@return boolean
function BlzAddAbilityStringLevelArrayField(whichAbility, whichField, level, value) end

---@param whichAbility ability
---@param whichField abilitybooleanlevelarrayfield
---@param level integer
---@param value boolean
---@return boolean
function BlzRemoveAbilityBooleanLevelArrayField(whichAbility, whichField, level, value) end

---@param whichAbility ability
---@param whichField abilityintegerlevelarrayfield
---@param level integer
---@param value integer
---@return boolean
function BlzRemoveAbilityIntegerLevelArrayField(whichAbility, whichField, level, value) end

---@param whichAbility ability
---@param whichField abilityreallevelarrayfield
---@param level integer
---@param value real
---@return boolean
function BlzRemoveAbilityRealLevelArrayField(whichAbility, whichField, level, value) end

---@param whichAbility ability
---@param whichField abilitystringlevelarrayfield
---@param level integer
---@param value string
---@return boolean
function BlzRemoveAbilityStringLevelArrayField(whichAbility, whichField, level, value) end

---@param whichItem item
---@param index integer
---@return ability
function BlzGetItemAbilityByIndex(whichItem, index) end

---@param whichItem item
---@param abilCode integer
---@return ability
function BlzGetItemAbility(whichItem, abilCode) end

---@param whichItem item
---@param abilCode integer
---@return boolean
function BlzItemAddAbility(whichItem, abilCode) end

---@param whichItem item
---@param whichField itembooleanfield
---@return boolean
function BlzGetItemBooleanField(whichItem, whichField) end

---@param whichItem item
---@param whichField itemintegerfield
---@return integer
function BlzGetItemIntegerField(whichItem, whichField) end

---@param whichItem item
---@param whichField itemrealfield
---@return real
function BlzGetItemRealField(whichItem, whichField) end

---@param whichItem item
---@param whichField itemstringfield
---@return string
function BlzGetItemStringField(whichItem, whichField) end

---@param whichItem item
---@param whichField itembooleanfield
---@param value boolean
---@return boolean
function BlzSetItemBooleanField(whichItem, whichField, value) end

---@param whichItem item
---@param whichField itemintegerfield
---@param value integer
---@return boolean
function BlzSetItemIntegerField(whichItem, whichField, value) end

---@param whichItem item
---@param whichField itemrealfield
---@param value real
---@return boolean
function BlzSetItemRealField(whichItem, whichField, value) end

---@param whichItem item
---@param whichField itemstringfield
---@param value string
---@return boolean
function BlzSetItemStringField(whichItem, whichField, value) end

---@param whichItem item
---@param abilCode integer
---@return boolean
function BlzItemRemoveAbility(whichItem, abilCode) end

---@param whichUnit unit
---@param whichField unitbooleanfield
---@return boolean
function BlzGetUnitBooleanField(whichUnit, whichField) end

---@param whichUnit unit
---@param whichField unitintegerfield
---@return integer
function BlzGetUnitIntegerField(whichUnit, whichField) end

---@param whichUnit unit
---@param whichField unitrealfield
---@return real
function BlzGetUnitRealField(whichUnit, whichField) end

---@param whichUnit unit
---@param whichField unitstringfield
---@return string
function BlzGetUnitStringField(whichUnit, whichField) end

---@param whichUnit unit
---@param whichField unitbooleanfield
---@param value boolean
---@return boolean
function BlzSetUnitBooleanField(whichUnit, whichField, value) end

---@param whichUnit unit
---@param whichField unitintegerfield
---@param value integer
---@return boolean
function BlzSetUnitIntegerField(whichUnit, whichField, value) end

---@param whichUnit unit
---@param whichField unitrealfield
---@param value real
---@return boolean
function BlzSetUnitRealField(whichUnit, whichField, value) end

---@param whichUnit unit
---@param whichField unitstringfield
---@param value string
---@return boolean
function BlzSetUnitStringField(whichUnit, whichField, value) end

---@param whichUnit unit
---@param whichField unitweaponbooleanfield
---@param index integer
---@return boolean
function BlzGetUnitWeaponBooleanField(whichUnit, whichField, index) end

---@param whichUnit unit
---@param whichField unitweaponintegerfield
---@param index integer
---@return integer
function BlzGetUnitWeaponIntegerField(whichUnit, whichField, index) end

---@param whichUnit unit
---@param whichField unitweaponrealfield
---@param index integer
---@return real
function BlzGetUnitWeaponRealField(whichUnit, whichField, index) end

---@param whichUnit unit
---@param whichField unitweaponstringfield
---@param index integer
---@return string
function BlzGetUnitWeaponStringField(whichUnit, whichField, index) end

---@param whichUnit unit
---@param whichField unitweaponbooleanfield
---@param index integer
---@param value boolean
---@return boolean
function BlzSetUnitWeaponBooleanField(whichUnit, whichField, index, value) end

---@param whichUnit unit
---@param whichField unitweaponintegerfield
---@param index integer
---@param value integer
---@return boolean
function BlzSetUnitWeaponIntegerField(whichUnit, whichField, index, value) end

---@param whichUnit unit
---@param whichField unitweaponrealfield
---@param index integer
---@param value real
---@return boolean
function BlzSetUnitWeaponRealField(whichUnit, whichField, index, value) end

---@param whichUnit unit
---@param whichField unitweaponstringfield
---@param index integer
---@param value string
---@return boolean
function BlzSetUnitWeaponStringField(whichUnit, whichField, index, value) end

---@param whichUnit unit
---@return integer
function BlzGetUnitSkin(whichUnit) end

---@param whichItem item
---@return integer
function BlzGetItemSkin(whichItem) end

---@param whichUnit unit
---@param skinId integer
---@return nothing
function BlzSetUnitSkin(whichUnit, skinId) end

---@param whichItem item
---@param skinId integer
---@return nothing
function BlzSetItemSkin(whichItem, skinId) end

---@param itemid integer
---@param x real
---@param y real
---@param skinId integer
---@return item
function BlzCreateItemWithSkin(itemid, x, y, skinId) end

---@param id player
---@param unitid integer
---@param x real
---@param y real
---@param face real
---@param skinId integer
---@return unit
function BlzCreateUnitWithSkin(id, unitid, x, y, face, skinId) end

---@param objectid integer
---@param x real
---@param y real
---@param face real
---@param scale real
---@param variation integer
---@param skinId integer
---@return destructable
function BlzCreateDestructableWithSkin(objectid, x, y, face, scale, variation, skinId) end

---@param objectid integer
---@param x real
---@param y real
---@param z real
---@param face real
---@param scale real
---@param variation integer
---@param skinId integer
---@return destructable
function BlzCreateDestructableZWithSkin(objectid, x, y, z, face, scale, variation, skinId) end

---@param objectid integer
---@param x real
---@param y real
---@param face real
---@param scale real
---@param variation integer
---@param skinId integer
---@return destructable
function BlzCreateDeadDestructableWithSkin(objectid, x, y, face, scale, variation, skinId) end

---@param objectid integer
---@param x real
---@param y real
---@param z real
---@param face real
---@param scale real
---@param variation integer
---@param skinId integer
---@return destructable
function BlzCreateDeadDestructableZWithSkin(objectid, x, y, z, face, scale, variation, skinId) end

---@param whichPlayer player
---@return integer
function BlzGetPlayerTownHallCount(whichPlayer) end

---@param whichUnit unit
---@param order integer
---@return boolean
function BlzQueueImmediateOrderById(whichUnit, order) end

---@param whichUnit unit
---@param order integer
---@param x real
---@param y real
---@return boolean
function BlzQueuePointOrderById(whichUnit, order, x, y) end

---@param whichUnit unit
---@param order integer
---@param targetWidget widget
---@return boolean
function BlzQueueTargetOrderById(whichUnit, order, targetWidget) end

---@param whichUnit unit
---@param order integer
---@param x real
---@param y real
---@param instantTargetWidget widget
---@return boolean
function BlzQueueInstantPointOrderById(whichUnit, order, x, y, instantTargetWidget) end

---@param whichUnit unit
---@param order integer
---@param targetWidget widget
---@param instantTargetWidget widget
---@return boolean
function BlzQueueInstantTargetOrderById(whichUnit, order, targetWidget, instantTargetWidget) end

---@param whichPeon unit
---@param unitId integer
---@param x real
---@param y real
---@return boolean
function BlzQueueBuildOrderById(whichPeon, unitId, x, y) end

---@param forWhichPlayer player
---@param neutralStructure unit
---@param unitId integer
---@return boolean
function BlzQueueNeutralImmediateOrderById(forWhichPlayer, neutralStructure, unitId) end

---@param forWhichPlayer player
---@param neutralStructure unit
---@param unitId integer
---@param x real
---@param y real
---@return boolean
function BlzQueueNeutralPointOrderById(forWhichPlayer, neutralStructure, unitId, x, y) end

---@param forWhichPlayer player
---@param neutralStructure unit
---@param unitId integer
---@param target widget
---@return boolean
function BlzQueueNeutralTargetOrderById(forWhichPlayer, neutralStructure, unitId, target) end

---@param whichUnit unit
---@return integer
function BlzGetUnitOrderCount(whichUnit) end

---@param whichUnit unit
---@param onlyQueued boolean
---@return nothing
function BlzUnitClearOrders(whichUnit, onlyQueued) end

---@param whichUnit unit
---@param clearQueue boolean
---@return nothing
function BlzUnitForceStopOrder(whichUnit, clearQueue) end

