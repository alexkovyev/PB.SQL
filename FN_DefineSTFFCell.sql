DROP FUNCTION IF EXISTS FN_DefineSTFFCell;

CREATE OR REPLACE FUNCTION FN_DefineSTFFCell(
stff_id uuid
)
RETURNS varchar AS
$$
DECLARE
	c character varying(50);
BEGIN
	c = (SELECT "Code"
	 	FROM "Cell" CLL
			INNER JOIN "Halfstuff" STFF
	     			ON CLL."HalfstuffRefID" = STFF."RefID"
		WHERE CLL."IsOpen" = TRUE AND STFF."RefID" = stff_id
		ORDER BY CLL."ServeTime" DESC
		LIMIT 1);
	IF (c IS NULL) THEN 
	BEGIN
		c = (SELECT "Code"
		FROM "Cell" CLL
			INNER JOIN "Halfstuff" STFF
				ON CLL."HalfstuffRefID" = STFF."RefID"
		WHERE CLL."IsOpen" = FALSE AND STFF."RefID" = stff_id
		ORDER BY CLL."ServeTime" DESC
		LIMIT 1); 
	END;
	END IF;

--COMMIT;
RETURN c;
EXCEPTION
	WHEN OTHERS THEN
	BEGIN
		--ROLLBACK;
		RETURN 'Cell not found';
	END;

END $$LANGUAGE 'plpgsql';

IF (1 = 0)
SELECT * FROM FN_DefineSTFFCell('21f9f975-6838-11ea-8fdb-001d6001edc0');
