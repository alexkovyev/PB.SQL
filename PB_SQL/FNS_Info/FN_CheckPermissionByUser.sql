DROP FUNCTION IF EXISTS FN_CheckPermissionByUser;

CREATE OR REPLACE FUNCTION FN_CheckPermissionByUser(
	securityObjectID int, 
	userRefID uuid,
	permissionValue bigint
)
RETURNS boolean AS 
$$ 
DECLARE 
	isallow boolean;
BEGIN

	IF (securityObjectID is null OR
	   	userRefID is null OR
	   	permissionValue is null) THEN
		RETURN false;
	END IF;
	
	SELECT
		(P."Permissions" & permissionValue) = permissionValue
	INTO isallow
	FROM "Permissions" P
		INNER JOIN "UserProfile" UP
			ON UP."RoleRefID" = P."RoleRefID"
		INNER JOIN "Users" U
			ON U."RefID" = UP."UserRefID"
	WHERE 
		P."SecurityObjectID" = securityObjectID AND
		U."RefID" = userRefID
	FOR UPDATE;
		
	IF (isallow is null) THEN
		RETURN false;
	END IF;
	
	RETURN isallow;
		
END $$ LANGUAGE 'plpgsql';






