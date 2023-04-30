# Node Typescript Bootstrapper

This is an opinionated bootstrapping script to setup a Node Typescript project. It is not perfect, but it gets you up and running pretty quickly by:

 - initialising a new npm project
 - adding typescript, eslint and jest depedendencies along with default config files for them
 - it creates basic Docker-, docker-compose and .dockerignore files
 - sets up a .gitignore and a README.md

## Usage
```sh
# create a directory for your project
mkdir my-app; cd my-app

# copy the file to your repo
cp /path/to/node-ts-bootstrap/ts-bootstrap.sh .

# execute it
sh ts-bootstrap.sh

# cleanup
rm ts-bootstrap.sh
```

## Issues
1. Documentation is lacking
1. Probably already outdated