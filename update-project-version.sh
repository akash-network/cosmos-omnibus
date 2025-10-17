#!/bin/bash

# update-project-version.sh - Update version in cosmos-omnibus project
# Usage: ./update-project-version.sh <project-name> <old-version> <new-version>
# Example: ./update-project-version.sh akash v1.5.0 v1.6.0

set -euo pipefail

PROJECT_NAME="$1"
OLD_VERSION="$2"
NEW_VERSION="$3"

if [[ -z "$PROJECT_NAME" || -z "$OLD_VERSION" || -z "$NEW_VERSION" ]]; then
  echo "Usage: $0 <project-name> <old-version> <new-version>"
  exit 1
fi

if ! [[ "$OLD_VERSION" =~ ^v[0-9]+ ]] || ! [[ "$NEW_VERSION" =~ ^v[0-9]+ ]]; then
  echo "Versions must start with 'v' (e.g., v1.5.0)"
  exit 1
fi

echo "🔍 Updating $PROJECT_NAME from $OLD_VERSION → $NEW_VERSION"

PROJECT_DIR="./$PROJECT_NAME"
if [[ ! -d "$PROJECT_DIR" ]]; then
  echo "Project directory '$PROJECT_DIR' not found!"
  exit 1
fi

# Escape dots for regex (literal match)
OLD_ESCAPED="$(echo "$OLD_VERSION" | sed 's/\./\\./g')"
NEW_ESCAPED="$NEW_VERSION"

# Track temp files and success status - MUST be before trap
declare -a TEMP_FILES=()
declare -a ORIGINAL_FILES=()
ALL_SUCCESSFUL=true

