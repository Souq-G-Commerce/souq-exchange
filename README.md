```
  ____     ___    _   _    ___        _____   ___   _   _      _      _   _    ____   _____ 
 / ___|   / _ \  | | | |  / _ \      |  ___| |_ _| | \ | |    / \    | \ | |  / ___| | ____|
 \___ \  | | | | | | | | | | | |     | |_     | |  |  \| |   / _ \   |  \| | | |     |  _|  
  ___) | | |_| | | |_| | | |_| |  _  |  _|    | |  | |\  |  / ___ \  | |\  | | |___  | |___ 
 |____/   \___/   \___/   \__\_\ (_) |_|     |___| |_| \_| /_/   \_\ |_| \_|  \____| |_____|

```
# Souq NFT AMM V1

This repository contains all the core smart contract source code for Souq NFT AMM V1. The repository uses Hardhat as development environment for compilation, testing and deployment tasks.

# What is Souq?

Souq.finance is building an Automated Market Maker (AMM) as one its products for the purpose of trading non-fungible tokens (NFTs). The purpose of this AMM is to introduce a superior, incentive-aligned fee structure for project ecosystems, improve market efficiency and pricing dynamics, and enable instant liquidity in NFT markets.

## License
This repository is under Business Source License explained in the LICENSE.md file in this directory.

## Connect with the community
You can join the [Discord](https://discord.gg/clubsouq) channel if you have any inquiries or to connect with the community of souq users.

## Documentation

You can find all the technical documentation for the souq project in the following link

- [Technical Documentation](https://docs.souq.finance/)

## Getting Started

### Extra Documentation and Tutorials
The project is run as a Hardhat-based project, with sensible defaults.

- [Hardhat](https://github.com/nomiclabs/hardhat): compile, run and test smart contracts
- [Hardhat Docs](https://hardhat.org/docs). You might be in particular interested in reading the
- [Testing Contracts](https://hardhat.org/tutorial/testing-contracts) section.
- [Hardhat Tutorial](https://hardhat.org/tutorial): Full hardhat tutorial

### Sensible Defaults

This repository comes with sensible default configurations in the following files:

```text
├── .commitlintrc.yml
├── .editorconfig
├── .eslintignore
├── .eslintrc.yml
├── .gitignore
├── .prettierignore
├── .prettierrc.yml
├── .solcover.js
├── .solhintignore
├── .solhint.json
├── .yarnrc.yml
└── hardhat.config.ts
```

### GitHub Actions

This repository comes with GitHub Actions pre-configured. Your contracts will be linted and tested on every push and pull
request made to the `main` branch.

Note though that to make this work, you must use your `ALCHEMY_API_KEY` and your `MNEMONIC` as GitHub secrets.

You can edit the CI script in [.github/workflows/ci.yml](./.github/workflows/ci.yml).

### Conventional Commits

This repository enforces the [Conventional Commits](https://www.conventionalcommits.org/) standard for git commit
messages. This is a lightweight convention that creates an explicit commit history, which makes it easier to write
automated tools on top of.

### Git Hooks

This repository uses [Husky](https://github.com/typicode/husky) to run automated checks on commit messages, and
[Lint Staged](https://github.com/okonet/lint-staged) to automatically format the code with Prettier when making a git
commit.

## Usage

### Pre Requisites

Before being able to run any command, you need to create a `.env` file and set a BIP-39 compatible mnemonic as an
environment variable. You can follow the example in `.env.example`. If you don't already have a mnemonic, you can use
this [website](https://iancoleman.io/bip39/) to generate one.

Then, proceed with installing dependencies:

```sh
$ yarn install
```

### Compile

Compile the smart contracts with Hardhat:

```sh
$ yarn compile
```

### TypeChain

Compile the smart contracts and generate TypeChain bindings:

```sh
$ yarn typechain
```

### Test

Run the tests with Hardhat:

```sh
$ yarn test
```

To test specific script:

```sh
$ npx hardhat test test/<Sub_Folder>/<File_Name>.spec.ts
```

### Lint Solidity

Lint the Solidity code:

```sh
$ yarn lint:sol
```

### Lint TypeScript

Lint the TypeScript code:

```sh
$ yarn lint:ts
```

### Coverage

Generate the code coverage report:

```sh
$ yarn coverage
```

### Report Gas

See the gas usage per unit test and average gas per method call:

```sh
$ REPORT_GAS=true yarn test
```

### Clean

Delete the smart contract artifacts, the coverage reports and the Hardhat cache:

```sh
$ yarn clean
```

### Deploy

Deploy the contracts to Hardhat Network:

```sh
$ yarn deploy --welcome "Hello, welcome"
```
Goerli Testnet

```sh
$ npx hardhat run --network goerli scripts/deploy.ts
```

## Tips

### Syntax Highlighting

If you use VSCode, you can get Solidity syntax highlighting with the
[hardhat-solidity](https://marketplace.visualstudio.com/items?itemName=NomicFoundation.hardhat-solidity) extension.
