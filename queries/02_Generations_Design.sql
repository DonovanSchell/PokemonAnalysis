--table readout of pokemon base stats by generation
select
	pc.generation,
	round(avg(pc.total_points),0) as avg_total_points,
	round(avg(pc.hp),0) as avg_hp,
	round(avg(pc.attack),0) as avg_attack,
	round(avg(pc.defense),0) as avg_defense, 
	round(avg(pc.sp_attack),0) as avg_sp_attack,
	round(avg(pc.sp_defense),0) as avg_sp_defense,
	round(avg(pc.speed),0) as avg_speed
from pokemon_combined pc
where pc.variant = 'Base'
group by generation 
order by generation 
;
--generation 2 saw the lowest avg_total_points while base stats peaked in generation 7


--status breakdown by generation
select
	generation,
	count(*) as total_pokemon_ct,
	count(*) filter (where pc.status = 'Normal') as normal_ct,
	count(*) filter (where pc.status = 'Sub Legendary') as sub_legendary_ct,
	count(*) filter (where pc.status = 'Legenary') as legendary_ct,
	count(*) filter (where pc.status = 'Mythical') as mythical_ct
from pokemon_combined pc
where pc.variant = 'Base'
group by generation 
order by generation 
;
--generation 7 had the highest amount of legendary+ Pokemon out of any generation


--status percent by generation
select
	pc.generation,
	round(COUNT(*) FILTER (WHERE status = 'Normal')::numeric / COUNT(*),2) AS normal_percent,
	round(COUNT(*) FILTER (WHERE status = 'Sub Legendary')::numeric / COUNT(*),2) AS sub_legendary_percent,
	round(COUNT(*) FILTER (WHERE status = 'Legendary')::numeric / COUNT(*),2) AS legendary_percent,
	round(COUNT(*) FILTER (WHERE status = 'Mythical')::numeric / COUNT(*),2) AS mythical_percent
from pokemon_combined pc
where
	variant = 'Base'
group by pc.generation
order by pc.generation
;
--indeed, generation 7 had the highest porportion of legendary+ pokemon 


--table readout of legendary+ base stats by generation
select
	pc.generation,
	count(*),
	round(avg(pc.total_points),0) as avg_total_points,
	round(AVG(pc.hp),0) as avg_hp,
	round(AVG(pc.attack),0) as avg_attack,
	round(AVG(pc.defense),0) as avg_defense, 
	round(AVG(pc.sp_attack),0) as avg_sp_attack,
	round(AVG(pc.sp_defense),0) as avg_sp_defense,
	round(AVG(pc.speed),0) as avg_speed
from pokemon_combined pc
where --pc.status = 'Normal'
	pc.status IN (
		'Sub Legendary',
		'Legendary',
		'Mythical'
		)
	and pc.variant = 'Base'
group by generation 
order by generation 
;
/*legendary+ may be driving 7 to have higher stats due to their significantly higher share that generation.
however, that generation's legendary+ have some of lowest overall stats out of all other generations for legenary+.
and this generation's normal status pokemon exceeled in avg_attack, avg_defense, and avg_sp_defense*/


--stats by gen 7 pokemon, see what is driving higher stats...
select
	pc.name_only,
	pc.total_points,
	pc.hp,
	pc.attack,
	pc.defense, 
	pc.sp_attack,
	pc.sp_defense,
	pc.speed
from pokemon_combined pc 
where
	pc.status = 'Normal'
	and pc.variant = 'Base'
	and pc.generation = 7
group by 1,2,3,4,5,6,7,8
order by pc.sp_defense  desc
;
/*Attack was highest with Crabominable (478 total), Dhelmise (517 total), Bewear (500 total)
Defense highest with Taxopex (495), Golisopod (530), Turtonator (485)
Sp Def highest with Taxopex (495), Araquanid (454), Pyukumuku (410)
 */




--dual-type be generation
select 
	pc.generation,
	count(*) as total_pokemon_ct,
	count(*) FILTER (WHERE pc.type_2 <> '') AS dual_type_ct,
	round(COUNT(*) FILTER (WHERE pc.type_2 <> '')::numeric / COUNT(*),2) AS dual_percent,
	count(*) FILTER (WHERE pc.type_2 = '') AS mono_type_ct,
	round(COUNT(*) FILTER (WHERE pc.type_2 = '')::numeric / COUNT(*),2) AS dual_percent
from pokemon_combined pc 
where pc.variant = 'Base'
group by pc.generation 
order by pc.generation 
;
/* dual-type was consistently around 49% for generations 1-5
 * Then gen 6 jumped to 55% and then gen 7 to 63%
 * Then 40% in gen 8 
 * INSIGHTS:
 	* Gen 1-5 — consistently ~49% dual-type, suggesting Game Freak had a stable design philosophy
 	* Gen 6-7 — jumps to 55% then 63%, which coincides with the 3DS era and possibly more complex/creative designs
 	* Gen 8 — drops back to 40%, which is interesting and could reflect the Sword/Shield controversy where the Pokédex was cut significantly ("Dexit"), meaning fewer Pokémon overall and possibly simpler designs
 * SUMMARY: While stat totals have trended upward, Game Freak's approach to dual-typing has been inconsistent across generations, peaking in Gen 7 before dropping sharply in Gen 8.
 */


--generation total_points avg vs 3-generation rolling average (smooths out spikes)
WITH gen_avg AS (
    SELECT
        pc.generation,
        ROUND(AVG(pc.total_points), 0) AS avg_total_points
    FROM pokemon_combined pc
    WHERE pc.variant = 'Base'
    GROUP BY pc.generation
)
SELECT
    generation,
    avg_total_points,
    ROUND(AVG(avg_total_points) OVER (ORDER BY generation ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 0) AS rolling_3gen_avg,
    avg_total_points - ROUND(AVG(avg_total_points) OVER (ORDER BY generation ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 0) AS diff_from_rolling_avg
FROM gen_avg
ORDER BY generation;
/*
 * The rolling average tells a clearer power creep story than raw averages:
 	* Starts at 408 in Gen 1
 	* Dips through Gen 2-3 (407, 402) — early games were actually slightly weaker
 	* Jumps significantly at Gen 4 (442) — a well known turning point in the franchise with more complex designs
 	* Climbs steadily to 433 by Gen 8 — a 25 point increase from Gen 1's rolling average
 * The difference column is insightful:
 	* Gen 4 and Gen 7 are the biggest positive outliers (+25, +20) — these generations pulled the average up significantly
 	* Gen 3, 6, 8 are negative — they underperformed relative to their rolling average
 */
