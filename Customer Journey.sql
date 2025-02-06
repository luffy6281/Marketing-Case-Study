-- Common Table Expression (CTE) to identify and tag duplicate records

WITH DuplicateRecords AS (
    SELECT 
        JourneyID,        -- Select the unique identifier for each journey (and any other columns you want to include in the final result set)
        CustomerID,        -- Select the unique identifier for each customer
        ProductID,          -- Select the unique identifier for each product
        VisitDate,         
        Stage,             
        Action,            
        Duration,            
       
       
        ROW_NUMBER() OVER (PARTITION BY CustomerID, ProductID, VisitDate, Stage, Action  
            ORDER BY JourneyID) AS row_num  
  
    FROM 
        dbo.customer_journey -- Specifies the source table from which to select the data
)

  
-- Select all records from the CTE where row_num > 1, which indicates duplicate entries
    
SELECT *
FROM DuplicateRecords
-- WHERE row_num > 1  
ORDER BY JourneyID

  
-- Outer query selects the final cleaned and standardized data
    
SELECT 
    JourneyID,  
    CustomerID,  
    ProductID,  
    VisitDate, 
    Stage,  
    Action, 
    COALESCE(Duration, avg_duration) AS Duration  -- Replaces missing durations with the average duration for the corresponding date
FROM 
    (
        SELECT 
            JourneyID,
            CustomerID,  
            ProductID,  
            VisitDate,  
            UPPER(Stage) AS Stage, 
            Action,  
            Duration, 
            AVG(Duration) OVER (PARTITION BY VisitDate) AS avg_duration,  -- Calculates the average duration for each date, using only numeric values
            ROW_NUMBER() OVER (
                PARTITION BY CustomerID, ProductID, VisitDate, UPPER(Stage), Action
                ORDER BY JourneyID 
            ) AS row_num 
        FROM 
            dbo.customer_journey 
    ) AS subquery  
WHERE 
    row_num = 1; 
