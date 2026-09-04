USE logistics_operations;

-- ============================================
-- MASTER TABLES
-- ============================================

CREATE TABLE customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    customer_name VARCHAR(100),
    customer_type VARCHAR(30),
    credit_terms_days INT,
    primary_freight_type VARCHAR(50),
    account_status VARCHAR(20),
    contract_start_date DATE,
    annual_revenue_potential DECIMAL(15,2)
);

CREATE TABLE routes (
    route_id VARCHAR(20) PRIMARY KEY,
    origin_city VARCHAR(50),
    origin_state VARCHAR(10),
    destination_city VARCHAR(50),
    destination_state VARCHAR(10),
    typical_distance_miles DECIMAL(10,2),
    base_rate_per_mile DECIMAL(10,2),
    fuel_surcharge_rate DECIMAL(10,4),
    typical_transit_days INT
);

CREATE TABLE drivers (
    driver_id VARCHAR(20) PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    hire_date DATE,
    termination_date DATE,
    license_number VARCHAR(50),
    license_state VARCHAR(10),
    date_of_birth DATE,
    home_terminal VARCHAR(50),
    employment_status VARCHAR(20),
    cdl_class VARCHAR(10),
    years_experience INT
);

CREATE TABLE trucks (
    truck_id VARCHAR(20) PRIMARY KEY,
    unit_number VARCHAR(20),
    make VARCHAR(50),
    model_year INT,
    vin VARCHAR(50),
    acquisition_date DATE,
    acquisition_mileage DECIMAL(12,2),
    fuel_type VARCHAR(20),
    tank_capacity_gallons DECIMAL(10,2),
    status VARCHAR(20),
    home_terminal VARCHAR(50)
);

-- ============================================
-- LOADS
-- ============================================

CREATE TABLE loads (
    load_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20),
    route_id VARCHAR(20),
    load_date DATE,
    load_type VARCHAR(30),
    weight_lbs DECIMAL(12,2),
    pieces INT,
    revenue DECIMAL(15,2),
    fuel_surcharge DECIMAL(15,2),
    accessorial_charges DECIMAL(15,2),
    load_status VARCHAR(20),
    booking_type VARCHAR(30),

    CONSTRAINT fk_loads_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id),

    CONSTRAINT fk_loads_route
        FOREIGN KEY (route_id)
        REFERENCES routes(route_id)
);

-- ============================================
-- TRAILERS
-- ============================================

CREATE TABLE trailers (
    trailer_id VARCHAR(20) PRIMARY KEY,
    trailer_number VARCHAR(20),
    trailer_type VARCHAR(30),
    length_feet INT,
    model_year INT,
    vin VARCHAR(50),
    acquisition_date DATE,
    status VARCHAR(20),
    current_location VARCHAR(50)
);

-- ============================================
-- TRIPS
-- ============================================

CREATE TABLE trips (
    trip_id VARCHAR(20) PRIMARY KEY,
    load_id VARCHAR(20) NOT NULL UNIQUE,
    driver_id VARCHAR(20),
    truck_id VARCHAR(20),
    trailer_id VARCHAR(20),
    dispatch_date DATE,
    actual_distance_miles DECIMAL(10,2),
    actual_duration_hours DECIMAL(10,2),
    fuel_gallons_used DECIMAL(10,2),
    average_mpg DECIMAL(10,2),
    idle_time_hours DECIMAL(10,2),
    trip_status VARCHAR(20),

    CONSTRAINT fk_trips_load
        FOREIGN KEY (load_id)
        REFERENCES loads(load_id),

    CONSTRAINT fk_trips_driver
        FOREIGN KEY (driver_id)
        REFERENCES drivers(driver_id),

    CONSTRAINT fk_trips_truck
        FOREIGN KEY (truck_id)
        REFERENCES trucks(truck_id),

    CONSTRAINT fk_trips_trailer
        FOREIGN KEY (trailer_id)
        REFERENCES trailers(trailer_id)
);

-- ============================================
-- FUEL PURCHASES
-- ============================================

CREATE TABLE fuel_purchases (
    fuel_purchase_id VARCHAR(20) PRIMARY KEY,
    trip_id VARCHAR(20),
    truck_id VARCHAR(20),
    driver_id VARCHAR(20),
    purchase_date DATETIME,
    location_city VARCHAR(50),
    location_state VARCHAR(10),
    gallons DECIMAL(10,2),
    price_per_gallon DECIMAL(10,3),
    total_cost DECIMAL(12,2),
    fuel_card_number VARCHAR(30),

    CONSTRAINT fk_fuel_trip
        FOREIGN KEY (trip_id)
        REFERENCES trips(trip_id),

    CONSTRAINT fk_fuel_truck
        FOREIGN KEY (truck_id)
        REFERENCES trucks(truck_id),

    CONSTRAINT fk_fuel_driver
        FOREIGN KEY (driver_id)
        REFERENCES drivers(driver_id)
);

