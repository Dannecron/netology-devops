## gitignore

Создана директория [src/terraform](/src/terraform), добавлен файл: [terraform/.gitignore](/src/terraform/.gitignore).

Файлы, которые будут проигнорированы git:

* Любые файлы, которые находятся в директории `.terraform` (в любом месте глубже по файловой системе)
* Файлы с расширением `.tfstate`, либо содержащие в названии `.tfstate.`
* Файлы с названием `crash.log`
* Файлы, которые начинаются с `crash.` и имеют расширение `.log`
* Файлы с расширением `.tfvars`
* Файлы с названием `override.tf` или `override.tf.json`
* Файлы, название которых заканчивается на `_override.tf` или `_override.tf.json`
* Файлы с названием `.terraformrc` или `terraform.rc`