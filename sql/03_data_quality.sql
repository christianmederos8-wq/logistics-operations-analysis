USE logistics_operations;

-- ============================================
-- 1. ROW COUNTS
-- ============================================

SELECT 'customers' AS table_name, COUNT(*) AS rows_count FROM customers
UNION ALL
SELECT 'routes', COUNT(*) FROM routes
UNION ALL
SELECT 'drivers', COUNT(*) FROM drivers
UNION ALL
SELECT 'trucks', COUNT(*) FROM trucks
UNION ALL
SELECT 'trailers', COUNT(*) FROM trailers
UNION ALL
SELECT 'facilities', COUNT(*) FROM facilities
UNION ALL
SELECT 'loads', COUNT(*) FROM loads
UNION ALL
SELECT 'trips', COUNT(*) FROM trips
UNION ALL
SELECT 'fuel_purchases', COUNT(*) FROM fuel_purchases
UNION ALL
SELECT 'maintenance_records', COUNT(*) FROM maintenance_records
UNION ALL
SELECT 'delivery_events', COUNT(*) FROM delivery_events
UNION ALL
SELECT 'safety_incidents', COUNT(*) FROM safety_incidents
UNION ALL
SELECT 'driver_monthly_metrics', COUNT(*) FROM driver_monthly_metrics
UNION ALL
SELECT 'truck_utilization_metrics', COUNT(*) FROM truck_utilization_metrics;

-- ============================================
-- 2. DUPLICATE / KEY CHECKS
-- ============================================

SELECT
    'customers' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT customer_id) AS unique_keys
FROM customers

UNION ALL

SELECT
    'routes',
    COUNT(*),
    COUNT(DISTINCT route_id)
FROM routes

UNION ALL

SELECT
    'drivers',
    COUNT(*),
    COUNT(DISTINCT driver_id)
FROM drivers

UNION ALL

SELECT
    'trucks',
    COUNT(*),
    COUNT(DISTINCT truck_id)
FROM trucks

UNION ALL

SELECT
    'trailers',
    COUNT(*),
    COUNT(DISTINCT trailer_id)
FROM trailers

UNION ALL

SELECT
    'facilities',
    COUNT(*),
    COUNT(DISTINCT facility_id)
FROM facilities

UNION ALL

SELECT
    'loads',
    COUNT(*),
    COUNT(DISTINCT load_id)
FROM loads

UNION ALL

SELECT
    'trips',
    COUNT(*),
    COUNT(DISTINCT trip_id)
FROM trips

UNION ALL

SELECT
    'fuel_purchases',
    COUNT(*),
    COUNT(DISTINCT fuel_purchase_id)
FROM fuel_purchases

UNION ALL

SELECT
    'maintenance_records',
    COUNT(*),
    COUNT(DISTINCT maintenance_id)
FROM maintenance_records

UNION ALL

SELECT
    'delivery_events',
    COUNT(*),
    COUNT(DISTINCT event_id)
FROM delivery_events

UNION ALL

SELECT
    'safety_incidents',
    COUNT(*),
    COUNT(DISTINCT incident_id)
FROM safety_incidents;

-- ============================================
-- 3. NULL / MISSING VALUE CHECKS
-- ============================================

-- Trips
SELECT
    COUNT(*) AS total_trips,
    SUM(driver_id IS NULL) AS missing_driver_id,
    SUM(truck_id IS NULL) AS missing_truck_id,
    SUM(trailer_id IS NULL) AS missing_trailer_id
FROM trips;

-- Fuel purchases
SELECT
    COUNT(*) AS total_fuel_purchases,
    SUM(trip_id IS NULL) AS missing_trip_id,
    SUM(truck_id IS NULL) AS missing_truck_id,
    SUM(driver_id IS NULL) AS missing_driver_id
FROM fuel_purchases;

-- Loads
SELECT
    SUM(customer_id IS NULL) AS missing_customer,
    SUM(route_id IS NULL) AS missing_route,
    SUM(load_date IS NULL) AS missing_load_date,
    SUM(weight_lbs IS NULL) AS missing_weight,
    SUM(revenue IS NULL) AS missing_revenue,
    SUM(load_status IS NULL) AS missing_status
FROM loads;

-- Delivery events
SELECT
    SUM(load_id IS NULL) AS missing_load,
    SUM(trip_id IS NULL) AS missing_trip,
    SUM(facility_id IS NULL) AS missing_facility,
    SUM(scheduled_datetime IS NULL) AS missing_scheduled_datetime,
    SUM(actual_datetime IS NULL) AS missing_actual_datetime
