-- =====================================================
-- 06_business_questions.sql
-- Logistics Operations & Fleet Performance Analysis
-- Business Questions
-- =====================================================

USE logistics_operations;

-- =====================================================
-- BQ1. TOP CUSTOMERS BY REVENUE
-- =====================================================

-- Business Question:
-- Which customers generate the most revenue?

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(l.load_id) AS total_loads,
    ROUND(SUM(l.revenue), 2) AS total_revenue,
    ROUND(
        SUM(l.revenue) / (SELECT SUM(revenue) FROM loads) * 100,
        2
    ) AS revenue_share_pct
FROM customers c
JOIN loads l
    ON c.customer_id = l.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY total_revenue DESC
LIMIT 10;

/*
Observation:

XYZ Foods generated the highest revenue at approximately 1.54M,
followed closely by Superior Group and Metro Group.

However, the largest customer represents only 0.59% of total company revenue.

The top 10 customers together account for approximately 5.7% of total revenue,
suggesting that revenue is broadly distributed across the customer base
and customer concentration risk appears relatively low.
*/

-- =====================================================
-- BQ2. TOP ROUTES BY REVENUE
-- =====================================================

-- Business Question:
-- Which routes generate the most revenue?

SELECT
    r.route_id,
    r.origin_city,
    r.origin_state,
    r.destination_city,
    r.destination_state,
    COUNT(l.load_id) AS total_loads,
    ROUND(SUM(l.revenue), 2) AS total_revenue,
    ROUND(
        SUM(l.revenue) / (SELECT SUM(revenue) FROM loads) * 100,
        2
    ) AS revenue_share_pct
FROM routes r
JOIN loads l
    ON r.route_id = l.route_id
GROUP BY
    r.route_id,
    r.origin_city,
    r.origin_state,
    r.destination_city,
    r.destination_state
ORDER BY total_revenue DESC
LIMIT 10;

/*
Observation:

The Philadelphia, PA to Seattle, WA route generated the highest revenue
at approximately 10.07M, representing 3.84% of total company revenue.

Several other long-distance routes also generated more than 9M in revenue.

The top 10 routes together account for approximately 34.43% of total revenue,
showing that revenue is considerably more concentrated by route than by customer.
*/

-- =====================================================
-- BQ3. HIGHEST AND LOWEST REVENUE PER MILE BY ROUTE
-- =====================================================

-- Business Question:
-- Which routes have the highest and lowest revenue per mile?

WITH route_performance AS (
    SELECT
        r.route_id,
        r.origin_city,
        r.origin_state,
        r.destination_city,
        r.destination_state,
        COUNT(l.load_id) AS total_loads,
        ROUND(SUM(l.revenue), 2) AS total_revenue,
        ROUND(SUM(t.actual_distance_miles), 2) AS total_miles,
        ROUND(
            SUM(l.revenue) / NULLIF(SUM(t.actual_distance_miles), 0),
            2
        ) AS revenue_per_mile
    FROM routes r
    JOIN loads l
        ON r.route_id = l.route_id
    JOIN trips t
        ON l.load_id = t.load_id
    GROUP BY
        r.route_id,
        r.origin_city,
        r.origin_state,
        r.destination_city,
        r.destination_state
)

(
    SELECT
        'Highest' AS performance_group,
        route_id,
        origin_city,
        origin_state,
        destination_city,
        destination_state,
        total_loads,
        total_revenue,
        total_miles,
        revenue_per_mile
    FROM route_performance
    ORDER BY revenue_per_mile DESC
    LIMIT 5
)

UNION ALL

(
    SELECT
        'Lowest' AS performance_group,
        route_id,
        origin_city,
        origin_state,
        destination_city,
        destination_state,
        total_loads,
        total_revenue,
        total_miles,
        revenue_per_mile
    FROM route_performance
    ORDER BY revenue_per_mile ASC
    LIMIT 5
);

/*
Observation:

The Philadelphia, PA to New York, NY route achieved the highest
revenue per mile at 2.72, despite generating relatively low total revenue.

Several long-distance routes generated high total revenue but lower
revenue per mile. For example, Miami, FL to Seattle, WA generated
approximately 7.52M in revenue but only 1.61 per mile.

This shows that total revenue alone does not fully describe route performance.
Revenue per mile provides an additional measure of revenue efficiency.

This metric should not be interpreted as profitability because operating
costs are not included.
*/

