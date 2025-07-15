# Metric 1 General Hospital Comparison Analysis

SELECT *,
    RANK() OVER (PARTITION BY Measure_ID ORDER BY CAST(Score AS FLOAT)) AS Rank_Best,
    RANK() OVER (PARTITION BY Measure_ID ORDER BY CAST(Score AS FLOAT) DESC) AS Rank_Worst
FROM (
    SELECT
    Facility_Name,
    State,
    Measure_ID,
    Measure_Name,
    CAST(Score AS FLOAT) AS Score
FROM
    dbo.[TEC-Hospital]
WHERE
    Measure_ID IN ('ED_2_Strata_1', 'OP_18b', 'OP_18c', 'OP_22', 'OP_23')
    AND Score NOT IN ('Not Available', '', 'high', 'low', 'medium', 'very high')
) AS ranked_data

# Metric 2 Emergency Department Bottlenecks
# Correlation Between OP-22 and OP-18b/OP-18c Hospital Level

SELECT
    Facility_Name,
    State,
    MAX(CASE WHEN Measure_ID = 'OP_22' THEN CAST(Score AS FLOAT) END) AS OP_22,
    MAX(CASE WHEN Measure_ID = 'OP_18b' THEN CAST(Score AS FLOAT) END) AS OP_18b,
    MAX(CASE WHEN Measure_ID = 'OP_18c' THEN CAST(Score AS FLOAT) END) AS OP_18c
FROM
    dbo.[TEC-Hospital]
WHERE
    Measure_ID IN ('OP_22', 'OP_18b', 'OP_18c')
	AND Score NOT IN ('Not Available', '', 'high', 'low', 'medium', 'very high')
GROUP BY
    Facility_Name, State


# Correlation between ED_2 & OP_18B Hospital Level

SELECT
    Facility_Name,
    State,
    MAX(CASE WHEN Measure_ID = 'ED_2_Strata_1' THEN CAST(Score AS FLOAT) END) AS ED_2,
    MAX(CASE WHEN Measure_ID = 'OP_18b' THEN CAST(Score AS FLOAT) END) AS OP_18b
FROM
    dbo.[TEC-Hospital]
WHERE
    Measure_ID IN ('ED_2_Strata_1', 'OP_18b')
	AND Score NOT IN ('Not Available', '', 'high', 'low', 'medium', 'very high')
GROUP BY
    Facility_Name, State

# Metric 3 Regional Trends

# Average Wait Time by State (OP-18b & OP-18c)

SELECT
    State,
    Measure_ID,
    AVG(CAST(Score AS FLOAT)) AS Avg_Score
FROM
    DBO.[TEC-State]
WHERE
    Measure_ID IN ('OP_18b', 'OP_18c')
    AND TRY_CAST(Score AS FLOAT) IS NOT NULL
GROUP BY
    State, Measure_ID


# Patient Volumes By State

SELECT
    State,
	Measure_ID,
    SUM(CAST(Sample AS INT)) AS Total_Patients
FROM
    dbo.[TEC-Hospital]
WHERE
    Measure_ID IN ('OP_18b', 'OP_18c')
    AND Sample IS NOT NULL
	AND ISNUMERIC(Sample) = 1
GROUP BY
    State, Measure_ID
ORDER BY Total_Patients DESC

# Metric 4 Seasonal/Time-based Trends:

SELECT
    Facility_Name,
    Measure_ID,
    FORMAT(CAST([End_Date] AS DATE), 'yyyy') + '-Q' + 
        DATENAME(QUARTER, CAST([End_Date] AS DATE)) AS Reporting_Period,
    CAST(Score AS FLOAT) AS Score
FROM
    dbo.[TEC-Hospital]
WHERE
    Measure_ID IN ('ED_2', 'OP_18b', 'OP_18c', 'OP_22', 'OP_23')
    AND Score NOT IN ('Not Available', '')