FROM delivery_events;

-- ============================================
-- 4. REFERENTIAL INTEGRITY CHECKS
-- ============================================

SELECT
    'loads -> customers' AS relationship,
    COUNT(*) AS invalid_references
FROM loads l
LEFT JOIN customers c
    ON l.customer_id = c.customer_id
WHERE l.customer_id IS NOT NULL
  AND c.customer_id IS NULL

UNION ALL

SELECT
    'loads -> routes',
    COUNT(*)
FROM loads l
LEFT JOIN routes r
    ON l.route_id = r.route_id
WHERE l.route_id IS NOT NULL
  AND r.route_id IS NULL

UNION ALL

SELECT
    'trips -> loads',
    COUNT(*)
FROM trips t
LEFT JOIN loads l
    ON t.load_id = l.load_id
WHERE t.load_id IS NOT NULL
  AND l.load_id IS NULL

UNION ALL

SELECT
    'trips -> drivers',
    COUNT(*)
FROM trips t
LEFT JOIN drivers d
    ON t.driver_id = d.driver_id
WHERE t.driver_id IS NOT NULL
  AND d.driver_id IS NULL

UNION ALL

SELECT
    'trips -> trucks',
    COUNT(*)
FROM trips t
LEFT JOIN trucks tr
    ON t.truck_id = tr.truck_id
WHERE t.truck_id IS NOT NULL
  AND tr.truck_id IS NULL

UNION ALL

SELECT
    'trips -> trailers',
    COUNT(*)
FROM trips t
LEFT JOIN trailers tl
    ON t.trailer_id = tl.trailer_id
WHERE t.trailer_id IS NOT NULL
  AND tl.trailer_id IS NULL

UNION ALL

SELECT
    'fuel_purchases -> trips',
    COUNT(*)
FROM fuel_purchases fp
LEFT JOIN trips t
    ON fp.trip_id = t.trip_id
WHERE fp.trip_id IS NOT NULL
  AND t.trip_id IS NULL

UNION ALL

SELECT
    'fuel_purchases -> trucks',
    COUNT(*)
FROM fuel_purchases fp
LEFT JOIN trucks tr
    ON fp.truck_id = tr.truck_id
WHERE fp.truck_id IS NOT NULL
  AND tr.truck_id IS NULL

UNION ALL

SELECT
    'fuel_purchases -> drivers',
    COUNT(*)
FROM fuel_purchases fp
LEFT JOIN drivers d
    ON fp.driver_id = d.driver_id
WHERE fp.driver_id IS NOT NULL
  AND d.driver_id IS NULL

UNION ALL

SELECT
    'maintenance_records -> trucks',
    COUNT(*)
FROM maintenance_records m
LEFT JOIN trucks tr
    ON m.truck_id = tr.truck_id
WHERE m.truck_id IS NOT NULL
  AND tr.truck_id IS NULL

UNION ALL

SELECT
    'delivery_events -> loads',
    COUNT(*)
FROM delivery_events de
LEFT JOIN loads l
    ON de.load_id = l.load_id
WHERE de.load_id IS NOT NULL
  AND l.load_id IS NULL

UNION ALL

SELECT
    'delivery_events -> trips',
    COUNT(*)
FROM delivery_events de
LEFT JOIN trips t
    ON de.trip_id = t.trip_id
WHERE de.trip_id IS NOT NULL
  AND t.trip_id IS NULL

UNION ALL

SELECT
    'delivery_events -> facilities',
    COUNT(*)
FROM delivery_events de
LEFT JOIN facilities f
    ON de.facility_id = f.facility_id
WHERE de.facility_id IS NOT NULL
  AND f.facility_id IS NULL

UNION ALL

SELECT
    'safety_incidents -> trips',
    COUNT(*)
FROM safety_incidents si
LEFT JOIN trips t
    ON si.trip_id = t.trip_id
WHERE si.trip_id IS NOT NULL
  AND t.trip_id IS NULL

UNION ALL

SELECT
    'safety_incidents -> trucks',
    COUNT(*)
FROM safety_incidents si
LEFT JOIN trucks tr
    ON si.truck_id = tr.truck_id
WHERE si.truck_id IS NOT NULL
  AND tr.truck_id IS NULL

UNION ALL

SELECT
    'safety_incidents -> drivers',
    COUNT(*)
FROM safety_incidents si
LEFT JOIN drivers d
    ON si.driver_id = d.driver_id
