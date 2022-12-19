{"ERC165.sol":{"content":"// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nimport \"./IERC165.sol\";\n\n/**\n * @dev Implementation of the {IERC165} interface.\n *\n * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check\n * for the additional interface id that will be supported. For example:\n *\n * ```solidity\n * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {\n *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);\n * }\n * ```\n *\n * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.\n */\nabstract contract ERC165 is IERC165 {\n    /**\n     * @dev See {IERC165-supportsInterface}.\n     */\n    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {\n        return interfaceId == type(IERC165).interfaceId;\n    }\n}\n"},"ERC165Checker.sol":{"content":"// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nimport \"./IERC165.sol\";\n\n/**\n * @dev Library used to query support of an interface declared via {IERC165}.\n *\n * Note that these functions return the actual result of the query: they do not\n * `revert` if an interface is not supported. It is up to the caller to decide\n * what to do in these cases.\n */\nlibrary ERC165Checker {\n    // As per the EIP-165 spec, no interface should ever match 0xffffffff\n    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;\n\n    /**\n     * @dev Returns true if `account` supports the {IERC165} interface,\n     */\n    function supportsERC165(address account) internal view returns (bool) {\n        // Any contract that implements ERC165 must explicitly indicate support of\n        // InterfaceId_ERC165 and explicitly indicate non-support of InterfaceId_Invalid\n        return\n            _supportsERC165Interface(account, type(IERC165).interfaceId) \u0026\u0026\n            !_supportsERC165Interface(account, _INTERFACE_ID_INVALID);\n    }\n\n    /**\n     * @dev Returns true if `account` supports the interface defined by\n     * `interfaceId`. Support for {IERC165} itself is queried automatically.\n     *\n     * See {IERC165-supportsInterface}.\n     */\n    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {\n        // query support of both ERC165 as per the spec and support of _interfaceId\n        return supportsERC165(account) \u0026\u0026 _supportsERC165Interface(account, interfaceId);\n    }\n\n    /**\n     * @dev Returns a boolean array where each value corresponds to the\n     * interfaces passed in and whether they\u0027re supported or not. This allows\n     * you to batch check interfaces for a contract where your expectation\n     * is that some interfaces may not be supported.\n     *\n     * See {IERC165-supportsInterface}.\n     *\n     * _Available since v3.4._\n     */\n    function getSupportedInterfaces(address account, bytes4[] memory interfaceIds)\n        internal\n        view\n        returns (bool[] memory)\n    {\n        // an array of booleans corresponding to interfaceIds and whether they\u0027re supported or not\n        bool[] memory interfaceIdsSupported = new bool[](interfaceIds.length);\n\n        // query support of ERC165 itself\n        if (supportsERC165(account)) {\n            // query support of each interface in interfaceIds\n            for (uint256 i = 0; i \u003c interfaceIds.length; i++) {\n                interfaceIdsSupported[i] = _supportsERC165Interface(account, interfaceIds[i]);\n            }\n        }\n\n        return interfaceIdsSupported;\n    }\n\n    /**\n     * @dev Returns true if `account` supports all the interfaces defined in\n     * `interfaceIds`. Support for {IERC165} itself is queried automatically.\n     *\n     * Batch-querying can lead to gas savings by skipping repeated checks for\n     * {IERC165} support.\n     *\n     * See {IERC165-supportsInterface}.\n     */\n    function supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {\n        // query support of ERC165 itself\n        if (!supportsERC165(account)) {\n            return false;\n        }\n\n        // query support of each interface in _interfaceIds\n        for (uint256 i = 0; i \u003c interfaceIds.length; i++) {\n            if (!_supportsERC165Interface(account, interfaceIds[i])) {\n                return false;\n            }\n        }\n\n        // all interfaces supported\n        return true;\n    }\n\n    /**\n     * @notice Query if a contract implements an interface, does not check ERC165 support\n     * @param account The address of the contract to query for support of an interface\n     * @param interfaceId The interface identifier, as specified in ERC-165\n     * @return true if the contract at account indicates support of the interface with\n     * identifier interfaceId, false otherwise\n     * @dev Assumes that account contains a contract that supports ERC165, otherwise\n     * the behavior of this method is undefined. This precondition can be checked\n     * with {supportsERC165}.\n     * Interface identification is specified in ERC-165.\n     */\n    function _supportsERC165Interface(address account, bytes4 interfaceId) private view returns (bool) {\n        bytes memory encodedParams = abi.encodeWithSelector(IERC165.supportsInterface.selector, interfaceId);\n        (bool success, bytes memory result) = account.staticcall{gas: 30000}(encodedParams);\n        if (result.length \u003c 32) return false;\n        return success \u0026\u0026 abi.decode(result, (bool));\n    }\n}\n"},"IERC165.sol":{"content":"// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC165 standard, as defined in the\n * https://eips.ethereum.org/EIPS/eip-165[EIP].\n *\n * Implementers can declare support of contract interfaces, which can then be\n * queried by others ({ERC165Checker}).\n *\n * For an implementation, see {ERC165}.\n */\ninterface IERC165 {\n    /**\n     * @dev Returns true if this contract implements the interface defined by\n     * `interfaceId`. See the corresponding\n     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]\n     * to learn more about how these ids are created.\n     *\n     * This function call must use less than 30 000 gas.\n     */\n    function supportsInterface(bytes4 interfaceId) external view returns (bool);\n}\n"}}