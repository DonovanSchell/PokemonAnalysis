/*Layer 1 — "Has This Type" (Type Membership)
This treats every type equally regardless of position
Answers "which types are strongest overall?" */
SELECT
    pokemon_type,
    COUNT(*) as count,
    ROUND(AVG(total_points)) as avg_total_points,
    ROUND(AVG(hp)) as avg_hp,
    ROUND(AVG(attack)) as avg_attack,
    ROUND(AVG(defense)) as avg_defense,
    ROUND(AVG(sp_attack)) as avg_sp_atk,
    ROUND(AVG(sp_defense)) as avg_sp_def,
    ROUND(AVG(speed)) as avg_speed
FROM (
    SELECT type_1 AS pokemon_type, total_points, hp, attack, defense, sp_attack, sp_defense, speed
    FROM pokemon_combined WHERE variant = 'Base'

    UNION ALL

    SELECT type_2 AS pokemon_type, total_points, hp, attack, defense, sp_attack, sp_defense, speed
	FROM pokemon_combined WHERE variant = 'Base' AND NULLIF(type_2, '') IS NOT NULL
) t
GROUP BY pokemon_type
ORDER BY avg_total_points DESC;

/*Layer 2 — Type Combination Drill Down
This treats every type combination as its own unique identity.
Answers "how strong are Pokémon that have X type at all?*/
SELECT
    CONCAT(pc.type_1, '/', COALESCE(pc.type_2, 'None')) AS type_combo,
    COUNT(*) as count,
    ROUND(AVG(pc.total_points)) as avg_total_points,
    ROUND(AVG(pc.hp)) as avg_hp,
    ROUND(AVG(pc.attack)) as avg_attack,
    ROUND(AVG(pc.defense)) as avg_defense,
    ROUND(AVG(pc.sp_attack)) as avg_sp_atk,
    ROUND(AVG(pc.sp_defense)) as avg_sp_def,
    ROUND(AVG(pc.speed)) as avg_speed
FROM pokemon_combined pc
WHERE variant = 'Base'
GROUP BY type_combo
ORDER BY avg_total_points DESC;

--how much above/below avg are top/bottom types from avg across all Pokemon as a baseline?
WITH overall_avg AS (
    SELECT
        ROUND(AVG(total_points)) as avg_total_points,
        ROUND(AVG(hp)) as avg_hp,
        ROUND(AVG(attack)) as avg_attack,
        ROUND(AVG(defense)) as avg_defense,
        ROUND(AVG(sp_attack)) as avg_sp_atk,
        ROUND(AVG(sp_defense)) as avg_sp_def,
        ROUND(AVG(speed)) as avg_speed
    FROM pokemon_combined
    WHERE variant = 'Base'
),
group_avg AS (
    SELECT
        CASE 
            WHEN pokemon_type IN ('Dragon', 'Steel', 'Ice', 'Fighting') THEN 'Top Performers'
            WHEN pokemon_type IN ('Poison', 'Normal', 'Bug') THEN 'Bottom Performers'
        END AS type_group,
        ROUND(AVG(total_points)) as avg_total_points,
        ROUND(AVG(hp)) as avg_hp,
        ROUND(AVG(attack)) as avg_attack,
        ROUND(AVG(defense)) as avg_defense,
        ROUND(AVG(sp_attack)) as avg_sp_atk,
        ROUND(AVG(sp_defense)) as avg_sp_def,
        ROUND(AVG(speed)) as avg_speed
    FROM (
        SELECT type_1 AS pokemon_type, total_points, hp, attack, defense, sp_attack, sp_defense, speed
        FROM pokemon_combined WHERE variant = 'Base'

        UNION ALL

        SELECT type_2 AS pokemon_type, total_points, hp, attack, defense, sp_attack, sp_defense, speed
        FROM pokemon_combined WHERE variant = 'Base' AND type_2 IS NOT NULL AND type_2 <> ''
    ) t
    WHERE pokemon_type IN ('Dragon', 'Steel', 'Ice', 'Fighting', 'Poison', 'Normal', 'Bug')
    GROUP BY type_group
)
SELECT
    ga.type_group,
    ga.avg_total_points,
    ga.avg_total_points - oa.avg_total_points AS diff_total_points,
    ga.avg_attack - oa.avg_attack AS diff_attack,
    ga.avg_defense - oa.avg_defense AS diff_defense,
    ga.avg_hp - oa.avg_hp AS diff_hp,
    ga.avg_sp_atk - oa.avg_sp_atk AS diff_sp_atk,
    ga.avg_sp_def - oa.avg_sp_def AS diff_sp_def,
    ga.avg_speed - oa.avg_speed AS diff_speed
