DROP FUNCTION IF EXISTS FN_RenewReservation;

CREATE OR REPLACE FUNCTION FN_RenewReservation(
cell_name varchar,
exps int,
is_balance_reset_required boolean
)
RETURNS boolean AS
$$
DECLARE
	cell_id uuid;
	stff_id uuid;
	time_of_serve time;
	opened boolean;
BEGIN

cell_id := (SELECT "RefID" 
	    FROM "Cell"
	    WHERE "Code" = cell_name);
stff_id := (SELECT "HalfstuffRefID" 
	    FROM "Cell" 
	    WHERE "RefID" = cell_id);

IF (is_balance_reset_required = FALSE) THEN
BEGIN
	IF ((SELECT "IsOpen" FROM "Cell" WHERE "RefID" = cell_id) = FALSE) THEN
	opened := (SELECT FN_OpenPackage(cell_name)); END IF;

	UPDATE "Halfstuff"
	SET
		"Reserve" = "Reserve" + exps, 
		"Balance" = "Balance" - exps
	WHERE "RefID" = stff_id;
	
	UPDATE "Cell"
	SET
		"Balance" = (SELECT "Balance" FROM "Halfstuff" WHERE "RefID" = stff_id)
	WHERE "HalfstuffRefID" = stff_id;
	--COMMIT;
END; 

ELSE
BEGIN
	UPDATE "Halfstuff"
	SET
		"Balance" = "Balance" + "Reserve",
		"Reserve" = 0
	WHERE "RefID" = stff_id;
	
	UPDATE "Cell"
	SET "Balance" = (SELECT "Balance" FROM "Halfstuff" WHERE "RefID" = stff_id)
	WHERE "HalfstuffRefID" = stff_id;
	--COMMIT;
END; 
END IF;

--COMMIT;
RETURN TRUE;
EXCEPTION
	WHEN OTHERS THEN
	BEGIN
		--ROLLBACK;
		RETURN FALSE;
	END;

END $$LANGUAGE 'plpgsql';

IF (1 = 0)
SELECT * FROM FN_RenewReservation('A1_A3', 3, true);
