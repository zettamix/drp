#!/bin/bash
path="/home/infonavit/migration"
zpath="/home/infonavit/nojejs/img/"

#Please (set the execution of the script as an alias and) run it as needed

mysql -uroot -ptoor -Dbmp_2_8 -e"create table if not exists fills2 like fills;"

mysql -uroot -ptoor -Dbmp_2_8 -e"create table if not exists messages2 like messages;"

insert into fills2 select * from fills where altuser=bmp and last;

insert into messages2 select * from messages where id in (select source_id from fills2);

mysqldump --opt --host=bm28reportsrr.cjaguzeo9pm4.us-east-1.rds.amazonaws.com --user=alopez --password=lopez03a --no-create-info --lock-tables=false --where="id=49898819" bmp_2_8 messages2 > $path/messages2.sql

mysqldump --opt --host=bm28reportsrr.cjaguzeo9pm4.us-east-1.rds.amazonaws.com --user=alopez --password=lopez03a --no-create-info --lock-tables=false --where="source_id=49898819" bmp_2_8 fills2 > $path/fills2.sql

zip -r $zpath $path/img.zip *

echo "Replacing line"
echo "The result is:"
sleep 2
sed "s:KEY \`templateIdent1LastIndex\` (\`template_id\`,\`ident1\`,\`last\`),:jajaja xD:" 2test.txt > almostthere.txt
sed 's:jajaja xD:KEY `templateIdent1LastIndex` (`template_id`,`ident1`,`last`):' almostthere.txt > finallythere.txt
echo "Done"