FROM group_avg ga
CROSS JOIN overall_avg oa
ORDER BY ga.avg_total_points DESC;

--distribution of normal, sub legendary, legendary, and mythical across top/bottom perfoming types
WITH type_status AS (
    SELECT
        CASE 
            WHEN pokemon_type IN ('Dragon', 'Steel', 'Ice', 'Fighting') THEN 'Top Performers'
            WHEN pokemon_type IN ('Poison', 'Normal', 'Bug') THEN 'Bottom Performers'
        END AS type_group,
        status,
        COUNT(*) as count
    FROM (
        SELECT type_1 AS pokemon_type, status
        FROM pokemon_combined WHERE variant = 'Base'

        union all

        SELECT type_2 AS pokemon_type, status
        FROM pokemon_combined WHERE variant = 'Base' AND type_2 IS NOT NULL AND type_2 <> ''
    ) t
    WHERE pokemon_type IN ('Dragon', 'Steel', 'Ice', 'Fighting', 'Poison', 'Normal', 'Bug')
    GROUP BY type_group, status
),
group_totals AS (
    SELECT type_group, SUM(count) as total
    FROM type_status
    GROUP BY type_group
)
SELECT
    ts.type_group,
    ts.status,
    ts.count,
    gt.total,
    ROUND(ts.count::numeric / gt.total * 100, 1) AS pct_of_group
FROM type_status ts
JOIN group_totals gt ON ts.type_group = gt.type_group
ORDER BY ts.type_group, ts.count DESC;

--difference of avg base stats against avg of pokemon all-up as baseline
WITH overall_avg AS (
    SELECT
        ROUND(AVG(total_points)) as avg_total_points,
        ROUND(AVG(hp)) as avg_hp,
        ROUND(AVG(attack)) as avg_attack,
        ROUND(AVG(defense)) as avg_defense,
        ROUND(AVG(sp_attack)) as avg_sp_atk,
        ROUND(AVG(sp_defense)) as avg_sp_def,
        ROUND(AVG(speed)) as avg_speed
    FROM pokemon_combined
    WHERE variant = 'Base' AND status = 'Normal'
),
group_avg AS (
    SELECT
        CASE 
            WHEN pokemon_type IN ('Dragon', 'Steel', 'Ice', 'Fighting') THEN 'Top Performers'
            WHEN pokemon_type IN ('Poison', 'Normal', 'Bug') THEN 'Bottom Performers'
        END AS type_group,
        ROUND(AVG(total_points)) as avg_total_points,
        ROUND(AVG(hp)) as avg_hp,
        ROUND(AVG(attack)) as avg_attack,
        ROUND(AVG(defense)) as avg_defense,
        ROUND(AVG(sp_attack)) as avg_sp_atk,
        ROUND(AVG(sp_defense)) as avg_sp_def,
        ROUND(AVG(speed)) as avg_speed
    FROM (
        SELECT type_1 AS pokemon_type, total_points, hp, attack, defense, sp_attack, sp_defense, speed
        FROM pokemon_combined WHERE variant = 'Base' AND status = 'Normal'

        UNION ALL

        SELECT type_2 AS pokemon_type, total_points, hp, attack, defense, sp_attack, sp_defense, speed
        FROM pokemon_combined WHERE variant = 'Base' AND status = 'Normal' AND type_2 IS NOT NULL AND type_2 <> ''
    ) t
    WHERE pokemon_type IN ('Dragon', 'Steel', 'Ice', 'Fighting', 'Poison', 'Normal', 'Bug')
    GROUP BY type_group
)
SELECT
    ga.type_group,
    ga.avg_total_points,
    ga.avg_total_points - oa.avg_total_points AS diff_total_points,
    ga.avg_attack - oa.avg_attack AS diff_attack,
    ga.avg_defense - oa.avg_defense AS diff_defense,
    ga.avg_hp - oa.avg_hp AS diff_hp,
    ga.avg_sp_atk - oa.avg_sp_atk AS diff_sp_atk,
    ga.avg_sp_def - oa.avg_sp_def AS diff_sp_def,
    ga.avg_speed - oa.avg_speed AS diff_speed
FROM group_avg ga
CROSS JOIN overall_avg oa
ORDER BY ga.avg_total_points DESC;
