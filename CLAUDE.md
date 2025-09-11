# Instructions Claude - Config Neovim

## ⚠️ WORKFLOW AUTOMATIQUE OBLIGATOIRE - CONFIGURATIONS CLAUDE ⚠️
**RÈGLE ABSOLUE** : À chaque modification des fichiers de configuration nvim (`~/.config/nvim/`) :
1. **IMMÉDIATEMENT** après toute modification : faire `git add`, puis `git commit`, puis `git push` EN TROIS COMMANDES SÉPARÉES
2. **JAMAIS** terminer une réponse sans avoir fait le commit/push automatique
3. **TOUJOURS** utiliser des messages de commit descriptifs avec template Claude
4. **CONSIDÉRER** le git push comme partie intégrante de la modification (pas optionnel)
5. **NE PAS ATTENDRE** de commande utilisateur - le faire automatiquement
6. **ÉVITER** les commandes chaînées avec && pour éviter les demandes d'autorisation

**RAPPEL** : Si tu modifies un fichier dans `~/.config/nvim/`, tu DOIS finir par git add/commit/push dans la même réponse.

## Contexte du projet
- Configuration Neovim basée sur Kickstart.nvim
- Thème Flexoki avec fonctions en blanc
- Repo GitHub : https://github.com/inepsie/nvim-config.git
- Credential helper automatique configuré via `~/.local/bin/git-credential-claude`
- Test modification config nvim - 2025-09-12