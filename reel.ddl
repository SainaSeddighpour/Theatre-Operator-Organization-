connect to SE3DB3;

----------------------------------------------------------------------------------------------------
--  DDL Statements for MANY TO ONE (and at least one) RELATIONSHIP BETWEEN PERSON AND PHONE NUMBER
----------------------------------------------------------------------------------------------------

------------------------------------
--  DDL Statement for table person
------------------------------------
CREATE TABLE person(
    personID INT NOT NULL PRIMARY KEY,
    firstName VARCHAR(100) NOT NULL,
    lastName VARCHAR(100) NOT NULL,
    age INT NOT NULL,
    street VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    province VARCHAR(100) NOT NUll,
    occupation VARCHAR(100) NOT NULL,
    numberseq INT NOT NULL  --at least one relation between contact and person
);

--------------------------------------
--  DDL Statement for table phoneNumber
--------------------------------------
CREATE TABLE phoneNumber (
    numberseq INT NOT NULL PRIMARY KEY,
    lineType VARCHAR(30) NOT NULL,
    personID INT NOT NULL REFERENCES person(personID)  --exactly one relation between contact and person
);


-------------------------------------------
--  DDL Statement for table associatedWith (defined because of the at least relation)
-------------------------------------------
CREATE TABLE associatedWith(
    personID INT NOT NULL REFERENCES person(personID),
    numberseq INT NOT NULL REFERENCES phoneNumber(numberseq),
    PRIMARY KEY(personID,numberseq)
);
--at least one relation between contact and person, constraints added after since phoneNumber is defined after person
ALTER TABLE person ADD FOREIGN KEY(personID, numberseq) REFERENCES associatedWith(personID, numberseq);

---------------------------------------------------------------------------------------------
--  DDL Statements for ISA relation between person -> actor, movie goer and director: ER method
---------------------------------------------------------------------------------------------
-------------------------------------------
--  DDL Statement for table movie_director
-------------------------------------------
CREATE TABLE movie_director(
    personID_director INT NOT NULL,
    studioAffiliation VARCHAR(100) NOT NULL,
    experience INT NOT NULL,
    netWorth_director DECIMAL NOT NULL,
     -- the at least one relation between movie and directs
    movieID INT NOT NULL,
    FOREIGN KEY(personID_director) REFERENCES person(personID) on delete CASCADE,
    PRIMARY KEY(personID_director)
);

-------------------------------------------
--  DDL Statement for table movie_actor
-------------------------------------------
CREATE TABLE movie_actor(
    personID_actor INT NOT NULL,
    netWorth_actor DECIMAL NOT NULL,
    agentName VARCHAR(100) NOT Null,
    FOREIGN KEY(personID_actor) REFERENCES person(personID) on delete CASCADE,
    PRIMARY KEY(personID_actor)
);

-------------------------------------------
--  DDL Statement for table movie_goer
-------------------------------------------
CREATE TABLE movie_goer(
    personID_moviegoer INT NOT NULL,
    FOREIGN KEY(personID_moviegoer) REFERENCES person(personID) on delete CASCADE,
    PRIMARY KEY(personID_moviegoer)
);

---------------------------------------------------------------------------------------------
--  DDL Statements for one to many relation between movie and movie_director
---------------------------------------------------------------------------------------------
-------------------------------------------
--  DDL Statement for table movie
-------------------------------------------
CREATE TABLE movie(
    movieID INT NOT NULL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    genre VARCHAR(100) NOT NULL CHECK(genre IN ('D', 'C', 'H','F','R','S')),
    releaseDate DATE NOT NULL,
    grossEarnings DECIMAL NOT NULL,
    personID_director INT NOT NULL REFERENCES movie_director(personID_director), -- exactly one relation between movie and movie director
    personID_actor INT NOT NULL --at least one relation between actor and movie (starring)
);

