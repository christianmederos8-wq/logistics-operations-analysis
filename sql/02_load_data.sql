USE logistics_operations;

-- ============================================
-- LOAD CUSTOMERS
-- ============================================

LOAD DATA LOCAL INFILE
'C:/Users/Anthony/Desktop/SQL/Portafolio/logistics-operations-analysis/data/raw/customers.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    customer_id,
    customer_name,
    customer_type,
    credit_terms_days,
    primary_freight_type,
    account_status,
    contract_start_date,
    annual_revenue_potential
);

-- ============================================
-- LOAD ROUTES
-- ============================================

LOAD DATA LOCAL INFILE
'C:/Users/Anthony/Desktop/SQL/Portafolio/logistics-operations-analysis/data/raw/routes.csv'
INTO TABLE routes
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    route_id,
    origin_city,
    origin_state,
    destination_city,
    destination_state,
    typical_distance_miles,
    base_rate_per_mile,
    fuel_surcharge_rate,
    typical_transit_days
);

-- ============================================
-- LOAD DRIVERS
-- ============================================

LOAD DATA LOCAL INFILE
'C:/Users/Anthony/Desktop/SQL/Portafolio/logistics-operations-analysis/data/raw/drivers.csv'
INTO TABLE drivers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    driver_id,
    first_name,
    last_name,
    hire_date,
    @termination_date,
    license_number,
    license_state,
    date_of_birth,
    home_terminal,
    employment_status,
    cdl_class,
    years_experience
)
SET termination_date = NULLIF(@termination_date, '');

-- ============================================
-- LOAD TRUCKS
-- ============================================

LOAD DATA LOCAL INFILE
'C:/Users/Anthony/Desktop/SQL/Portafolio/logistics-operations-analysis/data/raw/trucks.csv'
INTO TABLE trucks
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    truck_id,
    unit_number,
    make,
    model_year,
    vin,
    acquisition_date,
    acquisition_mileage,
    fuel_type,
    tank_capacity_gallons,
    status,
    home_terminal
);

-- ============================================
-- LOAD TRAILERS
-- ============================================

LOAD DATA LOCAL INFILE
'C:/Users/Anthony/Desktop/SQL/Portafolio/logistics-operations-analysis/data/raw/trailers.csv'
INTO TABLE trailers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    trailer_id,
    trailer_number,
    trailer_type,
    length_feet,
    model_year,
    vin,
    acquisition_date,
    status,
    current_location
);

-- ============================================
-- LOAD FACILITIES
-- ============================================

LOAD DATA LOCAL INFILE
'C:/Users/Anthony/Desktop/SQL/Portafolio/logistics-operations-analysis/data/raw/facilities.csv'
INTO TABLE facilities
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    facility_id,
    facility_name,
    facility_type,
    city,
    state,
    latitude,
    longitude,
    dock_doors,
    operating_hours
);

-- ============================================
-- LOAD LOADS
-- ============================================

LOAD DATA LOCAL INFILE
'C:/Users/Anthony/Desktop/SQL/Portafolio/logistics-operations-analysis/data/raw/loads.csv'
INTO TABLE loads
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    load_id,
    customer_id,
    route_id,
    load_date,
    load_type,
    weight_lbs,
    pieces,
    revenue,
    fuel_surcharge,
    accessorial_charges,
    load_status,
    booking_type
);

CREATE TABLE trips_staging (
    trip_id VARCHAR(20),
    load_id VARCHAR(20),
    driver_id VARCHAR(20),
    truck_id VARCHAR(20),
    trailer_id VARCHAR(20),
    dispatch_date DATE,
    actual_distance_miles DECIMAL(10,2),
    actual_duration_hours DECIMAL(10,2),
    fuel_gallons_used DECIMAL(10,2),
    average_mpg DECIMAL(10,2),
    idle_time_hours DECIMAL(10,2),
    trip_status VARCHAR(20)
);

