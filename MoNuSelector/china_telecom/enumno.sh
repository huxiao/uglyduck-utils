#!/bin/bash

TRAVERSING_N=8

trap "rm -f temp.* && exit" SIGINT

if [ -e new_phonenum.txt ]
then
    mv new_phonenum.txt overdue_phonenum.txt
fi

phantomjs traverse_website.js -c
pages=$?
if [ -z $pages ]; then
    echo "无法获取号码库页数，程序退出。"
    exit -1
fi

echo "当前号码库中共有${pages}页号码，开始进行号码统计："

echo -n "> 读取号码库..."
for (( i = 0; i < $TRAVERSING_N; i++ )); do
    phantomjs traverse_website.js >> temp.tvn.$i &
done
wait
for (( i = 0; i < $TRAVERSING_N; i++ )); do
    cat temp.tvn.$i >> temp.tvn
done
cat temp.tvn | egrep -o "^[0-9]{11}" | sort -u > new_phonenum.txt
echo "[OK]"

phonenumFileName="phonenum_`date +%F_%H.%M`.txt"
cp new_phonenum.txt $phonenumFileName
phoneItemNum=$(wc -l $phonenumFileName | awk '{print $1}')
echo "号码保存于$phonenumFileName，共$phoneItemNum个号码。"

tatisticTime=$(date +%F' '%T)
echo "号码统计于$tatisticTime，共$phoneItemNum个号码。" > temp.report

if [ -e overdue_phonenum.txt ]
then
    diff overdue_phonenum.txt new_phonenum.txt > temp.diff
    egrep "^>" temp.diff | egrep -o "[0-9]{11}" > temp.newer
    if [ 0 -eq `wc -l temp.newer | awk '{print $1}'` ]
    then
        echo "号码库较上次统计无新增号码。" >> temp.report
    else
        echo -e "\n号码池较上次统计新增的号码：" >> temp.report
        cat temp.newer >> temp.report
    fi

    egrep "^<" temp.diff | egrep -o "[0-9]{11}" > temp.older
    if [ 0 -eq `wc -l temp.older | awk '{print $1}'` ]
    then
        echo "号码池较上次统计没有减少增号码。" >> temp.report
    else
        echo -e "\n号码池较上次统计减少的号码：" >> temp.report
        cat temp.older >> temp.report
    fi
fi

echo -e "\n号码列表：" >> temp.report

cat $phonenumFileName >> temp.report
cp temp.report $phonenumFileName
rm -f temp.*
