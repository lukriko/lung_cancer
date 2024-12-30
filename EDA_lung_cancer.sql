use lung_cancer;

-- 1 means yes, 2 means NO

-- average age 
select avg(age) from LC_table;

-- total count of population in survey
select count(gender) from LC_table;
 
-- male, female population in survey
select gender,count(gender) as population_by_gender from LC_table group by gender; 

-- count of population with smoking habit per gender
select gender,count(gender) as smoking_habit from LC_table
where smoking = 1
group by gender;

-- count of population with lung cancer per gender
select gender, count(gender) as lung_cancer from LC_table
where lung_cancer = "YES"
group by gender;

-- percentage of smoking population per gender out of whole population per gender
select l1.gender, 
       concat((count(case when l1.smoking = 1 then 1 end) / count(l2.gender)) * 100, "%") as smoking_ratio_per_gender
from lc_table l1
join lc_table l2
    on l1.gender = l2.gender
group by l1.gender;

-- count of population with chronical disease and smoking habit above the average age per gender
select gender,chronic_disease,smoking,count(gender) as smoking_CD_older_AA from LC_table
where chronic_disease = 1 and smoking = 1 and age >  (select avg(age) from LC_table)
group by gender;

-- select maximum,minimum and range of age
select max(age) max_age,min(age) min_age,(max(age) - min(age)) range_of_age from LC_table;

-- standard deviation for age 
select stddev_pop(age) as standard_deviation from LC_table;

-- count of population within the group of average age - stdev and average age + stdev
select gender, count(age) from LC_table
where age > (select avg(age) - stddev_pop(age) from LC_table) and age < (select avg(age) + stddev_pop(age) from LC_table)
group by gender; 
 
 -- percentage of the count of population within the group of 
 -- average age - stdev and average age + stdev from whole population
SET @avg_age = (SELECT avg(age) FROM lc_table);
SET @stddev_age = (SELECT stddev_pop(age) FROM lc_table);

SELECT 
       CONCAT((COUNT(CASE 
                WHEN l1.age > @avg_age - @stddev_age 
                     AND l1.age < @avg_age + @stddev_age
                THEN 1 
                ELSE NULL 
            END) / COUNT(l2.gender) ) * 100,'%') AS ratio_within_one_stddev
FROM lc_table l1
JOIN lc_table l2 ON l1.gender = l2.gender;



-- probability 


-- probability of lung cancer given smoking
  -- p(lung cancer | smoking) = p(smoking | lung cancer) * p(lung cancer)/p(smoking)
-- calculate p(smoking | lung cancer)
set @smoking_given_lc = (
    select count(*) * 1.0 / (select count(*) from lc_table where lung_cancer = 'yes')
    from lc_table 
    where smoking = 1 and lung_cancer = 'yes'
);

-- calculate p(lung cancer)
set @lc = (
    select count(*) * 1.0 / count(*)
    from lc_table
    where lung_cancer = 'yes'
);

-- calculate p(smoking)
set @smoking = (
    select count(*) * 1.0 / count(*)
    from lc_table
    where smoking = 1
);
select concat(round((@smoking_given_lc * @lc) / @smoking,4)*100,"%") as prob_lc_given_smoking;



-- count of population having coughing, smoking,consuming alcohol and not having lung cancer per gender
set @full_count = (select count(gender) from LC_table);
select gender, count(*) as cough_smoking_AC_noLC from LC_table
where coughing = 1 and smoking = 1 and alcohol_consuming = 1 and lung_cancer = "NO"
group by gender; 

-- percent count of population having coughing, smoking,consuming alcohol and not having lung cancer per gender
-- of whole population

 select concat(round((count(*)/@full_count*100),2),'%') as cough_smoking_AC_noLC_over_population 
 from LC_table
where coughing = 1 and smoking = 1 and alcohol_consuming = 1 and lung_cancer = "NO"; 


-- lung_cancer per age 
  select age, count(*) as LC_count from lc_table
    where lung_cancer = 'yes'
    group by age
    order by age asc;
    
-- max amount of lung cancer in given age
with cte_lc_1 as (
    select age, count(*) as LC_count from lc_table
    where lung_cancer = 'yes'
    group by age
)
select age, LC_count
from cte_lc_1
where LC_count = (select max(LC_count) from cte_lc_1);

-- count of smoking population with shortness of breath per gender
select gender,count(*) from LC_table
where smoking = 1 and shortness_of_breath = 1
group by gender;

-- count of anxiety and rank per age
select * from LC_table;
with anxiety_count as (
    select age,count(anxiety) as anxiety_count
    from lc_table
    where anxiety = 1
    group by age
)
select age,anxiety_count,dense_rank() over (order by anxiety_count asc) as rank_within_age
from anxiety_count
    order by anxiety_count asc;




