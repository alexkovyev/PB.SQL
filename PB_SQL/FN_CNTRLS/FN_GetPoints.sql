DROP FUNCTION IF EXISTS FN_GetPoints;

CREATE OR REPLACE FUNCTION FN_GetPoints(
    cntrlname character varying,
	userprofilerefid uuid
)
RETURNS TABLE (
	ui_name character varying,
	id integer,
	enabled boolean
) AS
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
			RETURN;
		END IF;
	END IF;
	
	RETURN QUERY
	with outpoints(ui_name_xml, outpoint_xml) as (
		select 
			xpath('//UI_Name/text()', "ExtendedParams"),
			unnest(xpath('//Point', "ExtendedParams"))
		from "Controllers"
		where "Name" = cntrlname
	)
	select 
		unnest(ui_name_xml)::character varying as ui_name,
		(unnest(xpath('//@id', outpoint_xml))::character varying)::integer as id,
		(unnest(xpath('//@enabled', outpoint_xml))::character varying)::boolean as enabled
	from outpoints
	order by ui_name;

END $$ LANGUAGE 'plpgsql';

IF (1 = 0) THEN
    SELECT *
    FROM FN_GetPoints('OutPointCNTRL');
END IF;