--------------------------------------------------------------------------------
-- Total sales per promotion
--------------------------------------------------------------------------------
select 
    p.PromotionKey, p.EnglishPromotionName, SalesAmount
from 
    DimPromotion p,
    (select s.PromotionKey, sum(SalesAmount) SalesAmount from FactInternetSales s where PromotionKey != 1 group by s.PromotionKey) s
where 
    p.PromotionKey = s.PromotionKey
order 
    by p.PromotionKey;

--------------------------------------------------------------------------------
-- The number of finance records where the amount is more than the average amount
--------------------------------------------------------------------------------
select 
    count(*) 
from 
    FactFinance 
where 
    Amount > (select avg(amount) from FactFinance);

--------------------------------------------------------------------------------
-- Product categories for surveys received from German customers in 4th quarter
--  of 2002
--------------------------------------------------------------------------------
select 
    distinct City, StateProvinceName, DimProductCategory.EnglishProductCategoryName 
from 
    FactSurveyResponse, DimCustomer, DimProductCategory, DimDate, DimGeography
where 
    FactSurveyResponse.CustomerKey = DimCustomer.CustomerKey and
    FactSurveyResponse.ProductCategoryKey = DimProductCategory.ProductCategoryKey and
    FactSurveyResponse.DateKey = DimDate.DateKey and
    DimCustomer.GeographyKey = DimGeography.GeographyKey and
    CountryRegionCode = 'DE' and
    CalendarYear = 2002 and
    CalendarQuarter = 4
order by 
    StateProvinceName, City, EnglishProductCategoryName;

--------------------------------------------------------------------------------
-- Prospective buyers in Minnesota where the same occupation is not found 
-- between individuals with different marital status
--------------------------------------------------------------------------------
select 
    distinct MaritalStatus, Occupation 
from 
    ProspectiveBuyer b1 
where 
    MaritalStatus = 'M' 
    and StateProvinceCode = 'MN' 
    and not exists (select * from ProspectiveBuyer b2 where MaritalStatus = 'S' and StateProvinceCode = 'MN' and b1.Occupation = b2.Occupation)
union
select
    distinct MaritalStatus, Occupation 
from 
    ProspectiveBuyer b1 
where 
    MaritalStatus = 'S' 
    and StateProvinceCode = 'MN' 
    and not exists (select * from ProspectiveBuyer b2 where MaritalStatus = 'M' and StateProvinceCode = 'MN' and b1.Occupation = b2.Occupation);

--------------------------------------------------------------------------------
-- Geographies for each customer, including geographies without any customer
--------------------------------------------------------------------------------
select 
    * 
from 
    DimGeography g 
    left join DimCustomer c 
        on g.GeographyKey = c.GeographyKey;

--------------------------------------------------------------------------------
-- Top 3 quotas applied to every sales person
--------------------------------------------------------------------------------
select 
    FirstName, LastName, SalesAmountQuota 
from 
    DimEmployee, (select top 3 SalesAmountQuota from FactSalesQuota order by SalesAmountQuota desc) t2
where 
    SalesPersonFlag = 1
order by 
    LastName, FirstName, SalesAmountQuota desc;
