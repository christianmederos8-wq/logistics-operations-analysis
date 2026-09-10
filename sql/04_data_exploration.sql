-- =====================================================
-- 04_data_exploration.sql
-- Logistics Operations & Fleet Performance Analysis
-- Exploratory Data Analysis
-- =====================================================

USE logistics_operations;


-- =====================================================
-- 1. TEMPORAL ANALYSIS
-- =====================================================

-- Business Question:
-- How did load volume evolve over time?

-- Annual load volume
SELECT
    YEAR(load_date) AS load_year,
    COUNT(*) AS total_loads
FROM loads
GROUP BY YEAR(load_date)
ORDER BY load_year ASC;

/*
Results:

2022 | 28,589 loads
2023 | 28,165 loads
2024 | 28,656 loads

Observation:
Annual load volume remained relatively stable between 2022 and 2024,
with a slight decrease in 2023 followed by a recovery in 2024.
*/

-- =====================================================
-- 2. MONTHLY LOAD VOLUME
-- =====================================================

-- Business Question:
-- How did monthly load volume evolve between 2022 and 2024?

SELECT 
    YEAR(load_date) AS load_year,
    MONTH(load_date) AS load_month,
    COUNT(*) AS total_loads
FROM loads
GROUP BY 
    YEAR(load_date),
    MONTH(load_date)
ORDER BY 
    load_year,
    load_month;

/*
Observation:

Monthly load volume remained relatively stable throughout the analyzed period,
with most months recording approximately 2,300 to 2,500 loads.

February showed the lowest load volume in all three years:

2022: 2,179 loads
2023: 2,136 loads
2024: 2,267 loads

However, February has fewer calendar days than the other months.
Therefore, monthly totals alone are not enough to conclude that February
had lower operational demand.

A daily average analysis would be necessary to determine whether the lower
monthly volume is caused by fewer operating days or by an actual reduction
in load activity.
*/

-- =====================================================
-- 3. AVERAGE DAILY LOAD VOLUME
-- =====================================================

-- Business Question:
-- Was February's lower monthly load volume caused by lower operational activity,
-- or simply by having fewer calendar days?

SELECT
    YEAR(load_date) AS load_year,
    MONTH(load_date) AS load_month,
    COUNT(*) AS total_loads,
    DAY(LAST_DAY(MIN(load_date))) AS days_in_month,
    ROUND(
        COUNT(*) / DAY(LAST_DAY(MIN(load_date))),
        2
    ) AS avg_daily_loads
FROM loads
GROUP BY
    YEAR(load_date),
    MONTH(load_date)
ORDER BY
    load_year,
    load_month;

/*
Observation:

After adjusting monthly load volume by the number of calendar days,
daily operational activity remained relatively stable throughout the period.

Most months recorded approximately 75 to 81 loads per day.

February no longer consistently appears as the month with the lowest
operational activity:

2022: 77.82 loads/day
2023: 76.29 loads/day
2024: 78.17 loads/day

This indicates that February's lower monthly load totals were largely
explained by the smaller number of calendar days rather than by a
significant reduction in daily load activity.

Overall, load activity appears stable across the analyzed period,
with no strong seasonal pattern identified at this stage.
*/

-- =====================================================
-- 4. ANNUAL REVENUE
-- =====================================================

-- Business Question:
-- How much revenue did the company generate each year?

SELECT
    YEAR(load_date) AS load_year,
    SUM(revenue) AS total_revenue
FROM loads
GROUP BY load_year
ORDER BY load_year ASC;

/*
Observation:

Annual revenue remained relatively stable between 2022 and 2024.

2022: 87.85M
2023: 86.96M
2024: 87.72M

Revenue decreased slightly in 2023 and recovered in 2024.

Since annual load volume was also relatively stable during the same period,
the company appears to have maintained a consistent level of operational
and financial activity across the three years.
*/


-- =====================================================
-- 5. AVERAGE REVENUE PER LOAD
-- =====================================================

-- Business Question:
-- Did the average revenue per load remain stable between 2022 and 2024?

SELECT
    YEAR(load_date) AS load_year,
    ROUND(AVG(revenue), 2) AS avg_revenue_per_load
FROM loads
GROUP BY load_year
ORDER BY load_year ASC;

/*
Observation:

Average revenue per load remained very stable across the three years.

2022: 3,072.89
2023: 3,087.36
2024: 3,061.12

The differences between years are minimal, indicating that the company's
average revenue generated per load remained consistent over time.

This is aligned with the previous findings, where both annual load volume
and total annual revenue also remained relatively stable.
*/

