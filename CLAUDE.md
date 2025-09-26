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
- Configuration Neovim basée sur Kickstart.nvim (~997 lignes de code)
- Thème Flexoki avec fonctions en blanc
- Repo GitHub : https://github.com/inepsie/nvim-config.git
- Credential helper automatique configuré via `~/.local/bin/git-credential-claude`
- **Dernière mise à jour système linting** : 2025-09-26

## 🔧 Système de Linting C/C++ (Mis à jour 2025-09-26)
### Configuration actuelle
- **Auto-détection** : Préfère `cppcheck` → fallback vers `gcc`/`g++` → notification si rien
- **Linters custom** : `gcc_lint` et `gpp_lint` utilisant GCC système
- **Virtual text** : Messages d'erreur/warning affichés directement dans le code
- **Diagnostics** : Configuration complète avec icônes, navigation, popup flottants

### Raccourcis linting
- `<leader>cl` : Linter le fichier courant manuellement
- `<leader>cL` : Toggle auto-linting on/off
- `<leader>ct` : Analyse approfondie avec feedback intelligent
- `<leader>e` : Popup détails erreur courante
- `[d` / `]d` : Navigation erreur précédente/suivante
- `<leader>q` : Quickfix list de toutes les erreurs

### Fichiers système linting
- `lua/kickstart/plugins/lint.lua` : Configuration nvim-lint + linters custom
- `lua/config/options.lua` : Configuration vim.diagnostic (virtual text, signes, etc.)
- `lua/config/keymaps.lua` : Raccourcis linting et diagnostic

### Recommandations d'installation
```bash
sudo apt install cppcheck  # Pour un linting optimal
```

## 📁 Structure de la configuration
```
~/.config/nvim/
├── init.lua                    # Point d'entrée principal
├── lua/config/
│   ├── options.lua            # Options Neovim + diagnostics
│   ├── keymaps.lua            # Raccourcis clavier
│   ├── autocmds.lua           # Auto-commandes
│   └── plugins.lua            # Plugins custom
├── lua/kickstart/plugins/     # Plugins Kickstart modifiés
│   ├── lint.lua              # ★ Système linting custom
│   ├── autopairs.lua         # Auto-pairs
│   ├── debug.lua             # Debug adapters
│   ├── gitsigns.lua          # Git signes
│   ├── indent_line.lua       # Indentation
│   └── neo-tree.lua          # Explorateur fichiers
└── lua/custom/plugins/        # Plugins supplémentaires
    ├── colorschemes.lua       # Thèmes alternatifs
    └── rainbow.lua            # Rainbow brackets
```