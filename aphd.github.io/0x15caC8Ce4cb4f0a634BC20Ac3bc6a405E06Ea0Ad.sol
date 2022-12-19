{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "istanbul",
    "libraries": {},
    "metadata": {
      "bytecodeHash": "ipfs",
      "useLiteralContent": true
    },
    "optimizer": {
      "enabled": true,
      "runs": 200
    },
    "remappings": [],
    "outputSelection": {
      "*": {
        "*": [
          "evm.bytecode",
          "evm.deployedBytecode",
          "abi"
        ]
      }
    }
  },
  "sources": {
    "contracts/v2/IOldMetaHolder.sol": {
      "content": "//SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\n/// @title IOldMetaHolder\n/// @author Simon Fremaux (@dievardump)\ninterface IOldMetaHolder {\n    function get(uint256 tokenId)\n        external\n        pure\n        returns (\n            uint256,\n            string memory,\n            string memory\n        );\n}\n"
    },
    "contracts/v2/OldMetaHolder.sol": {
      "content": "//SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\nimport './IOldMetaHolder.sol';\n\n/// @title IOldMetaHolder\n/// @author Simon Fremaux (@dievardump)\ncontract OldMetaHolder is IOldMetaHolder {\n    function get(uint256 tokenId)\n        external\n        pure\n        override\n        returns (\n            uint256,\n            string memory,\n            string memory\n        )\n    {\n        if (tokenId == 1) {\n            return (\n                1891779262497205,\n                'Fana',\n                'QmZQYVKggf3FHfF68C7qjMNqQYAgnYDa7UBe35Bqg1tKL9'\n            );\n        }\n        if (tokenId == 2) {\n            return (\n                3019419497262163,\n                'georgeboya',\n                'Qma5UjjVVJfg3uzk4BHJrvn8REpahurgQCtRJPeju2wBe7'\n            );\n        }\n        if (tokenId == 3) {\n            return (\n                7689739740778617,\n                'SnaileXpress',\n                'QmVGe3Hd6ggPR4uPfZ8iw2A3ZWDwNzFXbhUCkERMpywrvT'\n            );\n        }\n        if (tokenId == 4) {\n            return (\n                6982555367698223,\n                'studionouveau',\n                'QmTSm5nCcFSL9GrWR8EJtPSraXJ6VE3KWJM5eqRhs1aScn'\n            );\n        }\n        if (tokenId == 5) {\n            return (\n                1510385436526155,\n                'DAIMALYAD',\n                'QmPh8hgqTzmt7wzXcZofiDNAvoirefGu1yE2bz6btFmyBC'\n            );\n        }\n        if (tokenId == 6) {\n            return (\n                5923251554066009,\n                'ChaosC',\n                'QmUBe17AqQBLRKkc6Ary5Vzfni7mv6yCKoSuUFP1ZCCeL4'\n            );\n        }\n        if (tokenId == 7) {\n            return (\n                8791714849687747,\n                'HODL',\n                'QmZZjjkFRjPsDW3QBRiXToozk56Vk2yZB6MW23MHNCqkgV'\n            );\n        }\n        if (tokenId == 8) {\n            return (\n                6988284344166647,\n                'HisDudeness',\n                'QmTaXXRmMZstDMaR7fqdXvViU2d4o3h6Z8w5fgXihxtpFF'\n            );\n        }\n        if (tokenId == 9) {\n            return (\n                4520157963886749,\n                'STUREC',\n                'QmYYFDCPrCCV2Eie1kWTwmffka5gY4r8MLq5hfwuJwD7nC'\n            );\n        }\n        if (tokenId == 10) {\n            return (\n                8687588643696989,\n                'WMP',\n                'Qmcqxn9vUwU1MRC4xA57jhGB2zaRHorKhWwYDdr4zmAFnK'\n            );\n        }\n        if (tokenId == 11) {\n            return (\n                5948983295283979,\n                'Evil',\n                'QmXnv4Vmo6LH5AxHykx5czHMKC5pXAuHDv8c5xhqXTSqf5'\n            );\n        }\n        if (tokenId == 12) {\n            return (\n                2557921492214273,\n                'MehakJain',\n                'QmedQq5eXWn8MtEmZLQDwdeqHJrVuZNYpwwKppubThBKMP'\n            );\n        }\n        if (tokenId == 13) {\n            return (\n                4923016702189283,\n                'TACO',\n                'QmX8qekdJAu7HFFjRARBSWgrzNidtcb78or93pDGxnEwiJ'\n            );\n        }\n        if (tokenId == 14) {\n            return (\n                503230352259835,\n                'JJ',\n                'QmWEykS91b1Sm2U169UWt6LEL7uNd1YswE2DsKUXgWq5sZ'\n            );\n        }\n        if (tokenId == 15) {\n            return (\n                3393466007662535,\n                'bluen1ne',\n                'QmTUo524U8HYVH3Jj6Bs8BMPpEmBPJC2GWEVYQj71BFuPs'\n            );\n        }\n        if (tokenId == 16) {\n            return (\n                5968451401041859,\n                'everlasting',\n                'QmV22YbH8VDbRSSrwp2rCxWb42i6TQjSQ9ovLSMS3Ancz4'\n            );\n        }\n        if (tokenId == 17) {\n            return (\n                7755993193895255,\n                'DragoNate',\n                'Qmdx8RZUejp6CAfSc218bqFP45TA7jAe4Sz5JQbAQBkd8J'\n            );\n        }\n        if (tokenId == 18) {\n            return (\n                4875848917732907,\n                'BabyLion',\n                'Qmf9RxknEmvnVfFXe9PnnFayzTwZUW6NZ2nLahs79fpbTL'\n            );\n        }\n        if (tokenId == 19) {\n            return (\n                3456254112895985,\n                'bergleeuw',\n                'QmSQsQiAJHWNPekaL7NqDt8zcfRYCApKEMjainBMoZmB6H'\n            );\n        }\n        if (tokenId == 20) {\n            return (\n                7098169906134027,\n                'Enigma',\n                'Qma69PAFnsgecw9sJzZRGc2yzMJY62ibJpwUcokuhzBref'\n            );\n        }\n        if (tokenId == 21) {\n            return (\n                3457563018359027,\n                'barthazian',\n                'Qmea4eDirwcguSLSyyS86y2a3PwcWSmtT4cw8b1sLGETqf'\n            );\n        }\n        if (tokenId == 22) {\n            return (\n                5816344603404167,\n                'URBANA',\n                'QmNaHjSvZUJqB1TZ3mVgD2JdeK6ctY9c2WGLNSywjpGpaB'\n            );\n        }\n        if (tokenId == 23) {\n            return (\n                3174680349988913,\n                'tea_eye',\n                'QmfThzkWFgn4cb9wAJ3NPMP2mZACsvCx3tohVRrHFAGqCH'\n            );\n        }\n        if (tokenId == 24) {\n            return (\n                8496431026892907,\n                'Gotrilla',\n                'QmPpMpqBgXGuNA3eFj1dvKND8rkQtabQgM3VDoLxPCcpV3'\n            );\n        }\n        if (tokenId == 25) {\n            return (\n                413351762046683,\n                'jims',\n                'QmUNAwEM63YvnaZEaVhH9YBM5aA7qL9M8ey8x8CunHks9B'\n            );\n        }\n        if (tokenId == 26) {\n            return (\n                1138136008402565,\n                'Tomato',\n                'Qmci3YFcU7VMao3z11BatFX9NypUbv6Acs8ZokQK4v3omr'\n            );\n        }\n        if (tokenId == 27) {\n            return (\n                375537615587261,\n                'Harambe',\n                'QmdAsSbhfPg5XdS2AuuuUNQuVUoSU43XARN6ZX4Jh3L2Fy'\n            );\n        }\n        if (tokenId == 28) {\n            return (\n                8090389347118167,\n                'SP4CE',\n                'QmProUnCGpmK5PoUiuzYoF4zw7DCxxiBo2zRXfDidmstQy'\n            );\n        }\n        if (tokenId == 29) {\n            return (\n                5400266765307335,\n                'cali',\n                'Qme4KQU1W4jfYX5BHvNDEckRnzSTNTFefUyYqjbSgKieSd'\n            );\n        }\n        if (tokenId == 30) {\n            return (\n                2597411029448361,\n                'bryanbrinkman',\n                'QmWbi8zvBvwzv8yrubtL83udFXXJ8d7BwacCAuMNz7b2F9'\n            );\n        }\n        if (tokenId == 31) {\n            return (\n                3936824586365177,\n                'CPyrc',\n                'QmR2cdB8uFVKEM2x5B5d7vw21fYHwWEyUpsZTdirDWnAb4'\n            );\n        }\n        if (tokenId == 32) {\n            return (\n                1885984200493465,\n                'bitch',\n                'QmfBiXPmaaKudKUgoqSJzqchiBvxc4yYUgyrpWR27qw2Fw'\n            );\n        }\n        if (tokenId == 33) {\n            return (\n                4383631648904757,\n                'redlioneye',\n                'QmYhJhKZduPdwRUUbAHi8V2F51vKh6NnVSpQZUNkir1o5f'\n            );\n        }\n        if (tokenId == 34) {\n            return (\n                2230863757095789,\n                'AnnMarieAlanes',\n                'QmRHPaU4or41Dbnb9t7nfe5j8r6rma6XUPQGUnZqM2FGRd'\n            );\n        }\n        if (tokenId == 35) {\n            return (\n                418337872527845,\n                'xray',\n                'QmewNDHACH2GsC3TLcyZokeydEJN5EdHwnG7B3wwcFpyXp'\n            );\n        }\n        if (tokenId == 36) {\n            return (\n                4080317775462397,\n                'Twobadour',\n                'QmSBRnpNxhZV8ji34QFfvZe2NQZJ8ovApw7YUZrjp4SkCk'\n            );\n        }\n        if (tokenId == 37) {\n            return (\n                4298717361819411,\n                'Space',\n                'QmNkMEMSEqvjyt8hzMBHjYNRDvrpzuYX3QGLgcdLk65PKq'\n            );\n        }\n        if (tokenId == 38) {\n            return (\n                8729027721952123,\n                'Pablo',\n                'QmWfSPSmFG6HZYV4u3uE14MtAt4Jq5yLcXTLe61LAZtnxq'\n            );\n        }\n        if (tokenId == 39) {\n            return (\n                2388704601596245,\n                'Desi',\n                'QmeQvDa4knJ5dY9zcd9LvLzwRFm88SXGkFzTbzjbMekzXw'\n            );\n        }\n        if (tokenId == 40) {\n            return (\n                8393750241199603,\n                'Hunter_NFT',\n                'QmVowT6nhZRdSMDRiVjs1m37N84BVR6uPREobBSTKCbrUW'\n            );\n        }\n        if (tokenId == 41) {\n            return (\n                4562793198440239,\n                'nftartcards',\n                'QmWDNtC33SYPVnybZEUYfm4Kc9XV2U9CgZAgo45bhttjQ7'\n            );\n        }\n        if (tokenId == 42) {\n            return (\n                153705409506349,\n                'BruceTheGoose',\n                'QmXfezn24ntPJgneUfUeP7mkvc9BUDekqxNZ5ahkmzgQFa'\n            );\n        }\n        if (tokenId == 43) {\n            return (\n                142983777563647,\n                'Silence',\n                'Qmf4becQQJXWcnZB1Cv7r4bHG2dVdYKWRxeRvgmkmQ3tUG'\n            );\n        }\n        if (tokenId == 44) {\n            return (\n                2806355914071487,\n                '07.12.19',\n                'QmcWhKd2X9hh5KBNbj8vQCDoGYBhZTdRLmvNSMR6WWW7nQ'\n            );\n        }\n        if (tokenId == 45) {\n            return (\n                7737953903733737,\n                'MantaXR',\n                'QmQoHTabQQVYA9jHCRb39hQmDqTr2vhBbLyzcPEs67sNuw'\n            );\n        }\n        if (tokenId == 46) {\n            return (\n                6802622488411019,\n                'NGMI',\n                'QmZTWu9TkgMguwmckThfcRpKGTtM76dLr2AnfQLYkHGMTF'\n            );\n        }\n        if (tokenId == 47) {\n            return (\n                2453013391125737,\n                'BitAndrew',\n                'QmVTJJVh9x9P1wFifffFA39mzod6KGRKLHVFbyw1ontQ7s'\n            );\n        }\n        if (tokenId == 48) {\n            return (\n                2465057794406231,\n                'NFTValley',\n                'QmNkT7KHcL4NvyrXhL4b98Lq5AnjFK85SELzcKZnhDj2J3'\n            );\n        }\n        if (tokenId == 49) {\n            return (\n                4991684195400103,\n                'Wallkanda',\n                'QmbhFf7XF76HY7unRMoMT6NT5HpYhEMt8xyExX3YV9xbTv'\n            );\n        }\n        if (tokenId == 50) {\n            return (\n                5433022144351547,\n                'CaktuxFundsArtTheft',\n                'QmezKk6sC6FEGcaF8vtEA4TiqCXcdTL7PyiFnnmSEkEdCT'\n            );\n        }\n        if (tokenId == 51) {\n            return (\n                875032090208313,\n                'Atlantis',\n                'QmZF3MWmfDy22bggbSJYQshjysRvVWKJkCKNQX1PCESMCB'\n            );\n        }\n        if (tokenId == 52) {\n            return (\n                8771349494261373,\n                'Joff',\n                'QmTXtz67BrmwxYy1coHWBkoT4fm4avMVhEoVgAcLQRsg3K'\n            );\n        }\n        if (tokenId == 53) {\n            return (\n                5236512245990149,\n                'SuperMassive',\n                'QmVyXMRC6ex1p8RGGrwEsyXRSvU4ioKy9NqJJr34syww59'\n            );\n        }\n        if (tokenId == 54) {\n            return (\n                8622795196955971,\n                'ShinjiAkhirah',\n                'QmXg23tciPqvH4a36PuYadWVbpnuXhGP7UEqgmT4sUK83Z'\n            );\n        }\n        if (tokenId == 55) {\n            return (\n                5591623809830205,\n                'GREEKDX',\n                'QmQqojVETod2yZNTTVNojhdNySPZ56R3uXy4XrE28Xe7uL'\n            );\n        }\n        if (tokenId == 56) {\n            return (\n                4590813225046495,\n                'APEDEV',\n                'QmeV97pf42tzt9b4f4J4jpvBfER1BEi2zonw6HBXJvuEVq'\n            );\n        }\n        if (tokenId == 57) {\n            return (\n                4745774527000625,\n                'Ebbo',\n                'QmUhiA7c8E8WTKppz85YqBFMxjssJhkbtwJhGLRv31CbtZ'\n            );\n        }\n        if (tokenId == 58) {\n            return (\n                4862399629459103,\n                'SuperTopSecret',\n                'QmXiFnUV6QNhfbx7ACkcWdyPvkt6gpeEE83xKTLWHMX155'\n            );\n        }\n        if (tokenId == 59) {\n            return (\n                4381414138919363,\n                'WHYNOTME',\n                'Qmc6b56YNrgTfavzx1c47pt1J1LFUXkg7dYv6wg8knmuXy'\n            );\n        }\n        if (tokenId == 60) {\n            return (\n                7391300037459061,\n                'ElonMusk',\n                'QmQAuq1a9jm2Dr6sG3HtwGH4xRmTkn5AWE74pPrCAU641t'\n            );\n        }\n        if (tokenId == 62) {\n            return (\n                115990660039927,\n                'WGMeets',\n                'QmXTJabgMuhGi5etbKj6jnEKwS4pN8qJHHipAsTjC76J3T'\n            );\n        }\n        if (tokenId == 63) {\n            return (\n                5079846608831287,\n                'HumptyDigital',\n                'QmaWCeSutLtNJ6DXvsMtkZvwM8isVx1Z3r8R7YC6wcGDyJ'\n            );\n        }\n        if (tokenId == 64) {\n            return (\n                5570565631105865,\n                'orty',\n                'QmcYg3FetydSsgU2usHtAdWEMrmYveDgLsCpcNMo2pMntk'\n            );\n        }\n        if (tokenId == 65) {\n            return (\n                5977411952183263,\n                'SysAdmInCrypto',\n                'Qme8dBkZjG1iTkjG86a7KxwjMBxsjUe2e5eLSgKW1HgcTn'\n            );\n        }\n        if (tokenId == 66) {\n            return (\n                7973704714097377,\n                'RFC',\n                'QmRBiK1eqgFWDxKCMRP9CcfZHE4QMqmVnnycq6SgFPVhRR'\n            );\n        }\n        if (tokenId == 67) {\n            return (\n                8304996682849101,\n                '555',\n                'QmUPbEg9uQ4vRgt4qSw5X9R9NwvZNFKbGuimQe4cdRLPrk'\n            );\n        }\n        if (tokenId == 68) {\n            return (\n                7185966646180013,\n                'guido',\n                'QmeyVk7NAYpZFqwyfNZktoLhC93hMDKGeYUqWGVm7vcqjX'\n            );\n        }\n        if (tokenId == 69) {\n            return (\n                3645940995873561,\n                'Tazposts',\n                'QmPexfrP6H9Jf11AWP92qKYMaoh7gA4yoBAuese6aqkA8n'\n            );\n        }\n        if (tokenId == 70) {\n            return (\n                181688662956301,\n                'FRAMBOR-BREWERY',\n                'QmUMMu1np9wx1UNdZcTCsRMzwsopNEu3UYC4cz7D77Ntum'\n            );\n        }\n        if (tokenId == 71) {\n            return (\n                8117363819514271,\n                'Chiara',\n                'QmbVFTNmER4ETHuvL4nPSftYuaSkgRuWhT6rAvjkRZ8aGP'\n            );\n        }\n        if (tokenId == 72) {\n            return (\n                8454038579543797,\n                'm00se',\n                'Qmc6EB3BU73fBmx6FANTb4RenZ4us4vwT145tsY9JTnzRU'\n            );\n        }\n        if (tokenId == 73) {\n            return (\n                5818393290185465,\n                'DAAN',\n                'QmVfPcZvbFtQ4EeyzZouuZ84rJDaSb5vb8h9PwHULsW5b8'\n            );\n        }\n        if (tokenId == 74) {\n            return (\n                4473354115576139,\n                'STIJN',\n                'QmPnNMgHhGSzbHSQpvbc3gMb3xMuEca3Ha2vipvDzcAoKZ'\n            );\n        }\n        if (tokenId == 75) {\n            return (\n                196038521084569,\n                'EMMA',\n                'QmRpHVLftC9Z5DiEUtRJrcsqS7BTE5j9TzcgqRHLNxXqUJ'\n            );\n        }\n        if (tokenId == 76) {\n            return (\n                4636829616986687,\n                'simulation',\n                'QmfSQp9H9U1LeKmguhBt6p8m3euaAXUeo6J2F7BiP2Kgxs'\n            );\n        }\n        if (tokenId == 77) {\n            return (\n                1234385732989531,\n                'Jazz',\n                'QmQbCq1dmQVL4q6jpTw5YYDPT5mG2FkLJdbvksawviFRtc'\n            );\n        }\n        if (tokenId == 78) {\n            return (\n                2124383117365177,\n                'Internaut',\n                'QmZSsCtQHb9E2q6dHy7uMpDHERNNxUGz76jbTogyx5ijSc'\n            );\n        }\n        if (tokenId == 79) {\n            return (\n                3965933145713547,\n                'bootoo',\n                'QmQU7t5xopVHo494KAm9c9QM9o6GenvxnGw4NrLnA6UE4B'\n            );\n        }\n        if (tokenId == 80) {\n            return (\n                3937211439401641,\n                'Jivinci',\n                'QmS5dCwUPrsKEZSg7pHqAezibKWSywKUuCTgf3mGznj1uS'\n            );\n        }\n        if (tokenId == 81) {\n            return (\n                8590927387405867,\n                'Aires',\n                'QmSBKFRdr1FHBTACe6QUvsjTZ84mdR4E5fXgiRpZPj7kCW'\n            );\n        }\n        if (tokenId == 82) {\n            return (\n                8730501088474769,\n                'ZMM',\n                'QmVuR564BKiQsP96SU3bQrZf9Dazp8mFZQfU3RUTE1ZnY6'\n            );\n        }\n\n        if (tokenId == 83) {\n            return (\n                941601682289385,\n                'Zorro',\n                'QmNvNHcSZbmTXG6tHvb11zZirixQkxunUQdYX69yRmiPf3'\n            );\n        }\n\n        if (tokenId == 84) {\n            return (\n                6736220662735793,\n                'Utopia',\n                'QmNMfh86tTgxqf9vPctdAeYAeELyCfUYNiGqPte41aPwkt'\n            );\n        }\n\n        revert('Unknow tokenId');\n    }\n}\n"
    }
  }
}}