-- =====================================================
-- 6. LOAD TYPE PERFORMANCE
-- =====================================================

-- Business Question:
-- How do load volume and financial performance vary by load type?

SELECT
    load_type,
    COUNT(*) AS total_loads,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(AVG(revenue), 2) AS avg_revenue_per_load
FROM loads
GROUP BY load_type
ORDER BY total_revenue DESC;

/*
Observation:

Load volume and revenue were distributed almost evenly between
Refrigerated and Dry Van loads.

Refrigerated:
42,946 loads
131.97M total revenue
3,072.86 average revenue per load

Dry Van:
42,464 loads
130.56M total revenue
3,074.58 average revenue per load

Refrigerated loads generated slightly more total revenue, mainly due to
their slightly higher load volume.

Average revenue per load was nearly identical between both load types,
indicating no meaningful revenue advantage per load based solely on load type.
*/

-- =====================================================
-- 7. LOAD WEIGHT BY TYPE
-- =====================================================

-- Business Question:
-- How does transported weight vary by load type?

SELECT
    load_type,
    COUNT(*) AS total_loads,
    ROUND(AVG(weight_lbs), 2) AS avg_weight_lbs,
    ROUND(SUM(weight_lbs), 2) AS total_weight_lbs
FROM loads
GROUP BY load_type
ORDER BY avg_weight_lbs DESC;

/*
Observation:

Average transported weight was nearly identical between both load types.

Dry Van:
42,464 loads
27,497.20 lbs average weight

Refrigerated:
42,946 loads
27,458.02 lbs average weight

The difference in average weight was minimal, indicating that load type
does not appear to have a meaningful effect on the average transported weight.

Refrigerated loads showed a slightly higher total transported weight,
mainly because they had a slightly higher number of loads.
*/

-- =====================================================
-- 8. TOP CUSTOMERS BY LOAD VOLUME
-- =====================================================

-- Business Question:
-- Which customers generated the highest number of loads?

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(l.load_id) AS total_loads
FROM customers c
JOIN loads l
    ON c.customer_id = l.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY total_loads DESC
LIMIT 10;

/*
Observation:

The customer with the highest load volume was Superior Group
with 497 loads, followed by United Supply Chain with 489 loads.

The top 10 customers accounted for 4,812 loads, approximately 5.63%
of all loads in the dataset.

This suggests that load volume is relatively diversified across the
customer base, with no single customer dominating operations.
*/

-- =====================================================
-- 9. TOP CUSTOMERS BY REVENUE
-- =====================================================

-- Business Question:
-- Which customers generate the highest revenue for the company?

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(l.load_id) AS total_loads,
    ROUND(SUM(l.revenue), 2) AS total_revenue
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

XYZ Foods generated the highest total revenue with approximately 1.54M,
followed closely by Superior Group.

The ranking by revenue does not exactly match the ranking by load volume,
showing that customers with more loads are not necessarily the customers
that generate the highest revenue.

The top 10 customers generated approximately 14.96M in revenue,
representing about 5.7% of total company revenue.

This suggests that revenue is relatively diversified across the customer base.
*/

-- =====================================================
-- 10. TOP CUSTOMERS BY AVERAGE REVENUE PER LOAD
-- =====================================================

-- Business Question:
-- Which customers generate the highest average revenue per load?

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(l.load_id) AS total_loads,
    ROUND(SUM(l.revenue), 2) AS total_revenue,
    ROUND(AVG(l.revenue), 2) AS avg_revenue_per_load
FROM customers c
JOIN loads l
    ON c.customer_id = l.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY avg_revenue_per_load DESC
LIMIT 10;

/*
Observation:

First Group (CUST00070) recorded the highest average revenue per load
at 3,294.30, despite not being one of the highest customers by total revenue.

This demonstrates that customers with the highest total revenue are not
necessarily those with the highest value per individual load.

XYZ Foods (CUST00200) stands out because it appears among both the
highest-revenue customers and the customers with the highest average
revenue per load.

The results also show that customer names are not necessarily unique,
as different customer IDs may share the same customer name.
Therefore, customer-level analysis should use customer_id as the
primary identifier.
*/

-- =====================================================
-- 11. REVENUE BY CUSTOMER TYPE
-- =====================================================

-- Business Question:
-- How does revenue vary by customer type?

SELECT
    c.customer_type,
    COUNT(l.load_id) AS total_loads,
    ROUND(SUM(l.revenue), 2) AS total_revenue,
    ROUND(AVG(l.revenue), 2) AS avg_revenue_per_load
FROM customers c
JOIN loads l
    ON l.customer_id = c.customer_id
