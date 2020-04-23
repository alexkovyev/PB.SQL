DROP FUNCTION IF EXISTS FN_CheckPermissionByRole;

CREATE OR REPLACE FUNCTION FN_CheckPermissionByRole(
	securityObjectID int, 
	roleRefID uuid,
	permissionValue bigint
)
RETURNS boolean AS 
$$ 
DECLARE 
	isallow boolean;
BEGIN

	IF (securityObjectID is null OR
	   	roleRefID is null OR
	   	permissionValue is null) THEN
		RETURN false;
	END IF;
	
	SELECT
		(P."Permissions" & permissionValue) = permissionValue
	INTO isallow
	FROM "Permissions" P
	WHERE 
		P."SecurityObjectID" = securityObjectID AND
		P."RoleRefID" = roleRefID
	FOR UPDATE;
	
	IF (isallow is null) THEN
		RETURN false;
	END IF;
		
	RETURN isallow;
		
END $$ LANGUAGE 'plpgsql';









