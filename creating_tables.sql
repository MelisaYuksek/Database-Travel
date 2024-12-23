CREATE TABLE public.users (  --overlapping /total comp.
    "userid" SERIAL,
    "name" VARCHAR(50) NOT NULL,
    "surname" VARCHAR(50) NOT NULL,
    "email" VARCHAR(50) UNIQUE NOT NULL,
    "password" VARCHAR(255) NOT NULL,
    "phoneno" VARCHAR(30),
	CONSTRAINT "userPK" PRIMARY KEY ("userid") 
	
);

CREATE TABLE public.adminuser (
    "userid" INT,
	"adminprivileges" VARCHAR(50),
    "permissionlevel" VARCHAR(5) NOT NULL,
	 CONSTRAINT "adminuser_userFK" FOREIGN KEY ("userid") REFERENCES public.users("userid")
)INHERITS("public"."users");


CREATE TABLE public.regularuser (
	"userid" INT,
    "regularuserprivileges" VARCHAR(50),
    "membershiptype" VARCHAR(10),
	CONSTRAINT "regularuser_userFK" FOREIGN KEY ("userid") REFERENCES public.users("userid")
) INHERITS("public"."users");


CREATE TABLE public.locations ( --disjoint / partial comp.
    "locationid" SERIAL,
    "name" VARCHAR(100) NOT NULL,
    "country" VARCHAR(50) NOT NULL,
    "city" VARCHAR(50) NOT NULL,
	CONSTRAINT "locationPK" PRIMARY KEY ("locationid") 
);

CREATE TABLE public.cities (
    "locationid" INT,
    "cityname" VARCHAR(100) NOT NULL,
    "state" VARCHAR(100),
	CONSTRAINT "city_locationFK" FOREIGN KEY ("locationid") REFERENCES public.locations("locationid")
)INHERITS("public"."locations");



CREATE TABLE public.countries (
    "locationid" INT,
    "countryname" VARCHAR(100) NOT NULL,
    "continent" VARCHAR(50),
	 CONSTRAINT "country_locationFK" FOREIGN KEY ("locationid") REFERENCES public.locations("locationid")
)INHERITS("public"."locations");

CREATE TABLE public.payments (
    "paymentid" SERIAL,
    "paymentdate" DATE DEFAULT CURRENT_DATE,
    "totalamount" NUMERIC(10, 2) NOT NULL,
    "paymentmethod" VARCHAR(50) NOT NULL,
    CONSTRAINT "paymentPK" PRIMARY KEY ("paymentid")
);

CREATE TABLE public.reservations ( --disjoint / total comp.
    "reservationid" SERIAL,
    "reservationdate" DATE DEFAULT CURRENT_DATE,
    "userid" INT NOT NULL,
    "paymentid" INT NOT NULL,
    CONSTRAINT "reservationPK" PRIMARY KEY ("reservationid"),
    CONSTRAINT "reservation_userFK" FOREIGN KEY ("userid") REFERENCES public.users("userid") ON DELETE CASCADE,
    CONSTRAINT "reservation_paymentFK" FOREIGN KEY ("paymentid") REFERENCES public.payments("paymentid") ON DELETE SET NULL
);

CREATE TABLE public.transport (
    "transportid" SERIAL,
    "type" VARCHAR(50) NOT NULL,
    "departuretime" TIMESTAMP NOT NULL,
	 "reservationid" INT NOT NULL,
	CONSTRAINT "transportPK" PRIMARY KEY ("transportid"),
	 CONSTRAINT "transport_reservationFK" FOREIGN KEY ("reservationid") REFERENCES public.reservations("reservationid") ON DELETE CASCADE
)INHERITS("public"."reservations");


CREATE TABLE public.accommodation ( --disjoint / partial comp.
    "accommodationid" SERIAL,
    "type" VARCHAR(50) CHECK ("type" IN ('hotel', 'hostel')),
    "date" DATE NOT NULL,
	"reservationid" INT NOT NULL,
    CONSTRAINT "accommodationPK" PRIMARY KEY ("accommodationid"),
	  CONSTRAINT "accommodation_reservationFK" FOREIGN KEY ("reservationid") REFERENCES public.reservations("reservationid") ON DELETE CASCADE
)INHERITS("public"."reservations");

CREATE TABLE public.hotels (
    "hotelid" SERIAL,
    "hotelname" VARCHAR(100) NOT NULL,
    "starrating" INT CHECK ("starrating" BETWEEN 1 AND 5),
    "address" TEXT NOT NULL,
	"accommodationid" INT NOT NULL,
    CONSTRAINT "hotelPK" PRIMARY KEY ("hotelid"),
	  CONSTRAINT "hotel_accommodationFK" FOREIGN KEY ("accommodationid") REFERENCES public.accommodation("accommodationid") ON DELETE CASCADE
)INHERITS("public"."accommodation");