-- ============================================
-- MAINTENANCE RECORDS
-- ============================================

CREATE TABLE maintenance_records (
    maintenance_id VARCHAR(20) PRIMARY KEY,
    truck_id VARCHAR(20),
    maintenance_date DATE,
    maintenance_type VARCHAR(30),
    odometer_reading DECIMAL(12,2),
    labor_hours DECIMAL(10,2),
    labor_cost DECIMAL(12,2),
    parts_cost DECIMAL(12,2),
    total_cost DECIMAL(12,2),
    facility_location VARCHAR(50),
    downtime_hours DECIMAL(10,2),
    service_description VARCHAR(100),

    CONSTRAINT fk_maintenance_truck
        FOREIGN KEY (truck_id)
        REFERENCES trucks(truck_id)
);

-- ============================================
-- SAFETY INCIDENTS
-- ============================================

CREATE TABLE safety_incidents (
    incident_id VARCHAR(20) PRIMARY KEY,
    trip_id VARCHAR(20),
    truck_id VARCHAR(20),
    driver_id VARCHAR(20),
    incident_date DATETIME,
    incident_type VARCHAR(50),
    location_city VARCHAR(50),
    location_state VARCHAR(10),
    at_fault_flag BOOLEAN,
    injury_flag BOOLEAN,
    vehicle_damage_cost DECIMAL(12,2),
    cargo_damage_cost DECIMAL(12,2),
    claim_amount DECIMAL(12,2),
    preventable_flag BOOLEAN,
    description VARCHAR(255),

    CONSTRAINT fk_incident_trip
        FOREIGN KEY (trip_id)
        REFERENCES trips(trip_id),

    CONSTRAINT fk_incident_truck
        FOREIGN KEY (truck_id)
        REFERENCES trucks(truck_id),

    CONSTRAINT fk_incident_driver
        FOREIGN KEY (driver_id)
        REFERENCES drivers(driver_id)
);

-- ============================================
-- FACILITIES
-- ============================================

CREATE TABLE facilities (
    facility_id VARCHAR(20) PRIMARY KEY,
    facility_name VARCHAR(100),
    facility_type VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(10),
    latitude DECIMAL(10,6),
    longitude DECIMAL(10,6),
    dock_doors INT,
    operating_hours VARCHAR(30)
);

-- ============================================
-- DELIVERY EVENTS
-- ============================================

CREATE TABLE delivery_events (
    event_id VARCHAR(20) PRIMARY KEY,
    load_id VARCHAR(20),
    trip_id VARCHAR(20),
    event_type VARCHAR(20),
    facility_id VARCHAR(20),
    scheduled_datetime DATETIME,
    actual_datetime DATETIME,
    detention_minutes INT,
    on_time_flag BOOLEAN,
    location_city VARCHAR(50),
    location_state VARCHAR(10),

    CONSTRAINT fk_delivery_load
        FOREIGN KEY (load_id)
        REFERENCES loads(load_id),

    CONSTRAINT fk_delivery_trip
        FOREIGN KEY (trip_id)
        REFERENCES trips(trip_id),

    CONSTRAINT fk_delivery_facility
        FOREIGN KEY (facility_id)
        REFERENCES facilities(facility_id)
);

-- ============================================
-- DRIVER MONTHLY METRICS
-- ============================================

CREATE TABLE driver_monthly_metrics (
    driver_id VARCHAR(20),
    month DATE,
    trips_completed INT,
    total_miles DECIMAL(12,2),
    total_revenue DECIMAL(15,2),
    average_mpg DECIMAL(10,2),
    total_fuel_gallons DECIMAL(12,2),
    on_time_delivery_rate DECIMAL(6,4),
    average_idle_hours DECIMAL(10,2),

    PRIMARY KEY (driver_id, month),

    CONSTRAINT fk_driver_metrics_driver
        FOREIGN KEY (driver_id)
        REFERENCES drivers(driver_id)
);

-- ============================================
-- TRUCK UTILIZATION METRICS
-- ============================================

CREATE TABLE truck_utilization_metrics (
    truck_id VARCHAR(20),
    month DATE,
    trips_completed INT,
    total_miles DECIMAL(12,2),
    total_revenue DECIMAL(15,2),
    average_mpg DECIMAL(10,2),
    maintenance_events INT,
    maintenance_cost DECIMAL(15,2),
    downtime_hours DECIMAL(10,2),
    utilization_rate DECIMAL(8,4),

    PRIMARY KEY (truck_id, month),

    CONSTRAINT fk_truck_metrics_truck
        FOREIGN KEY (truck_id)
        REFERENCES trucks(truck_id)
);