LOAD DATA LOCAL INFILE
'C:/Users/Anthony/Desktop/SQL/Portafolio/logistics-operations-analysis/data/raw/trips.csv'
INTO TABLE trips_staging
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    trip_id,
    load_id,
    driver_id,
    truck_id,
    trailer_id,
    dispatch_date,
    actual_distance_miles,
    actual_duration_hours,
    fuel_gallons_used,
    average_mpg,
    idle_time_hours,
    trip_status
);

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT trip_id) AS unique_trip_ids,
    COUNT(DISTINCT load_id) AS unique_load_ids
FROM trips_staging;

-- ============================================
-- LOAD CLEANED TRIPS INTO FINAL TABLE
-- ============================================

INSERT INTO trips (
    trip_id,
    load_id,
    driver_id,
    truck_id,
    trailer_id,
    dispatch_date,
    actual_distance_miles,
    actual_duration_hours,
    fuel_gallons_used,
    average_mpg,
    idle_time_hours,
    trip_status
)
SELECT
    ts.trip_id,
    ts.load_id,

    CASE
        WHEN d.driver_id IS NOT NULL THEN ts.driver_id
        ELSE NULL
    END AS driver_id,

    CASE
        WHEN tr.truck_id IS NOT NULL THEN ts.truck_id
        ELSE NULL
    END AS truck_id,

    CASE
        WHEN tl.trailer_id IS NOT NULL THEN ts.trailer_id
        ELSE NULL
    END AS trailer_id,

    ts.dispatch_date,
    ts.actual_distance_miles,
    ts.actual_duration_hours,
    ts.fuel_gallons_used,
    ts.average_mpg,
    ts.idle_time_hours,
    ts.trip_status

FROM trips_staging ts
LEFT JOIN drivers d
    ON ts.driver_id = d.driver_id
LEFT JOIN trucks tr
    ON ts.truck_id = tr.truck_id
LEFT JOIN trailers tl
    ON ts.trailer_id = tl.trailer_id;
    
    DROP TABLE trips_staging;

-- ============================================
-- LOAD FUEL PURCHASES
-- ============================================

LOAD DATA LOCAL INFILE
'C:/Users/Anthony/Desktop/SQL/Portafolio/logistics-operations-analysis/data/raw/fuel_purchases.csv'
INTO TABLE fuel_purchases
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    fuel_purchase_id,
    trip_id,
    truck_id,
    driver_id,
    purchase_date,
    location_city,
    location_state,
    gallons,
    price_per_gallon,
    total_cost,
    fuel_card_number
);

SET SESSION net_read_timeout = 600;
SET SESSION net_write_timeout = 600;

CREATE TABLE fuel_purchases_staging (
    fuel_purchase_id VARCHAR(20),
    trip_id VARCHAR(20),
    truck_id VARCHAR(20),
    driver_id VARCHAR(20),
    purchase_date DATETIME,
    location_city VARCHAR(50),
    location_state VARCHAR(10),
    gallons DECIMAL(10,2),
    price_per_gallon DECIMAL(10,3),
    total_cost DECIMAL(12,2),
    fuel_card_number VARCHAR(30)
);

LOAD DATA LOCAL INFILE
'C:/Users/Anthony/Desktop/SQL/Portafolio/logistics-operations-analysis/data/raw/fuel_purchases.csv'
INTO TABLE fuel_purchases_staging
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    fuel_purchase_id,
    trip_id,
    truck_id,
    driver_id,
    purchase_date,
    location_city,
    location_state,
    gallons,
    price_per_gallon,
    total_cost,
    fuel_card_number
);

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT fuel_purchase_id) AS unique_ids
FROM fuel_purchases_staging;

-- ============================================
-- LOAD CLEANED FUEL PURCHASES
-- ============================================

START TRANSACTION;

DELETE FROM fuel_purchases;

