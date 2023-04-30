#!/bin/sh

# Initialise a new project
npm init -y

# Install TypeScript
npm i -D typescript
npm i -D @types/node

npx tsc --init \
    --rootDir src \
    --outDir dist \
    --esModuleInterop \
    --resolveJsonModule \
    --lib es6 \
    --module commonjs \
    --allowJs false \
    --noImplicitAny true

# ...add a second tsconfig for building to exclude spec files
cat >tsconfig.prod.json <<EOL
{
    "extends": "./tsconfig",
    "exclude": [
        "**/*.spec.ts"
    ]
}
EOL

# Setup placeholder code
mkdir src

cat >src/index.ts <<EOL
console.log('Hello, Bob')
EOL

cat >src/index.spec.ts <<EOL
describe('testing index.ts', () => {
    test('placeholder', () => {
        expect(1).toBe(1)
    })
})
EOL

# Setup ES Lint
npm i -D eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin

cat >.eslintrc <<EOL
{
  "root": true,
  "parser": "@typescript-eslint/parser",
  "plugins": [
    "@typescript-eslint"
  ],
  "extends": [
    "eslint:recommended",
    "plugin:@typescript-eslint/eslint-recommended",
    "plugin:@typescript-eslint/recommended"
  ]
}
EOL

cat >.eslintignore <<EOL
node_modules
dist
EOL

# Setup Tests/Jest
npm i -D jest @types/jest ts-jest

cat >jest.config.js <<EOL
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
};
EOL

# Setup package.json
node -p "\
var data = require('./package.json'); \
data.scripts['build'] = 'rm -rf ./dist && tsc -p tsconfig.prod.json'; \
data.scripts['lint'] = 'eslint . --ext .ts'; \
data.scripts['lint:fix'] = 'eslint . --ext .ts --fix'; \
data.scripts['start'] = 'node dist/index.js'; \
data.scripts['start:dev'] = 'npm run lint && npm run test && node dist/index.js'; \
data.scripts['test'] = 'jest --coverage'; \
data.scripts['test:watch'] = 'jest --coverage --watch'; \
JSON.stringify(data, null, 2); \
" > package.tmp

rm package.json
mv package.tmp package.json

# Setup Docker
cat >Dockerfile <<EOL
ARG IMG=node:18-alpine

# Build
FROM \$IMG as builder
WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm test
RUN npm run build

# Runtime
FROM \$IMG
ENV NODE_ENV production
USER node
WORKDIR /app

COPY package*.json ./
RUN npm ci --production

COPY --from=builder /app/dist ./dist

CMD [ "node", "dist/index.js" ]
EOL

cat >docker-compose.yml <<EOL
version: "3"
services:
  app:
    build: .
EOL

cat >.dockerignore <<EOL
# Ignore everything
*

# Allow source
!/src
!/jest.config.js
!/package*.json
!/tsconfig*.json

# Ignore files inside allowed directories
**/*.log
**/.DS_Store
**/Thumbs.db
EOL

# Setup git
cat >.gitignore <<EOL
# Ignore all dot files except
.*
!.dockerignore
!.eslintignore
!.eslintrc
!.gitignore

# Ignore build and test artifacts
coverage
dist
node_modules

# Ignore this file
ts-init.sh
EOL

DIRNAME="${PWD##*/}"

cat >README.md <<EOL
# $DIRNAME

I totally promise to update this file.

## Usage

- \`npm test\` - run the tests. Use the \`:watch\` modifier if needed.
- \`npm run lint\` - run the linter. Use the \`:fix\` modifier to automatically fix linting issues.
- \`npm run build\` - build and outputs to the ./dist directory.
- \`npm start\` - executes the application in ./dist.
- \`npm run start:dev\` - this will run the linter and tests before executing the application in ./dist.

## Docker
Build the Docker image
\`\`\`
docker build -t $DIRNAME .
# or use docker compose
docker compose build
\`\`\`

Run the application
\`\`\`
docker run --rm $DIRNAME
# or use docker compose
docker run --rm app
\`\`\`
EOL