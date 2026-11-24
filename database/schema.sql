-- Run once in an empty TicketHelper schema on Oracle Database XE 11.2 or later.
WHENEVER SQLERROR EXIT SQL.SQLCODE

CREATE SEQUENCE tickethelper_seq MAXVALUE 999999999999999999 NOCYCLE;

CREATE TABLE users (
    user_id NUMBER(18) NOT NULL,
    email VARCHAR2(254 CHAR) NOT NULL,
    password_hash VARCHAR2(255 CHAR) NOT NULL,
    display_name VARCHAR2(80 CHAR) NOT NULL,
    created_at TIMESTAMP(6) DEFAULT SYS_EXTRACT_UTC(SYSTIMESTAMP) NOT NULL,
    CONSTRAINT pk_users PRIMARY KEY (user_id),
    CONSTRAINT ck_users_email CHECK (TRIM(email) IS NOT NULL)
);

CREATE UNIQUE INDEX uq_users_email_ci ON users (LOWER(TRIM(email)));

CREATE TABLE venues (
    venue_id NUMBER(18) NOT NULL,
    name VARCHAR2(200 CHAR) NOT NULL,
    region VARCHAR2(80 CHAR) NOT NULL,
    address VARCHAR2(300 CHAR) NOT NULL,
    latitude NUMBER(9,6),
    longitude NUMBER(9,6),
    CONSTRAINT pk_venues PRIMARY KEY (venue_id),
    CONSTRAINT ck_venues_coords CHECK (
        (latitude IS NULL AND longitude IS NULL)
        OR (latitude IS NOT NULL AND longitude IS NOT NULL
            AND latitude BETWEEN -90 AND 90 AND longitude BETWEEN -180 AND 180)
    )
);

CREATE INDEX ix_venues_region ON venues (region);

CREATE TABLE artists (
    artist_id NUMBER(18) NOT NULL,
    name VARCHAR2(200 CHAR) NOT NULL,
    CONSTRAINT pk_artists PRIMARY KEY (artist_id)
);

CREATE TABLE performances (
    performance_id NUMBER(18) NOT NULL,
    venue_id NUMBER(18) NOT NULL,
    title VARCHAR2(200 CHAR) NOT NULL,
    genre VARCHAR2(80 CHAR),
    starts_at TIMESTAMP(6) NOT NULL,
    ends_at TIMESTAMP(6),
    CONSTRAINT pk_performances PRIMARY KEY (performance_id),
    CONSTRAINT fk_perf_venue FOREIGN KEY (venue_id) REFERENCES venues (venue_id),
    CONSTRAINT ck_perf_period CHECK (ends_at > starts_at)
);

CREATE INDEX ix_perf_venue_start ON performances (venue_id, starts_at);
CREATE INDEX ix_perf_start ON performances (starts_at);

CREATE TABLE performance_artists (
    performance_id NUMBER(18) NOT NULL,
    artist_id NUMBER(18) NOT NULL,
    CONSTRAINT pk_performance_artists PRIMARY KEY (performance_id, artist_id),
    CONSTRAINT fk_pa_perf FOREIGN KEY (performance_id)
        REFERENCES performances (performance_id) ON DELETE CASCADE,
    CONSTRAINT fk_pa_artist FOREIGN KEY (artist_id) REFERENCES artists (artist_id)
);

CREATE INDEX ix_pa_artist ON performance_artists (artist_id);

CREATE TABLE festivals (
    festival_id NUMBER(18) NOT NULL,
    venue_id NUMBER(18) NOT NULL,
    title VARCHAR2(200 CHAR) NOT NULL,
    starts_at TIMESTAMP(6) NOT NULL,
    ends_at TIMESTAMP(6) NOT NULL,
    CONSTRAINT pk_festivals PRIMARY KEY (festival_id),
    CONSTRAINT fk_festival_venue FOREIGN KEY (venue_id) REFERENCES venues (venue_id),
    CONSTRAINT ck_festival_period CHECK (ends_at > starts_at)
);

CREATE INDEX ix_festival_venue_start ON festivals (venue_id, starts_at);

CREATE TABLE stages (
    stage_id NUMBER(18) NOT NULL,
    festival_id NUMBER(18) NOT NULL,
    name VARCHAR2(120 CHAR) NOT NULL,
    CONSTRAINT pk_stages PRIMARY KEY (stage_id),
    CONSTRAINT fk_stage_festival FOREIGN KEY (festival_id) REFERENCES festivals (festival_id),
    CONSTRAINT uq_stage_festival_name UNIQUE (festival_id, name)
);

CREATE TABLE favorites (
    user_id NUMBER(18) NOT NULL,
    performance_id NUMBER(18) NOT NULL,
    created_at TIMESTAMP(6) DEFAULT SYS_EXTRACT_UTC(SYSTIMESTAMP) NOT NULL,
    CONSTRAINT pk_favorites PRIMARY KEY (user_id, performance_id),
    CONSTRAINT fk_fav_user FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE,
    CONSTRAINT fk_fav_perf FOREIGN KEY (performance_id)
        REFERENCES performances (performance_id) ON DELETE CASCADE
);

CREATE INDEX ix_fav_perf ON favorites (performance_id);

CREATE TABLE ticket_schedules (
    ticket_schedule_id NUMBER(18) NOT NULL,
    performance_id NUMBER(18) NOT NULL,
    sale_type VARCHAR2(12 CHAR) NOT NULL,
    opens_at TIMESTAMP(6) NOT NULL,
    closes_at TIMESTAMP(6),
    booking_url VARCHAR2(2048 BYTE),
    CONSTRAINT pk_ticket_schedules PRIMARY KEY (ticket_schedule_id),
    CONSTRAINT fk_ticket_perf FOREIGN KEY (performance_id)
        REFERENCES performances (performance_id) ON DELETE CASCADE,
    CONSTRAINT uq_ticket_perf_type_open UNIQUE (performance_id, sale_type, opens_at),
    CONSTRAINT ck_ticket_type CHECK (sale_type IN ('PRESALE', 'GENERAL', 'ADDITIONAL')),
    CONSTRAINT ck_ticket_period CHECK (closes_at > opens_at)
);