INSERT INTO fuel_purchases (
    fuel_purchase_id,
    trip_id,
    truck_id,
    driver_id,
    purchase_date,
    location_city,
    location_state,
    gallons,
    price_per_gallon,
    total_cost,
    fuel_card_number
)
SELECT
    fp.fuel_purchase_id,
    fp.trip_id,

    CASE
        WHEN tr.truck_id IS NOT NULL THEN fp.truck_id
        ELSE NULL
    END AS truck_id,

    CASE
        WHEN d.driver_id IS NOT NULL THEN fp.driver_id
        ELSE NULL
    END AS driver_id,

    fp.purchase_date,
    fp.location_city,
    fp.location_state,
    fp.gallons,
    fp.price_per_gallon,
    fp.total_cost,
    fp.fuel_card_number

FROM fuel_purchases_staging fp

LEFT JOIN trucks tr
    ON fp.truck_id = tr.truck_id

LEFT JOIN drivers d
    ON fp.driver_id = d.driver_id;

COMMIT;

DROP TABLE fuel_purchases_staging;

-- ============================================
-- LOAD MAINTENANCE RECORDS
-- ============================================

LOAD DATA LOCAL INFILE
'C:/Users/Anthony/Desktop/SQL/Portafolio/logistics-operations-analysis/data/raw/maintenance_records.csv'
INTO TABLE maintenance_records
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    maintenance_id,
    truck_id,
    maintenance_date,
    maintenance_type,
    odometer_reading,
    labor_hours,
    labor_cost,
    parts_cost,
    total_cost,
    facility_location,
    downtime_hours,
    service_description
);

-- ============================================
-- LOAD DELIVERY EVENTS
-- ============================================

LOAD DATA LOCAL INFILE
'C:/Users/Anthony/Desktop/SQL/Portafolio/logistics-operations-analysis/data/raw/delivery_events.csv'
INTO TABLE delivery_events
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    event_id,
    load_id,
    trip_id,
    event_type,
    facility_id,
    scheduled_datetime,
    actual_datetime,
    detention_minutes,
    @on_time_flag,
    location_city,
    location_state
)
SET on_time_flag =
    CASE
        WHEN LOWER(TRIM(@on_time_flag)) = 'true' THEN 1
        ELSE 0
    END;
    
-- ============================================
-- LOAD SAFETY INCIDENTS
-- ============================================

LOAD DATA LOCAL INFILE
'C:/Users/Anthony/Desktop/SQL/Portafolio/logistics-operations-analysis/data/raw/safety_incidents.csv'
INTO TABLE safety_incidents
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    incident_id,
    trip_id,
    truck_id,
    driver_id,
    incident_date,
    incident_type,
    location_city,
    location_state,
    @at_fault_flag,
    @injury_flag,
    vehicle_damage_cost,
    cargo_damage_cost,
    claim_amount,
    @preventable_flag,
    description
)
SET
    at_fault_flag =
        CASE WHEN LOWER(TRIM(@at_fault_flag)) = 'true' THEN 1 ELSE 0 END,
    injury_flag =
        CASE WHEN LOWER(TRIM(@injury_flag)) = 'true' THEN 1 ELSE 0 END,
    preventable_flag =
        CASE WHEN LOWER(TRIM(@preventable_flag)) = 'true' THEN 1 ELSE 0 END;
-- ============================================
-- LOAD DRIVER MONTHLY METRICS
-- ============================================

LOAD DATA LOCAL INFILE
'C:/Users/Anthony/Desktop/SQL/Portafolio/logistics-operations-analysis/data/raw/driver_monthly_metrics.csv'
INTO TABLE driver_monthly_metrics
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    driver_id,
    month,
    trips_completed,
    total_miles,
    total_revenue,
    average_mpg,
    total_fuel_gallons,
    on_time_delivery_rate,
    average_idle_hours
);

-- ============================================
-- LOAD TRUCK UTILIZATION METRICS
-- ============================================

LOAD DATA LOCAL INFILE
'C:/Users/Anthony/Desktop/SQL/Portafolio/logistics-operations-analysis/data/raw/truck_utilization_metrics.csv'
INTO TABLE truck_utilization_metrics
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    truck_id,
    month,
    trips_completed,
    total_miles,
    total_revenue,
    average_mpg,
    maintenance_events,
    maintenance_cost,
    downtime_hours,
    utilization_rate
);

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