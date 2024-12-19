	
	
	CREATE TABLE "public"."Users" (
    "UserID" SERIAL,
    "Name" VARCHAR(50) NOT NULL,
    "Surname" VARCHAR(50) NOT NULL,
    "Email" VARCHAR(50) UNIQUE NOT NULL,
    "Password" VARCHAR(8) NOT NULL,
    "PhoneNo" VARCHAR(15),
    CONSTRAINT "UsersPK" PRIMARY KEY("UserID"),
    CONSTRAINT "EmailUnique" UNIQUE("Email")
	);
	
	CREATE TABLE "public"."AdminUser" (
	"AdminPrivileges" VARCHAR(50),
	"PermissionLevel" INTEGER(5) NOT NULL,
	CONSTRAINT "AdminUserPK" PRIMARY KEY("UserID"),
	CONSTRAINT "AdminUserFK" FOREIGN KEY("UserID") REFERENCES "public"."Users"("UserID")
	ON DELETE CASCADE ON UPDATE CASCADE
	);
	
	CREATE TABLE "public"."RegularUser" (
	"RegularUserPrivileges" VARCHAR(50),
	"MembershipType" VARCHAR(10),
	CONSTRAINT "RegularUserPK" PRIMARY KEY("UserID"),
	CONSTRAINT "RegularUserFK" FOREIGN KEY("UserID") REFERENCES "public"."Users"("UserID")
	ON DELETE CASCADE ON UPDATE CASCADE
	);
	

	
	CREATE TABLE "public"."Reservations" (
    "ReservationID" SERIAL,
    "UserID" INTEGER NOT NULL,
    "PaymentID" INTEGER,
    "ReservationDate" DATE DEFAULT CURRENT_DATE,
    CONSTRAINT "ReservationsPK" PRIMARY KEY("ReservationID"),
    CONSTRAINT "ReservationsUserFK" FOREIGN KEY("UserID") REFERENCES "public"."Users"("UserID") 
    ON DELETE CASCADE ON UPDATE CASCADE

	);

	CREATE TABLE "public"."Locations" (
    "LocationID" SERIAL,
    "Name" VARCHAR(100) NOT NULL,
    "Country" VARCHAR(50) NOT NULL,
    "City" VARCHAR(50) NOT NULL,
    CONSTRAINT "LocationsPK" PRIMARY KEY("LocationID")
	);

	CREATE TABLE "public"."Payments" (
    "PaymentID" SERIAL,
    "ReservationID" INTEGER NOT NULL,
    "PaymentDate" DATE DEFAULT CURRENT_DATE,
    "PaymentMethod" VARCHAR(20) NOT NULL,
    "TotalAmount" MONEY NOT NULL,
    CONSTRAINT "PaymentsPK" PRIMARY KEY("PaymentID"),
    CONSTRAINT "PaymentsReservationFK" FOREIGN KEY("ReservationID") REFERENCES "public"."Reservations"("ReservationID") 
    ON DELETE CASCADE ON UPDATE CASCADE
	);

	CREATE TABLE "public"."Reviews" (
    "ReviewID" SERIAL,
    "UserID" INTEGER NOT NULL,
    "ReviewDate" DATE DEFAULT CURRENT_DATE,
    "ReviewText" TEXT NOT NULL,
    "ReviewType" VARCHAR(20) CHECK ("ReviewType" IN ('ReservationReview', 'LocationReview')),
    CONSTRAINT "ReviewsPK" PRIMARY KEY("ReviewID"),
    CONSTRAINT "ReviewsUserFK" FOREIGN KEY("UserID") REFERENCES "public"."Users"("UserID") 
    ON DELETE CASCADE ON UPDATE CASCADE
	);

	CREATE TABLE "public"."Transport" (
    "TransportID" SERIAL,
    "ReservationID" INTEGER NOT NULL,
    "Type" VARCHAR(50) NOT NULL,
    "DepartureTime" TIMESTAMP NOT NULL,
    CONSTRAINT "TransportPK" PRIMARY KEY("TransportID"),
    CONSTRAINT "TransportReservationFK" FOREIGN KEY("ReservationID") REFERENCES "public"."Reservations"("ReservationID") 
    ON DELETE CASCADE ON UPDATE CASCADE
	);

	CREATE TABLE "public"."Accommodation" (
    "AccommodationID" SERIAL,
    "ReservationID" INTEGER NOT NULL,
    "Type" VARCHAR(50) CHECK ("Type" IN ('Hotel', 'Hostel')),
    "Date" DATE NOT NULL,
    CONSTRAINT "AccommodationPK" PRIMARY KEY("AccommodationID"),
    CONSTRAINT "AccommodationReservationFK" FOREIGN KEY("ReservationID") REFERENCES "public"."Reservations"("ReservationID") 
    ON DELETE CASCADE ON UPDATE CASCADE
	);

	CREATE TABLE "public"."Hotels" (
    "HotelID" SERIAL,
    "AccommodationID" INTEGER NOT NULL,
    "HotelName" VARCHAR(100) NOT NULL,
    "StarRating" INTEGER CHECK ("StarRating" BETWEEN 1 AND 5),
    "Address" TEXT,
    CONSTRAINT "HotelsPK" PRIMARY KEY("HotelID"),
    CONSTRAINT "HotelsAccommodationFK" FOREIGN KEY("AccommodationID") REFERENCES "public"."Accommodation"("AccommodationID") 
    ON DELETE CASCADE ON UPDATE CASCADE
	;

	CREATE TABLE "public"."Hostels" (
    "HostelID" SERIAL,
    "AccommodationID" INTEGER NOT NULL,
    "HostelName" VARCHAR(100) NOT NULL,
    "Address" TEXT,
    CONSTRAINT "HostelsPK" PRIMARY KEY("HostelID"),
    CONSTRAINT "HostelsAccommodationFK" FOREIGN KEY("AccommodationID") REFERENCES "public"."Accommodation"("AccommodationID") 
    ON DELETE CASCADE ON UPDATE CASCADE
	);

	CREATE TABLE "public"."Activities" (
    "ActivityID" SERIAL,
    "ActivityName" VARCHAR(100) NOT NULL,
    "Description" TEXT,
    CONSTRAINT "ActivitiesPK" PRIMARY KEY("ActivityID")
	);


	CREATE TABLE "public"."TransportCompany" (
    "CompanyID" SERIAL,
    "TransportID" INTEGER NOT NULL,
    "CompanyName" VARCHAR(100) NOT NULL,
    "ContactInfo" TEXT,
    "Address" TEXT,
    CONSTRAINT "TransportCompanyPK" PRIMARY KEY("CompanyID"),
    CONSTRAINT "TransportCompanyFK" FOREIGN KEY("TransportID") REFERENCES "public"."Transport"("TransportID") 
    ON DELETE CASCADE ON UPDATE CASCADE	
	);

	CREATE TABLE "public"."ReservationReviews" (
    "ReviewID" INTEGER NOT NULL,
    "ReservationID" INTEGER NOT NULL,
    CONSTRAINT "ReservationReviewsPK" PRIMARY KEY("ReviewID"),
    CONSTRAINT "ReservationReviewsFK1" FOREIGN KEY("ReviewID") REFERENCES "public"."Reviews"("ReviewID") 
    ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "ReservationReviewsFK2" FOREIGN KEY("ReservationID") REFERENCES "public"."Reservations"("ReservationID") 
    ON DELETE CASCADE ON UPDATE CASCADE
	);

	CREATE TABLE "public"."LocationReviews" (
    "ReviewID" INTEGER NOT NULL,
    "LocationID" INTEGER NOT NULL,
    CONSTRAINT "LocationReviewsPK" PRIMARY KEY("ReviewID"),
    CONSTRAINT "LocationReviewsFK1" FOREIGN KEY("ReviewID") REFERENCES "public"."Reviews"("ReviewID") 
    ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "LocationReviewsFK2" FOREIGN KEY("LocationID") REFERENCES "public"."Locations"("LocationID") 
    ON DELETE CASCADE ON UPDATE CASCADE
	);

	CREATE TABLE "public"."Trips" (
    "TripID" SERIAL,
    "UserID" INTEGER NOT NULL,
    "Title" VARCHAR(100) NOT NULL,
    "StartDate" DATE NOT NULL,
    "EndDate" DATE NOT NULL,
    "TotalCost" MONEY NOT NULL,
    "ParticipantCount" INTEGER NOT NULL CHECK ("ParticipantCount" > 0),
    CONSTRAINT "TripsPK" PRIMARY KEY("TripID"),
    CONSTRAINT "TripsUserFK" FOREIGN KEY("UserID") REFERENCES "public"."Users"("UserID") 
    ON DELETE CASCADE ON UPDATE CASCADE
	);

	CREATE TABLE "public"."TripLocations" (
    "TripID" INTEGER NOT NULL,
    "LocationID" INTEGER NOT NULL,
    CONSTRAINT "TripLocationsPK" PRIMARY KEY("TripID", "LocationID"),
    CONSTRAINT "TripLocationsFK1" FOREIGN KEY("TripID") REFERENCES "public"."Trips"("TripID") 
    ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "TripLocationsFK2" FOREIGN KEY("LocationID") REFERENCES "public"."Locations"("LocationID") 
    ON DELETE CASCADE ON UPDATE CASCADE
	);

	CREATE TABLE "public"."TripActivities" (
    "TripID" INTEGER NOT NULL,
    "ActivityID" INTEGER NOT NULL,
    CONSTRAINT "TripActivitiesPK" PRIMARY KEY("TripID", "ActivityID"),
    CONSTRAINT "TripActivitiesFK1" FOREIGN KEY("TripID") REFERENCES "public"."Trips"("TripID") 
    ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "TripActivitiesFK2" FOREIGN KEY("ActivityID") REFERENCES  
	);

	CREATE TABLE "public"."Cities" (
    "LocationID" INTEGER NOT NULL,
    "CityName" VARCHAR(100) NOT NULL,
    "State" VARCHAR(100),
    CONSTRAINT "CitiesPK" PRIMARY KEY("LocationID"),
    CONSTRAINT "CitiesFK" FOREIGN KEY("LocationID") REFERENCES "public"."Locations"("LocationID") 
    ON DELETE CASCADE ON UPDATE CASCADE
	);

	CREATE TABLE "public"."Countries" (
    "LocationID" INTEGER NOT NULL,
    "CountryName" VARCHAR(100) NOT NULL,
    "Continent" VARCHAR(50),
    CONSTRAINT "CountriesPK" PRIMARY KEY("LocationID"),
    CONSTRAINT "CountriesFK" FOREIGN KEY("LocationID") REFERENCES "public"."Locations"("LocationID") 
    ON DELETE CASCADE ON UPDATE CASCADE
	);
