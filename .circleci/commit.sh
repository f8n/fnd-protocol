#!/bin/sh
# Based on https://github.com/eldarlabs/ghpages-deploy-script/blob/master/scripts/deploy-ghpages.sh

echo "Auto-commit starting..."

# abort the script if there is a non-zero error
set -e

remote=$(git config remote.origin.url)

# now lets setup a new repo so we can update the branch
echo "git config email"
git config --global user.email "$GH_EMAIL" > /dev/null 2>&1
echo "git config name"
git config --global user.name "$GH_NAME" > /dev/null 2>&1

cd ~/repo

# stage any changes and new files
echo "git add"
git add -A
if ! git diff-index --quiet origin/$CIRCLE_BRANCH --; then
  echo "Changes detected. Committing..."
  # now commit
  git commit -m "auto lint/docs/gas/size update"
  echo "Pushing commit..."
  # and push
  git push --set-upstream origin $CIRCLE_BRANCH
else
  echo "No changes to commit."
fi

echo "Auto-commit done."