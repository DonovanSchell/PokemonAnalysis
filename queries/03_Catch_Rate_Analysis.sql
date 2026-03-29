--Count of Pokemon by status and avg catch rate
select
	status,
	count(*),
	round(avg(catch_rate),2) as avg_catch_rate
from pokemon_combined pc 
where variant = 'Base'
group by pc.status
order by
	avg_catch_rate
;
--catch difficulty from most challenging to least is mythical, sub legendary, legendary, and normal


--generation by chatch rate difficulty
select
	generation,
	count(*),
	round(avg(catch_rate),0) as avg_catch_rate
from pokemon_combined pc 
where variant = 'Base'
group by generation
order by
	avg_catch_rate
;
--Generation difficulty was 79 (with 84 Pokemons), 4 (104), 2 (100), 8 (82), 6 (66), 1 (151), 5 (149), 3 (134) (note: lower rate number = higher difficulty)


--Count of Pokemon by status and avg catch rate
select
	generation,
	status,
	count(*),
	round(avg(catch_rate),2) as avg_catch_rate
from pokemon_combined pc 
where 
	variant = 'Base' 
	and pc.generation = 7
--	and pc.name_only <> 'Eternatus'
group by 
	status,
	generation
order by
	generation,
	avg_catch_rate
;
/*nearly every gen had sub legendary and then legendary outpace other status types for catch difficultly, except:
 	* 1: sub & leg (both 3), myt, nor
 	* 2: sub & leg (both 3), myt, nor
 	* 3: sub & myt (both 3), leg, nor
 	* 4: sub & leg (both 3), myt, nor
 	* 5: sub & myt & leg (all 3), nor
 	* 6: myt, leg, nor
 	* 7: myt, sub, leg, nor
 		* Legendary difficulty pulled down by Necrozma
 			* "Necrozma's catch rate was bumped up all the way to max in US/UM. This is likely to tie in to how it got severely weakened after the battle in Ultra Megalopolis.
 			* Or, according to Colress, it may have wanted to be caught on purpose to take Solgaleo/Lunala's power."
 			* Source: https://www.reddit.com/r/pokemon/comments/auvsac/what_is_with_necrozmas_catch_rate/
 	* 8: sub & myt (both 3), nor, leg (2 at 129 avg)
 		* Legendary difficulty pulled down by Eternatus
 		* Excluding Eternatus: sub & myt & leg (all 3), nor
*/


--which Pokemon are causing the gen 8 low-difficulty catch rating?
select
	pc.name_only,
	pc.catch_rate 
from pokemon_combined pc 
where pc.variant = 'Base' and pc.status = 'Legendary' and pc.generation = 8
;
/* Low-difficult catch rate is Eternatus, which has a 100% guaranteed catch rate. The online Pokemon community notes that:
	* "He’s necessary for the game to progress so he’s basically an instant catch. RIP to anyone who uses a master ball on him"
 	* source: https://www.reddit.com/r/PokemonSwordAndShield/comments/t93n5a/did_you_know_that_eternatus_has_the_highest_catch/
 *Otherwise, the generation's only other legendary is Calyrex, which has the expected high-difficulty catch rate of 3 (aligned with other legendary( 
*/

--which Legendary+ DON'T follow the typical high-difficulty 3 catch rate?
select
	pc.name_only,
	pc.catch_rate 
from pokemon_combined pc 
where
	pc.variant = 'Base'
	and pc.status = 'Legendary'
order by catch_rate desc
;
/*Mythical:
 	* 45: Celebi, Mew (45)
 	* 30: Phione
 * Legendary:
 	* 255: Eternatus, Necrozma
 	* 45: Cosmog, Cosmoen, Solgaleo, Lunala, Xerneas, Rayquaza, Yveltal
 * Sub Legendary:
 	* 45: Kartana, Guzzlord, Poipole, Naganadel, Xurkitree, Celesteela, Nihilego, Buzzwole, Pheromosa
 	* 30:  Stakataka, Blacephalon
 *What is % of each status not at 3? Find the rate... maybe 255 vs 45 vs 30 vs 3
 */


--What is % of status and catch rate
select
	pc.status,
	round(COUNT(*) FILTER (WHERE pc.catch_rate = 255)::numeric / COUNT(*),2) AS percent_255,
	round(COUNT(*) FILTER (WHERE pc.catch_rate = 45)::numeric / COUNT(*),2) AS percent_45,
	round(COUNT(*) FILTER (WHERE pc.catch_rate = 30)::numeric / COUNT(*),2) AS percent_30,
	round(COUNT(*) FILTER (WHERE pc.catch_rate = 3)::numeric / COUNT(*),2) AS percent_3
from pokemon_combined pc 
where
	pc.variant = 'Base'
group by pc.status
; 

--what are the high-difficulty "Normal" status Pokemon?
select
	count(*),
	pc.name_only,
	pc.catch_rate,
	pc.total_points
--	avg(pc.hp) as avg_hp,
--	avg(pc.attack) as avg_attack,
--	avg(pc.defense) as avg_defense
from pokemon_combined pc 
where
	pc.variant = 'Base'
	and pc.status = 'Normal'
	and pc.catch_rate = 30
group by name_only, pc.catch_rate, pc.total_points 
order by
	pc.total_points desc
;
/*19 "Normal" status Pokemon are difficult-catch rate
	 * Nearly all a >500 total base points, with only 4 in the 400s (Absol, Chansey, Chatot, Murkrow)
	 	* why hard to catch: "low base capture rates, high flee rates, and their status as single-stage or non-evolving Pokémon that are treated as fully evolved"
 */

--what gen is Necrozma?
select 
	generation,
	status,
	pc.name_only 
from pokemon_combined pc 
where pc.name_only = 'Necrozma';

select pc.name_only, pc.total_points from pokemon_combined pc where pc.variant = 'Base' order by pc.total_points desc;
--26.7% of Pokemon are total base points 500 or higher
