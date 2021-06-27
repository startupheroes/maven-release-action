# Maven releaser docker action

This action provides an easy way to execute maven release workflows inside your repository using GitHub Actions.

## Requirements

- This action needs you to use `actions/checkout` to have a repository to work on. See `Example Usage`
- This action needs you to have a maven wrapper available in your project root directory. e.g. `./mvnw`

## Inputs

## `project-pom-location`

**Optional** `pom.xml` file location relative to the project root. Default: `"./pom.xml"`

## `versioning`

**Optional** SemVer versioning - patch, minor, major. Default: `"patch"`

## Outputs

## `message`

Output message of the release containing information about release or errors if any
### Examples: 
#### Success
```markdown
Release *finished!* :white_check_mark:
    *Artifact:* example 
    *Repository:* organization/example-project 
    *Release Version:* 1.23.4
```
#### Example Error
```markdown
organization/example-project tests has failed :red_circle:
```

## Example usage
```yaml
- uses: actions/checkout@v2
- uses: startupheroes/maven-release@v1
  with:
    project-pom-location: './pom.xml'
    versioning: 'patch'
    github-token: ${{ github.token }}
```