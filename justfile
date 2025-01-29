# list recipes
default:
    @just --list

# run latexmk
latexmk:
    latexmk -pdf -pvc

# format all files in the repo
fmt:
    treefmt
