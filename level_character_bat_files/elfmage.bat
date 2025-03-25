; =============================
;    HIGH ELF MAGE (LVL 30)
; =============================

; --- PLAYER LEVEL ---
player.setlevel 30

; --- HIGH ELF RACIAL TRAITS ---
player.addspell 000E40CA  ; Highborn (High Elf power, Magicka regen boost)
player.modav magicka 50   ; High Elf innate Magicka bonus

; --- BUFFS FOR EASE OF TESTING (comment out if you want a more difficult life)
player.modav carryweight 250
player.modav stamina 150
player.modav speedmult 100

; ================================
; REALISTIC SKILL DISTRIBUTION @30
; ================================
; Expected skill levels for a level 30 High Elf Mage.

player.setav destruction 80   ; Main offensive skill
player.setav restoration 70   ; Healing, wards, anti-undead
player.setav alteration 70    ; Defensive buffs, Paralyze
player.setav illusion 60      ; Crowd control, invisibility
player.setav enchanting 60    ; Improved magicka regen on gear
player.setav conjuration 40   ; Some basic summoning
player.setav speechcraft 40        ; Persuasion, buying spells
player.setav alchemy 35       ; Crafting useful potions
player.setav lockpicking 25   ; Some experience with locked chests
player.setav sneak 20         ; Occasional stealth with invisibility

; --- CORE ATTRIBUTES ---
player.setav magicka 350   ; Large Magicka pool
player.setav health 150    ; Low health (squishy)

; ===================
; PERKS FOR A MAGE
; ===================

player.addperk 000F2CA8  ; Novice Destruction
player.addperk 000C44BF  ; Apprentice Destruction
player.addperk 000C44C0  ; Adept Destruction
player.addperk 000153CF  ; Destruction Dual Casting
player.addperk 000153D2  ; Impact
player.addperk 00105F32  ; Rune Master
player.addperk 000581E7  ; Augmented Flames Rank 1
player.addperk 0010FCF8  ; Augmented Flames Rank 2
player.addperk 000F392E  ; Intense Flames
player.addperk 000581EA  ; Augmented Frost Rank 1
player.addperk 0010FCF9  ; Augmented Frost Rank 2
player.addperk 000F3933  ; Deep Freeze
player.addperk 00058200  ; Augmented Shock Rank 1
player.addperk 0010FCFA  ; Augmented Shock Rank 2
; (Optional) player.addperk 000F3F0E  ; Disintegrate (Destruction 70)

player.addperk 000F2CAA  ; Novice Restoration
player.addperk 000C44C7  ; Apprentice Restoration
player.addperk 000C44C8  ; Adept Restoration
player.addperk 000153D1  ; Restoration Dual Casting
player.addperk 000581F8  ; Regeneration
player.addperk 000581F9  ; Respite
player.addperk 000581F4  ; Recovery Rank 1
player.addperk 000581F5  ; Recovery Rank 2
player.addperk 00068BCC  ; Ward Absorb
player.addperk 000581E4  ; Necromage

player.addperk 000F2CA6  ; Novice Alteration
player.addperk 000C44B7  ; Apprentice Alteration
player.addperk 000C44B8  ; Adept Alteration
player.addperk 000153CD  ; Alteration Dual Casting
player.addperk 000D7999  ; Mage Armor Rank 1
player.addperk 000D799A  ; Mage Armor Rank 2
player.addperk 000D799B  ; Mage Armor Rank 3
player.addperk 00053128  ; Magic Resistance Rank 1
player.addperk 00053129  ; Magic Resistance Rank 2
player.addperk 0005312A  ; Magic Resistance Rank 3
player.addperk 000581FC  ; Stability

player.addperk 000F2CA9  ; Novice Illusion
player.addperk 000C44C3  ; Apprentice Illusion
player.addperk 000C44C4  ; Adept Illusion
player.addperk 000153D0  ; Illusion Dual Casting
player.addperk 000581E1  ; Animage
player.addperk 000581E2  ; Kindred Mage
player.addperk 00059B77  ; Hypnotic Gaze
player.addperk 00059B78  ; Aspect of Terror
player.addperk 000C44B5  ; Rage
player.addperk 00059B76  ; Master of the Mind

player.addperk 000BEE97  ; Enchanter Rank 1
player.addperk 000C367C  ; Enchanter Rank 2
player.addperk 000C367D  ; Enchanter Rank 3
player.addperk 000C367E  ; Enchanter Rank 4
player.addperk 000C367F  ; Enchanter Rank 5
player.addperk 00058F7E  ; Insightful Enchanter
; (Optional) player.addperk 00058F7D  ; Corpus Enchanter ; Extra Effect - include only if Enchanting = 100
player.addperk 00058F7C  ; Soul Squeezer
player.addperk 00108A44  ; Soul Siphon
; (Optional) player.addperk 00058F7F  ; Extra Effect - include only if Enchanting = 100

