#!/bin/bash

set -x
LOGFILE='./*.log'

# проверяем файл блокировки
if [ -e ./lock_file ] 
then
  echo "Скрипт уже запущен!"
  exit
else
  touch ./lock_file
fi

# файл с письмом
if [ -e list.txt ]
then
  rm list.txt
fi
touch list.txt

OLD_TIME="никогда"
NUMBER_OF_LAST_PRINTED_STRING=0
LAST_STRING=$(wc -l *.log  | cut -d ' ' -f1)

# считываем время последнего записанного лога
# создаем файл, чтобы парсить
if [ -s ./temp_file ]
then 
  OLD_TIME=$(cat ./temp_file)
  NUMBER_OF_LAST_PRINTED_STRING=$(grep -n $OLD_TIME  $LOGFILE | cut -d ':' -f1 | tail -n 1) 
fi

# проверяем, есть ли новые логи
if [ $LAST_STRING -eq $NUMBER_OF_LAST_PRINTED_STRING ]
then
  echo "No logs!"
  rm ./lock_file
  exit
fi

if [ $NUMBER_OF_LAST_PRINTED_STRING -gt 0 ]
then
  tail -n +$NUMBER_OF_LAST_PRINTED_STRING >> ./log.tmp
else
  cp $LOGFILE ./log.tmp
fi
LOGFILE='./log.tmp'

# записываем время собранных логов в письмо
# и обновляем файл со временем последнего лога
NEW_TIME=$(grep -o "\[.*\]" $LOGFILE | tr -d '[]' | cut -d ' ' -f1 | tail -n 1)
echo "Время собранных логов: с $OLD_TIME до $NEW_TIME" >> list.txt
echo $NEW_TIME >> ./temp_file

# получаем список ip-адресов
echo "Список ip - адресов с наибольшим количеством запросов" >> list.txt
echo "Запросы: ip-адреса:" >> list.txt
cut -d ' ' -f1 $LOGFILE | uniq -c | sort -g -r | head -n 10 >> list.txt

# получаем список url
echo "Список url с наибольшим количеством запросов" >> list.txt
echo "Запросы: url-адреса:" >> list.txt
grep -o "http.*" $LOGFILE | cut -d ' ' -f1 | cut -d '"' -f1 | cut -d ')' -f1 | uniq -c | sort -g -r | head -n 10 >> list.txt

# получаем список ошибок
echo "Список ошибок" >> list.txt
grep -e " 4.. ... " -e " 5.. ... "  $LOGFILE | cut -d ' ' -f4,6- | sed 's/"-"//g' | sed 's/rt=.*//g' | sed 's/\[//g' >> list.txt

# полуяаем список http-ответов
echo "Список http-ответов:" >> list.txt
echo "Кол-во: http-ответ:" >> list.txt
grep -i "GET"  $LOGFILE | grep -o " [0-9]* [0-9]* " | cut -d ' ' -f2 | sort | uniq -c | sort -g -r >> list.txt

# удаляем файл блокировки и вспомогательные файлы
rm ./lock_file
rm ./log.tmp