WHERE si.driver_id IS NOT NULL
  AND d.driver_id IS NULL;
  
-- ============================================
-- 5. RANGE AND LOGICAL VALUE CHECKS
-- ============================================

-- Loads
SELECT
    SUM(weight_lbs <= 0) AS invalid_weight,
    SUM(pieces <= 0) AS invalid_pieces,
    SUM(revenue < 0) AS negative_revenue,
    SUM(fuel_surcharge < 0) AS negative_fuel_surcharge,
    SUM(accessorial_charges < 0) AS negative_accessorial_charges
FROM loads;

-- Trips
SELECT
    SUM(actual_distance_miles <= 0) AS invalid_distance,
    SUM(actual_duration_hours <= 0) AS invalid_duration,
    SUM(fuel_gallons_used <= 0) AS invalid_fuel_usage,
    SUM(average_mpg <= 0) AS invalid_mpg,
    SUM(idle_time_hours < 0) AS negative_idle_time,
    SUM(idle_time_hours > actual_duration_hours) AS idle_greater_than_duration
FROM trips;

-- Investigate trips where idle time exceeds trip duration

SELECT
    trip_id,
    actual_distance_miles,
    actual_duration_hours,
    idle_time_hours,
    average_mpg,
    trip_status
FROM trips
WHERE idle_time_hours > actual_duration_hours
LIMIT 20;

-- Trips
SELECT
    SUM(actual_distance_miles <= 0) AS invalid_distance,
    SUM(actual_duration_hours <= 0) AS invalid_duration,
    SUM(fuel_gallons_used <= 0) AS invalid_fuel_usage,
    SUM(average_mpg <= 0) AS invalid_mpg,
    SUM(idle_time_hours < 0) AS negative_idle_time
FROM trips;

-- Observation:
-- In some trips, idle_time_hours is greater than actual_duration_hours.
-- Based on the data, actual_duration_hours appears to represent active driving time,
-- while idle_time_hours may capture separate waiting/idling periods.

SELECT
    COUNT(*) AS trips_idle_greater_than_duration
FROM trips
WHERE idle_time_hours > actual_duration_hours;

-- ============================================
-- 6. MAINTENANCE VALUE CHECKS
-- ============================================

SELECT
    SUM(odometer_reading < 0) AS negative_odometer,
    SUM(labor_hours < 0) AS negative_labor_hours,
    SUM(labor_cost < 0) AS negative_labor_cost,
    SUM(parts_cost < 0) AS negative_parts_cost,
    SUM(total_cost < 0) AS negative_total_cost,
    SUM(downtime_hours < 0) AS negative_downtime
FROM maintenance_records;

-- ============================================
-- 7. DELIVERY EVENT CHECKS
-- ============================================

SELECT
    SUM(detention_minutes < 0) AS negative_detention,
    SUM(actual_datetime IS NULL) AS missing_actual_datetime,
    SUM(scheduled_datetime IS NULL) AS missing_scheduled_datetime
FROM delivery_events;

-- ============================================
-- 8. DATE CONSISTENCY CHECKS
-- ============================================

SELECT COUNT(*) AS invalid_driver_dates
FROM drivers
WHERE termination_date IS NOT NULL
  AND termination_date < hire_date;
  
-- ============================================
-- 9. CATEGORICAL VALUE CHECKS
-- ============================================

-- Load status
SELECT load_status, COUNT(*) AS total
FROM loads
GROUP BY load_status
ORDER BY total DESC;

-- Booking type
SELECT booking_type, COUNT(*) AS total
FROM loads
GROUP BY booking_type
ORDER BY total DESC;

-- Load type
SELECT load_type, COUNT(*) AS total
FROM loads
GROUP BY load_type
ORDER BY total DESC;

-- Trip status
SELECT trip_status, COUNT(*) AS total
FROM trips
GROUP BY trip_status
ORDER BY total DESC;

-- Delivery event type
SELECT event_type, COUNT(*) AS total
FROM delivery_events
GROUP BY event_type
ORDER BY total DESC;

-- Truck status
SELECT status, COUNT(*) AS total
FROM trucks
GROUP BY status
ORDER BY total DESC;

-- Maintenance type
SELECT maintenance_type, COUNT(*) AS total
FROM maintenance_records
GROUP BY maintenance_type
ORDER BY total DESC;

-- Safety incident type
SELECT incident_type, COUNT(*) AS total
FROM safety_incidents
GROUP BY incident_type
ORDER BY total;