CREATE TABLE public.hostels (
    "hostelid" SERIAL,
    "hostelname" VARCHAR(100) NOT NULL,
    "starrating" INT CHECK ("starrating" BETWEEN 1 AND 5),
    "address" TEXT NOT NULL,
	"accommodationid" INT NOT NULL,
    CONSTRAINT "hostelPK" PRIMARY KEY ("hostelid"),
	 CONSTRAINT "hostel_accommodationFK" FOREIGN KEY ("accommodationid") REFERENCES public.accommodation("accommodationid") ON DELETE CASCADE
)INHERITS("public"."accommodation");




CREATE TABLE public.transportcompany (
    "companyid" SERIAL PRIMARY KEY,
    "transportid" INT NOT NULL REFERENCES public.transport("transportid") ON DELETE CASCADE ON UPDATE CASCADE,
    "companyname" VARCHAR(100) NOT NULL,
    "contactinfo" TEXT,
    "address" TEXT
);

CREATE TABLE public.reviews ( --disjoint / total comp.
    "reviewid" SERIAL,
    "userid" INT NOT NULL,
    "reviewdate" DATE DEFAULT CURRENT_DATE,
    "reviewtext" TEXT NOT NULL,
    "reviewtype" VARCHAR(50) NOT NULL,
    CONSTRAINT "reviewPK" PRIMARY KEY ("reviewid"),
    CONSTRAINT "review_userFK" FOREIGN KEY ("userid") REFERENCES public.users("userid") ON DELETE CASCADE
);

CREATE TABLE public.reservationreview (
    "reviewid" INT NOT NULL,
    "reservationid" INT NOT NULL,
    CONSTRAINT "reservationreviewPK" PRIMARY KEY ("reviewid", "reservationid"),
    CONSTRAINT "reservationreview_reservationFK" FOREIGN KEY ("reservationid") REFERENCES public.reservations("reservationid") ON DELETE CASCADE,
    CONSTRAINT "reservationreview_reviewFK" FOREIGN KEY ("reviewid") REFERENCES public.reviews("reviewid") ON DELETE CASCADE
) INHERITS("public"."reviews");

CREATE TABLE public.locationreview (
    "locationreviewid" SERIAL,
    "reviewid" INT NOT NULL,
	"locationid" INT NOT NULL,
     CONSTRAINT "locationreviewPK" PRIMARY KEY ("locationreviewid"),
    CONSTRAINT "locationreview_locationFK" FOREIGN KEY ("locationid") REFERENCES public.locations("locationid") ON DELETE CASCADE,
    CONSTRAINT "locationreview_reviewFK" FOREIGN KEY ("reviewid") REFERENCES public.reviews("reviewid") ON DELETE CASCADE
)INHERITS("public"."reviews");


CREATE TABLE public.trips (
    "tripid" SERIAL,
    "userid" INT NOT NULL,
    "title" VARCHAR(100) NOT NULL,
    "startdate" DATE NOT NULL,
    "enddate" DATE NOT NULL,
    "totalcost" DECIMAL(10, 2) NOT NULL,
    "participantcount" INT CHECK ("participantcount" >= 1),
    CONSTRAINT "tripPK" PRIMARY KEY ("tripid"),
    CONSTRAINT "trip_userFK" FOREIGN KEY ("userid") REFERENCES public.users("userid") ON DELETE CASCADE
);

CREATE TABLE public.activities (
    "activityid" SERIAL,
    "activityname" VARCHAR(100) NOT NULL,
    "description" TEXT,
    CONSTRAINT "activityPK" PRIMARY KEY ("activityid")
);


CREATE TABLE public.tripactivities (
    "tripid" INT NOT NULL,
    "activityid" SERIAL,
    "cost" DECIMAL(10, 2) NOT NULL,
    "activitydate" DATE NOT NULL,
    CONSTRAINT "tripactivityPK" PRIMARY KEY ("tripid", "activityid"),
    CONSTRAINT "tripactivity_tripFK" FOREIGN KEY ("tripid") REFERENCES public.trips("tripid") ON DELETE CASCADE,
    CONSTRAINT "tripactivity_activityFK" FOREIGN KEY ("activityid") REFERENCES public.activities("activityid") ON DELETE CASCADE
);

CREATE TABLE public.triplocations (
    "tripid" INT NOT NULL,
    "locationid" INT NOT NULL,
    "type" VARCHAR(50) NOT NULL,
    "description" TEXT,
    CONSTRAINT "triplocationPK" PRIMARY KEY ("tripid", "locationid"),
    CONSTRAINT "triplocation_tripFK" FOREIGN KEY ("tripid") REFERENCES public.trips("tripid") ON DELETE CASCADE,
    CONSTRAINT "triplocation_locationFK" FOREIGN KEY ("locationid") REFERENCES public.locations("locationid") ON DELETE CASCADE
);



INSERT INTO "public"."adminuser" ("userid", "name", "surname", "email", "phoneno", "password") 
VALUES (6, 'Marlane', 'Rutigliano', 'mrutigliano5@godaddy.com', '+47 (546) 118-7356', 'pH3><s.wYN6UX''?G');
