-- finish adding comments

-- COGS FAQ view
-- I ran a SQL query which attempted to infer the COGS column from other columns. I did this to see if COGS was a redundant column
-- COGS is not a redundant column 

 SELECT "Lloyds_data"."COGS" / "Lloyds_data"."Units Sold" AS "COGS/Units Sold",
    "Lloyds_data"."COGS" / "Lloyds_data"."Units Sold" / "Lloyds_data"."Manufacturing Price"::double precision AS "COGS/Units Sold/Manufacturing Price",
    "Lloyds_data"."Manufacturing Price",
    "Lloyds_data"."COGS" / "Lloyds_data"."Manufacturing Price"::double precision AS "COGS/Manufacturing Price"
   FROM "Lloyds_data";

-- Date normalized view 

 SELECT "Lloyds_data"."Date",
    date_part('month'::text, "Lloyds_data"."Date") AS month_number,
    to_char("Lloyds_data"."Date", 'Month'::text) AS month_name,
    date_part('year'::text, "Lloyds_data"."Date") AS year
   FROM "Lloyds_data"
  ORDER BY "Lloyds_data"."Year", (date_part('month'::text, "Lloyds_data"."Date"));

-- Date normalized validated view 

 SELECT count(*) AS count
   FROM date_normalized d
     JOIN "Lloyds_data" ld ON d."Date" = ld."Date"
  WHERE d."Date" <> ld."Date" AND d.month_number <> ld."Month Number"::double precision AND d.month_name <> ld."Month Name" AND d.year <> ld."Year"::double precision;

-- Discount view

 SELECT "Lloyds_data"."Product",
    avg("Lloyds_data"."Discounts" / "Lloyds_data"."Gross Sales")::numeric(10,5) * 100::numeric AS averagediscountpercentage
   FROM "Lloyds_data"
  WHERE "Lloyds_data"."Discount Band" <> 'None'::text
  GROUP BY "Lloyds_data"."Product";

 -- Discount band view

  WITH cte1 AS (
         SELECT "Lloyds_data"."Discount Band",
            (min("Lloyds_data"."Discounts" / "Lloyds_data"."Gross Sales") * 100::double precision)::numeric(10,2) AS min_low,
            (max("Lloyds_data"."Discounts" / "Lloyds_data"."Gross Sales") * 100::double precision)::numeric(10,2) AS max_low
           FROM "Lloyds_data"
          WHERE "Lloyds_data"."Discount Band" = 'Low'::text
          GROUP BY "Lloyds_data"."Discount Band"
        ), cte2 AS (
         SELECT "Lloyds_data"."Discount Band",
            (min("Lloyds_data"."Discounts" / "Lloyds_data"."Gross Sales") * 100::double precision)::numeric(10,2) AS min_med,
            (max("Lloyds_data"."Discounts" / "Lloyds_data"."Gross Sales") * 100::double precision)::numeric(10,2) AS max_med
           FROM "Lloyds_data"
          WHERE "Lloyds_data"."Discount Band" = 'Medium'::text
          GROUP BY "Lloyds_data"."Discount Band"
        ), cte3 AS (
         SELECT "Lloyds_data"."Discount Band",
            (min("Lloyds_data"."Discounts" / "Lloyds_data"."Gross Sales") * 100::double precision)::numeric(10,2) AS min_high,
            (max("Lloyds_data"."Discounts" / "Lloyds_data"."Gross Sales") * 100::double precision)::numeric(10,2) AS max_high
           FROM "Lloyds_data"
          WHERE "Lloyds_data"."Discount Band" = 'High'::text
          GROUP BY "Lloyds_data"."Discount Band"
        )
 SELECT cte1."Discount Band",
    cte1.min_low,
    cte1.max_low
   FROM cte1
UNION ALL
 SELECT cte2."Discount Band",
    cte2.min_med AS min_low,
    cte2.max_med AS max_low
   FROM cte2
UNION ALL
 SELECT cte3."Discount Band",
    cte3.min_high AS min_low,
    cte3.max_high AS max_low
   FROM cte3;

