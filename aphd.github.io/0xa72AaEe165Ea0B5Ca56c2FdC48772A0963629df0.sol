{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "berlin",
    "libraries": {},
    "metadata": {
      "bytecodeHash": "ipfs",
      "useLiteralContent": true
    },
    "optimizer": {
      "enabled": true,
      "runs": 2000
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
    "@openzeppelin/contracts/utils/Strings.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/**\n * @dev String operations.\n */\nlibrary Strings {\n    bytes16 private constant _HEX_SYMBOLS = \"0123456789abcdef\";\n\n    /**\n     * @dev Converts a `uint256` to its ASCII `string` decimal representation.\n     */\n    function toString(uint256 value) internal pure returns (string memory) {\n        // Inspired by OraclizeAPI's implementation - MIT licence\n        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol\n\n        if (value == 0) {\n            return \"0\";\n        }\n        uint256 temp = value;\n        uint256 digits;\n        while (temp != 0) {\n            digits++;\n            temp /= 10;\n        }\n        bytes memory buffer = new bytes(digits);\n        while (value != 0) {\n            digits -= 1;\n            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));\n            value /= 10;\n        }\n        return string(buffer);\n    }\n\n    /**\n     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.\n     */\n    function toHexString(uint256 value) internal pure returns (string memory) {\n        if (value == 0) {\n            return \"0x00\";\n        }\n        uint256 temp = value;\n        uint256 length = 0;\n        while (temp != 0) {\n            length++;\n            temp >>= 8;\n        }\n        return toHexString(value, length);\n    }\n\n    /**\n     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.\n     */\n    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {\n        bytes memory buffer = new bytes(2 * length + 2);\n        buffer[0] = \"0\";\n        buffer[1] = \"x\";\n        for (uint256 i = 2 * length + 1; i > 1; --i) {\n            buffer[i] = _HEX_SYMBOLS[value & 0xf];\n            value >>= 4;\n        }\n        require(value == 0, \"Strings: hex length insufficient\");\n        return string(buffer);\n    }\n}\n"
    },
    "contracts/MetaDataGenerator.sol": {
      "content": "//SPDX-License-Identifier: Unlicense\npragma solidity ^0.8.6;\n\nimport {StringLib} from './libs/StringLib.sol';\nimport {ColorLib} from './libs/ColorLib.sol';\nimport {SceneLib} from './libs/SceneLib.sol';\nimport {Base64} from './libs/Base64.sol';\n\nimport {IMetaDataGenerator} from './interfaces/IMetaDataGenerator.sol';\n\n// Burny boys https://etherscan.io/address/0x18a808dd312736fc75eb967fc61990af726f04e4#code\n\n/**\n * @title MetaDataGenerator\n * @dev Helper contract used to generate metadata and images for the PiggySafe ERC-721 NFTs.\n *      Holds the scenes that are used to generate the SVG fully on-chain encoded using colormap of up to 16 colors.\n */\ncontract MetaDataGenerator is IMetaDataGenerator {\n    string internal constant svgStart =\n        '<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\" viewBox=\"0 0 24 24\">\\n';\n    string internal constant svgEnd = '</svg>';\n\n    // The base colors (e.g., 0x00000000) encoded into 2 uint256. Color inserted to value and shifted to tightly pack them.\n    uint256[] public baseColorPalette;\n\n    // The colors used for randomize color values (for hats etc). 4 sets each containing 4 colors and then encoded into into 2 uint256\n    uint256[] public randomizeColorPalettes;\n\n    // Each layer (\"trait\") has many different scenes as possiblity, 2d array to store all the scenes. `scenes[0][1]` provides scene 1 for layer 0 etc.\n    bytes[][] public scenes;\n\n    string[] public attributeNames;\n    string[][] public attributeValues;\n    string public constant NOTHING = 'Nothing';\n\n    // The actor who may initiate the values of the contract\n    address public owner;\n\n    // flag to freeze the contract details. When ossified, the contract cannot be update ever again.\n    bool public override ossified;\n\n    modifier onlyOwner() {\n        require(owner == msg.sender, 'Not owner');\n        _;\n    }\n\n    modifier notOssified() {\n        require(!ossified, 'Contract ossified');\n        _;\n    }\n\n    constructor() {\n        owner = msg.sender;\n    }\n\n    function init(\n        string[] memory _attributeNames,\n        string[] memory _attributeValues,\n        uint256[] memory _basePalette,\n        uint256[] memory _randomizePalette,\n        bytes[] memory _scenes,\n        uint256[] memory _indexes\n    ) public notOssified onlyOwner {\n        addLayers(_attributeNames);\n        setBaseColorPalette(_basePalette);\n        setRandomizeColorPalette(_randomizePalette);\n        addScenes(_scenes, _attributeValues, _indexes);\n        ossified = true;\n        owner = address(0);\n    }\n\n    function setBaseColorPalette(uint256[] memory _basePalette) internal {\n        baseColorPalette = _basePalette;\n    }\n\n    function setRandomizeColorPalette(uint256[] memory _randomizePalette) internal {\n        randomizeColorPalettes = _randomizePalette;\n    }\n\n    function addLayers(string[] memory _attributeNames) internal {\n        for (uint8 i = 0; i < _attributeNames.length; i++) {\n            scenes.push();\n            attributeValues.push();\n            attributeNames.push(_attributeNames[i]);\n        }\n    }\n\n    function addScenes(\n        bytes[] memory _scenes,\n        string[] memory _attributeValues,\n        uint256[] memory _indexes\n    ) internal {\n        require(_scenes.length == _indexes.length, 'Invalid size');\n        require(_attributeValues.length == _indexes.length, 'Invalid size');\n        for (uint8 i = 0; i < _indexes.length; i++) {\n            scenes[_indexes[i]].push(_scenes[i]);\n            attributeValues[_indexes[i]].push(_attributeValues[i]);\n        }\n    }\n\n    /**\n     * @dev Helper function that creates a `colorPalette` based on the basis colors + 4 colors chosen from the `randomizeColorPalettes` using the\n     *      `activeGene` byte 0-4 as indexes. Allows us to have different colored hats based on the gene.\n     * @param activeGene The active gene of the piggy to construct a palette for\n     * @return colorPalette The color palette for the active gene.\n     */\n    function constructPalette(uint256 activeGene)\n        internal\n        view\n        returns (uint256[] memory colorPalette)\n    {\n        colorPalette = new uint256[](2);\n        colorPalette[0] = baseColorPalette[0];\n        colorPalette[1] = baseColorPalette[1];\n\n        // insert at indexes 12, 13, 14, 15 from the randomizer\n        for (uint8 i = 0; i < 4; i++) {\n            // first move 4*i indexes to get to the right subset of the colors\n            // then ((activeGene >> (4 * i)) & 0x0f) % f is to get the index in the logical color to insert at 12 + i\n            uint256 activeIndex = 4 * i + (((activeGene >> (4 * i)) & 0x0f) % 4);\n            uint256 color = ColorLib.getColor(randomizeColorPalettes, activeIndex);\n            colorPalette[1] += color * (256**((4 + i) * 4)); // each color use 4 bytes so we add it at value bytes* (4+i*4), e.g., starting at byte 16 and moving 4 bytes at a time until 32\n        }\n    }\n\n    /**\n     * @dev Return a flattened composite and color mapping for specific `activeGene`.\n     *      The composite is constructed from using the scenes specified by `activeGene`,\n     *      `colorPalette` is useful for mapping the values in the composite to hex color values.\n     *      Note: Very gas entensive as it loops through the active scenes and add to the composite.\n     * @return composite return a flattened 24*24 matrix (576 array) and colorPalette\n     */\n    function getEncodedData(uint256 activeGene) public view override returns (EncodedData memory) {\n        uint8[576] memory composite;\n        string[] memory attributes = new string[](scenes.length);\n        uint256[] memory colorPalette = constructPalette(activeGene);\n\n        activeGene >>= 16; // Get past the colors. // We could probably just do it inside 1 byte\n        // Only run while when there is possible layers to add\n\n        for (uint256 layerIndex = 0; layerIndex < scenes.length; layerIndex++) {\n            bool isActive = layerIndex == 0 || (activeGene & 0x0f) > 0;\n            uint256 sceneIndex = (activeGene & 0x0f) % scenes[layerIndex].length;\n            attributes[layerIndex] = isActive ? attributeValues[layerIndex][sceneIndex] : NOTHING;\n\n            if (isActive) {\n                uint256[9] memory words = SceneLib.decodeToWords(scenes[layerIndex][sceneIndex]);\n                uint256 compositeIndex = 0;\n                for (uint8 i = 0; i < 9; i++) {\n                    if (words[i] == 0) {\n                        compositeIndex += 64;\n                        continue;\n                    }\n                    uint8[64] memory vals = SceneLib.decodeWord(words[i]);\n                    for (uint8 j = 0; j < 64; j++) {\n                        if (vals[j] > 0) {\n                            composite[compositeIndex + j] = vals[j];\n                        }\n                    }\n                    compositeIndex += 64;\n                }\n            }\n            activeGene >>= 4;\n        }\n\n        return EncodedData(composite, colorPalette, attributes);\n    }\n\n    function ethBalanceLine(uint256 balance) internal pure returns (string memory) {\n        return\n            string(\n                abi.encodePacked(\n                    '<text x=\"1\" y=\"23\" fill=\"green\" font-family=\"sans-serif\" font-size=\"1.25\">',\n                    StringLib.toBalanceString(balance, 3),\n                    'ETH</text>\\n'\n                )\n            );\n    }\n\n    /**\n     * @dev Creates a SVG image with the specified params. Very gas intensive because of heavy use of string manipulation for SVG file\n     * have optimisations for adding lines as single strings, otherwise adding pixels one by one. Without optimisation, full image will > gasLimit.\n     * @param activeGene The active gene of the piggy\n     * @param balance The amount of eth that the piggy contains\n     * @return svg Contents of a svg image.\n     */\n    function getSVG(uint256 activeGene, uint256 balance)\n        public\n        view\n        override\n        returns (string memory)\n    {\n        EncodedData memory data = getEncodedData(activeGene);\n        return createSVG(data.composite, data.colorPalette, balance);\n    }\n\n    function createSVG(\n        uint8[576] memory composite,\n        uint256[] memory colorPalette,\n        uint256 balance\n    ) internal pure returns (string memory svg) {\n        svg = string(abi.encodePacked(svgStart));\n\n        string[] memory colors = new string[](16);\n        for (uint8 i = 1; i < colors.length; i++) {\n            colors[i] = StringLib.toHexColor(ColorLib.getColor(colorPalette, i));\n        }\n        string[] memory location = new string[](24);\n        for (uint8 i = 0; i < 24; i++) {\n            location[i] = StringLib.toString(i);\n        }\n\n        for (uint32 y = 0; y < 24; y++) {\n            uint32 xStart = 0;\n            uint32 xEnd = 0;\n            uint256 lastVal = 0;\n            for (uint32 x = 0; x < 24; x++) {\n                uint256 val = composite[y * 24 + x];\n                // Add to the current line\n                if (val == lastVal) {\n                    xEnd = x;\n                } else {\n                    // Add current line if value is NOT invisible, then reset line\n                    if (lastVal > 0) {\n                        svg = string(\n                            abi.encodePacked(\n                                svg,\n                                '<rect x =\"',\n                                location[xStart],\n                                '\" y=\"',\n                                location[y],\n                                '\" width=\"',\n                                location[xEnd - xStart + 1],\n                                '\" height=\"1\" shape-rendering=\"crispEdges\" fill=\"#',\n                                colors[lastVal],\n                                '\"/>\\n'\n                            )\n                        );\n                    }\n                    xStart = x;\n                    xEnd = x;\n                    lastVal = val;\n                }\n            }\n            // If value is NOT invisible add it\n            if (lastVal > 0) {\n                svg = string(\n                    abi.encodePacked(\n                        svg,\n                        '<rect x =\"',\n                        location[xStart],\n                        '\" y=\"',\n                        location[y],\n                        '\" width=\"',\n                        location[xEnd - xStart + 1],\n                        '\" height=\"1\" shape-rendering=\"crispEdges\" fill=\"#',\n                        colors[lastVal],\n                        '\"/>\\n'\n                    )\n                );\n            }\n        }\n        svg = string(abi.encodePacked(svg, ethBalanceLine(balance), svgEnd));\n    }\n\n    /**\n     * @dev Generate a string with the attributes\n     * @param attributes The Attributes (layer, scene)[] to add\n     * @param balance The amount of tokens stored in the Piggy\n     * @param activeGene the active gene\n     * @return attributeString\n     */\n    function toAttributeString(\n        string[] memory attributes,\n        uint256 balance,\n        uint256 activeGene\n    ) internal view returns (string memory attributeString) {\n        attributeString = string(\n            abi.encodePacked(\n                '\"attributes\": [{\"trait_type\": \"balance\", \"value\": ',\n                StringLib.toBalanceString(balance, 3),\n                '}, {\"trait_type\": \"colorgene\", \"value\": \"',\n                StringLib.toHex(activeGene & 0xffff),\n                '\"}'\n            )\n        );\n\n        for (uint8 i = 0; i < attributes.length; i++) {\n            attributeString = string(\n                abi.encodePacked(\n                    attributeString,\n                    ', {\"trait_type\" : \"',\n                    attributeNames[i],\n                    '\", \"value\": \"',\n                    attributes[i],\n                    '\"}'\n                )\n            );\n        }\n\n        attributeString = string(abi.encodePacked(attributeString, ']'));\n    }\n\n    function tokenURI(MetaDataParams memory params) public view override returns (string memory) {\n        string memory name = string(\n            abi.encodePacked('CryptoPiggy #', StringLib.toString(params.tokenId))\n        );\n        string memory tokenOwner = StringLib.toHex(uint160(params.owner), 20);\n        string memory description = 'The mighty holder of coin';\n        EncodedData memory data = getEncodedData(params.activeGene);\n        string memory image = Base64.encode(\n            bytes(createSVG(data.composite, data.colorPalette, params.balance))\n        );\n\n        return\n            string(\n                abi.encodePacked(\n                    'data:application/json;base64,',\n                    Base64.encode(\n                        bytes(\n                            abi.encodePacked(\n                                '{\"name\":\"',\n                                name,\n                                '\", \"description\":\"',\n                                description,\n                                '\",',\n                                toAttributeString(\n                                    data.attributes,\n                                    params.balance,\n                                    params.activeGene\n                                ),\n                                ',\"owner\":\"',\n                                tokenOwner,\n                                '\", \"image\": \"data:image/svg+xml;base64,',\n                                image,\n                                '\"}'\n                            )\n                        )\n                    )\n                )\n            );\n    }\n}\n"
    },
    "contracts/interfaces/IMetaDataGenerator.sol": {
      "content": "//SPDX-License-Identifier: Unlicense\npragma solidity ^0.8.6;\n\ninterface IMetaDataGenerator {\n    struct MetaDataParams {\n        uint256 tokenId;\n        uint256 activeGene;\n        uint256 balance;\n        address owner;\n    }\n\n    struct Attribute {\n        uint256 layer;\n        uint256 scene;\n    }\n\n    struct EncodedData {\n        uint8[576] composite;\n        uint256[] colorPalette;\n        string[] attributes;\n    }\n\n    function getSVG(uint256 activeGene, uint256 balance) external view returns (string memory);\n\n    function tokenURI(MetaDataParams memory params) external view returns (string memory);\n\n    function getEncodedData(uint256 activeGene) external view returns (EncodedData memory);\n\n    function ossified() external view returns (bool);\n}\n"
    },
    "contracts/libs/Base64.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.6;\n\n/// @title Base64\n/// @author Brecht Devos - <brecht@loopring.org>\n/// @notice Provides a function for encoding some bytes in base64\nlibrary Base64 {\n    string internal constant TABLE =\n        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';\n\n    function encode(bytes memory data) internal pure returns (string memory) {\n        if (data.length == 0) return '';\n\n        // load the table into memory\n        string memory table = TABLE;\n\n        // multiply by 4/3 rounded up\n        uint256 encodedLen = 4 * ((data.length + 2) / 3);\n\n        // add some extra buffer at the end required for the writing\n        string memory result = new string(encodedLen + 32);\n\n        assembly {\n            // set the actual output length\n            mstore(result, encodedLen)\n\n            // prepare the lookup table\n            let tablePtr := add(table, 1)\n\n            // input ptr\n            let dataPtr := data\n            let endPtr := add(dataPtr, mload(data))\n\n            // result ptr, jump over length\n            let resultPtr := add(result, 32)\n\n            // run over the input, 3 bytes at a time\n            for {\n\n            } lt(dataPtr, endPtr) {\n\n            } {\n                dataPtr := add(dataPtr, 3)\n\n                // read 3 bytes\n                let input := mload(dataPtr)\n\n                // write 4 characters\n                mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(18, input), 0x3F)))))\n                resultPtr := add(resultPtr, 1)\n                mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(12, input), 0x3F)))))\n                resultPtr := add(resultPtr, 1)\n                mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(6, input), 0x3F)))))\n                resultPtr := add(resultPtr, 1)\n                mstore(resultPtr, shl(248, mload(add(tablePtr, and(input, 0x3F)))))\n                resultPtr := add(resultPtr, 1)\n            }\n\n            // padding with '='\n            switch mod(mload(data), 3)\n            case 1 {\n                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))\n            }\n            case 2 {\n                mstore(sub(resultPtr, 1), shl(248, 0x3d))\n            }\n        }\n\n        return result;\n    }\n}\n"
    },
    "contracts/libs/ColorLib.sol": {
      "content": "//SPDX-License-Identifier: Unlicense\npragma solidity ^0.8.6;\n\n// Possible test a version where we are just using abi.encode? Could actually be that it is just as good?\n\n// Filling from the right.\n\nlibrary ColorLib {\n    uint256 internal constant COLOR_MASK = 0xFFFFFFFF;\n\n    function createPaletteFromColorList(uint256[] memory _colors)\n        internal\n        pure\n        returns (uint256[] memory)\n    {\n        uint256 subCount = _colors.length % 8 > 0 ? _colors.length / 8 + 1 : _colors.length / 8;\n        uint256[] memory palette = new uint256[](subCount);\n        for (uint8 i = 0; i < subCount; i++) {\n            uint256 available = _min(_colors.length - i * 8, 8);\n            uint256[] memory subList = new uint256[](available);\n            for (uint8 j = 0; j < available; j++) {\n                subList[j] = _colors[i * 8 + j];\n            }\n            palette[i] = _createSubPaletteFromColorList(subList);\n        }\n        return palette;\n    }\n\n    function _createSubPaletteFromColorList(uint256[] memory _colors)\n        internal\n        pure\n        returns (uint256)\n    {\n        require(_colors.length <= 8, 'Too long');\n        uint256 subPalette = 0;\n        for (uint8 i = 0; i < _colors.length; i++) {\n            require(_colors[i] <= COLOR_MASK, 'Not a color');\n            subPalette += _colors[i] * 256**(i * 4);\n        }\n        return subPalette;\n    }\n\n    // Probably need some special case for the non-pixel.\n    function getColor(uint256[] memory colorPalette, uint256 index)\n        internal\n        pure\n        returns (uint256)\n    {\n        if (index / 8 > colorPalette.length - 1) {\n            return 0;\n        }\n        uint256 subPalette = colorPalette[index / 8];\n        uint256 shift = 256**((index % 8) * 4);\n        return (subPalette / shift) & COLOR_MASK;\n    }\n\n    function _min(uint256 a, uint256 b) internal pure returns (uint256) {\n        return a > b ? b : a;\n    }\n}\n"
    },
    "contracts/libs/SceneLib.sol": {
      "content": "//SPDX-License-Identifier: Unlicense\npragma solidity ^0.8.6;\n\n/**\n * All of this encoding is assuming that we use a custom mapping of colors to use only 4 bits per pixel\n */\n\nlibrary SceneLib {\n    uint256 constant bitsPerPixel = 4; // Best if divisor of 256, e.g., 2, 4, 8, 16, 32\n    uint256 constant unitSize = 2**bitsPerPixel; // The number of colors we can handle\n    uint256 constant encodingInWord = 256 / bitsPerPixel;\n    uint256 constant wordsNeeded = 576 / encodingInWord; //_layer.length / encodingInWord;\n\n    function encodeScene(uint8[] memory _scene) internal pure returns (bytes memory) {\n        uint256[wordsNeeded] memory scene;\n        for (uint16 i = 0; i < wordsNeeded; i++) {\n            for (uint16 j = 0; j < encodingInWord; j++) {\n                scene[i] += uint256(_scene[i * encodingInWord + j]) * unitSize**j; // Is this real actually. Only have 8 possibilities here\n            }\n        }\n        return abi.encode(scene);\n    }\n\n    function decodeToWords(bytes memory _layer)\n        internal\n        pure\n        returns (uint256[wordsNeeded] memory)\n    {\n        // For some reason I cannot use a constant but must manually write in `abi.decode`\n        uint256[wordsNeeded] memory layer = abi.decode(_layer, (uint256[9]));\n        return layer;\n    }\n\n    function decodeWord(uint256 _word) internal pure returns (uint8[encodingInWord] memory) {\n        uint8[encodingInWord] memory wordVals;\n        for (uint16 i = 0; i < encodingInWord; i++) {\n            wordVals[i] = uint8((_word / unitSize**i) & (unitSize - 1));\n        }\n        return wordVals;\n    }\n}\n"
    },
    "contracts/libs/StringLib.sol": {
      "content": "//SPDX-License-Identifier: Unlicense\npragma solidity ^0.8.6;\n\nimport {Strings} from '@openzeppelin/contracts/utils/Strings.sol';\n\nlibrary StringLib {\n    bytes16 private constant _HEX_SYMBOLS = '0123456789abcdef';\n\n    function toBalanceString(uint256 balance, uint256 decimals)\n        internal\n        pure\n        returns (string memory)\n    {\n        return\n            string(\n                abi.encodePacked(\n                    StringLib.toString(balance / 1e18),\n                    '.',\n                    StringLib.toFixedLengthString(\n                        (balance % 1e18) / (10**(18 - decimals)),\n                        decimals\n                    )\n                )\n            );\n    }\n\n    function toFixedLengthString(uint256 value, uint256 digits)\n        internal\n        pure\n        returns (string memory)\n    {\n        require(value <= 10**digits, 'Value cannot be in digits');\n\n        bytes memory buffer = new bytes(digits);\n        for (uint8 i = 0; i < digits; i++) {\n            buffer[digits - 1 - i] = bytes1(uint8(48 + uint256(value % 10)));\n            value /= 10;\n        }\n\n        return string(buffer);\n    }\n\n    function toString(uint256 value) internal pure returns (string memory) {\n        return Strings.toString(value);\n    }\n\n    function toHex(uint256 value) internal pure returns (string memory) {\n        return Strings.toHexString(value);\n    }\n\n    function toHex(uint256 value, uint256 length) internal pure returns (string memory) {\n        return Strings.toHexString(value, length);\n    }\n\n    // TODO: Fix this\n\n    function toHexColor(uint256 value) internal pure returns (string memory) {\n        bytes memory buffer = new bytes(8);\n        buffer[0] = _HEX_SYMBOLS[(value >> 28) & 0xf];\n        buffer[1] = _HEX_SYMBOLS[(value >> 24) & 0xf];\n        buffer[2] = _HEX_SYMBOLS[(value >> 20) & 0xf];\n        buffer[3] = _HEX_SYMBOLS[(value >> 16) & 0xf];\n        buffer[4] = _HEX_SYMBOLS[(value >> 12) & 0xf];\n        buffer[5] = _HEX_SYMBOLS[(value >> 8) & 0xf];\n        buffer[6] = _HEX_SYMBOLS[(value >> 4) & 0xf];\n        buffer[7] = _HEX_SYMBOLS[(value) & 0xf];\n        return string(buffer);\n    }\n}\n"
    }
  }
}}