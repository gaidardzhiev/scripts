#!/bin/sh

fusage() {
	printf 'usage: %s {start-branch|add|commit|push|pull|merge|merge-to-main}\n' "$0"
	printf 'commands:\n'
	printf '\tstart-branch\tcreate and switch to a new branch\n'
	printf '\tadd\t\tstage changes\n'
	printf '\tcommit\t\tcommit staged changes\n'
	printf '\tpush\t\tpush commits to remote\n'
	printf '\tpull\t\tpull changes from remote\n'
	printf '\tmerge\t\tmerge a branch into the current branch\n'
	printf '\tmerge-to-main\tmerge the current branch into main branch and push\n'
	exit 1
}

fm2m() {
	current=$(git branch --show-current)
	[ -z "$current" ] && printf "could not detect current branch\n" && exit 1
	[ "$current" = "main" ] && printf "you are already on main branch. Nothing to merge.\n" && exit 1
	printf "checking out main branch...\n"
	git checkout main || { printf "failed to checkout main branch\n"; exit 1; }
	printf "merging branch '%s' into main...\n" "$current"
	git merge --no-ff "$current" || { printf "merge failed... resolve conflicts manually...\n"; exit 1; }
	printf "pushing main branch to remote...\n"
	git push origin main || { printf "push failed\n"; exit 1; }
	printf "successfully merged branch '%s' into main and pushed.\n" "$current"
}

case "$1" in
	start-branch)
		printf "enter new branch name:\n"
		read branch
		[ -z "$branch" ] && printf "branch name cannot be empty\n" && exit 1
		git checkout -b "$branch" || exit 1
		;;
	add)
		printf "enter files to add (or '.' to add all):\n"
		read files
		[ -z "$files" ] && printf "no files specified\n" && exit 1
		git add $files || exit 1
		;;
	commit)
		printf "enter commit message:\n"
		read message
		[ -z "$message" ] && printf "commit message cannot be empty\n" && exit 1
		git commit -m "$message" || exit 1
		;;
	push)
		printf "pushing to remote repository...\n"
		git push --set-upstream origin "$(git branch --show-current)" || exit 1
		;;
	pull)
		printf "pulling latest changes from remote...\n"
		git pull || exit 1
		;;
	merge)
		printf "enter branch name to merge into current branch:\n"
		read branch
		[ -z "$branch" ] && printf "branch name cannot be empty\n" && exit 1
		git merge "$branch" || exit 1
		;;
	merge-to-main)
		fm2m
		;;
	*)
		fusage
		;;
esac