GROUP BY c.customer_type
ORDER BY total_revenue DESC;

/*
Observation:

Contract customers generated the highest total revenue at approximately
98.80M, followed by Spot customers at 82.85M and Dedicated customers
at 80.88M.

However, average revenue per load was very similar across all customer types:

Contract:   3,067.32
Spot:       3,085.04
Dedicated:  3,069.98

This indicates that the higher revenue generated by Contract customers
is primarily explained by their higher load volume rather than by
higher revenue per individual load.
*/

-- =====================================================
-- 12. ACTUAL REVENUE VS ANNUAL REVENUE POTENTIAL
-- =====================================================

-- Business Question:
-- How does each customer's actual annual revenue compare with
-- its estimated annual revenue potential?

SELECT
    c.customer_id,
    c.customer_name,
    YEAR(l.load_date) AS load_year,
    ROUND(SUM(l.revenue), 2) AS actual_revenue,
    c.annual_revenue_potential,
    ROUND(
        SUM(l.revenue) - c.annual_revenue_potential,
        2
    ) AS revenue_gap,
    ROUND(
        (SUM(l.revenue) / NULLIF(c.annual_revenue_potential, 0)) * 100,
        2
    ) AS achievement_percentage
FROM customers c
JOIN loads l
    ON c.customer_id = l.customer_id
GROUP BY
    c.customer_id,
    c.customer_name,
    YEAR(l.load_date),
    c.annual_revenue_potential
ORDER BY achievement_percentage DESC;

/*
Observation:

Actual revenue showed substantial differences when compared with the
estimated annual revenue potential.

Only a small proportion of customer-year observations reached or exceeded
100% of their estimated potential, while most remained below it.

Achievement percentages showed a very wide range, including values well
above 100%, indicating that the annual_revenue_potential field should be
interpreted cautiously.

The estimated potential does not appear to closely follow actual annual
revenue in this dataset. Therefore, this metric will be retained for
exploratory purposes but should not be used as a primary customer
performance KPI without additional business context regarding how the
potential values were defined.
*/

-- =====================================================
-- 13. TOP ROUTES BY REVENUE
-- =====================================================

-- Business Question:
-- Which routes generate the highest revenue for the company?

SELECT
    r.route_id,
    r.origin_city,
    r.origin_state,
    r.destination_city,
    r.destination_state,
    COUNT(l.load_id) AS total_loads,
    ROUND(SUM(l.revenue), 2) AS total_revenue
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

The highest-revenue route was Philadelphia, PA to Seattle, WA,
generating approximately 10.07M in revenue.

The routes with the highest revenue were not always those with the
highest number of loads, suggesting differences in revenue generated
per individual load.

The top 10 routes generated approximately 34.4% of total company revenue,
indicating a relatively high concentration of revenue among a limited
number of routes.
*/

-- =====================================================
-- 14. TOP ROUTES BY AVERAGE REVENUE PER LOAD
-- =====================================================

-- Business Question:
-- Which routes generate the highest average revenue per load?

SELECT
    r.route_id,
    r.origin_city,
    r.origin_state,
    r.destination_city,
    r.destination_state,
    COUNT(l.load_id) AS total_loads,
    ROUND(SUM(l.revenue), 2) AS total_revenue,
    ROUND(AVG(l.revenue), 2) AS avg_revenue_per_load
FROM routes r
JOIN loads l
    ON r.route_id = l.route_id
GROUP BY
    r.route_id,
    r.origin_city,
    r.origin_state,
    r.destination_city,
    r.destination_state
ORDER BY avg_revenue_per_load DESC
LIMIT 10;

/*
Observation:

Charlotte, NC to Portland, OR had the highest average revenue per load
at 7,077.37, followed by Philadelphia, PA to Seattle, WA at 6,873.07.

Most of the highest-revenue routes also ranked highly in average revenue
per load, indicating that their strong financial performance is not
explained solely by load volume.
*/

-- =====================================================
-- 15. REVENUE PER MILE BY ROUTE
-- =====================================================

-- Business Question:
-- Which routes generate the highest average revenue per mile?

SELECT
    r.route_id,
    r.origin_city,
    r.origin_state,
    r.destination_city,
    r.destination_state,
    r.typical_distance_miles,
    COUNT(l.load_id) AS total_loads,
    ROUND(SUM(l.revenue), 2) AS total_revenue,
    ROUND(AVG(l.revenue), 2) AS avg_revenue_per_load,
    ROUND(
        AVG(l.revenue) / r.typical_distance_miles,
        2
    ) AS avg_revenue_per_mile