-- =====================================================
-- BQ4. ACTUAL VS TYPICAL DISTANCE BY ROUTE
-- =====================================================

-- Business Question:
-- How does actual distance compare with typical route distance?

SELECT
    r.route_id,
    r.origin_city,
    r.origin_state,
    r.destination_city,
    r.destination_state,
    r.typical_distance_miles,
    ROUND(AVG(t.actual_distance_miles), 2) AS avg_actual_distance_miles,
    ROUND(
        AVG(t.actual_distance_miles) - r.typical_distance_miles,
        2
    ) AS distance_difference_miles,
    ROUND(
        (
            (AVG(t.actual_distance_miles) - r.typical_distance_miles)
            / NULLIF(r.typical_distance_miles, 0)
        ) * 100,
        2
    ) AS distance_deviation_pct
FROM routes r
JOIN loads l
    ON r.route_id = l.route_id
JOIN trips t
    ON l.load_id = t.load_id
GROUP BY
    r.route_id,
    r.origin_city,
    r.origin_state,
    r.destination_city,
    r.destination_state,
    r.typical_distance_miles
ORDER BY distance_difference_miles DESC;

/*
Observation:

Actual travel distance was consistently higher than the typical route distance
across all routes.

The average deviation was relatively small and consistent, generally ranging
between approximately 2.4% and 3.1%.

Miami, FL to Seattle, WA showed the largest absolute difference,
with approximately 88.72 additional miles per trip.

Because the percentage deviation is similar across nearly all routes,
the pattern appears systematic rather than concentrated in a small number
of inefficient routes.
*/

-- =====================================================
-- BQ5. FUEL EFFICIENCY BY ROUTE
-- =====================================================

-- Business Question:
-- Which routes have the lowest fuel efficiency?

SELECT
    r.route_id,
    r.origin_city,
    r.origin_state,
    r.destination_city,
    r.destination_state,
    COUNT(t.trip_id) AS total_trips,
    ROUND(SUM(t.actual_distance_miles), 2) AS total_miles,
    ROUND(SUM(t.fuel_gallons_used), 2) AS total_fuel_gallons,
    ROUND(
        SUM(t.actual_distance_miles) /
        NULLIF(SUM(t.fuel_gallons_used), 0),
        2
    ) AS avg_mpg
FROM routes r
JOIN loads l
    ON r.route_id = l.route_id
JOIN trips t
    ON l.load_id = t.load_id
GROUP BY
    r.route_id,
    r.origin_city,
    r.origin_state,
    r.destination_city,
    r.destination_state
ORDER BY avg_mpg ASC
LIMIT 10;

/*
Observation:

The routes with the lowest fuel efficiency showed very similar results,
ranging from approximately 6.42 to 6.44 MPG.

Houston, TX to Portland, OR recorded one of the lowest values at 6.42 MPG.

The small differences between these routes suggest that fuel efficiency
is relatively consistent among the lowest-performing routes, with no
single route showing an unusually poor result.
*/

-- =====================================================
-- BQ6. TRUCKS WITH HIGHEST MAINTENANCE COST AND DOWNTIME
-- =====================================================

-- Business Question:
-- Which trucks generate the highest maintenance cost and downtime?

WITH truck_maintenance AS (
    SELECT
        t.truck_id,
        t.unit_number,
        t.make,
        t.model_year,
        COUNT(m.maintenance_id) AS maintenance_events,
        ROUND(SUM(m.total_cost), 2) AS total_maintenance_cost,
        ROUND(SUM(m.downtime_hours), 2) AS total_downtime_hours,
        ROUND(AVG(m.total_cost), 2) AS avg_maintenance_cost
    FROM trucks t
    JOIN maintenance_records m
        ON t.truck_id = m.truck_id
    GROUP BY
        t.truck_id,
        t.unit_number,
        t.make,
        t.model_year
),

truck_ranking AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            ORDER BY total_maintenance_cost DESC
        ) AS maintenance_cost_rank,
        DENSE_RANK() OVER (
            ORDER BY total_downtime_hours DESC
        ) AS downtime_rank
    FROM truck_maintenance
)

