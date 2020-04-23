DROP FUNCTION IF EXISTS FN_GetPointStatistics;

CREATE OR REPLACE FUNCTION FN_GetPointStatistics(
	point_refid uuid
)
RETURNS TABLE (
	numberoforderstoday integer,
	numberofordersnow integer,
	numberoferrors integer,
	numberofunavailabledishes integer
) AS
$$ 
DECLARE 
	numberoforderstoday integer := 0;
	numberofordersnow integer := 0;
	numberofunavailabledishes integer := 0;
	numberoferrors integer := 0;
BEGIN
	
	numberofordersnow := (
		SELECT 
			COUNT(1)
		FROM "Order"
		WHERE 
			"State" != 'Ready' AND
<<<<<<< HEAD
			date_part('day', "OrderDateTime") = date_part('day', NOW()) AND
			date_part('month', "OrderDateTime") = date_part('month', NOW()) AND
			date_part('year', "OrderDateTime") = date_part('year', NOW())
=======
			"OrderDateTime"::date = NOW()::date
			
>>>>>>> 07c01a5e5145c25a8700cd9e13ba5ed6e3a33f44
	);
	
	numberoforderstoday := (
		SELECT 
			COUNT(1)
		FROM "Order"
		WHERE
			"State" = 'Ready' AND
<<<<<<< HEAD
			date_part('day', "OrderDateTime") = date_part('day', NOW()) AND
			date_part('month', "OrderDateTime") = date_part('month', NOW()) AND
			date_part('year', "OrderDateTime") = date_part('year', NOW())
=======
			"OrderDateTime"::date = NOW()::date
>>>>>>> 07c01a5e5145c25a8700cd9e13ba5ed6e3a33f44
	);
	
	numberoferrors := (
		SELECT 
			COUNT(1)
		FROM "ClientSideLogs"
		WHERE 
			"IsError" = true AND
<<<<<<< HEAD
			date_part('day', "created_dt") = date_part('day', NOW()) AND
			date_part('month', "created_dt") = date_part('month', NOW()) AND
			date_part('year', "created_dt") = date_part('year', NOW())
=======
			"created_dt"::date = NOW()::date
>>>>>>> 07c01a5e5145c25a8700cd9e13ba5ed6e3a33f44
	);
	
	numberofunavailabledishes := 
	(
		SELECT 
			COUNT(1)
		FROM "Dough" D
		WHERE 
			FN_CheckAvailablityOfSTFF('dough', D."RefID") = true AND
			FN_CheckAvailablityOfSTFF('paper', null) = true
	) +
	(
		SELECT 
			COUNT(1)
		FROM "Sauce" S
		WHERE 
			FN_CheckAvailablityOfSTFF('sauce', S."RefID") = true AND
			FN_CheckAvailablityOfSTFF('paper', null) = true
	) +
	(
		SELECT 
			COUNT(1)
		FROM "Additive" ADVE
		WHERE 
			FN_CheckAvailablityOfSTFF('additive', ADVE."RefID") = true AND
			FN_CheckAvailablityOfSTFF('paper', null) = true
	) +
	(
		SELECT 
			COUNT(1)
		FROM "Filling" FLNG
		WHERE 
			FN_CheckAvailablityOfSTFF('filling', FLNG."RefID") = true AND
			FN_CheckAvailablityOfSTFF('paper', null) = true
	) +
	(
		SELECT 
			COUNT(1)
		FROM "Dish" DSH
		WHERE  
			DSH."IsCustomDish" = false AND
			FN_CheckAvailablityOfSTFF('dough', DSH."DoughRefID") = true AND
			FN_CheckAvailablityOfSTFF('sauce', DSH."SauceRefID") = true AND
			FN_CheckAvailablityOfSTFF('filling', DSH."FillingRefID") = true AND
			FN_CheckAvailablityOfSTFF('additive', DSH."AdditiveRefID") = true AND
			FN_CheckAvailablityOfSTFF('paper', null) = true
	);
	
	RETURN QUERY SELECT 
		numberoforderstoday, 
		numberofordersnow,
		numberoferrors,
		numberofunavailabledishes;

END $$ LANGUAGE 'plpgsql';




