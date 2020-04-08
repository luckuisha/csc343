-- Wet World's Schema.
/*
  AGE CONSTRAINT: we could have forced "divers" to be 16+ when
  they register as a diver,  but that would unfairly prevent 
  one from booking a dive for a future date when they may be 16+

  CAPACITY CONSTRAINT: We did not enforce the number of divers per 
  site/monitor because it would have required cross-table 
  constraints without triggers. 

  MULTIPLE GROUP CAPACITY CONTRAINT: Can not enforce total number of divers 
  at a site with multiple bookings at the same time and type of dive. This requires
  triggers. 

  RATING CONSTRAINT: We tried to ensure that monitors are rated only by lead 
  divers that have used them, but this was is unable to be constrained through
  booking (where our lead divers are) as it is not a key in bookings. We could
  have created a new table with lead divers with their own credit card information
  but that would have caused more problems. We assumed that the lead diver could
  have multiple credit cards and would create redundancies in the schema. 
  Therefore, now any diver can rate the monitor. 
  Similarily, sites can be rated by any diver as we were unable to constrain 
  whether the diver has dove there since it would require a trigger. Moreover, 
  we were unable to use a foreign key constraint as diversInBooking's divers are not
  keys in this table. 

  MONITOR TIME CONTRAINT: We were unable to contrain the monitors frequency of dives
  to less than 3 dives within a 24 hour period as it would require a trigger. 

  DIVER DOUBLE BOOKING CONTRAINT: unable to constrain whether a diver can
  dive at two different dives at the same time. This would require a trigger

  DIVER SERVICE PURCHASE CHECK CONTRAINT: unable to check whether a service 
  purchased is offered at the site as it would require a cross table constraint 
  which is not possible without a trigger. 
  
  WORKING CONTRAINTS ARE LISTED BELOW IN COMMENTS THROUGHOUT TABLES

*/

DROP SCHEMA IF EXISTS wetWorldSchema CASCADE;
CREATE SCHEMA WetWorldSchema;
SET SEARCH_PATH TO WetWorldSchema;


CREATE TYPE qualificationType AS ENUM ('NAUI', 'CMAS', 'PADI');
CREATE TYPE timeSlots AS ENUM ('morning', 'afternoon', 'night');
CREATE TYPE diveTypes AS ENUM ('open', 'cave', 'deep');

-- A person who dives.
CREATE TABLE Diver
(
  d_id INT PRIMARY KEY,
  -- The first name of the diver
  firstName VARCHAR(50) NOT NULL,
  -- The surname of the diver
  surName VARCHAR(50) NOT NULL,
  -- The email of the diver
  email varchar(30) NOT NULL,
  -- diver's birthday
  DOB DATE NOT NULL,
  --diver's qualification
  --CONSTRAINT: A diver must be qualified
  qualification qualificationType NOT NULL
);

-- a person who monitors dives
CREATE TABLE Monitor
(
  m_id INT PRIMARY KEY,
  --name of monitor
  firstName VARCHAR(50) NOT NULL,
  -- The surname of the monitor
  surname VARCHAR(50) NOT NULL,
  -- The email of the monitor
  email varchar(30) NOT NULL,

  -- monitor's max number of divers in open water dives
  max_open INT NOT NULL,

  -- monitor's max number of divers in cave dives
  max_cave INT NOT NULL,
  -- monitor's max number of divers in deep dives
  max_deep INT NOT NULL,


  -- monitor's prices by time and type. NULL means not offered
  price_morning_open FLOAT,
  price_morning_cave FLOAT,
  price_morning_deep FLOAT,

  price_afternoon_open FLOAT,
  price_afternoon_cave FLOAT,
  price_afternoon_deep FLOAT,

  price_night_open FLOAT,
  price_night_cave FLOAT,
  price_night_deep FLOAT
);

