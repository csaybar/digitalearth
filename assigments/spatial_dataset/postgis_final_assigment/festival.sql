-- ---------------------------------------------------------------------
-- Homework Spatial databases
--
-- Date: Feb 25 2021
-- Author: Cesar Aybar
--
-- Run this script to generate the City Festival database
--
-- The data in this table is for educational purposes only. No guarantee
-- for completeness or correctness is given ... and don’t freak out, there
-- is also not political message or statement hidden.
-- ---------------------------------------------------------------------

-- ---------------------------------------------------------------------
-- CREATE A SPATIAL TABLE
-- ---------------------------------------------------------------------

CREATE TABLE city_festival (
    name_facility CHARACTER VARYING,
    code_facility INTEGER,
    open INTEGER,
    close INTEGER,
    cost FLOAT,
    max_people_support INTEGER,
    owner CHARACTER VARYING,
    geom geometry(Point, 4326)
);

-- ---------------------------------------------------------------------
-- CITY FESTIVAL DATASET
-- ---------------------------------------------------------------------

INSERT INTO city_festival (name_facility, code_facility ,open, close, cost, max_people_support, owner, geom) VALUES
('roller coasters', 001, 8, 22, 10.5, 130, 'Luis', 'Point(-73.5121512 40.724435)'),
('roller coasters', 001, 7, 23, 12.5, 120, 'Luis', 'Point(-73.45559 40.623623)'),
('booths', 002, 10, 23, 8.65, 110, 'Enrique', 'Point(-73.24215 40.3473473)'),
('booths', 002, 12, 23, 5.5, 140, 'Enrique', 'Point(-73.115212 40.3252352)'),
('booths', 002, 11, 23, 7.5, 120 , 'Enrique','Point(-73.7457457 40.1512512)'),
('tents', 003, 9, 21, 8.25, 200, 'Jaime', 'Point(-73.634636 40.623623)'),
('Theater', 004, 6, 21, 8.75, 110,'Pedro', 'Point(-73.4353463 40.362132)'),
('Theater', 004, 8, 20, 8.75, 115, 'Pedro', 'Point(-73.7458484 40.45845)'),
('Theater', 004, 10, 23, 8.75, 115,'Pedro', 'Point(-73.124125 40.3262362)'),
('tents', 003, 9, 20, 10.25, 300, 'Jaime', 'Point(-73.659566 40.8458458)'),
('tents', 003, 9, 20, 12.5,  205, 'Jaime', 'Point(-73.6343734 40.247627)'),
('Public bathrooms', 005, 10, 24, 0.5, 30, 'Myriam', 'Point(-73.236323 40.1235125)'),
('Public bathrooms', 005, 12, 24, 0.5, 20, 'Myriam', 'Point(-73.47347 40.236326)'),
('Public bathrooms', 005, 6, 20, 0, 20, 'Myriam', 'Point(-73.463346 40.548458)'),
('Public bathrooms', 005, 6, 20, 0, 30, 'Myriam', 'Point(-73.734737 40.135162)'),
('Game-I', 006, 6, 22, 5.5, 40, 'Cesar', 'Point(-73.235236 40.596955)'),
('Game-I', 006, 7, 23, 5.25, 40, 'Cesar', 'Point(-73.845458 40.4623623)'),
('Game-I', 006, 7, 23, 5.75, 30, 'Cesar', 'Point(-73.236236 40.434347)'),
('Game-II', 007, 8, 24, 2.5, 30, 'Manuel', 'Point(-73.474577 40.845458)'),
('Game-II', 007, 8, 24, 2.5, 20, 'Manuel', 'Point(-73.346346 40.584584)'),
('Game-II', 007, 8, 24, 2.25, 20, 'Manuel', 'Point(-73.236532 40.0639262)'),
('Game-III', 008, 9, 24, 18.5, 10, 'Lorena', 'Point(-73.16162 40.9925392)'),
('Game-III', 008, 8, 20, 12.5, 10, 'Lorena', 'Point(-73.85484 40.273272)'),
('Game-III', 008, 7, 22, 15.5, 20, 'Lorena', 'Point(-73.23623 40.851285)'),
('booths', 002, 10, 23, 5.5, 35, 'Enrique', 'Point(-73.74363 40.0512512)');