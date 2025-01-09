set positional-arguments

# default recipe to display help information
default:
    @just --list

# Spawns the devnet
devnet-up:
    @just ./devnet/devnet-up
    @just ./contracts/deploy-contracts

# Stops the devnet **This will prune all docker containers**
devnet-down:
    @just ./devnet/devnet-down

e2e-test:
    @just ./world-chain-builder/e2e-test

# Builds and tags the world-chain-builder image
build:
    @just ./devnet/build

build-node *args='':
    @just ./world-chain-builder/build-max-perf $@

# Tests the world-chain-builder
test:
    @just ./world-chain-builder/test

# Formats the world-chain-builder
fmt: 
    @just ./world-chain-builder/fmt