FROM routes r
JOIN loads l
    ON r.route_id = l.route_id
GROUP BY
    r.route_id,
    r.origin_city,
    r.origin_state,
    r.destination_city,
    r.destination_state,
    r.typical_distance_miles
ORDER BY avg_revenue_per_mile DESC;

/*
Observation:

Revenue per mile varied considerably across routes.

Philadelphia, PA to New York, NY recorded the highest average revenue
per mile at 2.78, despite having relatively low revenue per load.

This shows that routes with the highest revenue per load are not
necessarily the most efficient in revenue generated per mile.

Route distance therefore plays an important role when comparing
financial performance across lanes.
*/

-- =====================================================
-- 16. TRIP OPERATIONAL OVERVIEW
-- =====================================================

-- Exploratory Question:
-- What are the main operational characteristics of the trips?

SELECT
    COUNT(*) AS total_trips,
    ROUND(AVG(actual_distance_miles), 2) AS avg_distance_miles,
    ROUND(AVG(actual_duration_hours), 2) AS avg_duration_hours,
    ROUND(AVG(fuel_gallons_used), 2) AS avg_fuel_gallons,
    ROUND(AVG(average_mpg), 2) AS avg_mpg,
    ROUND(AVG(idle_time_hours), 2) AS avg_idle_hours
FROM trips;

/*
Observation:

The dataset contains 85,410 trips.

On average, each trip covered 1,430.27 miles, lasted 25.01 hours,
used 221.83 gallons of fuel, and achieved an average fuel efficiency
of 6.50 MPG.

Average idle time was 7.01 hours per trip, indicating that idle time
is a relevant operational variable that should be analyzed further.
*/

-- =====================================================
-- 17. TRIP STATUS DISTRIBUTION
-- =====================================================

-- Exploratory Question:
-- How are trips distributed by status?

SELECT
    trip_status,
    COUNT(*) AS total_trips
FROM trips
GROUP BY trip_status
ORDER BY total_trips DESC;

/*
Observation:

All 85,410 trips in the dataset are classified as Completed.

Since trip_status contains only one category, it does not provide
useful variation for further operational analysis.
*/

-- =====================================================
-- 18. FUEL PURCHASE OVERVIEW
-- =====================================================

-- Exploratory Question:
-- What are the main characteristics of fuel purchases and fuel costs?

SELECT
    COUNT(*) AS total_fuel_purchases,
    ROUND(SUM(gallons), 2) AS total_gallons,
    ROUND(SUM(total_cost), 2) AS total_fuel_cost,
    ROUND(AVG(gallons), 2) AS avg_gallons_per_purchase,
    ROUND(
        SUM(total_cost) / SUM(gallons),
        2
    ) AS avg_price_per_gallon
FROM fuel_purchases;

/*
Observation:

The dataset contains 196,442 fuel purchases totaling approximately
24.52 million gallons and 95.59M in fuel costs.

The average purchase was 124.82 gallons, while the weighted average
fuel price was approximately 3.90 per gallon.

Fuel represents a significant operational cost and should be analyzed
further when evaluating fleet and route efficiency.
*/

-- =====================================================
-- 19. FUEL PRICE BY YEAR
-- =====================================================

-- Exploratory Question:
-- How did the average fuel price per gallon change over time?

SELECT
    YEAR(purchase_date) AS purchase_year,
    ROUND(SUM(total_cost) / SUM(gallons), 2) AS avg_price_per_gallon,
    ROUND(SUM(total_cost), 2) AS total_fuel_cost,
    ROUND(SUM(gallons), 2) AS total_gallons
FROM fuel_purchases
GROUP BY YEAR(purchase_date)
ORDER BY purchase_year ASC;

/*
Observation:

The weighted average fuel price decreased from 4.20 per gallon in 2022
to 3.85 in 2023 and 3.65 in 2024.

Despite similar fuel consumption across these years, total fuel costs
declined as fuel prices decreased.

A small number of fuel purchases appear in 2025. Since 2025 contains
only a limited amount of data, it should not be compared directly
with the complete years.
*/

-- =====================================================
-- 20. MAINTENANCE OVERVIEW
-- =====================================================

-- Exploratory Question:
-- What are the main characteristics of maintenance activity and costs?

SELECT
    COUNT(*) AS total_maintenance_records,
    ROUND(SUM(total_cost), 2) AS total_maintenance_cost,
    ROUND(AVG(total_cost), 2) AS avg_maintenance_cost,
    ROUND(AVG(labor_hours), 2) AS avg_labor_hours,
    ROUND(AVG(downtime_hours), 2) AS avg_downtime_hours