SELECT
    truck_id,
    unit_number,
    make,
    model_year,
    maintenance_events,
    total_maintenance_cost,
    total_downtime_hours,
    avg_maintenance_cost,
    maintenance_cost_rank,
    downtime_rank
FROM truck_ranking
WHERE
    maintenance_cost_rank <= 10
    OR downtime_rank <= 10
ORDER BY
    maintenance_cost_rank,
    downtime_rank;

/*
Observation:

TRK00003, a 2018 Peterbilt, showed the most critical maintenance
performance, ranking first in both total maintenance cost and downtime.

It accumulated approximately 90.16K in maintenance costs and
1,133.10 hours of downtime.

Maintenance cost and downtime do not always move together.
For example, TRK00081 ranked third in maintenance cost but only
29th in downtime, while TRK00046 ranked 24th in maintenance cost
but fourth in downtime.

This indicates that evaluating both cost and downtime provides a more
complete view of fleet maintenance performance than using either
metric alone.
*/

-- =====================================================
-- BQ7. TRUCK AGE, FUEL EFFICIENCY AND MAINTENANCE COST
-- =====================================================

-- Business Question:
-- Does truck age appear related to MPG or maintenance cost?

WITH fuel_by_truck AS (
    SELECT
        truck_id,
        SUM(actual_distance_miles) /
        NULLIF(SUM(fuel_gallons_used), 0) AS avg_mpg
    FROM trips
    WHERE truck_id IS NOT NULL
    GROUP BY truck_id
),

maintenance_by_truck AS (
    SELECT
        truck_id,
        SUM(total_cost) AS total_maintenance_cost
    FROM maintenance_records
    GROUP BY truck_id
)

SELECT
    t.model_year,
    COUNT(t.truck_id) AS total_trucks,
    ROUND(AVG(f.avg_mpg), 2) AS avg_mpg,
    ROUND(AVG(m.total_maintenance_cost), 2) AS avg_maintenance_cost
FROM trucks t
JOIN fuel_by_truck f
    ON t.truck_id = f.truck_id
JOIN maintenance_by_truck m
    ON t.truck_id = m.truck_id
GROUP BY t.model_year
ORDER BY t.model_year ASC;

/*
Observation:

Fuel efficiency remained very stable across model years,
ranging from approximately 6.42 to 6.46 MPG.

No clear relationship was observed between truck model year
and fuel efficiency.

Maintenance cost also did not show a consistent pattern with truck age.
Older trucks were not systematically more expensive to maintain
than newer trucks.

The 2021 model year showed the highest average maintenance cost,
but this result is based on only one truck and should therefore
be interpreted cautiously.

Overall, truck age does not appear to be a strong standalone predictor
of fuel efficiency or maintenance cost in this dataset.
*/

-- =====================================================
-- BQ8. DELIVERY DELAYS AND DETENTION BY FACILITY
-- =====================================================

-- Business Question:
-- Where are delivery delays and detention concentrated?

SELECT
    f.facility_id,
    f.facility_name,
    f.city,
    f.state,
    COUNT(de.event_id) AS total_deliveries,

    SUM(
        CASE
            WHEN de.on_time_flag = 0 THEN 1
            ELSE 0
        END
    ) AS delayed_deliveries,

    ROUND(
        SUM(
            CASE
                WHEN de.on_time_flag = 0 THEN 1
                ELSE 0
            END
        ) / COUNT(de.event_id) * 100,
        2
    ) AS delay_rate_pct,

    ROUND(AVG(de.detention_minutes), 2) AS avg_detention_minutes,

    ROUND(SUM(de.detention_minutes), 2) AS total_detention_minutes

FROM facilities f
JOIN delivery_events de
    ON f.facility_id = de.facility_id

WHERE de.event_type = 'Delivery'

GROUP BY
    f.facility_id,
    f.facility_name,
    f.city,
    f.state

ORDER BY
    delay_rate_pct DESC,
    avg_detention_minutes DESC;

