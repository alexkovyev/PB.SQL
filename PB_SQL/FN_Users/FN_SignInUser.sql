DROP FUNCTION IF EXISTS FN_SignInUser;

CREATE OR REPLACE FUNCTION FN_SignInUser(
	username character varying,
	pwd character varying
)
RETURNS TABLE (
	userRefID uuid,
	userFN character varying,
	userSN character varying,
	userLN character varying,
	userEmail character varying,
	userPhone character varying,
	roleName character varying,
	pages character varying[],
	userProfileRefID uuid
) AS 
$$ BEGIN
	RETURN QUERY SELECT 
		U."RefID" as "userRefID",
		U."FirstName" as "userFN",
		U."SecondName" as "userSN", 
		U."LastName" as "userLN",
		U."Email" as "userEmail",
		U."Phone" as "userPhone",
		RL."Name" as "roleName",
		(
			SELECT 
				array_agg(SO."Name")
			FROM "SecurityObjects" SO
			WHERE 
				(
					FN_CheckPermissionByRole(SO."SecurityObjectID", RL."RefID", 1) = true OR
					FN_CheckPermissionByRole(SO."SecurityObjectID", RL."RefID", 2) = true OR
					FN_CheckPermissionByRole(SO."SecurityObjectID", RL."RefID", 4) = true
				) AND
				SO."Description" = 'Page'
		),
		UP."RefID"
	FROM "Users" U
		INNER JOIN "UserProfile" UP 
			ON UP."UserRefID" = U."RefID"
		INNER JOIN "Roles" RL
			ON UP."RoleRefID" = RL."RefID"
	WHERE 
		FN_DecryptPassword(pwd, U."PasswordHash") = true AND
		U."Phone" = username
	FOR UPDATE;

END $$ LANGUAGE 'plpgsql';





