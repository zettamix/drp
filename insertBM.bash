#!/bin/bash
#Files used
f2="fills2.sql"
m2="messages2.sql"
mc="messageCompare.sql"
mcr="rmessageCompare.txt"
mcrc="$(cat rmessageCompare.txt)"
fc="fillsCompare.sql"
fcr="rfillsCompare.txt"
fcrc="$(cat rfillsCompare.txt)"
fcne="columnsfillsnameextract.txt"
fcnef="fcnefinal.txt"
cfcnef="$(cat fcnefinal.txt)"
mcne="columnsmessagesnameextract.txt"
mcnef="mcnefinal.txt"
cmcnef="$(cat mcnefinal.txt)"
#prod host
dbh=""
#prod user
dbu=""
#prod pass
dbp=""
#photos local path
localpath="/home/zubu/test/amazonsynch/"
#s3 target bucket
destbucket="s3://bmdrp-test"


getsqlfiles () {
echo "Getting sql files"
#wget on hold until public access is configured
wget --verbose --no-cache 
}

insertfills2 () {
echo"Drop, create and inserting Fills2 on Prod"
mysql -ptoor -Dbmp_2_8 < $f2
wait
sleep 2
echo "Done"
sleep 2
echo ""
}

insertmessa2 () {
echo "Drop, create and insert Messages2 on Prod"
mysql -ptoor -Dbmp_2_8 < $m2
wait
sleep 2
echo "Done"
sleep 2
echo ""
}

comparef () {
echo "Comparing structure between fills and fills2"
sleep 2
mysql -ptoor -Dbmp_2_8 < $fc > $fcr
wait
if [ "no differences" == "$fcrc" ]; then
echo "Structure of tables fills and fills2 are the same, lets continue"
sleep 2
else
echo "Structure of tables fills and fills2 don't have the same structure please verify to continue"
sleep 2
exit 0
fi
echo ""
}

comparem () {
echo "Comparing structure between messages and messages2"
sleep 2
mysql -ptoor -Dbmp_2_8 < $mc > $mcr
wait
if [ "no differences" == "$mcrc" ]; then
echo "Structure of tables messages and messages2 are the same, lets continue"
sleep 2
else
echo "Structure of Tables messages and messages2 don't have the same structure please verify to continue"
sleep 2
exit 0
fi
echo ""
}

insertmessageprod () {
echo "Process to insert in to messages in Prod environment started"
sleep 2
echo "Building query to insert"
sleep 2
mysql -h$dbh -u$dbu -p$dbp -Dbmp_2_8 -e"select column_name from information_schema.columns where table_schema='bmp_2_8' and table_name='messages';" > $mcne
wait
awk 'NR>2' $mcne | tr '\n' ',' | sed '$s/.$//' > $mcnef
wait
echo "DONE, Query ready to be inserted"
sleep 2
echo "Inserting rows into messages in Prod environment"
mysql -h$dbh -u$dbu -p$dbp -Dbmp_2_8 -e"insert into messages select id=NULL as id,"$cmcnef" from messages2;"
wait
echo "DONE, messages inserted successfully"
sleep 2
echo ""
}

insertfillsprod () {
echo "Process to insert in to fills in Prod environment started"
sleep 2
echo "Building query to insert"
sleep 2
mysql -h$dbh -u$dbu -p$dbp -Dbmp_2_8 -e"select column_name from information_schema.columns where table_schema='bmp_2_8' and table_name='fills';" > $fcne
wait
awk 'NR>2' $fcne | tr '\n' ',' | sed '$s/.$//' > $fcnef
wait
echo "DONE, Query ready to be inserted"
mysql -h$dbh -u$dbu -p$dbp -Dbmp_2_8 -e"insert into fills select id=NULL as id,"$cfcnef" from fills2;"
wait
echo "Insert DONE"
sleep 2
echo "Updating each fill with their new source_id"
mysql -h$dbh -u$dbu -p$dbp -Dbmp_2_8 -e"update fills as f,(select m.id,m.name from messages as m,messages2 as mdos where m.name=mdos.name) as mm set f.source_id=mm.id where mm.name=f.name;"
wait
echo "DONE, fills inserted successfully"
sleep 2
echo ""
}

uploadaws () {
echo "Getting photos from server"
sleep 2
#Pendin until to have remote access to the server
echo "Uploading media to s3"
sleep 2
s3cmd sync $path $destbucket
wait
echo "All DONE"
echo ""
}

continue () {
#Just a continue function
echo ""
echo "Continue? y/n"
echo ""
read ans
if [ "$ans" = "n" ]; then
echo "Installation incomplete BYE"
exit 0
else
echo ""
echo "=============================Lest CONTINUE=================================="
fi
}

alld () {
#Just bye
echo ""
echo "=============================ALL DONE BYE=================================="
}

getsqlfiles

insertfills2

insertmessa2

comparem

comparef

insertmessageprod

insertfillsprod

uploadaws

alld
