DROP FUNCTION IF EXISTS FN_UpdPoints;

CREATE OR REPLACE FUNCTION FN_UpdPoints(
    cntrlname character varying,
	pointid integer,
	enabled boolean,
    execby character varying,
	userprofilerefid uuid
)
RETURNS boolean AS
$$ 
DECLARE 
	isallow boolean;
BEGIN
	IF (cntrlname = 'OvenPointCNTRL') THEN
		isallow = (
			FN_CheckPermissionByUserProfile(14, userprofilerefid, 1) OR
			FN_CheckPermissionByUserProfile(14, userprofilerefid, 8)
		);
		
		IF (isallow = false) THEN
			RETURN 0;
		END IF;
	END IF;

	UPDATE "Controllers"
	SET
		"ExtendedParams" = xml(REPLACE(
			"ExtendedParams"::text,
			data.from_change,
			data.to_change
		)),
        "updated_by" = execby,
        "updated_dt" = NOW()
	FROM 
		(
			select
				"RefID",
				unnest(xpath(CONCAT('//Point[@id = ''', pointid, ''']'), "ExtendedParams"))::text,
				REPLACE(
					unnest(xpath(CONCAT('//Point[@id = ''', pointid, ''']'), "ExtendedParams"))::text,
					CONCAT(
						'enabled="',
						unnest(xpath(CONCAT('//Point[@id = ''', pointid, ''']/@enabled'), "ExtendedParams"))::text,
						'"'
					),
					CONCAT(
						'enabled="',
						enabled,
						'"'
					)
				)
			from "Controllers"
			where 
				"Name" = cntrlname AND
				xmlexists(CONCAT('//Point[@id = ''', pointid, ''']') PASSING by ref "ExtendedParams")
		) as data(refid, from_change, to_change)
	WHERE
		"RefID" = data.refid;

    RETURN 1;
	COMMIT;
END $$ LANGUAGE 'plpgsql';