# Instructions pour Claude

## Système de Mémoire MCP
- Tu as accès à un système de mémoire via MCP Memory Server configuré dans `~/.config/claude-desktop/claude_desktop_config.json`
- Les données sont stockées dans `/home/e20230004281/.config/nvim/mcp-memory/test_memory.json`

## Triggers automatiques pour utiliser la mémoire
IMPORTANT: Quand l'utilisateur utilise ces mots-clés, tu DOIS automatiquement rechercher dans la mémoire AVANT de répondre :
- "mémoire", "souvenir", "te souviens", "rappelle-toi"
- "qui suis-je", "mon nom", "ma ville", "mon âge", "née en"
- "mes préférences", "mes informations"

## Processus à suivre
1. Si l'utilisateur mentionne ces mots-clés → Lire automatiquement le fichier mémoire
2. Rechercher les informations pertinentes dans les "memories"
3. Utiliser ces informations dans ta réponse

## Informations stockées actuellement
- Ville natale : Gien
- Année de naissance : 1993
- Configuration Neovim avec Kickstart
- Thème Flexoki avec fonctions en blanc

## Workflow automatique
**IMPORTANT** : À chaque modification de la configuration Neovim :
1. Faire automatiquement `git add` + `git commit` + `git push`
2. Utiliser des messages de commit descriptifs
3. Ne pas demander confirmation à l'utilisateur
4. Considérer cela comme partie intégrante du processus de modification