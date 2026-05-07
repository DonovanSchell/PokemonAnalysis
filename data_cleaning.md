# Pokémon Dataset — Data Cleaning Notes

## Overview
The source dataset required several cleaning and quality steps before analysis could begin. This document outlines the issues identified, the approach taken to resolve them, and any judgment calls made along the way.

---

## Source Data
**Primary Source:** [Complete Pokemon Dataset (Updated 16.04.21) - Kaggle](https://www.kaggle.com/datasets/mariotormo/complete-pokemon-dataset-updated-090420)

The raw dataset was a single flat table (`completepokedexdataset`) with 1,045 rows and 155 columns.

---

## Issue 1: Variant & Name Extraction

### Problem
Pokémon names in the source dataset contained embedded variant information within the name field. For example:
- `Mega Charizard X`
- `Galarian Zen Mode Darmanitan`
- `Giratina Altered Forme`

This made it impossible to group or filter by base Pokémon name without first extracting the name and variant separately.

### Resolution
A 70+ condition CASE statement was written using `LIKE`, `SUBSTRING`, and `SUBSTR` pattern matching to extract two clean fields:
- `name_only` — the base Pokémon name (e.g. `Charizard`, `Darmanitan`, `Giratina`)
- `variant` — the form label (e.g. `Mega X`, `Galarian Zen Mode`, `Altered`)

```sql
case
    when name like 'Mega % X' then substring(name, 6, LENGTH(name)-7)
    when name like 'Mega % Y' then substring(name, 6, LENGTH(name)-7)
    when name like 'Mega %' then substring(name, 6)
    when name like 'Alolan %' then substring(name, 8)
    when name like 'Galarian % Standard Mode' then substring(name, 10, LENGTH(name)-23)
    -- ... 70+ additional conditions
    else name
end as name_only
```

---

## Issue 2: Missing Base Variants

### Problem
After initial variant extraction, a data quality check revealed that 30+ Pokémon lacked a `Base` variant — their form-specific names were not being correctly mapped to the Base label, causing them to be excluded from analyses filtered to `variant = 'Base'`.

The following query was used to identify affected Pokémon:

```sql
SELECT
    name_only,
    COUNT(*) as variant_count,
    STRING_AGG(variant, ', ' ORDER BY variant) as variants_available
FROM pokemon_combined
GROUP BY name_only
HAVING SUM(CASE WHEN variant = 'Base' THEN 1 ELSE 0 END) = 0
ORDER BY name_only;
```

### Resolution
Three categories of issues were identified and resolved:

---

### Category 1: Source Data Typos
Three Pokémon had misspelled `name_only` values in the source dataset, causing them to appear as separate unknown Pokémon. These were corrected via `UPDATE`:

```sql
UPDATE pokemon_combined
SET name_only = 'Gourgeist' WHERE name_only = 'Gourgeis';

UPDATE pokemon_combined
SET name_only = 'Pumpkaboo' WHERE name_only = 'Pumpkabo';

UPDATE pokemon_combined
SET name_only = 'Rockruff'
WHERE name_only = 'Own' AND variant = 'Tempo';
```

| Original | Corrected | Notes |
|----------|-----------|-------|
| `Gourgeis` | `Gourgeist` | Missing 't' in source data |
| `Pumpkabo` | `Pumpkaboo` | Missing 'o' in source data |
| `Own` | `Rockruff` | Tempo Rockruff misnamed in source data |

---

### Category 2: Form-Specific Names Remapped to Base
20+ Pokémon had a canonical default form that should have been labeled `Base` but were instead receiving a form-specific variant label. These were corrected in the `variant` CASE statement by remapping the relevant conditions to return `'Base'`:

| Pokémon | Form Remapped to Base |
|---------|-----------------------|
| Darmanitan | Standard Mode |
| Deoxys | Normal Forme |
| Giratina | Altered Forme |
| Hoopa | Confined |
| Keldeo | Ordinary Forme |
| Landorus | Incarnate Forme |
| Thundurus | Incarnate Forme |
| Tornadus | Incarnate Forme |
| Lycanroc | Midday Form |
| Meloetta | Aria Forme |
| Minior | Meteor Form |
| Morpeko | Full Belly Mode |
| Oricorio | Baile Style |
| Shaymin | Land Forme |
| Wishiwashi | Solo Form |
| Wormadam | Plant Cloak |
| Zacian | Hero of Many Battles |
| Zamazenta | Hero of Many Battles |
| Zygarde | 50% Forme |

---

### Category 3: Arbitrary Base Assignment (Documented)
For Pokémon with no official "default" form — where all forms are considered equal — one form was designated as `Base` and documented here for transparency:

| Pokémon | Base Form Chosen | Rationale |
|---------|-----------------|-----------|
| Aegislash | Blade Forme | Listed first in Pokédex |
| Basculin | Red-Striped Form | Listed first in Pokédex |
| Eiscue | Ice Face | Default out-of-battle form |
| Gourgeist | Average Size | Most neutral size descriptor |
| Indeedee | Male | Listed first in Pokédex |
| Meowstic | Male | Listed first in Pokédex |
| Pumpkaboo | Average Size | Most neutral size descriptor |
| Toxtricity | Amped Form | Listed first in Pokédex |
| Urshifu | Single Strike Style | Listed first in Pokédex |

```sql
UPDATE pokemon_combined
SET variant = 'Base'
WHERE name_only = 'Gourgeist' AND variant = 'Average Size';

UPDATE pokemon_combined
SET variant = 'Base'
WHERE name_only = 'Pumpkaboo' AND variant = 'Average Size';
```

---

## Validation
After all corrections were applied, the no-Base-variant query returned **zero rows**, confirming that every Pokémon in `pokemon_combined` has a Base variant and will be included in analyses filtered to `variant = 'Base'`.

---

## Outstanding Notes
- The arbitrary Base assignments in Category 3 are documented above and should be considered when interpreting analyses involving these specific Pokémon
- Source data typos in Category 1 were corrected in `pokemon_combined` directly via `UPDATE` rather than at the source, as the source table (`completepokedexdataset`) is treated as read-only
- Gourgeist and Pumpkaboo size variants have no official canonical form — Average Size was chosen as the most neutral option
