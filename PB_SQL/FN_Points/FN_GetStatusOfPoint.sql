DROP FUNCTION IF EXISTS FN_GetStatusOfPoint;

CREATE OR REPLACE FUNCTION FN_GetStatusOfPoint(
    address character varying,
	userProfileRefID uuid
)
RETURNS character varying AS
$$ 
DECLARE 
	turningstatus character varying;
	isallowhardreload boolean;
BEGIN
	
	turningstatus := (
		SELECT 
			PC."TurningStatus"
		FROM "Point" PC
		WHERE
			PC."Address" = address
	);
	
	IF (turningstatus = 'OFF AFTER CRITICAL ERROR') THEN
		-- this is allow user to hard reload system
		isallowhardreload = FN_CheckPermissionByUserProfile(4, userProfileRefID, 8);
		
		IF (isallowhardreload = false) THEN
			turningstatus = 'LATER';
		END IF;
	END IF;
	
	RETURN turningstatus;

END $$ LANGUAGE 'plpgsql';





