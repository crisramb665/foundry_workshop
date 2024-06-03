-include .env

SHELL := /bin/bash

install :; forge install

build :; forge clean && forge build

test-coverage-report :; forge coverage --report lcov

test-gas-report :; forge test --gas-report -vvv

deploy :; source .env && forge script script/Staker.s.sol:StakerDeploy --rpc-url ${RPC_URL} --private-key ${PRIVATE_KEY} --skip-simulation --broadcast --verify --etherscan-api-key ${ARBISCAN_API_KEY} -vvvv

deploy-fork :; source .env && forge script script/Staker.s.sol:StakerDeploy --fork-url http://localhost:8545 --private-key ${PRIVATE_KEY} --broadcast -vvvv

scripts :; chmod +x ./scripts/*