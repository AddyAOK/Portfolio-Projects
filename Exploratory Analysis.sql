-- Exploratory Analysis


SELECT *
FROM layoffs_staging2;


-- Selects the maximum values of total_laid_off and percentage_laid_off columns.
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;


-- Selects all columns where percentage_laid_off is 1 and orders the result by total_laid_off in descending order.
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;


-- Selects all columns where percentage_laid_off is 1 and orders the result by funds_raised_millions in descending order.
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;


-- Groups the data by company and sums the total_laid_off for each company, ordering the results by the total in descending order.
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP by company
ORDER BY 2 DESC;


-- Selects the minimum and maximum dates from the date column in layoffs_staging2.
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;


-- Groups the data by industry and sums the total_laid_off for each industry, ordering the results by the total in descending order.
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP by industry
ORDER BY 2 DESC;


-- Groups the data by country and sums the total_laid_off for each country, ordering the results by the total in descending order.
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP by country
ORDER BY 2 DESC;


-- Groups the data by year (extracted from the date column) and sums the total_laid_off for each year, ordering the results by year in descending order.
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP by YEAR(`date`)
ORDER BY 1 DESC;


-- Groups the data by stage and sums the total_laid_off for each stage, ordering the results by the total in descending order.
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP by stage
ORDER BY 2 DESC;


-- Groups the data by company and sums the percentage_laid_off for each company, ordering the results by the total in descending order.
SELECT company, SUM(percentage_laid_off)
FROM layoffs_staging2
GROUP by company
ORDER BY 2 DESC;


-- Extracts the month and year from the date column, groups by this extracted month, and sums the total_laid_off for each month, ordering the results by month in ascending order.
SELECT SUBSTRING(`date`, 1,7) AS `MOUNTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1,7) IS NOT NULL
GROUP BY `MOUNTH`
ORDER BY 1 ASC;


-- Calculates a rolling total of layoffs by month using a subquery to sum the total_laid_off for each month up to and including the current month.
WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`, 1,7) AS `MOUNTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1,7) IS NOT NULL
GROUP BY `MOUNTH`
ORDER BY 1 ASC
)
SELECT `MOUNTH`, total_off
,SUM(total_off) OVER(ORDER BY `MOUNTH`) AS rolling_total
FROM Rolling_total;


-- Groups the data by company and sums the total_laid_off for each company, ordering the results by the total in descending order.
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP by company
ORDER BY 2 DESC;


-- Groups the data by company and year (extracted from the date column), and sums the total_laid_off for each combination of company and year, ordering the results by company in ascending order.
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP by company, YEAR(`date`)
ORDER BY company ASC;


-- Groups the data by company and year (extracted from the date column), and sums the total_laid_off for each combination of company and year, ordering the results by the total_laid_off in descending order.
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP by company, YEAR(`date`)
ORDER BY 3 DESC;


-- First, groups the data by company and year, and sums the total_laid_off for each combination.
-- Then, ranks the companies for each year based on the total_laid_off in descending order.
-- Finally, selects the top 5 companies with the highest layoffs for each year.
WITH Company_YEAR (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP by company, YEAR(`date`)
), Company_Year_Rank AS
(SELECT *, 
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;