FROM maintenance_records;

/*
Observation:

The dataset contains 2,920 maintenance records with a total cost
of approximately 5.73M.

The average maintenance event cost 1,962.53, required 4.18 labor hours,
and resulted in 24.74 hours of downtime.

Downtime appears to be an important operational factor to analyze
further when evaluating fleet performance.
*/

-- =====================================================
-- 21. MAINTENANCE TYPE DISTRIBUTION
-- =====================================================

-- Exploratory Question:
-- How are maintenance records distributed by maintenance type?

SELECT
    maintenance_type,
    COUNT(*) AS total_maintenance_events,
    ROUND(SUM(total_cost), 2) AS total_maintenance_cost,
    ROUND(AVG(total_cost), 2) AS avg_maintenance_cost,
    ROUND(AVG(downtime_hours), 2) AS avg_downtime_hours
FROM maintenance_records
GROUP BY maintenance_type
ORDER BY total_maintenance_events DESC;

/*
Observation:

Inspection was the most frequent maintenance type, but it had the
lowest average and total maintenance cost.

Preventive maintenance generated the highest total cost and the highest
average cost per event.

Average downtime was very similar across all maintenance types,
remaining around 24 to 25 hours.
*/


-- =====================================================
-- 22. DELIVERY EVENT PERFORMANCE
-- =====================================================

-- Exploratory Question:
-- How do delivery events perform in terms of on-time rate and detention?

SELECT
    event_type,
    COUNT(*) AS total_events,
    ROUND(AVG(detention_minutes), 2) AS avg_detention_minutes,
    ROUND(AVG(on_time_flag) * 100, 2) AS on_time_rate
FROM delivery_events
GROUP BY event_type
ORDER BY total_events DESC;

/*
Observation:

Pickup events achieved a 66.73% on-time rate with an average
detention time of 76.47 minutes.

Delivery events showed weaker performance, with an on-time rate
of only 44.61% and an average detention time of 106.60 minutes.

This suggests that delivery operations experience greater delays
than pickup operations.
*/

-- =====================================================
-- 23. SAFETY INCIDENT OVERVIEW
-- =====================================================

-- Exploratory Question:
-- What are the main characteristics of safety incidents?

SELECT
    COUNT(*) AS total_incidents,
    ROUND(AVG(at_fault_flag) * 100, 2) AS at_fault_rate,
    ROUND(AVG(injury_flag) * 100, 2) AS injury_rate,
    ROUND(AVG(preventable_flag) * 100, 2) AS preventable_rate,
    ROUND(SUM(vehicle_damage_cost), 2) AS total_vehicle_damage_cost,
    ROUND(SUM(cargo_damage_cost), 2) AS total_cargo_damage_cost,
    ROUND(SUM(claim_amount), 2) AS total_claim_amount
FROM safety_incidents;

/*
Observation:

The dataset contains 168 safety incidents.

31.55% were classified as at-fault incidents,
19.64% involved injuries, and 37.50% were preventable.

Total claim amount was approximately 2.64M.

The total claim amount matches the combined vehicle and cargo damage costs,
so these values should not be added together when calculating total incident cost.
*/

-- =====================================================
-- 24. DRIVER PROFILE OVERVIEW
-- =====================================================

-- Exploratory Question:
-- What are the main characteristics of the driver workforce?

SELECT
    employment_status,
    COUNT(*) AS total_drivers,
    ROUND(AVG(years_experience), 2) AS avg_years_experience
FROM drivers
GROUP BY employment_status
ORDER BY total_drivers DESC;

/*
Observation:

The driver workforce is predominantly active, with 124 active drivers
and 26 terminated drivers.

Average driving experience is relatively high in both groups:
13.71 years for active drivers and 12.46 years for terminated drivers.

Overall, the workforce appears to have substantial driving experience.
*/

-- =====================================================
-- 25. TRUCK FLEET OVERVIEW
-- =====================================================

-- Exploratory Question:
-- What are the main characteristics of the truck fleet?

SELECT
    status,
    fuel_type,
    COUNT(*) AS total_trucks,
    ROUND(AVG(model_year), 0) AS avg_model_year,
    MIN(model_year) AS oldest_model_year,
    MAX(model_year) AS newest_model_year
FROM trucks
GROUP BY
    status,
    fuel_type
ORDER BY total_trucks DESC;

/*
Observation:

The fleet contains 120 trucks, all powered by diesel.

Most trucks are active, with 92 active units, while 15 are currently
in maintenance and 13 are inactive.

Truck model years range from 2015 to 2021, with an average model year
of approximately 2016.
*/