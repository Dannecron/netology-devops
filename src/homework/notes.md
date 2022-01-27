# Git

## Git new commands

В git постепенно появляются алиасы, чтобы команды становились узконаправленными. Новые полезные команды:
1. [`git restore`](https://git-scm.com/docs/git-restore) - восстановление файлов в рабочей директории (например, откат изменений как при использовании `git checkout -- .`)
2. [`git switch`](https://git-scm.com/docs/git-switch) - переключение веток. Более узконаправленная команда, чем `git checkout` или `git branch`.

## Git rebase

Примерный порядок действий перебазирования веток в `main`:
1. `git switch new-branch`
2. `git rebase main`
3. _optional_ исправление конфликтов, выполнение команды `git rebase --continue`
4. `git checkout main`
5. `git merge new-branch`
6. `git branch -D new-branch`
