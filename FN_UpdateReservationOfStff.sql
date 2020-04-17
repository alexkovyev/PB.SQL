DROP FUNCTION IF EXISTS FN_UpdateReservationOfStff;

CREATE OR REPLACE FUNCTION FN_UpdateReservationOfStff
(
	stffRefID uuid,
	exps int,
	is_return_reserve boolean
)
RETURNS boolean AS
$$
BEGIN 
  IF (is_return_reserve = true) THEN
    UPDATE "Halfstuff"
    SET "Reserve" = "Reserve" - exps,
	"Balance" = "Balance" + exps
	WHERE "RefID" = stffRefID;
  ELSIF (is_return_reserve = false) THEN
    UPDATE "Halfstuff"
    SET "Reserve" = "Reserve" - exps
	WHERE "RefID" = stffRefID;
  END IF;		
  RETURN true;
  COMMIT;
  RETURN false;
  ROLLBACK;
END $$ LANGUAGE 'plpgsql';

IF (1 = 0) THEN
	SELECT * 
	FROM FN_UpdateReservationOfStff('21f9f975-6838-11ea-8fdb-001d6001edc0', 1, false);
END IF;