-- No natural primary key view

 SELECT DISTINCT "Lloyds_data"."Segment",
    "Lloyds_data"."Country",
    "Lloyds_data"."Product",
    "Lloyds_data"."Date"
   FROM "Lloyds_data";

-- Product view 

 SELECT DISTINCT "Lloyds_data"."Product",
    "Lloyds_data"."Manufacturing Price"
   FROM "Lloyds_data";

-- Quarterly sale profits view 

 SELECT sum("Lloyds_data"." Sales")::numeric(10,2) AS sum_sales,
    sum("Lloyds_data"."Profit")::numeric(10,2) AS sum_profit,
    "Lloyds_data"."Year" AS year,
    date_part('quarter'::text, "Lloyds_data"."Date") AS quarter
   FROM "Lloyds_data"
  GROUP BY "Lloyds_data"."Year", (date_part('quarter'::text, "Lloyds_data"."Date"))
  ORDER BY "Lloyds_data"."Year", (date_part('quarter'::text, "Lloyds_data"."Date"));

-- Redundancy in data 

WITH cte AS (
         SELECT "Lloyds_data"."Gross Sales" - "Lloyds_data"."Units Sold" * "Lloyds_data"."Sale Price"::double precision AS gross_sales,
            "Lloyds_data"." Sales" - ("Lloyds_data"."Units Sold" * "Lloyds_data"."Sale Price"::double precision - "Lloyds_data"."Discounts") AS sales,
            "Lloyds_data"."Profit" - ("Lloyds_data"."Units Sold" * "Lloyds_data"."Sale Price"::double precision - "Lloyds_data"."Discounts" - "Lloyds_data"."COGS") AS profit
           FROM "Lloyds_data"
        )
 SELECT cte.gross_sales,
    cte.sales,
    cte.profit
   FROM cte
  WHERE cte.gross_sales <> 0::double precision OR 0.0000000001::double precision < cte.sales AND cte.sales <> 0::double precision OR cte.profit <> 0::double precision AND 0.0000000001::double precision < cte.profit;

-- Summary country view

SELECT "Lloyds_data"."Country",
    sum("Lloyds_data"."Units Sold") AS sum,
    avg("Lloyds_data"."Units Sold")::numeric(10,2) AS avg,
    count("Lloyds_data"."Units Sold") AS count,
    min("Lloyds_data"."Units Sold") AS min,
    max("Lloyds_data"."Units Sold") AS max
   FROM "Lloyds_data"
  GROUP BY "Lloyds_data"."Country"
  ORDER BY "Lloyds_data"."Country";

-- Summary product view 

 SELECT "Lloyds_data"."Product",
    sum("Lloyds_data"."Units Sold") AS sum,
    avg("Lloyds_data"."Units Sold")::numeric(10,2) AS avg,
    count("Lloyds_data"."Units Sold") AS count,
    min("Lloyds_data"."Units Sold") AS min,
    max("Lloyds_data"."Units Sold") AS max
   FROM "Lloyds_data"
  GROUP BY "Lloyds_data"."Product"
  ORDER BY "Lloyds_data"."Product";

-- Units sold by country view

SELECT "Lloyds_data"."Country",
    "Lloyds_data"."Product",
    sum("Lloyds_data"."Units Sold") AS sum_units_sold
   FROM "Lloyds_data"
  GROUP BY "Lloyds_data"."Country", "Lloyds_data"."Product"
  ORDER BY "Lloyds_data"."Country", "Lloyds_data"."Product";

-- Units sold by country_month_date view 

 SELECT "Lloyds_data"."Country",
    "Lloyds_data"."Product",
    "Lloyds_data"."Month Number",
    "Lloyds_data"."Year",
    sum("Lloyds_data"."Units Sold") AS sum,
    avg("Lloyds_data"."Units Sold") AS avg
   FROM "Lloyds_data"
  GROUP BY "Lloyds_data"."Country", "Lloyds_data"."Product", "Lloyds_data"."Month Number", "Lloyds_data"."Year"
  ORDER BY "Lloyds_data"."Country", "Lloyds_data"."Product", "Lloyds_data"."Year", "Lloyds_data"."Month Number";