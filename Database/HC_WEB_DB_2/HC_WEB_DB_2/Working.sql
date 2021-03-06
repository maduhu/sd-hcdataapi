	-- audit table
	SELECT * FROM ETL_Audit;
	
	-- indicators without indicator table
	SELECT ID, varCode
	FROM [HC_DB_WEB_2].[dbo].indicator_metadata
	WHERE varCode NOT IN(SELECT TABLE_NAME FROM INFORMATION_SCHEMA.COLUMNS)
	ORDER BY varCode

	-- tables without indicator metadata
	SELECT DISTINCT TABLE_NAME 
	FROM INFORMATION_SCHEMA.COLUMNS	
	WHERE TABLE_NAME NOT IN(SELECT varCode
	FROM [HC_DB_WEB_2].[dbo].indicator_metadata) 
	AND TABLE_NAME NOT IN ('CELL5M', 'CELL_VALUES', 'CELL_VALUES_old', 
				'classification', 'collection', 'collection_group', 'continuous_classification',
				'country','country_collection','discrete_classification','domain_country_results',
				'domain_variable','drupal_metadata','indicator_metadata','schema','schema_domain',
				'Variable_Inventory','GAUL_2008_0','GAUL_2012_0','ETL_Audit','indicator_metadata_old',
				'indicator_metadata_r2','tmp_build_cell_values','vCountryList','domain_6_MarketAccess')
	AND TABLE_NAME NOT IN (SELECT DISTINCT [column_name] FROM [domain_variable])
	ORDER BY TABLE_NAME


-- Checks
SELECT COUNT(ID) FROM [HC_DB_WEB_2].dbo.CELL_VALUES;
SELECT DISTINCT column_name FROM [HC_DB_WEB_2].dbo.CELL_VALUES order by column_name;
SELECT SUM(CAST(value as float)) FROM [HC_DB_WEB_2].dbo.CELL_VALUES WHERE column_name = 'AN05_TLU';
SELECT COUNT(CELL5M) FROM CELL5M

SELECT CAST(value as float) FROM CELL_VALUES
WHERE column_name = 'AREA_TOTAL'

SELECT COUNT(CELL5M) as ct, column_name
FROM CELL_VALUES
GROUP BY column_name
ORDER BY ct DESC

SELECT cm.CELL5M, value
FROM CELL5M cm
LEFT JOIN CELL_VALUES cv
ON CM.CELL5M = cv.CELL5M
WHERE column_name = 'AREA_WBODY'


SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DROP TABLE #tmpCELL_VALUES

CREATE TABLE #tmpCELL_VALUES ( CELL5M INT NOT NULL PRIMARY KEY);

INSERT INTO #tmpCELL_VALUES (CELL5M) SELECT CELL5M FROM CELL5M;

ALTER TABLE #tmpCELL_VALUES ADD AREA_WBODY float;

UPDATE #tmpCELL_VALUES SET AREA_WBODY = CAST(value as float) FROM CELL_VALUES as CV WITH (NOLOCK) 
		WHERE CV.column_name = 'AREA_WBODY' AND CV.CELL5M = #tmpCELL_VALUES.CELL5M;

select * from  #tmpCELL_VALUES

USE HC_DB_WEB_2
GO
SELECT * INTO AREA_WBODY FROM (SELECT CELL5M,CAST(value as float) as AREA_WBODY FROM CELL_VALUES as CV WITH (NOLOCK) 
		WHERE CV.column_name = 'AREA_WBODY') AS foo

-- Create new non-clustered index
USE [HC_DB_WEB_2]
GO
CREATE NONCLUSTERED INDEX AREA_WBODY_idx ON [dbo].AREA_WBODY (
	AREA_WBODY ASC
)
INCLUDE ([CELL5M]) WITH (SORT_IN_TEMPDB = ON)
GO

USE HC_DB_WEB_2
GO
SELECT * INTO AREA_TOTAL FROM (SELECT CELL5M,CAST(value as float) as AREA_TOTAL FROM CELL_VALUES as CV WITH (NOLOCK) 
		WHERE CV.column_name = 'AREA_TOTAL') AS foo

		-- Create new non-clustered index
USE [HC_DB_WEB_2]
GO
CREATE NONCLUSTERED INDEX AREA_TOTAL_idx ON [dbo].AREA_TOTAL (
	AREA_TOTAL ASC
)
INCLUDE ([CELL5M]) WITH (SORT_IN_TEMPDB = ON)
GO


USE HC_DB_WEB_2
GO
SELECT * INTO PN05_TOT FROM (SELECT CELL5M,CAST(value as float) as PN05_TOT FROM CELL_VALUES as CV WITH (NOLOCK) 
		WHERE CV.column_name = 'PN05_TOT') AS foo

		-- Create new non-clustered index
