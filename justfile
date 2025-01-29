# list recipes
default:
    @just --list

# run latexmk
latexmk:
    latexmk -pdf -pvc -interaction=nonstopmode | pplatex -i - -q

# format all files in the repo
fmt:
    treefmt
