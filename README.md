# Analyzing Pokémon Game Design

**SQL Portfolio Project | PostgreSQL | 1,045 rows | Tableau dashboard**

An analysis of 898 Pokémon across 8 generations, exploring game balance, player experience, and design trends.

A work-in-progress Tableau dashboard can be found here: [Pokémon Dashboard](https://public.tableau.com/app/profile/donovan.schell/viz/PokemonDashboard_17738990665290/TypeStats)

---

## Dataset

### Source 1: [Complete Pokemon Dataset (Updated 16.04.21) - Kaggle](https://www.kaggle.com/datasets/mariotormo/complete-pokemon-dataset-updated-090420)

**Size:** 1,045 rows | 155 columns | 898 Pokémon

**Key fields:** Name, Variant, Generation, Status, Type_1, Type_2, Total_Points, HP, Attack, Defense, Sp_Attack, Sp_Defense, Speed

### Source 2: [Pokédex For All 1025 Pokémon (+ text descriptions) - Kaggle](https://www.kaggle.com/datasets/rzgiza/pokdex-for-all-1025-pokemon-w-text-description)

**Size:** 1,025 rows | 13 columns | 1,025 Pokémon

**Key fields:** Info

---

## Data Pipeline

The raw dataset was a single flat table requiring normalization and cleaning before analysis. The second source was included to add Pokédex descriptions to the dataset.

**1. Data Cleaning:** Pokémon names contained embedded variant information (e.g. "Mega Charizard X", "Galarian Zen Mode Darmanitan"). A 70+ condition CASE statement was written using pattern matching to extract two clean fields: name_only (base Pokémon name) and variant (e.g. Mega, Alolan, Galarian, Base).

**2. Data Modeling:** The flat table was normalized into six domain-specific tables, along with joining to the second data source for the Pokédex description text:

| Table | Contents |
|-------|----------|
| pokemon_identity_table | Name, variant, generation, status, types
| pokemon_base_stats | HP, Attack, Defense, Sp. Attack, Sp. Defense, Speed |
| pokemon_physical_attributes | Height, weight, abilities |
| pokemon_training | Catch rate, base experience, growth rate |
| pokemon_breeding | Egg types, egg cycles, gender ratio |
| pokemon_defense | Type effectiveness multipliers |
| pokemon_description | info |

**3. Data Integration:** The six normalized tables were rejoined alongside an external Pokédex description table in two ways — first as a CREATE TABLE statement producing the persistent pokemon_combined analytical table, and then rebuilt as a fully CTE-based query for practice with modular SQL patterns. Both approaches join on name_details and pokedex_number across all seven sources.

**SQL Skills Demonstrated:** String manipulation, pattern matching with LIKE, SUBSTRING/SUBSTR, CASE, normalization, JOIN, CTEs

---

## Key Questions

1. Are certain Pokémon types systematically stronger?
2. How has Pokémon design changed across generations?
3. Which Pokémon are hardest to obtain?
4. What archetypes of Pokémon exist?
5. Which types are most defensively resilient?
6. What Pokémon are easiest to breed and train?
7. Any correlation between Pokémon attributes and fighting abilities?
8. What six-Pokémon team would optimize combat across weakness and strengths?
9. Are there Pokémon that are difficult to obtain but not particularly strong?
