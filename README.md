# Playground

Esse projeto foi feito para testar alguns comandos gits e seus efeitos em branchs e commits

# Comandos uteis

```bash
# Logs
git log --online
git --no-pager log --oneline origin/master
git --no-pager log --oneline origin/suporte
git log -n 5 --oneline
git log --stat
git log --since="2 weeks ago"

# Buscando branhcs
git --no-pager branch -a                            # Visualizando todas as branchs
git --no-pager branch -r                            # Visualizando somente branchs remotas

# Buscando ancestral comum e diferencas
git --no-pager merge-base origin/master origin/suporte           
git --no-pager diff --name-only origin/master origin/suporte    
git rev-list --count origin/suporte..origin/master
git rev-list --count origin/master..origin/suporte
```
