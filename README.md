# Playground

Esse projeto foi feito para testar alguns comandos gits e seus efeitos em branchs e commits

# Comandos uteis

```bash
git log --online
git --no-pager log --oneline
git log -n 5 --oneline
git log --stat
git log --since="2 weeks ago"


git --no-pager branch -a                    # Visualizando todas as branchs
git --no-pager branch -r                    # Visualizando somente branchs remotas

git --no-pager merge-base master suporte    # Acha o ancestral comum entre essas branchs
git rev-list --count suporte..master
git rev-list --count master..suporte
```