-------------------------------------------
--  DDL Statement for table awards
-------------------------------------------
CREATE TABLE awards(
    aname VARCHAR(100) NOT NULL,
    ayear INT NOT NULL,
    totalBudget DECIMAL NOT NULL,
    omovieID INT NOT NULL,
    personID_director INT NOT NULL REFERENCES movie_director(personID_director), --to represent the one to many relationship between awards and movie_director (the director's primary key is the personID)
    FOREIGN KEY (omovieID) REFERENCES movie(movieID) ON DELETE CASCADE,
    PRIMARY KEY (omovieID, aname, ayear),
    CHECK (ayear<=2022)
);
-------------------------------------------
--  DDL Statement for table directs
-------------------------------------------
--at least one relation between movie director and movie
CREATE TABLE directs(
    personID_director INT NOT NULL REFERENCES movie_director(personID_director),
    movieID INT NOT NULL REFERENCES movie(movieID),
    PRIMARY KEY (personID_director, movieID)
);
--at least one relation between movie director and movie

--at least one relation between movie director and movie, directs is defined after, therefore, add the constraints afterwards
ALTER TABLE movie_director ADD FOREIGN KEY (personID_director, movieID) REFERENCES directs(personID_director, movieID) ON DELETE CASCADE;

---------------------------------------------------------------------------------------------
--  DDL Statements for many to many relation between movie and movie_actor
---------------------------------------------------------------------------------------------

-------------------------------------------
--  DDL Statement for table starring
-------------------------------------------
CREATE TABLE starring(
    personID_actor INT NOT NULL REFERENCES movie_actor(personID_actor),
    movieID INT NOT NULL REFERENCES movie(movieID),
    PRIMARY KEY (personID_actor, movieID)
);

--at least one relation between actor and movie (starring), constraints added after

ALTER TABLE MOVIE ADD FOREIGN KEY(personID_actor, movieID) REFERENCES starring(personID_actor, movieID) ON DELETE CASCADE;

-------------------------------------------
--  DDL Statement for table hasRole
-------------------------------------------
CREATE TABLE hasRole(
    ryear INT,
    actorRole VARCHAR(100) NOT NULL,
    oscar smallint CHECK (oscar IN (0,1)),
    movieID INT NOT NULL,
    personID_actor INT NOT NULL,
    FOREIGN KEY(movieID) REFERENCES movie(movieID) ON DELETE CASCADE ,
    FOREIGN KEY(personID_actor) REFERENCES movie_actor(personID_actor) ON DELETE CASCADE,
    PRIMARY KEY(movieID, personID_actor),
    CHECK (actorRole = 'lead actor' or 'supporting actor' or 'under study')
);

---------------------------------------------------------------------------------------------
--  DDL Statement for table many to many relation between movie and movietheatre (shows relation)
---------------------------------------------------------------------------------------------

-------------------------------------------
--  DDL Statement for table movieTheatre
-------------------------------------------
CREATE TABLE movieTheatre(
    theatreID INT NOT NULL PRIMARY KEY,
    theatreName VARCHAR(100) NOT NULL,
    theatreStreet VARCHAR(100) NOT NULL,
    theatreCity VARCHAR(100) NOT NULL,
    theatreProvince VARCHAR(100) NOT NULL,
    totalScreens INT NOT NULL
);
-------------------------------------------
--  DDL Statement for table shows
-------------------------------------------
CREATE TABLE shows(
    ticketPrice DECIMAL NOT NULL,
    screenNumber INT NOT NULL,
    showTime TIME NOT NULL,
    showDay VARCHAR(20) NOT NULL,
    movieID INT NOT NULL REFERENCES movie(movieID),
    theatreID INT NOT NULL REFERENCES movieTheatre(theatreID),
    PRIMARY KEY (movieID, theatreID), -- the primary keys of the entities connected to the relation become the primary keys of the relation
    CHECK (showDay = 'sunday' or 'monday' or 'tuesday' or 'wednesday' or 'thursday' or 'friday' or 'saturday')
);

---------------------------------------------------------------------------------------------
--  DDL Statement for table many to many relation between movieTheatre and movie_goer (visits relation)
---------------------------------------------------------------------------------------------

-------------------------------------------
--  DDL Statement for table visits
-------------------------------------------
CREATE TABLE visits(
    total_ticket_price DECIMAL NOT NULL,
    visitDate DATE NOT NULL,
    paymentMethod VARCHAR(100) NOT NULL,
    personID_moviegoer INT NOT NULL REFERENCES movie_goer(personID_moviegoer),
    theatreID INT NOT NULL REFERENCES movieTheatre(theatreID),
    PRIMARY KEY(personID_moviegoer,theatreID)
);
---------------------------------------------------------------------------------------------
--  DDL Statement for at least many-many relation between transaction and movie_goer (makes relation)
---------------------------------------------------------------------------------------------

-------------------------------------------
--  DDL Statement for table transaction
-------------------------------------------
CREATE TABLE otransaction(
    transactionID INT NOT NULL PRIMARY KEY,
    paymentMethodTransaction VARCHAR(100) NOT NULL,
    transactionDate DATE NOT NULL,
    totalPaid DECIMAL NOT NULL,
    SKU INT NOT NULL, --reference the product at least one relation
    personID_moviegoer INT NOT NULL --reference the movie_goer's primary key for the at least one relation
);

-------------------------------------------
--  DDL Statement for table makes
-------------------------------------------
CREATE TABLE makes(
    transactionID INT NOT NULL REFERENCES otransaction(transactionID),
    personID_moviegoer INT NOT NULL REFERENCES movie_goer(personID_moviegoer),
    PRIMARY KEY(transactionID, personID_moviegoer)
);

--at least one relation, the constraint is added later after makes is defined

ALTER TABLE otransaction ADD FOREIGN KEY(transactionID,personID_moviegoer) REFERENCES makes(transactionID, personID_moviegoer) ON DELETE CASCADE;

---------------------------------------------------------------------------------------------
--  DDL Statement for at least many-many relation between transaction and product (partOf relation)
---------------------------------------------------------------------------------------------
-------------------------------------------
--  DDL Statement for table product
-------------------------------------------
CREATE TABLE aproduct(
   SKU INT NOT NULL PRIMARY KEY,
   price DECIMAL NOT NULL,
   pname VARCHAR(100) NOT NULL,
   category VARCHAR(100) NOT NULL
);

-------------------------------------------
--  DDL Statement for table partOf
-------------------------------------------
CREATE TABLE partOf(
    quantity INT NOT NULL,
    transactionID INT NOT NULL REFERENCES otransaction(transactionID),
    SKU INT NOT NULL REFERENCES aproduct(SKU),
    PRIMARY KEY (transactionID, SKU)
);

--the constraints added to the reference of product in transaction (at least one relation)
ALTER TABLE otransaction ADD FOREIGN KEY(transactionID, SKU) REFERENCES partOf(transactionID, SKU) ON DELETE CASCADE;

---------------------------------------------------------------------------------------------
--  DDL Statement for one-one relation between rewardsCard and movie_goer (obtains relation)
---------------------------------------------------------------------------------------------

-------------------------------------------
--  DDL Statement for table rewardsCard
-------------------------------------------
CREATE TABLE rewardsCard(
    cardName INT NOT NULL PRIMARY KEY,
    balance DECIMAL NOT NULL,
    activationDate DATE NOT NULL,
    personID_moviegoer INT NOT NULL UNIQUE REFERENCES movie_goer(personID_moviegoer) --one-one relation
);

---------------------------------------------------------------------------------------------
--  DDL Statement for at least one relation between product and concessionStand (sells relation)
---------------------------------------------------------------------------------------------
-------------------------------------------
--  DDL Statement for table concessionStand
-------------------------------------------
CREATE TABLE concessionStand(
    ctype VARCHAR (30) NOT NULL CHECK (ctype IN ('souvenir', 'food')),
    theatreID INT NOT NULL,
    SKU INT NOT NULL, --at least one
    FOREIGN KEY (theatreID) REFERENCES movieTheatre(theatreID) ON DELETE CASCADE,
    PRIMARY KEY (ctype, theatreID)
);

-------------------------------------------
--  DDL Statement for table sells
-------------------------------------------
CREATE TABLE sells(
    ctype VARCHAR(30) NOT NULL,
    theatreID INT NOT NULL,
    FOREIGN KEY (ctype, theatreID) REFERENCES concessionStand(ctype, theatreID) on delete cascade,
    SKU INT NOT NULL REFERENCES aproduct(SKU) on delete cascade,
    PRIMARY KEY (SKU, theatreID, ctype)
);

ALTER TABLE concessionStand ADD FOREIGN KEY(SKU, theatreID, ctype) REFERENCES sells(SKU, theatreID, ctype);

connect reset;


