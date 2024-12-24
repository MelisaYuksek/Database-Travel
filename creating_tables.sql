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
    "userid" INT SERIAL,
	"adminprivileges" VARCHAR(50),
    "permissionlevel" VARCHAR(5) NOT NULL
	 CONSTRAINT unique_admin_userid CHECK (
        NOT EXISTS (SELECT 1 FROM public.users WHERE users.userid = adminuser.userid)
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

CREATE OR REPLACE FUNCTION add_admin_user(
    p_userid INT,
    p_name VARCHAR(50),
    p_surname VARCHAR(50),
    p_email VARCHAR(50),
    p_password VARCHAR(255),
    p_phoneno VARCHAR(30),
    p_adminprivileges VARCHAR(50),
    p_permissionlevel VARCHAR(5)
)
RETURNS VOID AS $$
BEGIN
    -- Check if userid exists in the users table
    IF NOT check_userid_not_exists(p_userid) THEN
        RAISE EXCEPTION 'Cannot add admin user because the UserID % already exists.', p_userid;
    END IF;
    
    -- Insert into the adminuser table
    INSERT INTO public.adminuser (userid, name, surname, email, password, phoneno, adminprivileges, permissionlevel)
    VALUES (
        p_userid,
        p_name,
        p_surname,
        p_email,
        p_password,
        p_phoneno,
        p_adminprivileges,
        p_permissionlevel
    );
    
    -- Optionally, you can raise a notice for success
    RAISE NOTICE 'Admin user % % added successfully.', p_name, p_surname;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION delete_admin_user(p_userid INT)
RETURNS VOID AS $$
BEGIN
    -- Delete from the adminuser table using the provided userid
    DELETE FROM public.adminuser WHERE userid = p_userid;

    -- Optionally, raise a notice
    RAISE NOTICE 'Admin user with userid % deleted successfully.', p_userid;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION update_admin_user(
    p_userid INT,
    p_name VARCHAR(50),
    p_surname VARCHAR(50),
    p_email VARCHAR(50),
    p_password VARCHAR(255),
    p_phoneno VARCHAR(30),
    p_adminprivileges VARCHAR(50),
    p_permissionlevel VARCHAR(5)
)
RETURNS VOID AS $$
BEGIN
    -- Update the adminuser table based on the provided userid
    UPDATE public.adminuser
    SET
        name = p_name,
        surname = p_surname,
        email = p_email,
        password = p_password,
        phoneno = p_phoneno,
        adminprivileges = p_adminprivileges,
        permissionlevel = p_permissionlevel
    WHERE userid = p_userid;

    -- Optionally, raise a notice
    RAISE NOTICE 'Admin user with userid % updated successfully.', p_userid;
END;
$$ LANGUAGE plpgsql;

--------------TRIGGER 1----------------
-- Kullanıcı Ekleme Logu Trigger'ı

CREATE OR REPLACE FUNCTION log_user_addition()
RETURNS TRIGGER AS $$
BEGIN
    -- Yeni eklenen kullanıcının log kaydını ekliyoruz
    INSERT INTO public.user_logs (userid, action, action_date) 
    VALUES (NEW.userid, 'User Added', CURRENT_TIMESTAMP);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Kullanıcı ekleme sonrası log kaydını ekleyen Trigger

CREATE TRIGGER after_user_add
AFTER INSERT ON public.adminuser
FOR EACH ROW
EXECUTE FUNCTION log_user_addition();
---------------------------------------------
--------------TRIGGER 2----------------
CREATE OR REPLACE FUNCTION cascade_delete_reservation()
RETURNS TRIGGER AS $$
BEGIN
    -- Silinen rezervasyonun transport ve accommodation kayıtlarını da sil
    DELETE FROM public.transport WHERE reservationid = OLD.reservationid;
    DELETE FROM public.accommodation WHERE reservationid = OLD.reservationid;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER after_reservation_delete
AFTER DELETE ON public.reservations
FOR EACH ROW
EXECUTE FUNCTION cascade_delete_reservation();
---------------------------------------------



INSERT INTO public.users ("name", "surname", "email",  "password", "phoneno") 
VALUES ('Evvy', 'Bloom', 'ebloom0@360.cn', '+1 (185) 105-9530', 'aB1.@yD2h');

INSERT INTO public.adminuser ("userid","name", "surname", "email",  "password", "phoneno","adminprivileges","permissionlevel")
VALUES (1,'Evvy', 'Bloom', 'ebloom0@360.cn', '+1 (185) 105-9530', 'aB1.@yD2h','ITAccess',3);

INSERT INTO public.users (name, surname, email, password, phoneno)
VALUES ('John', 'Doe', 'johndoe@example.com', 'password123', '123456789');

INSERT INTO public.adminuser (userid, adminprivileges, permissionlevel)
VALUES (5, 'AllAccess', 'A1');

