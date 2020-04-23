DROP FUNCTION IF EXISTS FN_CheckPermissionByUserProfile;

CREATE OR REPLACE FUNCTION FN_CheckPermissionByUserProfile(
	securityObjectID int, 
	userProfileRefID uuid,
	permissionValue bigint
)
RETURNS boolean AS 
$$ 
DECLARE 
	isallow boolean;
BEGIN

	IF (securityObjectID is null OR
	   	userProfileRefID is null OR
	   	permissionValue is null) THEN
		RETURN false;
	END IF;
	
	SELECT
		(P."Permissions" & permissionValue) = permissionValue
	INTO isallow
	FROM "Permissions" P
		INNER JOIN "UserProfile" UP
			ON UP."RoleRefID" = P."RoleRefID"
	WHERE 
		P."SecurityObjectID" = securityObjectID AND
		UP."RefID" = userProfileRefID
	FOR UPDATE;
	
	IF (isallow is null) THEN
		RETURN false;
	END IF;
	
	RETURN isallow;
		
END $$ LANGUAGE 'plpgsql';