# Cleanup function to remove temp files on script exit
cleanup() {
  if [[ ${#TEMP_FILES[@]} -gt 0 ]]; then
    for temp_file in "${TEMP_FILES[@]}"; do
      [[ -f "$temp_file" ]] && rm -f "$temp_file"
    done
  fi
  # Clean up any leftover .bak files
  find . \( -name "*.bak" -o -name "*.backup" -o -name "*.tmp.$$" \) -print0 2>/dev/null | xargs -0 rm -f 2>/dev/null || true
}

trap cleanup EXIT

echo ""
echo "Staging updates..."

# Function: safe_sed file 'cmd1' 'cmd2' ...
safe_sed() {
  local file="$1"
  shift
  local commands=("$@")

  if [[ ! -f "$file" ]]; then
    echo "   ⚠️  SKIP: $file does not exist"
    return 1
  fi

  echo "Staging: $(basename "$file")"

  # Create temp file for staging changes
  local temp_file="${file}.tmp.$$"
  cp "$file" "$temp_file"

  for cmd in "${commands[@]}"; do
    # macOS compatible sed (needs backup extension, use empty string)
    sed -i '' "$cmd" "$temp_file"
  done

  # Check if replacement happened
  if grep -q "$NEW_VERSION" "$temp_file" 2>/dev/null; then
    echo "   ✓ Staged: $file"
    TEMP_FILES+=("$temp_file")
    ORIGINAL_FILES+=("$file")
    return 0
  else
    echo "   ✗ FAILED: $file"
    rm -f "$temp_file"
    ALL_SUCCESSFUL=false
    return 1
  fi
}

# --- 1. build.yml ---
if [[ -f "$PROJECT_DIR/build.yml" ]]; then
  safe_sed "$PROJECT_DIR/build.yml" \
    "/VERSION:/s/${OLD_ESCAPED}/${NEW_VERSION}/" \
    "/BINARY_URL/s/${OLD_ESCAPED}/${NEW_VERSION}/g"
fi

# --- 2. deploy.yml ---
if [[ -f "$PROJECT_DIR/deploy.yml" ]]; then
  echo "Staging: deploy.yml"
  temp_deploy="${PROJECT_DIR}/deploy.yml.tmp.$$"
  cp "$PROJECT_DIR/deploy.yml" "$temp_deploy"
  
  if grep -q "image:" "$temp_deploy"; then
    sed -i '' -E "/image:[[:space:]]*ghcr\\.io/s|$OLD_ESCAPED|$NEW_ESCAPED|g" "$temp_deploy"
    
    if grep -q "$NEW_VERSION" "$temp_deploy" 2>/dev/null; then
      echo "   ✓ Staged: deploy.yml"
      TEMP_FILES+=("$temp_deploy")
      ORIGINAL_FILES+=("$PROJECT_DIR/deploy.yml")
    else
      echo "   ✗ FAILED: deploy.yml"
      rm -f "$temp_deploy"
      ALL_SUCCESSFUL=false
    fi
  else
    echo "   ⚠️  No image: field found in deploy.yml"
    rm -f "$temp_deploy"
  fi
fi

# --- 3. docker-compose.yml ---
if [[ -f "$PROJECT_DIR/docker-compose.yml" ]]; then
  echo "Staging: docker-compose.yml"
  temp_compose="${PROJECT_DIR}/docker-compose.yml.tmp.$$"
  cp "$PROJECT_DIR/docker-compose.yml" "$temp_compose"
  
  if grep -q "image:" "$temp_compose"; then
    sed -i '' -E "/image:[[:space:]]*ghcr\\.io/s|$OLD_ESCAPED|$NEW_ESCAPED|g" "$temp_compose"
    
    if grep -q "$NEW_VERSION" "$temp_compose" 2>/dev/null; then
      echo "   ✓ Staged: docker-compose.yml"
      TEMP_FILES+=("$temp_compose")
      ORIGINAL_FILES+=("$PROJECT_DIR/docker-compose.yml")
    else
      echo "   ✗ FAILED: docker-compose.yml"
      rm -f "$temp_compose"
      ALL_SUCCESSFUL=false
    fi
  else
    echo "   ⚠️  No image: field found in docker-compose.yml"
    rm -f "$temp_compose"
  fi
fi

# --- 4. Project README.md ---
if [[ -f "$PROJECT_DIR/README.md" ]]; then
  echo "Staging: Project README.md"
  temp_readme="${PROJECT_DIR}/README.md.tmp.$$"
  cp "$PROJECT_DIR/README.md" "$temp_readme"
  
  # Update Version field in markdown table
  sed -i '' "s/|[[:space:]]*Version[[:space:]]*|[[:space:]]*\`${OLD_ESCAPED}\`/|Version|\`${NEW_VERSION}\`/" "$temp_readme"
  
  # Update Image field - matches the pattern and replaces the version at the end
  sed -i '' "s/\(ghcr\.io\/akash-network\/cosmos-omnibus:v[0-9.]*-${PROJECT_NAME}-\)${OLD_ESCAPED}/\1${NEW_VERSION}/g" "$temp_readme"
  
  # Check if both updates happened
  if grep -q "|Version|\`${NEW_VERSION}\`" "$temp_readme" && grep -q "${PROJECT_NAME}-${NEW_VERSION}" "$temp_readme"; then
    echo "   ✓ Staged: Project README.md"
    TEMP_FILES+=("$temp_readme")
    ORIGINAL_FILES+=("$PROJECT_DIR/README.md")
  else
    echo "   ✗ FAILED: Project README.md"
    rm -f "$temp_readme"
    ALL_SUCCESSFUL=false
  fi
fi

# --- 5. Root README.md (project table) ---
if [[ -f "./README.md" ]]; then
  safe_sed "./README.md" \
    "/\[${PROJECT_NAME}\]/s/${OLD_ESCAPED}/${NEW_VERSION}/g"
fi

echo ""

# Apply changes only if all updates were successful
if [[ "$ALL_SUCCESSFUL" == true ]]; then
  echo "✅ All updates successful. Applying changes..."
  
  for i in "${!TEMP_FILES[@]}"; do
    temp_file="${TEMP_FILES[$i]}"
    original_file="${ORIGINAL_FILES[$i]}"
    
    # Apply the staged changes
    mv "$temp_file" "$original_file"
    
    echo "   Applied: $(basename "$original_file")"
  done
  
  # Clean up any remaining temp/backup files
  cleanup
  
  echo ""
  echo "✨ Version update complete for '$PROJECT_NAME': $OLD_VERSION → $NEW_VERSION"
else
  echo "❌ Some updates failed. Rolling back all changes..."
  
  # Clean up all temp files
  cleanup
  
  echo ""
  echo "⚠️  Version update aborted. No files were modified."
  exit 1
fi