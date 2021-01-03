ALTER TABLE
	salzburg_buildings
ADD COLUMN 
	security_level CHARACTER VARYING;

UPDATE 
	salzburg_buildings 
SET 
	security_level = 'public';
    
UPDATE 
	salzburg_buildings 
SET 
	security_level = 'protected' WHERE id%2=0;

UPDATE
	salzburg_buildings 
SET
	security_level = 'secret' WHERE id%3=0;

ALTER TABLE
	salzburg_buildings
ADD COLUMN 
	income INTEGER;

UPDATE 
	salzburg_buildings 
SET 
	income = floor(random() * 10000 + 1000)::int;

CREATE TABLE security_geofence (
	id SERIAL PRIMARY KEY,
	project CHARACTER VARYING,
	geom GEOMETRY
);

SELECT UpdateGeometrySRID('security_geofence','geom',32633);

INSERT INTO security_geofence (id, project, geom) VALUES (DEFAULT, 'intern', ST_GeomFromText('Polygon ((352387.999041571340058 5296931.33667475357651711, 354909.84093548177042976 5296931.33667475357651711, 354909.84093548177042976 5295245.0675822738558054, 352387.999041571340058 5295245.0675822738558054, 352387.999041571340058 5296931.33667475357651711))',32633));
