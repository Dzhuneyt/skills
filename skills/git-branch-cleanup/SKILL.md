---
name: git-branch-cleanup
description: Delete merged branches and show branch status summary
allowed-tools: [Bash]
disable-model-invocation: true
---

Execute the following steps:
1. Check if current directory is a valid git repository
2. Fetch latest changes to ensure branch merge status is current
3. Identify local branches and categorize them:
   - Merged branches that are safe to delete
   - Unmerged branches with unpushed commits (protect these)
   - Branches with no remote tracking (potential new work)
4. Show detailed summary of what will/won't be deleted with reasons
5. Only delete branches that are confirmed merged AND have been pushed
6. Show final branch status with tracking information

Safety rules:
- Never delete the current branch
- Never delete main, master, develop, or staging branches
- Never delete branches with unpushed commits (no remote tracking or ahead of remote)
- Only delete branches that are fully merged AND have been pushed to remote
- Always ask for confirmation before any deletion
- Clearly distinguish between "safe to delete" and "protected" branches

Branch categorization:
- **Safe to delete**: Merged branches that exist on remote and are fully merged
- **Protected - unpushed**: Branches with no remote tracking or ahead of remote
- **Protected - unmerged**: Branches with unmerged commits
- **Protected - system**: main, master, develop, staging, current branch

Output format:
- Show branches in categories with reasons for protection/deletion
- Display last commit info and push status for each branch
- Clearly indicate which branches contain potentially valuable unpushed work
- Provide summary of cleanup actions taken
