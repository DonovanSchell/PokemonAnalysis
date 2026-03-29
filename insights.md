# Key Insights & Analysis Notes

## About This Dataset

This dataset leverages the [Complete Pokemon Dataset (Updated 16.04.21)](https://www.kaggle.com/datasets/mariotormo/complete-pokemon-dataset-updated-090420) availabe on Kaggle.com. It contains information on 898 Pokémon (1,208 when including varieties) through Generation 8. This dataset includes information spanning Pokémon types, base stats, physical attributes, breeding details, catch rate, and type defenses.

Note that this dataset included variant types (e.g., Mega and regional types) along with names in the name field, which I subsequently separated into name_details (original name to serve as match key), name_only (isolating just the name), and variant (accounting for Mega, regional, and other types).

---

### Types Analysis: Dragon, Steel, Ice, and Fighting are intrinsically the strongest types, even after controlling for their higher concentration of Sub Legendary, Legendary, and Mythical Pokémon

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
| Strongest Types | 82% | 18% |
| Weakest Types | 96% | 4% |

However, when removing the Legendary+ types, the strongest types still lead by +58 Total Points on average (439 top performer avg vs 381 bottom performer avg) compared to the all-up average of ~403. So, a type advantage is **real, just not a Legendary+ inflation effect.**

**Takeaway: Even among ordinary (Base) Pokémon, Dragon/Steel/Ice/Fighting are intrinsincally stronger types, and Poison/Normal/Bug are weaker. The Legendary+ skew only amplifies this gap but doesn't create it.**

**SQL Skills Demonstrated:** Aggregation, FILTER, CASE, CTEs, UNION ALL, subqueries, CROSS JOIN, conditional filtering with NULLIF

*For an interactive view of this analysis, see the [Type Stats](https://public.tableau.com/app/profile/donovan.schell/viz/PokemonDashboard_17738990665290/TypeStats) tab of my  Pokémon Dashboard.*

---

### Generations Analysis: Power creep is real, *but nuanced.* Attack stats are the fastest growing, while speed has seen a slight decline

Average total points have trended upward from Gen 1 (408) to a rolling average peak of 433 by Gen 8 — a 25 point increase over the franchise's history. The fastest rising base stats across generations are attack stats, while defensive stats were the slowest growing and speed seeing a slight decline.

|    Stat Bucket   |       Base Stats        |
|------------------|-------------------------|
|  Fastest Growing |    Attack, Sp Attack    |
|  Slow Growing    | Defense, HP, Sp Defense |
|    Declining     |          Speed          |

Gen 4 and Gen 7 are the standout outliers, averaging 442 and 452 respectively — coming in above their rolling averages. Conversely, Gen 2, 3, and 8 underperformed relative to their rolling averages, suggesting Game Freak periodically pulls back before pushing stats higher again.

| Generation | Avg Total Points | Rolling 3-Gen Avg | Diff from Rolling Avg |
|---|-----|-----|---|
| 1 | 408 | 408 | 0 |
| 2 | 407 | 408 | -1 |
| 3 | 402 | 406 | -4 |
| 4 | 442 | 417 | +25 |
| 5 | 420 | 421 | -1 |
| 6 | 423 | 428 | -5 |
| 7 | 452 | 432 | +20 |
| 8 | 423 | 433 | -10 |

Importantly, Gen 7's elevated average is not explained by Legendary+ inflation. While Gen 7 has the highest proportion of Legendary+ Pokémon of any generation, those Pokémon actually have some of the lowest Legendary+ stats across all generations. The higher averages are instead driven by genuinely stronger Normal status Pokémon such as Golisopod, Dhelmise, and Bewear.

|Generation | Normal % | Sub Legendary % | Legendary % | Mythical % |
|-----------|----------|-----------------|-------------|------------|
| 1 | 96.7 | 2.0 | 0.7 | 0.7 |
| 2 | 94.0 | 3.0 | 2.0 | 1.0 |
| 3 | 93.3 | 3.7 | 2.2 | 0.7 |
| 4 | 88.5 | 5.8 | 1.9 | 3.8 |
| 5 | 94.6 | 2.0 | 2.0 | 1.3 |
| 6 | 93.9 | 0.0 | 3.0 | 3.0 |
| 7 | 67.9 | 20.2 | 6.0 | 6.0 |
| 8 | 90.2 | 6.1 | 2.4 | 1.2 |

Dual-typing followed an inconsistent pattern — stable at ~49% through Gen 5, peaking at 63% in Gen 7, then dropping to 40% in Gen 8. This possibly suggests that there is no strong correlation between dual-type prevalence and stat inflation.

**SQL Skill Demonstrated:** Aggregation, FILTER, CTEs, window functions (rolling average)

*For an interactive view of this analysis, see the [Generations](https://public.tableau.com/app/profile/donovan.schell/viz/PokemonDashboard_17738990665290/Generations) tab of my  Pokémon Dashboard.*

---

### Catch Rate Analysis: Mythical and Sub Legendary Pokémon are the hardest to catch, while certain "Normal" status Pokémon defy expectations with surprisingly high catch difficulty
Catch rate difficulty follows a clear hierarchy across status types — Mythical Pokémon are the hardest to catch on average, followed by Sub Legendary, Legendary, and Normal status Pokémon.

| Status | Count | Avg Catch Rate |
|--------|-------|----------------|
| Mythical | 17 | 9.53 |
| Sub Legendary | 42 | 13.29 |
| Legendary | 20 | 42.90 |
| Normal | 791 | 107.63 |

Among Legendary+ Pokémon, 55-82% follow the expected high-difficulty catch rate of 3 (note that the lower the catch rate, the higher the catch difficulty), but notable exceptions exist. Eternatus (Gen 8) and Necrozma (Gen 7) both have a catch rate of 255 — essentially guaranteed catches — for lore-driven reasons tied to their respective storylines. Several Legendary and Sub Legendary Pokémon including Xerneas, Rayquaza, and the Ultra Beasts carry a catch rate of 45, reflecting moderate difficulty relative to their status.

| Catch Rate | Sub Legendary | Mythical | Legendary | Normal |
|------------|---------------|----------|-----------|--------|
| 255 | 0% | 0% | 10% | 10% |
| 45 | 21% | 12% | 35% | 34% |
| 30 | 5% | 6% | 0% | 2% |
| 3 | 74% | 82% | 55% | 0% |

Generation 7 ranks as the most difficult generation to catch Pokémon in on average (avg catch rate: 79), while Generation 3 is the most accessible (avg catch rate: 114). Gen 7's difficulty is partly explained by its high concentration of Ultra Beasts and Legendary Pokémon.

Perhaps most surprisingly, 19 "Normal" status Pokémon carry a catch rate of 30 — rivaling many Legendary+ Pokémon in difficulty. Nearly all have total base points above 500, including Togekiss, Blissey, and Electivire. This reflects Game Freak's design philosophy of making fully evolved, non-legendary powerhouses harder to obtain.

| Pokémon | Catch Rate | Total Points |
|---------|------------|--------------|
| Togekiss | 30 | 545 |
| Blissey | 30 | 540 |
| Electivire | 30 | 540 |
| Magmortar | 30 | 540 |
| Magnezone | 30 | 535 |

**SQL Skills Demonstrated:** Aggregation, FILTER, subqueries, conditional filtering

*For an interactive catch success rate calcutor based on this analysis, see the [Catch Rate Calculator](https://public.tableau.com/app/profile/donovan.schell/viz/PokemonDashboard_17738990665290/CatchRateCalculator) tab of my  Pokémon Dashboard.*
