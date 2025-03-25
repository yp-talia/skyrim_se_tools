; =============================
;    ORC WARRIOR (LEVEL 30)
; =============================

; --- PLAYER LEVEL ---
player.setlevel 30

; --- ORC RACIAL TRAITS & ABILITIES ---
player.addspell 000AA026   ; Berserker Rage (Orc power)
player.addfac 00024029 1   ; Blood-Kin (allows access to Orc strongholds)

; --- BUFFS FOR EASE OF TESTING (comment out if you want a more difficult life)
player.modav carryweight 250
player.modav stamina 150
player.modav speedmult 100

; ================================
; SKILL DISTRIBUTION @30
; ================================
; These values approximate what an Orc warrior might have
; by level 30, with main skills (Two-Handed, Heavy Armor,
; Smithing) significantly higher, plus moderate levels in
; supporting skills. Feel free to adjust as needed.

; --- Primary Combat Skills ---
player.setav twohanded 80       ; Main damage skill
player.setav heavyarmor 70      ; Core defensive skill
player.setav smithing 60        ; Crafting/upgrading gear
player.setav block 50           ; Basic defensive with or without shield

; --- Secondary Skills (Moderate Levels) ---
player.setav onehanded 35       ; Might have used one-handed occasionally
player.setav marksman 30        ; Some minimal ranged use
player.setav enchanting 30      ; Some item enchanting for extra buffs
player.setav speechcraft 25     ; Basic bartering / persuasion
player.setav lockpicking 25     ; Occasional chest or door
player.setav alchemy 20         ; Possibly made a few potions along the way
player.setav restoration 20     ; May have used basic healing spells

; --- CORE ATTRIBUTES ---
player.setav health 300
player.setav stamina 200
player.modav damageResist 25  ; Natural toughness bonus

; ===================
; PERKS FOR AN ORC WARRIOR
; ===================
; --- Two-Handed Perks ---
player.addperk 000BABE8  ; Barbarian Rank 1
player.addperk 00079346  ; Barbarian Rank 2
player.addperk 00079347  ; Barbarian Rank 3
player.addperk 00079348  ; Barbarian Rank 4
player.addperk 00052D51  ; Champion's Stance
player.addperk 00052D52  ; Devastating Blow
player.addperk 000CB407  ; Great Critical Charge
player.addperk 0003AF9E  ; Sweep
player.addperk 0003AF84  ; Skull Crusher Rank 1
player.addperk 000C1E96  ; Skull Crusher Rank 2

; --- Heavy Armor Perks ---
player.addperk 000BCD2A  ; Juggernaut Rank 1
player.addperk 0007935E  ; Juggernaut Rank 2
player.addperk 00079361  ; Juggernaut Rank 3
player.addperk 00079362  ; Juggernaut Rank 4
player.addperk 00058F6F  ; Well Fitted
player.addperk 00058F6C  ; Tower of Strength
player.addperk 00058F6D  ; Conditioning
player.addperk 00107832  ; Matching Set

; --- Block Perks ---
player.addperk 000BCCAE  ; Shield Wall Rank 1
player.addperk 00079355  ; Shield Wall Rank 2
player.addperk 00079356  ; Shield Wall Rank 3
player.addperk 000D8C33  ; Quick Reflexes
player.addperk 00058F67  ; Power Bash
player.addperk 0005F594  ; Deadly Bash

; --- Smithing Perks ---
player.addperk 000CB40D  ; Steel Smithing
player.addperk 000CB40E  ; Dwarven Smithing
player.addperk 000CB410  ; Orcish Smithing
player.addperk 0005218E  ; Arcane Blacksmith

; ===================
; GEAR & INVENTORY
; ===================
; --- Gold & Lockpicks ---
player.additem 0000000F 4000   ; 4000 Gold
player.additem 0000000A 20     ; 20 Lockpicks

; --- Orcish Equipment ---
player.additem 00013957 1      ; Orcish Armor (Cuirass)
player.additem 00013956 1      ; Orcish Boots
player.additem 00013958 1      ; Orcish Gauntlets
player.additem 00013959 1      ; Orcish Helmet
player.additem 00013992 1      ; Orcish Warhammer (Two-Handed)

; --- Potions ---
player.additem 00039BE5 5      ; 5 Potions of Ultimate Healing
player.additem 00039CF3 5      ; 5 Potions of Ultimate Stamina
player.additem 00039980 3      ; 3 Philters of the Berserker (Fortify Two-Handed)
player.additem 000398F5 3      ; 3 Philters of the Knight (Fortify Heavy Armor)
player.additem 00039962 2      ; 2 Blacksmith's Philters (Fortify Smithing)

; --- Crafting Materials ---
player.additem 0005AD99 5      ; 5 Orichalcum Ingots
player.additem 0005ACE4 5      ; 5 Iron Ingots
player.additem 000800E4 10     ; 10 Leather Strips

; --- Food & Drink ---
player.additem 000F431D 5      ; 5 Venison Stews
player.additem 0002C35A 5      ; 5 Black-Briar Meads

; --- Gems & Misc Loot ---
player.additem 00063B45 2      ; 2 Garnets
player.additem 00063B46 2      ; 2 Amethysts
player.additem 00063B42 1      ; 1 Ruby
player.additem 00063B44 1      ; 1 Sapphire
player.additem 0001D4EC 2      ; 2 Torches

; --- Equip the Orcish Gear ---
player.equipitem 00013957
player.equipitem 00013956
player.equipitem 00013958
player.equipitem 00013959
player.equipitem 00013992

; --- Locate "Where in Oblivion Am I" Book ---
help modder