USE [HC_DB_WEB_2]
GO
CREATE NONCLUSTERED INDEX PN05_TOT_idx ON [dbo].PN05_TOT (
	PN05_TOT ASC
)
INCLUDE ([CELL5M]) WITH (SORT_IN_TEMPDB = ON)
GO
USE HC_DB_WEB_2
GO
SELECT * INTO PN05_URB FROM (SELECT CELL5M,CAST(value as float) as PN05_URB FROM CELL_VALUES as CV WITH (NOLOCK) 
		WHERE CV.column_name = 'PN05_URB') AS foo

		-- Create new non-clustered index
USE [HC_DB_WEB_2]
GO
CREATE NONCLUSTERED INDEX PN05_URB_idx ON [dbo].PN05_URB (
	PN05_URB ASC
)
INCLUDE ([CELL5M]) WITH (SORT_IN_TEMPDB = ON)
GO

SELECT CELL5M.CELL5M, AREA_WBODY.AREA_WBODY, AREA_TOTAL.AREA_TOTAL,PN05_TOT.PN05_TOT,PN05_URB.PN05_URB
FROM CELL5M 
LEFT OUTER JOIN AREA_WBODY
ON AREA_WBODY.CELL5M = CELL5M.CELL5M
LEFT OUTER JOIN AREA_TOTAL
ON AREA_TOTAL.CELL5M = CELL5M.CELL5M
LEFT OUTER JOIN PN05_TOT
ON PN05_TOT.CELL5M = CELL5M.CELL5M
LEFT OUTER JOIN PN05_URB
ON PN05_URB.CELL5M = CELL5M.CELL5M



SELECT CASE WHEN AEZ_CODE = 311 THEN 'Arid' WHEN AEZ_CODE = 314 THEN 'Humid' WHEN AEZ_CODE = 312 THEN 'Semi-Arid' WHEN AEZ_CODE = 315 THEN 'Arid' WHEN AEZ_CODE = 313 THEN 'Sub-Humid' WHEN AEZ_CODE = 321 THEN 'Tropical Highlands' WHEN AEZ_CODE = 322 THEN 'Tropical Highlands' WHEN AEZ_CODE = 323 THEN 'Tropical Highlands' WHEN AEZ_CODE = 324 THEN 'Tropical Highlands' END AS 'AEZ_CODE'
,CASE WHEN AEZ_CODE = 311 THEN '1' WHEN AEZ_CODE = 314 THEN '4' WHEN AEZ_CODE = 312 THEN '2' WHEN AEZ_CODE = 315 THEN '1' WHEN AEZ_CODE = 313 THEN '3' WHEN AEZ_CODE = 321 THEN '5' WHEN AEZ_CODE = 322 THEN '5' WHEN AEZ_CODE = 323 THEN '5' WHEN AEZ_CODE = 324 THEN '5' END AS 'sortorder_AEZ_CODE'
,ROUND(SUM(AREA_TOTAL), 2, 1) AS 'AREA_TOTAL' 
FROM (SELECT CELL5M.CELL5M,AEZ_CODE,AREA_TOTAL FROM CELL5M  LEFT OUTER JOIN AEZ_CODE ON AEZ_CODE.CELL5M = CELL5M.CELL5M LEFT OUTER JOIN AREA_TOTAL ON AREA_TOTAL.CELL5M = CELL5M.CELL5M) AS CELL_VALUES  
WHERE (AEZ_CODE = 311 OR AEZ_CODE = 314 OR AEZ_CODE = 312 OR AEZ_CODE = 315 OR AEZ_CODE = 313 OR AEZ_CODE = 321 OR AEZ_CODE = 322 OR AEZ_CODE = 323 OR AEZ_CODE = 324) GROUP BY CASE WHEN AEZ_CODE = 311 THEN 'Arid' WHEN AEZ_CODE = 314 THEN 'Humid' WHEN AEZ_CODE = 312 THEN 'Semi-Arid' WHEN AEZ_CODE = 315 THEN 'Arid' WHEN AEZ_CODE = 313 THEN 'Sub-Humid' WHEN AEZ_CODE = 321 THEN 'Tropical Highlands' WHEN AEZ_CODE = 322 THEN 'Tropical Highlands' WHEN AEZ_CODE = 323 THEN 'Tropical Highlands' WHEN AEZ_CODE = 324 THEN 'Tropical Highlands'END,CASE WHEN AEZ_CODE = 311 THEN '1' WHEN AEZ_CODE = 314 THEN '4' WHEN AEZ_CODE = 312 THEN '2' WHEN AEZ_CODE = 315 THEN '1' WHEN AEZ_CODE = 313 THEN '3' WHEN AEZ_CODE = 321 THEN '5' WHEN AEZ_CODE = 322 THEN '5' WHEN AEZ_CODE = 323 THEN '5' WHEN AEZ_CODE = 324 THEN '5'END ORDER BY 'sortorder_AEZ_CODE'

SELECT CELL5M.CELL5M,AEZ_CODE,AREA_TOTAL 
FROM CELL5M  
LEFT OUTER JOIN AEZ_CODE 
ON AEZ_CODE.CELL5M = CELL5M.CELL5M 
LEFT OUTER JOIN AREA_TOTAL 
ON AREA_TOTAL.CELL5M = CELL5M.CELL5M
