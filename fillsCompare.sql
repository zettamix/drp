set @var=(select if(count(1)>0,'differences','no differences') comparison from(select column_name,ordinal_position,data_type,column_type,count(1) rowcount from information_schema.columns where table_schema='bmp_2_8' and table_name in ('fills','fills2') group by column_name,ordinal_position,data_type,column_type having count(1)=1) a);

select if(@var='no differences','OK TO GO, no diffs between fills and fills2','UNABLE TO CONTINUE, there are diffs between fills and fills2');
