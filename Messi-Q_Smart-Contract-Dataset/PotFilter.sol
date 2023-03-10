// Copyright (C) 2021  Argent Labs Ltd. <https://argent.xyz>

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.s

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.6.12;

import "../BaseFilter.sol";

contract PotFilter is BaseFilter {

    bytes4 private constant DEPOSIT = bytes4(keccak256("join(uint256)"));
    bytes4 private constant WITHDRAW = bytes4(keccak256("exit(uint256)"));
    bytes4 private constant DRIP = bytes4(keccak256("drip()"));

    function isValid(address /*_wallet*/, address /*_spender*/, address /*_to*/, bytes calldata _data) external view override returns (bool) {
        // disable ETH transfer
        if (_data.length < 4) {
            return false;
        }
        bytes4 method = getMethod(_data);

        return method == DEPOSIT || method == WITHDRAW || method == DRIP; 
    }
}