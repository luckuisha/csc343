-- insert all the divers
INSERT INTO Diver
(d_id, firstName, surName, email, DOB, qualification)
VALUES
(0, 'rick', 'sanchez', 'dirtysanchez@morties.com', '09/08/1950'::DATE, 'CMAS'),
(1, 'morty', 'smith', 'morty@morties.com', '10/10/2005'::DATE, 'NAUI'),
(2, 'summer', 'smith', 'summer@morties.com', '01/27/2003'::DATE, 'CMAS'),
(3, 'beth', 'smith', 'beth@morties.com', '06/23/1975'::DATE, 'PADI'),
(4, 'jerry', 'smith', 'jerry@morties.com', '12/14/1976'::DATE, 'PADI'),
(5, 'diane', 'sanchez', 'diane@morties.com', '02/17/1950'::DATE, 'NAUI'),
(6, 'unity', 'unity', 'unity@morties.com', '01/01/2000'::DATE, 'CMAS'),
(7, 'spongebob', 'squarepants', 'sponge@ocean.com', '01/01/2000'::DATE, 'CMAS'),
(8, 'patrick', 'star', 'star@ocean.com', '01/01/2001'::DATE, 'CMAS'),
(9, 'squidward', 'tenticles', 'octopussy@ocean.com', '01/01/2002'::DATE, 'CMAS'),
(10, 'eugene', 'krabs', 'money@ocean.com', '01/01/2001'::DATE, 'NAUI'),
(11, 'sandy', 'cheeks', 'squirrel@ocean.com', '01/01/2001'::DATE, 'PADI');

-- insert all monitors
INSERT INTO Monitor
(m_id, firstName, surName, email, max_open, max_cave, max_deep,
    price_morning_open, price_morning_cave, price_morning_deep, 
    price_afternoon_open, price_afternoon_cave, price_afternoon_deep, 
    price_night_open, price_night_cave, price_night_deep)
VALUES
(0, 'michael', 'scott', 'mikey@office.com', 5, 0, 0, 20.10, NULL, NULL, 15.75, NULL, NULL, 35, NULL, NULL),
(1, 'dwight', 'schrute', 'dwight@office.com', 1, 1, 1, 5, 5, 5, 8, 8, 8, 15, 15, 15),
(2, 'jim', 'halpert', 'jimmy@office.com', 10, 15, 8, 12, 15, 20, 12, 15, 20, 20, 30, 50),
(3, 'pam', 'beesly', 'pam@office.com', 0, 5, 5, NULL, 3, 3, NULL, 5, 5, NULL, 69, 69),
(4, 'creed', 'batton', 'creed@office.com', 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

-- insert sites
INSERT INTO Site
(s_id, name, location,
    max_daylight, max_night,
    max_daylight_open, max_night_open, 
    max_daylight_cave, max_night_cave,
    max_daylight_deep, max_night_deep, 
    site_fee, 
    mask_price, reg_price, fin_price, comp_price,
    has_video, has_snack, has_shower, has_towel) 
VALUES
(0, 'dunder mifflin', 'scranton', 5, 0, 3, 0, 3, 0, 3, 0, 30, NULL, NULL, NULL, NULL, FALSE, FALSE, FALSE, FALSE),
(1, 'bikini bottom', 'pacific', 6, 6, 2, 2, 2, 2, 2, 2, 50, NULL, 15, 15, NULL, FALSE, TRUE, FALSE, TRUE),
(2, 'c-137 earth', 'this dimension', 15, 15, 15, 15, 10, 10, 8, 6, 420, 20, 30, 50, 69, TRUE, TRUE, TRUE, TRUE),
(3, 'no rating for me', 'boo', 15, 15, 15, 15, 10, 10, 8, 6, 420, 20, 30, 50, 69, TRUE, TRUE, TRUE, TRUE);

INSERT INTO MonitorPrivilege
(site_id_of_privilege, monitor_id_with_privileges)
VALUES
(0, 0), 
(2, 2), 
(1, 3),
(2, 3), 
(0, 1);

INSERT INTO Booking
(b_id, lead_diver_id, monitor_id, site_id, 
    num_divers, date_of_dive, timeslot_of_dive,
    type_of_dive, credit_card_number, 
    credit_card_security_code, credit_card_expiry)
VALUES
(0, 0, 0, 0, 3, '01/01/2020'::DATE, 'morning', 'open', 1234567889, 420, '01/01/2030'::DATE),
(1, 0, 2, 2, 7, '02/01/2020'::DATE, 'morning', 'open', 1234567889, 420, '01/01/2030'::DATE),
(2, 0, 3, 1, 3, '03/01/2020'::DATE, 'night', 'cave', 1234567889, 420, '01/01/2030'::DATE),
(3, 7, 3, 2, 6, '04/01/2020'::DATE, 'afternoon', 'cave', 987654321, 069, '01/01/2040'::DATE),
(4, 0, 2, 2, 8, '04/01/2020'::DATE, 'afternoon', 'cave', 987654321, 069, '01/01/2040'::DATE), 
(5, 4, 1, 0, 2, '04/01/2020'::DATE, 'night', 'deep', 420420420, 069, '01/01/2025'::DATE);

INSERT INTO DiversInBooking
(booking_id, diver_id,
    bought_mask, bought_reg, bought_fin, bought_comp)
VALUES
(0, 0, TRUE, TRUE, TRUE, TRUE),
(0, 1, TRUE, TRUE, TRUE, TRUE),
(1, 0, TRUE, TRUE, TRUE, FALSE),
(1, 1, TRUE, TRUE, FALSE, TRUE),
(1, 2, TRUE, FALSE, TRUE, TRUE),
(1, 3, FALSE, TRUE, TRUE, TRUE),
(1, 4, TRUE, TRUE, FALSE, FALSE),
(1, 5, TRUE, FALSE, TRUE, FALSE),
(2, 0, FALSE, TRUE, TRUE, FALSE),
(2, 1, TRUE, FALSE, FALSE, TRUE),
(3, 7, FALSE, TRUE, FALSE, TRUE),
(3, 8, FALSE, FALSE, TRUE, TRUE),
(3, 9, FALSE, FALSE, TRUE, FALSE),
(3, 10, FALSE, FALSE, FALSE, FALSE),
(3, 11, FALSE, TRUE, FALSE, FALSE),
(4, 0, TRUE, FALSE, FALSE, FALSE),
(4, 1, FALSE, FALSE, FALSE, TRUE),
(4, 2, FALSE, FALSE, FALSE, FALSE),
(4, 3, FALSE, TRUE, TRUE, TRUE),
(4, 4, TRUE, TRUE, FALSE, TRUE),
(4, 5, TRUE, FALSE, TRUE, FALSE),
(4, 6, TRUE, TRUE, TRUE, TRUE),
(5, 4, FALSE, FALSE, TRUE, FALSE);


INSERT INTO MonitorRating
(lead_diver_id_of_rating, monitor_id_of_rating, MonitorRating)
VALUES
(0, 0, 1),
(0, 3, 2),
(7, 3, 4),
(4, 1, 5);

INSERT INTO SiteRating
(diver_id_of_rating, site_id, SiteRating)
VALUES
(0, 0, 4),
(0, 2, 3),
(0, 1, 1),
(1, 0, 1),
(1, 1, 2),
(2, 2, 3),
(3, 2, 4), 
(4, 0, 5),
(4, 2, 5), 
(5, 2, 3), 
(6, 2, 4), 
(7, 2, 4), 
(8, 2, 3), 
(9, 2, 3), 
(10, 2, 4), 
(11, 2, 4);
