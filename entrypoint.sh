#!/bin/sh

solc /usr/src/SimpleContract/SmartContract.sol --bin -o /usr/src/SimpleContract/bin --opcodes --overwrite --abi;
solc /usr/src/ico/SuperToken.sol --bin -o /usr/src/ico/bin --opcodes --overwrite --abi;