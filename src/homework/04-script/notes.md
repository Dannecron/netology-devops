# Script languages

## Bash

* замена значения переменной

```shell
a=1234
a=${a/12/FOO}
echo $a
FOO34
```

* объявление и вывод массива

```shell
arrayInt=(1 2 3 4 5)
# первый элемент
echo $arrayInt
1
# все элементы
echo ${arrayInt[@]}
1 2 3 4 5
# конкретный элемент
echo ${arrayInt[3]}
4
# индексы
echo ${!arrayInt[@]}
# размерность
echo ${#arrayInt[@]}
# присвоение массива из команды
arrayLs=($(ls))
# добавление элементов в конец массива
arrayInt+=(12 123 13)
```

* Разделитель значений для bash

```shell
echo $IFS
export IFS=;
unset IFS
```