; --- Conjuration (optional secondary perks) ---
player.addperk 000F2CA7  ; Novice Conjuration
player.addperk 000C44BB  ; Apprentice Conjuration
player.addperk 000153CE  ; Conjuration Dual Casting
player.addperk 000640B3  ; Mystic Binding
player.addperk 000D799E  ; Soul Stealer
player.addperk 00105F30  ; Summoner Rank 1
player.addperk 000CB419  ; Atromancy
; (Optional) player.addperk 000581DD  ; Necromancy - if raising undead
; (Optional) player.addperk 000D799C  ; Oblivion Binding - if using bound weapons against summons
; (Optional) player.addperk 00105F31  ; Summoner Rank 2 - farther summon range (Conjuration 70)
; (Optional) player.addperk 000CB41A  ; Elemental Potency (Conjuration 80)
; (Optional) player.addperk 000D5F1C  ; Twin Souls (Conjuration 100)

; --- Alchemy (optional secondary perks) ---
player.addperk 000BE127  ; Alchemist Rank 1
player.addperk 000C07CA  ; Alchemist Rank 2
player.addperk 000C07CB  ; Alchemist Rank 3
player.addperk 00058215  ; Physician
player.addperk 00058216  ; Benefactor

; ===================
; GEAR
; ===================
; --- Gold & Lockpicks ---
player.additem 0000000F 5000   ; 5000 Gold
player.additem 0000000A 20     ; 20 Lockpicks

; Gear Items (IDs and quantities)
player.additem 0010F570 1   ; Archmage's Robes
player.additem 000F1B33 1   ; Savos Aren's Amulet
player.additem 00100E04 1   ; Ring of Peerless Destruction
player.additem 00061C8B 1   ; Morokei (Mask)
player.additem 00035369 1   ; Staff of Magnus
player.additem 00029B82 1   ; Staff of Fireballs
player.additem 000398F3 3   ; Elixir of Destruction (3 bottles)
player.additem 00039BE7 5   ; Potion of Ultimate Magicka (5 bottles)

; Destruction Spells
player.addspell 0001C789   ; Fireball
player.addspell 00045F9D   ; Chain Lightning
player.addspell 0010F7ED   ; Incinerate
player.addspell 0010F7EE   ; Thunderbolt
player.addspell 0010F7EC   ; Icy Spear

; Restoration Spells
player.addspell 0002F3B8   ; Fast Healing
player.addspell 000B62EF   ; Close Wounds
player.addspell 00012FD2   ; Heal Other
player.addspell 000211F1   ; Steadfast Ward
player.addspell 000211F0   ; Greater Ward

; Alteration Spells
player.addspell 0005AD5E   ; Ebonyflesh
player.addspell 0005AD5F   ; Paralyze
player.addspell 00043324   ; Candlelight
player.addspell 0001A4CC   ; Telekinesis
player.addspell 00099F39   ; Detect Life  (spell to detect living, optional)

; Illusion Spells
player.addspell 0004DEE9   ; Calm
player.addspell 0004DEEE   ; Frenzy
player.addspell 00027EB6   ; Invisibility
player.addspell 0004DEED   ; Pacify
player.addspell 0008F3EB   ; Muffle

; Conjuration Spells
player.addspell 000204C3   ; Conjure Flame Atronach
player.addspell 000204C4   ; Conjure Frost Atronach
player.addspell 000204C5   ; Conjure Storm Atronach
player.addspell 0010DDEC   ; Conjure Dremora Lord
player.addspell 0004DBA4   ; Soul Trap
player.addspell 000211EB   ; Bound Sword
player.addspell 000211ED   ; Bound Bow

; --- Potions & Soul Gems ---
player.additem 00039BE5 5      ; 5 Ultimate Magicka Potions
player.additem 00039BE4 5      ; 5 Ultimate Healing Potions
player.additem 0002E504 5      ; 5 Grand Soul Gems (Filled)

; --- Misc Items ---
player.additem 0001D4EC 2      ; 2 Torches

; --- Equip Mage Gear ---
player.equipitem 0010DFC8
player.equipitem 0010DFCA
player.equipitem 000139B2
player.equipitem 000FC036

; --- Locate \"Where in Oblivion Am I\" Book ---
help modder
