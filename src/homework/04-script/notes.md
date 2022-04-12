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

## YAML

* Типы данных

```yaml
root:
  emptyValue: 
  booleanTrue: true
  booleanFalse: false
  canonTime: 2020-12-15T00:30:44.1Z
  date: 2020-12-15
  list:
    - one
    - two
    - three
    - name: one
      type: two
      default: true
      using: [ localhost, 7.7.7.7 ]
```

* Многострочные значения в ключе

```yaml
---
root:
  first:|
    Этот вид
    сохранит все переходы на новую строку
  second:>
    А этот
    преобразует каждый переход на новую строку
    в пробел
```