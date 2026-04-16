#!/bin/bash
# sync-and-publish.sh

set -e  # Exit on error

echo "🔄 Syncing from upstream..."
git fetch upstream
git merge upstream/master --no-edit

echo "📁 Reorganizing files into docs directory..."

echo "📂 Moving markdown files to docs/..."
# Move all X16 Reference markdown files to docs/
mv *.md docs/ 2>/dev/null || true

echo " 📄 Converting README.md to index.md in docs/..."
# Copy README.md to docs/index.md
# if [ -f "README.md" ]; then
mv docs/README.md docs/index.md 2>/dev/null || true
# fi

echo "📂 Moving images to docs/..."
# Move images directory to docs/ if it exists
# if [ -d "images" ]; then
#   rm -rf docs/images
mv images docs/images 2>/dev/null || true
# fi

echo "Deleting symlinks in docs/ if they exist..."
# Remove any existing symlinks in docs/ that point to files in the root
find docs/ -type l -exec rm -f {} \; 2>/dev/null || true

# Clean up root - remove any remaining reference markdown files
# rm -f X16\ Reference\ -\ *.md 2>/dev/null || true

echo "🏗️ Building documentation..."
mkdocs build


echo "Staging and committing changes..."
git add .
git commit -m "Sync with upstream, reorganize files, and prepare for deployment: $(date)" || true

# Save the built site to a temp location before switching branches
cp -r site ../_site_temp

echo "📤 Deploying to gh-pages..."
git branch -f gh-pages master
git checkout gh-pages
# rm -rf *
cp -r ../_site_temp/* .
git add -A
git commit -m "Deploy to gh-pages: $(date)" || true
git push origin gh-pages

# echo "📤 Deploying to rtd branch..."
# git branch -f rtd master
# git checkout rtd
# # rm -rf *
# cp -r ../_site_temp/* .
# git add -A
# git commit -m "Deploy to rtd: $(date)" || true
# git push origin rtd

echo "✅ Back to master..."
git checkout master

# Clean up temp directory
rm -rf ../_site_temp

echo "✨ All done! Synced, reorganized, built, and deployed!"
