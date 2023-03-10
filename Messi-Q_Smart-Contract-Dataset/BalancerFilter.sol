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

import "./BaseFilter.sol";

contract BalancerFilter is BaseFilter {

    bytes4 private constant DEPOSIT = bytes4(keccak256("joinswapExternAmountIn(address,uint256,uint256)"));
    bytes4 private constant WITHDRAW1 = bytes4(keccak256("exitswapExternAmountOut(address,uint256,uint256)"));
    bytes4 private constant WITHDRAW2 = bytes4(keccak256("exitswapPoolAmountIn(address,uint256,uint256)"));
    bytes4 private constant ERC20_APPROVE = bytes4(keccak256("approve(address,uint256)"));

    function isValid(address /*_wallet*/, address /*_spender*/, address /*_to*/, bytes calldata _data) external view override returns (bool) {
        // disable ETH transfer
        if (_data.length < 4) {
            return false;
        }
        bytes4 method = getMethod(_data);
        // approve() is authorised for approving an underlying token to the pool (in case of deposits) or 
        // for approving the pool LP token to itself (in case of withdrawals). Note that BPool can only 
        // transfer underlying pool tokens (or burn its own pool LP tokens) => no need to validate the token address here
        return method == ERC20_APPROVE || method == DEPOSIT || method == WITHDRAW1 || method == WITHDRAW2;
    }
}