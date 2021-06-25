#!/bin/sh -l

PROJECT_REPO=${GITHUB_REPOSITORY##*/}
PROJECT_POM_LOCATION=$1
VERSIONING=$2

cd "$GITHUB_WORKSPACE/$PROJECT_REPO"
if [ $? -ne 0 ]; then
	echo "Could not find repository named $PROJECT_REPO"
	echo "::set-output name=message::Could not find repository named $PROJECT_REPO :thinking_face:"
	exit 1
fi

latest_pom_snapshot=$(./mvnw -f "$PROJECT_POM_LOCATION" help:evaluate -D expression=project.version -q -D forceStdout)
# remove postfixes (e.g. -snapshot) from dev version
pom_version=${latest_pom_snapshot%%-*}
if [[ $VERSIONING == 'patch' ]]; then
  release=$pom_version
else
  release=$(semver "$pom_version" -i "$VERSIONING")
fi
next=$(semver "${release}" -i patch)
project_pom_artifact=$(./mvnw -f "$PROJECT_POM_LOCATION" help:evaluate -D expression=project.artifactId -q -D forceStdout)

./mvnw -f "$PROJECT_POM_LOCATION" scm:check-local-modification
if [ $? -ne 0 ]; then
	echo "::set-output name=message::The build will stop as there is local modifications on $PROJECT_REPO :thinking_face:"
	exit 1
fi

echo "::set-output name=release_version::${release}"

./mvnw -f "$PROJECT_POM_LOCATION" versions:set -D newVersion="${release}"
git commit -am "Release ${release}"

if [ $? -ne 0 ]; then
	echo "Commit for preparing release has failed."
	echo "::set-output name=message::Commit for preparing release has failed for $PROJECT_REPO :thinking_face:"
	exit 1
fi

./mvnw -f "$PROJECT_POM_LOCATION" clean deploy scm:tag -P release \
       -D tag="${release}" \
       -D pushChanges=false \
       -D dependency-check.skip

./mvnw -f "$PROJECT_POM_LOCATION" versions:set -D newVersion="${next}"-SNAPSHOT
git commit -am "Set development version ${next}-SNAPSHOT"

git push && git push --tags
if [ $? -ne 0 ]; then
	echo "Commit for setting next development version has failed."
	echo "::set-output name=message::Commit for setting next development version has failed for $PROJECT_REPO :thinking_face: "
	exit 1
fi

cd -

echo "Release successfully finished."
echo "::set-output name=message::Release *finished!* :white_check_mark: *Artifact:* $project_pom_artifact *Repository:* $PROJECT_REPO *Release Version:* ${release}"