/*
Observation:

Delivery delays were broadly distributed across facilities rather than
being concentrated in a small number of locations.

FAC00048, Indianapolis Warehouse, recorded the highest delay rate at 58.08%,
followed closely by Charlotte Terminal at 58.07% and Nashville Distribution
Center at 57.69%.

However, delay rates were relatively similar across all facilities,
generally ranging from approximately 52% to 58%.

Average detention time was also fairly consistent, generally between
approximately 102 and 110 minutes.

These results suggest that delivery delays and detention may represent
a broader operational issue rather than a problem isolated to a few facilities.
*/

-- =====================================================
-- BQ9. ROUTES WITH WEAKEST ON-TIME DELIVERY PERFORMANCE
-- =====================================================

-- Business Question:
-- Which routes have the weakest on-time delivery performance?

SELECT
    r.route_id,
    r.origin_city,
    r.origin_state,
    r.destination_city,
    r.destination_state,
    COUNT(de.event_id) AS total_deliveries,

    SUM(
        CASE
            WHEN de.on_time_flag = 1 THEN 1
            ELSE 0
        END
    ) AS on_time_deliveries,

    SUM(
        CASE
            WHEN de.on_time_flag = 0 THEN 1
            ELSE 0
        END
    ) AS delayed_deliveries,

    ROUND(
        AVG(de.on_time_flag) * 100,
        2
    ) AS on_time_rate_pct,

    ROUND(
        AVG(de.detention_minutes),
        2
    ) AS avg_detention_minutes

FROM routes r
JOIN loads l
    ON r.route_id = l.route_id
JOIN trips t
    ON l.load_id = t.load_id
JOIN delivery_events de
    ON t.trip_id = de.trip_id

WHERE de.event_type = 'Delivery'

GROUP BY
    r.route_id,
    r.origin_city,
    r.origin_state,
    r.destination_city,
    r.destination_state

ORDER BY
    on_time_rate_pct ASC,
    avg_detention_minutes DESC

LIMIT 10;

/*
Observation:

The Seattle, WA to Charlotte, NC route recorded the weakest
on-time delivery performance at 42.40%.

The other lowest-performing routes showed very similar results,
with on-time delivery rates generally between approximately
42% and 43%.

Average detention time among these routes was also relatively similar,
generally around 100 to 108 minutes.

The small differences between routes suggest that poor delivery
reliability may be a broader operational issue rather than a problem
limited to a small number of routes.
*/

-- =====================================================
-- BQ10. DRIVERS WITH HIGHEST PREVENTABLE INCIDENT RATE
-- =====================================================

-- Business Question:
-- Which drivers have the highest preventable incident rate?

WITH driver_incidents AS (
    SELECT
        driver_id,
        SUM(
            CASE
                WHEN preventable_flag = 1 THEN 1
                ELSE 0
            END
        ) AS preventable_incidents
    FROM safety_incidents
    WHERE driver_id IS NOT NULL
    GROUP BY driver_id
)

SELECT
    d.driver_id,
    CONCAT(d.first_name, ' ', d.last_name) AS driver_name,
    COUNT(t.trip_id) AS total_trips,
    ROUND(SUM(t.actual_distance_miles), 2) AS total_miles,
    COALESCE(di.preventable_incidents, 0) AS preventable_incidents,
    ROUND(
        COALESCE(di.preventable_incidents, 0) /
        NULLIF(SUM(t.actual_distance_miles), 0) * 100000,
        2
    ) AS preventable_incidents_per_100k_miles
FROM drivers d
JOIN trips t
    ON d.driver_id = t.driver_id
LEFT JOIN driver_incidents di
    ON d.driver_id = di.driver_id
GROUP BY
    d.driver_id,
    d.first_name,
    d.last_name,
    di.preventable_incidents
ORDER BY preventable_incidents_per_100k_miles DESC
LIMIT 10;

/*
Observation:

Richard Hernandez and David Miller recorded the highest preventable
incident rate at 0.32 incidents per 100,000 miles.

Both drivers recorded three preventable incidents during the analyzed period.

The differences among the highest-ranked drivers were relatively small,
with rates ranging from 0.20 to 0.32 incidents per 100,000 miles.

Because the absolute number of preventable incidents is low,
these rankings should be interpreted cautiously.

Using incidents per 100,000 miles provides a fairer comparison than
using raw incident counts because it accounts for driver exposure.
*/
