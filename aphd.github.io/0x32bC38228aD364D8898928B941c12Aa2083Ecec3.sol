{{
  "language": "Solidity",
  "sources": {
    "Pngn.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\npragma solidity ^0.8.9;\n\ncontract Pngn{\n    address owner;\n    struct Player{\n        address payable addr;\n        uint last_action_time;\n        uint last_action_type;\n        bytes32 hash;\n        uint num;\n    }\n    \n    Player[8] players;\n    uint emptyseati = 9;\n    uint256 public withdrawableAmmount;\n    modifier onlyOwner() {\n        require(msg.sender == owner); //dev: You are not the owner\n        _;\n    }\n\n    modifier onlyWhenValueOk() {\n        require(msg.value == 0.2 ether); //dev: 0.2 ether only\n        _;\n    }\n    \n    \n\n    constructor() {\n        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor\n        withdrawableAmmount = 0;\n    }\n\n    function sit() external {\n        bool isNewPlayer = true;\n        for(uint i=0;i<8;i++){\n            if(players[i].addr == msg.sender){\n            //He already plays!\n                isNewPlayer = false;\n                break;\n            }\n        }\n        require(isNewPlayer==true); //dev: You are already playing\n        cleanup_players();\n        require(emptyseati != 9); //dev: There are no free seats\n        players[emptyseati].addr = payable(msg.sender);\n        players[emptyseati].last_action_time = block.timestamp;\n        players[emptyseati].last_action_type = 1;\n        uint opponenti;\n        if((emptyseati % 2) == 0){\n        //He is top\n            opponenti = emptyseati +1;\n        }\n        else{\n        //He is bottom\n            opponenti = emptyseati -1;\n        }\n        if(players[opponenti].addr != address(0)){\n            players[opponenti].last_action_time = block.timestamp - 1;\n        }\n    }\n\n    function pick(uint i, bytes32 _hash) external payable onlyWhenValueOk {        \n        require(i>=0 && i<8); //dev: Bad index\n        require(players[i].addr == msg.sender); //dev: You do not exist there\n        require(players[i].last_action_type == 1); //dev: You must be sitted to pick\n        uint opponenti;\n        if(i%2 == 0){\n            opponenti = i+1;\n        }\n        else{\n            opponenti = i-1;\n        }\n        require(players[opponenti].addr != address(0)); //dev: No opponent\n        players[i].last_action_type = 2;\n        players[i].last_action_time = block.timestamp;\n        players[i].hash = _hash;\n        players[i].num = 0;\n        players[opponenti].last_action_time = block.timestamp - 1;\n    }\n\n    function getPlayers() external view returns(Player[8] memory rp){\n        return players; \n    }\n\n    \n    function reveal(uint i, uint8 _pickednum, bytes32 _rand) external {\n        require(i>=0 && i<8); //dev: Bad index\n        require(players[i].addr == msg.sender); //dev: You do not exist there\n        require(_pickednum == 1 || _pickednum == 2); //dev: Invalid picked num\n        uint opponenti;\n        if(i%2 == 0){\n            opponenti = i+1;\n        }\n        else{\n            opponenti = i-1;\n        }\n        require(players[i].last_action_type == 2 ); //dev: You must be picked to reveal\n        require(players[opponenti].last_action_type > 1); //dev: Your opponent must be more than sitting\n        require(keccak256(abi.encodePacked(_pickednum,_rand))==players[i].hash); //dev: Your data failed verification\n        uint winneri = 9;\n        if(players[opponenti].last_action_type == 2){\n        // This is the first reveal\n            players[i].last_action_type = 3;\n            players[i].last_action_time = block.timestamp;\n            players[i].num = _pickednum;\n            players[opponenti].last_action_time = block.timestamp - 1; //refresh him too\n        }\n        else {\n        // This is the second reveal\n            if( _pickednum == players[opponenti].num){\n            //He found it\n                winneri = i;\n                players[i].num = _pickednum + 4;//He found it\n                players[opponenti].num = players[opponenti].num + 2;//He was guessed\n            }\n            else{\n            //He did not find it\n                winneri = opponenti; \n                players[i].num = _pickednum + 6;//He did not find it\n                // players[opponenti].num = players[opponenti].num ---> He was not guessed\n            }\n\n            players[i].last_action_type = 1;\n            players[i].last_action_time = block.timestamp;\n            players[i].hash = 0;\n            players[opponenti].last_action_type = 1;\n            players[opponenti].last_action_time = block.timestamp - 1;\n            players[opponenti].hash = 0;\n        }\n        if(winneri != 9){\n        //There is a winner pay him\n            address payable winner = players[winneri].addr;\n            withdrawableAmmount += 0.01 ether;\n            winner.transfer(0.39 ether);\n        }\n    }\n\n    function refundAndLeave(uint i) external {\n        bool canDo = false;\n        if(i>=0 && i<8){\n        //index in bounds\n            if(players[i].addr == msg.sender){\n            //ok it's his index\n                uint opponenti;\n                if(i%2 == 0){\n                //He is top-first\n                    opponenti = i+1;\n                }\n                else{\n                //He is bottom-second\n                    opponenti = i-1;\n                }\n                if(players[i].last_action_type == 2 && players[opponenti].last_action_type < 2){\n                //He is picked and no player or player sitting\n                    canDo = true;\n                }\n            }\n        }\n        require(canDo == true);//dev: Conditions insufficient\n        delete players[i];\n        cleanup_players();\n        payable(msg.sender).transfer(0.2 ether);\n    }\n\n    function kickAndWin(uint i) external {\n        bool canDo = false;\n        uint opponenti;\n        if(i>=0 && i<8){\n        //index in bounds\n            if(players[i].addr == msg.sender){\n            //ok it's his index\n                if(i%2 == 0){\n                //He is top-first\n                    opponenti = i+1;\n                }\n                else{\n                //He is bottom-second\n                    opponenti = i-1;\n                }\n                if(players[i].last_action_type == 3 && players[opponenti].last_action_type == 2 && (block.timestamp - players[opponenti].last_action_time ) > 15 minutes){\n                //He is revealed and the other is picked and late\n                    canDo = true;\n                }\n            }\n        }\n        require(canDo == true);//dev: Conditions insufficient\n        //Delete picked and late and pay revealer as a winner\n        delete players[opponenti];\n        players[i].last_action_type = 1;\n        players[i].last_action_time = block.timestamp;\n        players[i].hash = 0;\n        players[i].num = 9;\n        withdrawableAmmount += 0.01 ether;\n        cleanup_players();\n        payable(msg.sender).transfer(0.39 ether);\n    }\n\n    function cleanup_players() private {\n        emptyseati = 9;\n        uint priority_emptyseati = 9;\n        for(uint i=0;i<8;i=i+2){\n            if(players[i].addr != address(0) && players[i+1].addr != address(0)){\n            //if there are 2 players in this table\n                if(((block.timestamp - players[i].last_action_time) > 15 minutes) && players[i].last_action_type == 2 && players[i+1].last_action_type == 3){\n                //if first picker and late and second revealed then delete first and pay the second\n                    delete players[i];\n                    if(priority_emptyseati == 9) priority_emptyseati=i;\n                    players[i+1].last_action_type = 1;\n                    players[i+1].last_action_time = block.timestamp;\n                    players[i+1].hash = 0;\n                    players[i+1].num = 9;\n                    withdrawableAmmount += 0.01 ether;\n                    address payable winner_bylaterevealer = players[i+1].addr;\n                    winner_bylaterevealer.transfer(0.39 ether);\n                }\n                else if(((block.timestamp - players[i+1].last_action_time) > 15 minutes) && players[i+1].last_action_type == 2 && players[i].last_action_type == 3){\n                //if the other way arround delete second and pay first\n                    delete players[i+1];\n                    if(priority_emptyseati == 9) priority_emptyseati=i+1;\n                    players[i].last_action_type = 1;\n                    players[i].last_action_time = block.timestamp;\n                    players[i].hash = 0;\n                    players[i].num = 9;\n                    withdrawableAmmount += 0.01 ether;\n                    address payable winner_bylaterevealer = players[i].addr;\n                    winner_bylaterevealer.transfer(0.39 ether);\n                }\n                else if(((block.timestamp - players[i].last_action_time) > 15 minutes) && (block.timestamp - players[i+1].last_action_time) > 15 minutes && players[i].last_action_type == 2 && players[i+1].last_action_type == 2){\n                //if they are both picked and late make player with the most recent pick action a winner\n                    uint who=9;\n                    if(players[i].last_action_time > players[i+1].last_action_time){\n                        who = i;\n                    }\n                    else if(players[i+1].last_action_time > players[i].last_action_time){\n                        who = i+1;\n                    }\n                    else{\n                    //Equal lateness ?????? impossible. But make top-first a winner as a fallback decision\n                        who = i;\n                    }\n                    if(who != 9){\n                        address payable winner = players[who].addr;\n                        delete players[i];\n                        delete players[i+1];\n                        if(emptyseati == 9) emptyseati=i;\n                        withdrawableAmmount += 0.01 ether;\n                        winner.transfer(0.39 ether);\n                    }\n                }\n            }\n            //Having checked every case that has to do with payment, now check individually for a late sitter\n            for(uint j=0;j<2;j++){\n                if(players[i+j].addr != address(0) && (block.timestamp - players[i+j].last_action_time) > 15 minutes && players[i+j].last_action_type == 1){\n                //if not empty seat and sitted and late delete him\n                    delete players[i+j];\n                    if(priority_emptyseati == 9) priority_emptyseati = i + j;\n                }\n                else if(players[i+j].addr == address(0)){\n                    if(emptyseati == 9) emptyseati=i+j;\n                }\n            }\n        }\n        if(priority_emptyseati != 9){\n          emptyseati = priority_emptyseati;\n        }\n    }\n\n    function withdraw() external onlyOwner {\n        payable(msg.sender).transfer(withdrawableAmmount);\n        withdrawableAmmount = 0;\n    }\n}\n"
    }
  },
  "settings": {
    "evmVersion": "istanbul",
    "optimizer": {
      "enabled": true,
      "runs": 200
    },
    "outputSelection": {
      "*": {
        "*": [
          "evm.bytecode",
          "evm.deployedBytecode",
          "devdoc",
          "userdoc",
          "metadata",
          "abi"
        ]
      }
    }
  }
}}