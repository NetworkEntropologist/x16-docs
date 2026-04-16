#!/bin/bash
# sync-and-publish.sh

set -e  # Exit on error

echo "🔄 Syncing from upstream..."
git fetch upstream
git merge upstream/master --no-edit

echo "📁 Reorganizing files into docs directory..."

# Move all X16 Reference markdown files to docs/
mv X16\ Reference\ -\ *.md docs/ 2>/dev/null || true

# Copy README.md to docs/index.md
if [ -f "README.md" ]; then
  cp README.md docs/index.md || true
fi

# Move images directory to docs/ if it exists
if [ -d "images" ]; then
  rm -rf docs/images
  mv images docs/images
fi

# Clean up root - remove any remaining reference markdown files
rm -f X16\ Reference\ -\ *.md 2>/dev/null || true

echo "🏗️ Building documentation..."
mkdocs build

# Save the built site to a temp location before switching branches
cp -r site _site_temp

echo "📤 Deploying to gh-pages..."
git branch -f gh-pages master
git checkout gh-pages
rm -rf *
cp -r ../_site_temp/* .
git add -A
git commit -m "Deploy to gh-pages: $(date)" || true
git push origin gh-pages

echo "📤 Deploying to rtd branch..."
git branch -f rtd master
git checkout rtd
rm -rf *
cp -r ../_site_temp/* .
git add -A
git commit -m "Deploy to rtd: $(date)" || true
git push origin rtd

echo "✅ Back to master..."
git checkout master

# Clean up temp directory
rm -rf _site_temp

echo "✨ All done! Synced, reorganized, built, and deployed!"