-- sites where dives occur
CREATE TABLE Site
(
  s_id INT PRIMARY KEY,
  --name of site
  name VARCHAR(50) NOT NULL,
  -- location of site
  location VARCHAR(50) NOT NULL,

  -- site's max number of divers during day/night (should be greater than other maxima in category)
  max_daylight INT NOT NULL,
  max_night INT NOT NULL,
  -- site's max number of open water divers at a time
  max_daylight_open INT NOT NULL,
  max_night_open INT NOT NULL,
  -- site's max number of cave divers at a time
  max_daylight_cave INT NOT NULL,
  max_night_cave INT NOT NULL,
  --site's max number of night divers at a time
  -- monitor's max number of deep divers at a time
  max_daylight_deep INT NOT NULL,
  max_night_deep INT NOT NULL,

  --Site fee per diver
  site_fee FLOAT NOT NULL,

  --Paid services. NULL if not offered
  mask_price FLOAT,
  reg_price FLOAT,
  fin_price FLOAT,
  comp_price FLOAT,
  --Free services. TRUE if offered, FALSE otherwise
  has_video BOOLEAN NOT NULL,
  has_snack BOOLEAN NOT NULL,
  has_shower BOOLEAN NOT NULL,
  has_towel BOOLEAN NOT NULL
  --CONTRAINT: Enforce maxima condition explained before in line 110
  CHECK(max_daylight>= max_daylight_open AND max_daylight>= max_daylight_cave AND max_daylight>= max_daylight_deep),
  CHECK(max_night>= max_night_open AND max_night>= max_night_cave AND max_night>= max_night_deep)
);


--Monitor monitor_id can book at site site_id 
CREATE TABLE MonitorPrivilege
(
  site_id_of_privilege INT NOT NULL REFERENCES Site(s_id),
  monitor_id_with_privileges INT NOT NULL REFERENCES Monitor(m_id), 
  --CONTRAINT: ensures no redundancies when creating privileges
  PRIMARY KEY(site_id_of_privilege, monitor_id_with_privileges)
);

--------BOOKINGS---------
CREATE TABLE Booking
(
  b_id INT PRIMARY KEY,
  --lead diver id
  lead_diver_id INT NOT NULL REFERENCES Diver(d_id ),
  --monitor supervising the dive
  monitor_id INT NOT NULL REFERENCES Monitor(m_id),
  -- site of the dive
  site_id INT NOT NULL REFERENCES Site(s_id),
  -- total number of divers
  num_divers INT NOT NULL,
  --time of dive
  date_of_dive DATE NOT NULL,
  timeslot_of_dive timeslots NOT NULL,
  type_of_dive divetypes NOT NULL,

  --Supplied by lead diver
  credit_card_number INT NOT NULL,
  credit_card_security_code INT NOT NULL,
  credit_card_expiry DATE NOT NULL,

  --CONTRAINT: makes sure credit card as not expired prior to date of dive
  CHECK (date_of_dive<credit_card_expiry), 
  --CONSTRAINT: makes sure monitors can only be booked for specific sites
  --referenced in monitor privilege
  FOREIGN KEY (site_id, monitor_id) REFERENCES MonitorPrivilege
);

--Diver of diver_id is part of the dive of booking_id
CREATE TABLE DiversInBooking
(
  booking_id INT NOT NULL REFERENCES Booking(b_id),
  diver_id INT NOT NULL REFERENCES Diver(d_id),

  --Extras this diver purchased for this dive
  bought_mask BOOLEAN NOT NULL,
  bought_reg BOOLEAN NOT NULL,
  bought_fin BOOLEAN NOT NULL,
  bought_comp BOOLEAN NOT NULL, 

  --CONSTRAINT: Ensures only one diver inside a booking
  PRIMARY KEY (booking_id, diver_id)
);

---------RATINGS---------
CREATE TABLE MonitorRating
(
  --person who gave rating (lead diver)
  lead_diver_id_of_rating INT NOT NULL REFERENCES Diver(d_id), 
  -- monitor rated
  monitor_id_of_rating INT NOT NULL REFERENCES Monitor(m_id),
  --monitor's rating
  MonitorRating INT NOT NULL,

  --CONTRAINT: we restricted number of ratings per diver to one. diver is able to change
  --their rating but unable to add a new one
  PRIMARY KEY (lead_diver_id_of_rating, monitor_id_of_rating),
  --CONTRAINT: ensures rating is in the correct range
  CHECK (MonitorRating >=0 AND MonitorRating <=5)

);

CREATE TABLE SiteRating
(
  --person who gave rating
  diver_id_of_rating INT NOT NULL REFERENCES Diver(d_id),
  --site rated
  site_id INT NOT NULL REFERENCES Site(s_id),
  --site rating 
  SiteRating INT NOT NULL,
  --CONTRAINT: we restricted number of ratings per diver to one. diver is able to change
  --their rating but unable to add a new one
  PRIMARY KEY (diver_id_of_rating, site_id),
  --CONSTRAINT: ensures rating is in the correct range
  CHECK (SiteRating >=0 AND SiteRating <=5)
); 
