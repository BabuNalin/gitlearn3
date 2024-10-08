SELECT * FROM SALES_1;--SALES_ID, PRODUCT_ID, REGION_ID, SALES_TYPE, QUANTITY, SALES_DATE
SELECT * FROM PRODUCTS_1;--PRODUCT_ID, PRODUCT_NAME, CATEGORY, PRICE

SELECT * FROM 
(SELECT A.PRODUCT_NAME,TO_CHAR(B.SALES_DATE,'MON-YY')SALES_DATE,B.QUANTITY*A.PRICE TC_PRICE FROM PRODUCTS_1 A
JOIN SALES_1 B ON B.PRODUCT_ID=A.PRODUCT_ID)
PIVOT (SUM(TC_PRICE) FOR SALES_DATE IN ('JAN-23' JAN_23));

WITH CTE AS (
SELECT A.PRODUCT_NAME,TO_CHAR(B.SALES_DATE,'MON-YY')SALES_DATE,B.QUANTITY*A.PRICE TC_PRICE FROM PRODUCTS_1 A
JOIN SALES_1 B ON B.PRODUCT_ID=A.PRODUCT_ID
)
SELECT * FROM CTE 
PIVOT (SUM(TC_PRICE) FOR SALES_DATE IN ('JAN-23' JAN_23,'FEB-23' FEB_23))
UNION  
SELECT CAST ('TOTAL' AS NVARCHAR2(100))PRODUCT_NAME,SUM(JAN_23) JAN_23,SUM(FEB_23)FEB_23  FROM CTE 
PIVOT (SUM(TC_PRICE) FOR SALES_DATE IN ('JAN-23' JAN_23,'FEB-23' FEB_23));

SELECT A.PRODUCT_NAME,
SUM(CASE WHEN TO_CHAR(B.SALES_DATE,'MON-YY')='JAN-23' THEN B.QUANTITY*A.PRICE  END) JAN_23,
SUM(CASE WHEN TO_CHAR(B.SALES_DATE,'MON-YY')='FEB-23' THEN B.QUANTITY*A.PRICE  END) FEB_23,
SUM (B.QUANTITY*A.PRICE) GRAND_TOTAL
FROM PRODUCTS_1 A
JOIN SALES_1 B ON B.PRODUCT_ID=A.PRODUCT_ID AND  (TO_CHAR(B.SALES_DATE,'MON-YY')='JAN-23' OR TO_CHAR(B.SALES_DATE,'MON-YY')='FEB-23')
GROUP BY A.PRODUCT_NAME 
UNION ALL
SELECT CAST ('TOTAL' AS NVARCHAR2(100)) PRODUCT_NAME,
SUM(CASE WHEN TO_CHAR(B.SALES_DATE,'MON-YY')='JAN-23' THEN SUM(B.QUANTITY*A.PRICE)  END) JAN_23,
SUM(CASE WHEN TO_CHAR(B.SALES_DATE,'MON-YY')='FEB-23' THEN SUM(B.QUANTITY*A.PRICE)  END) FEB_23,
TO_NUMBER('0')
FROM PRODUCTS_1 A
JOIN SALES_1 B ON B.PRODUCT_ID=A.PRODUCT_ID
GROUP BY A.PRODUCT_NAME,TO_CHAR(B.SALES_DATE,'MON-YY')
;

SELECT 'TOTAL' PRODUCT_NAME,
SUM(CASE WHEN TO_CHAR(B.SALES_DATE,'MON-YY')='JAN-23' THEN SUM(B.QUANTITY*A.PRICE)  END) JAN_23,
SUM(CASE WHEN TO_CHAR(B.SALES_DATE,'MON-YY')='FEB-23' THEN SUM(B.QUANTITY*A.PRICE)  END) FEB_23
FROM PRODUCTS_1 A
JOIN SALES_1 B ON B.PRODUCT_ID=A.PRODUCT_ID
GROUP BY A.PRODUCT_NAME,TO_CHAR(B.SALES_DATE,'MON-YY') ;


WITH CTE AS (
SELECT A.PRODUCT_NAME,TO_CHAR(B.SALES_DATE,'MON-YY')SALES_DATE,B.QUANTITY*A.PRICE TC_PRICE FROM PRODUCTS_1 A
JOIN SALES_1 B ON B.PRODUCT_ID=A.PRODUCT_ID
)
SELECT PRODUCT_NAME,JAN_23, FEB_23,JAN_23+FEB_23 GD FROM CTE 
PIVOT (SUM(TC_PRICE) FOR SALES_DATE IN ('JAN-23' JAN_23,'FEB-23' FEB_23))
UNION  
SELECT CAST ('TOTAL' AS NVARCHAR2(100))PRODUCT_NAME,SUM(JAN_23) JAN_23,SUM(FEB_23)FEB_23 ,SUM(JAN_23)+SUM(FEB_23) G_D FROM CTE 
PIVOT (SUM(TC_PRICE) FOR SALES_DATE IN ('JAN-23' JAN_23,'FEB-23' FEB_23));

WITH CTE AS (
SELECT NVL(A.PRODUCT_NAME,'TOTAL') PRODUCT_NAME,NVL(TO_CHAR(B.SALES_DATE,'MON-YY'),'GRAND_TOTAL')SALES_DATE,SUM(B.QUANTITY*A.PRICE) TC_PRICE FROM PRODUCTS_1 A
JOIN SALES_1 B ON B.PRODUCT_ID=A.PRODUCT_ID AND TO_CHAR(B.SALES_DATE,'MON-YY') IN ('JAN-23','FEB-23')
GROUP BY CUBE(A.PRODUCT_NAME,TO_CHAR(B.SALES_DATE,'MON-YY'))
),
CTE2 AS(
SELECT PRODUCT_NAME,JAN_23, FEB_23,GRAND_TOTAL FROM CTE 
PIVOT (SUM(TC_PRICE) FOR SALES_DATE IN ('JAN-23' JAN_23,'FEB-23' FEB_23,'GRAND_TOTAL' GRAND_TOTAL)))
SELECt * FROM CTE2 ORDER BY 1;