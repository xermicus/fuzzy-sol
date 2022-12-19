# Fuzzing solang

Fuzzing the solang compiler can be roughly divided into 3 stages:
1. Scrap the internet for some contracts to weed out low hanging fruits
2. "Semantically aware" fuzzing: Take an existing contracts corpus and apply mutations directly to solidity source code should yield more bugs
3. Low level fuzzing with something like AFL

# Scrapped contracts
Use the `scrap/single.sh` script. Nothing too fancy to see here, since this is a one-shot anyways. But it allowed to find several panics anyways.

`aphd.github.io` is the entire dump of [this](https://aphd.github.io/smart-corpus/). Only outdated (solc <= 0.6) contracts.

```bash
for i in 0 1 2 3 4 5 6 7 8 9 a A b B c C d D e E f F; do
  parallel ../single.sh substrate ::: 0x$i*;
done
```

`Messi-Q_Smart-Contract-Dataset` is another solidity [contract collection](https://github.com/Messi-Q/Smart-Contract-Dataset)

```bash
for i in 0 1 2 3 4 5 6 7 8 9 0 A B C D E F G H I J K L M N O P Q R S T U V W X Y Z; do
  parallel ../single.sh substrate ::: $i*;
done
```

`ScrawID` is a nice collection of ["Real World Ethereum Smartt Contracts Labelled with Vulnerabilities"](https://github.com/sujeetc/ScrawlD)

```bash
parallel ../single.sh substrate ::: *.sol
```


# Solidity source code fuzzing 

TBD

