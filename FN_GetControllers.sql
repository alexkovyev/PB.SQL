DROP FUNCTION IF EXISTS FN_GetControllers;

CREATE OR REPLACE FUNCTION FN_GetControllers(
	cntrlname character varying,
	userprofilerefid uuid
)
RETURNS TABLE (
	ui_name character varying,
	id integer,
	enabled boolean
) AS
$$ 
BEGIN
	RETURN QUERY
	SELECT * 
		FROM FN_GetPoints(cntrlname, userprofilerefid);		
	RETURN QUERY
		with outpoints(ui_name_xml) as (
			select 
				xpath('//UI_Name/text()', "ExtendedParams"),
				"IsActive"
			from "Controllers"
			where "Name" != 'OvenPointCNTRL'
		)
		select 
			unnest(ui_name_xml)::character varying as ui_name,
			-999 as id,
			"IsActive" as enabled
		from outpoints
		order by ui_name;

END $$ LANGUAGE 'plpgsql';


IF (1 = 0) THEN
	SELECT *
	    FROM FN_GetControllers('OvenPointCNTRL', '56d7706c-5fc7-11ea-aab5-001d6001edc0');
END IF;