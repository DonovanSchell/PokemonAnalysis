# Key Insights & Analysis Notes

## About This Dataset

This dataset leverages the [Complete Pokemon Dataset (Updated 16.04.21)](https://www.kaggle.com/datasets/mariotormo/complete-pokemon-dataset-updated-090420) availabe on Kaggle.com. It contains information on 898 Pokémon (1,208 when including varieties) through Generation 8. This dataset includes information spanning Pokémon types, base stats, physical attributes, breeding details, catch rate, and type defenses.

Note that this dataset included variant types (e.g., Mega and regional types) along with names in the name field, which I subsequently separated into name_details (original name to serve as match key), name_only (isolating just the name), and variant (accounting for Mega, regional, and other types).

---

### Finding 1: Dragon, Steel, Ice, and Fighting are intrinsically the strongest types, even after controlling for their higher concentration of Sub Legendary, Legendary, and Mythical Pokémon

First for background, Pokémon can be dual-typed, where they have a primary (Type 1) and secondary (Type 2) type, which largely function equally regarding the Same Type Attack Bonus (STAB) and damage calcualtion, combing to determine overall resistance and weakness.

*Note: This analysis reviews Base variant Pokémon only (excluding alternative variants like Megas and regional types)*

**Strongest Types: Dragon, Steel, Ice, and Fighting**

When treating Type 1 and Type 2 equally, **dragon, steel, ice, and fighting were strongest for average Total Points** (Total Points represents a sum of all Pokémon base stats taken together, such as HP, Attack, Defense, etc). This result was driven most strongly by their high average base stats for attack and defense (these types had +16 pts higher attack and +13 pts higher defense compared to the average of all Pokémon).

**Weakest Types: Poison, Normal, and Bug**

Conversely, the Pokémon with the lowest average base stats were poison, normal, and bug. For these types, base stats were lower than average across the board, with Sp Attack and Defense coming in for their the lowests. Speed was +1 for bug and normal, indicating they leaned on being slightly faster.

**Do the Strongest Types have a Sub Legendary/Legendary/Mythical Advantage?**

Looking across Legendary+ statuses of each type, the strongest type Pokémon are skewed by having a higher percentage of Legendary+ Pokémon represented.

| Group | Normal% | Legendary+% |
|-------|----------|-------------|
| Top Performers | 82% | 18% |
| Bottom Performers | 96% | 4% |

However, when removing the Legendary+ types, the strongest types still lead by +58 Total Points on average (439 top performer avg vs 381 bottom performer avg) compared to the all-up average of ~403. So, a type advantage is **real, just not a Legendary+ inflation effect.**

**Takeaway: Even among ordinary (Base) Pokémon, Dragon/Steel/Ice/Fighting are intrinsincally stronger types, and Poison/Normal/Bug are weaker. The Legendary+ skew only amplifies this gap but doesn't create it.**

*For an interactive view of this analysis, see the [Type Stats](https://public.tableau.com/app/profile/donovan.schell/viz/PokemonDashboard_17738990665290/TypeStats) tab of my  Pokémon Dashboard.*
