-- Data Cleaning


SELECT *
FROM layoffs;


-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null values or blank values
-- 4. Remove any columns and rows


-- First create staging table. This is the one we will work in and clean the data.
CREATE TABLE layoffs_staging
LIKE layoffs;


INSERT layoffs_staging
SELECT *
FROM layoffs;




-- 1. Remove Duplicates
SELECT *
FROM layoffs_staging;


SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY company, industry, total_laid_off, percentage_laid_off, date
       ) AS row_num
FROM layoffs_staging;


WITH duplicate_cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`
           ) AS row_num
    FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;


-- Check oda to confirm duplicate
SELECT *
FROM world_layoffs.layoffs_staging
WHERE company = 'Oda'
;
-- Do not delete these are legitimite entries


-- These are what we would need to delete
WITH duplicate_cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, country, funds_raised_millions
           ) AS row_num
    FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;


CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


SELECT *
FROM layoffs_staging2;


INSERT INTO layoffs_staging2
(company,
location,
industry,
total_laid_off,
percentage_laid_off,
date,
stage,
country,
funds_raised_millions,
row_num)
SELECT company,
location,
industry,
total_laid_off,
percentage_laid_off,
date,
stage,
country,
funds_raised_millions,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,date, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		layoffs_staging;
        
        
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;


DELETE
FROM layoffs_staging2
WHERE row_num > 1;




-- 2. Standardize the Data

-- Check industry for nulls and blank values
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;


SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = ''
ORDER BY industry;


-- Check Bally
SELECT *
FROM layoffs_staging2
WHERE company LIKE 'airbnb%';
-- airbnb should be listed as travel


-- First we should set the blanks to nulls
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';


SELECT *
FROM world_layoffs.layoffs_staging2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;


UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2 ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;


-- Bally's can't be populated because there is no other reference
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;


-- Crypto has multiple variations that need to be standardized
SELECT DISTINCT industry
FROM world_layoffs.layoffs_staging2
ORDER BY industry;


UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');


SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;


-- Check if other catagories need to be standardized
SELECT *
FROM layoffs_staging2;


-- In country we have "United States" and "United States."
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY country;


UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country);


-- Now it only shows 'United States'
SELECT DISTINCT country
FROM world_layoffs.layoffs_staging2
ORDER BY country;


-- The date column needs to be standardized
SELECT *
FROM layoffs_staging2;


-- we can use str to date to update
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');


-- Convert the data type properly
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


SELECT *
FROM layoffs_staging2;




-- 3. Null Values
-- the null values are in total_laid_off, percentage_laid_off, and funds_raised_millions
-- They all look normal and I won't be changing these null values




-- 4. Remove any columns and rows
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL;


SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


-- Delete Useless data we can't really use
DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


SELECT *
FROM layoffs_staging2;


ALTER TABLE layoffs_staging2
DROP COLUMN row_num;


SELECT * 
FROM layoffs_staging2;