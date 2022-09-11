#!/bin/bash

# Increment a version string using Semantic Versioning (SemVer) terminology.

# Parse command line options.

if [[ "$1" =~ "major" ]]; then
  major=true
elif [[ "$1" =~ "minor" ]]; then
  minor=true
elif [[ "$1" =~ "patch" ]]; then
  patch=true
fi

shift

#version=$1
echo "cd to github workspace"
cd "${GITHUB_WORKSPACE}" || exit
git for-each-ref refs/tags/ --count=1 --sort=-version:refname --format='%(refname:short)'

version=$(git for-each-ref refs/tags/ --count=1 --sort=-version:refname --format='%(refname:short)')
echo "Version: ${version}"

if [ -z "${version}" ]; then
  echo "Couldn't determine version"
  exit 1
fi
# Build array from version string.

a=(${version//./ })
major_version=0

# Increment version numbers as requested.

if [ -n "$major" ]; then
  # Check for v in version (e.g. v1.0 not just 1.0)
  if [[ ${a[0]} =~ ([vV]?)([0-9]+) ]]; then
    v="${BASH_REMATCH[1]}"
    major_version=${BASH_REMATCH[2]}
    ((major_version++))
    a[0]=${v}${major_version}
  else
    ((a[0]++))
    major_version=a[0]
  fi

  a[1]=0
  a[2]=0
fi

if [ -n "$minor" ]; then
  ((a[1]++))
  a[2]=0
fi

if [ -n "$patch" ]; then
  ((a[2]++))
fi

echo "${a[0]}.${a[1]}.${a[2]}"
version="${a[0]}.${a[1]}.${a[2]}"
just_numbers="${major_version}.${a[1]}.${a[2]}"
echo "::set-output name=version::${version}"
echo "::set-output name=stripped-version::${just_numbers}"
