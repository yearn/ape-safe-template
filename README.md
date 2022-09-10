# ape-safe-template
Template repository for getting started with ape-safe

# Prereqs
Install docker
Also, go to `.env` and add your infura project id

# How to run ape-safe using docker
Just do ```run.sh``` and you will end up in a shell in a docker container with ape-safe, brownie, and ganache-cli installed! This will also mount the repo into docker so you can change your `main.py` script and brownie on it.


How to run the function `main()` in `scripts/main.py` using a Goreli fork:
```
./run.sh
../activate.sh
brownie run main --network gor-main-fork
```