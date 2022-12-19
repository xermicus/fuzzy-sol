{"auth.sol":{"content":"// Copyright (C) Centrifuge 2020, based on MakerDAO dss https://github.com/makerdao/dss\n//\n// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU Affero General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n//\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n// GNU Affero General Public License for more details.\n//\n// You should have received a copy of the GNU Affero General Public License\n// along with this program.  If not, see \u003chttps://www.gnu.org/licenses/\u003e.\n\npragma solidity \u003e=0.5.15 \u003c0.6.0;\n\nimport \"./note.sol\";\n\ncontract Auth is DSNote {\n    mapping (address =\u003e uint) public wards;\n    function rely(address usr) public auth note { wards[usr] = 1; }\n    function deny(address usr) public auth note { wards[usr] = 0; }\n    modifier auth { require(wards[msg.sender] == 1); _; }\n}\n"},"fixed_point.sol":{"content":"// Copyright (C) 2020 Centrifuge\n// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU Affero General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n//\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n// GNU Affero General Public License for more details.\n//\n// You should have received a copy of the GNU Affero General Public License\n// along with this program.  If not, see \u003chttps://www.gnu.org/licenses/\u003e.\n\npragma solidity \u003e=0.5.15 \u003c0.6.0;\n\ncontract FixedPoint {\n    struct Fixed27 {\n        uint value;\n    }\n}\n"},"interest.sol":{"content":"// Copyright (C) 2018 Rain \u003crainbreak@riseup.net\u003e and Centrifuge, referencing MakerDAO dss =\u003e https://github.com/makerdao/dss/blob/master/src/pot.sol\n//\n// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU Affero General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n//\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n// GNU Affero General Public License for more details.\n//\n// You should have received a copy of the GNU Affero General Public License\n// along with this program.  If not, see \u003chttps://www.gnu.org/licenses/\u003e.\n\npragma solidity \u003e=0.5.15 \u003c0.6.0;\n\nimport \"./math.sol\";\n\ncontract Interest is Math {\n    // @notice This function provides compounding in seconds\n    // @param chi Accumulated interest rate over time\n    // @param ratePerSecond Interest rate accumulation per second in RAD(10ˆ27)\n    // @param lastUpdated When the interest rate was last updated\n    // @param pie Total sum of all amounts accumulating under one interest rate, divided by that rate\n    // @return The new accumulated rate, as well as the difference between the debt calculated with the old and new accumulated rates.\n    function compounding(uint chi, uint ratePerSecond, uint lastUpdated, uint pie) public view returns (uint, uint) {\n        require(block.timestamp \u003e= lastUpdated, \"tinlake-math/invalid-timestamp\");\n        require(chi != 0);\n        // instead of a interestBearingAmount we use a accumulated interest rate index (chi)\n        uint updatedChi = _chargeInterest(chi ,ratePerSecond, lastUpdated, block.timestamp);\n        return (updatedChi, safeSub(rmul(updatedChi, pie), rmul(chi, pie)));\n    }\n\n    // @notice This function charge interest on a interestBearingAmount\n    // @param interestBearingAmount is the interest bearing amount\n    // @param ratePerSecond Interest rate accumulation per second in RAD(10ˆ27)\n    // @param lastUpdated last time the interest has been charged\n    // @return interestBearingAmount + interest\n    function chargeInterest(uint interestBearingAmount, uint ratePerSecond, uint lastUpdated) public view returns (uint) {\n        if (block.timestamp \u003e= lastUpdated) {\n            interestBearingAmount = _chargeInterest(interestBearingAmount, ratePerSecond, lastUpdated, block.timestamp);\n        }\n        return interestBearingAmount;\n    }\n\n    function _chargeInterest(uint interestBearingAmount, uint ratePerSecond, uint lastUpdated, uint current) internal pure returns (uint) {\n        return rmul(rpow(ratePerSecond, current - lastUpdated, ONE), interestBearingAmount);\n    }\n\n\n    // convert pie to debt/savings amount\n    function toAmount(uint chi, uint pie) public pure returns (uint) {\n        return rmul(pie, chi);\n    }\n\n    // convert debt/savings amount to pie\n    function toPie(uint chi, uint amount) public pure returns (uint) {\n        return rdivup(amount, chi);\n    }\n\n    function rpow(uint x, uint n, uint base) public pure returns (uint z) {\n        assembly {\n            switch x case 0 {switch n case 0 {z := base} default {z := 0}}\n            default {\n                switch mod(n, 2) case 0 { z := base } default { z := x }\n                let half := div(base, 2)  // for rounding.\n                for { n := div(n, 2) } n { n := div(n,2) } {\n                let xx := mul(x, x)\n                if iszero(eq(div(xx, x), x)) { revert(0,0) }\n                let xxRound := add(xx, half)\n                if lt(xxRound, xx) { revert(0,0) }\n                x := div(xxRound, base)\n                if mod(n,2) {\n                    let zx := mul(z, x)\n                    if and(iszero(iszero(x)), iszero(eq(div(zx, x), z))) { revert(0,0) }\n                    let zxRound := add(zx, half)\n                    if lt(zxRound, zx) { revert(0,0) }\n                    z := div(zxRound, base)\n                }\n            }\n            }\n        }\n    }\n}\n"},"math.sol":{"content":"// Copyright (C) 2018 Rain \u003crainbreak@riseup.net\u003e\n//\n// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU Affero General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n//\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n// GNU Affero General Public License for more details.\n//\n// You should have received a copy of the GNU Affero General Public License\n// along with this program.  If not, see \u003chttps://www.gnu.org/licenses/\u003e.\n\npragma solidity \u003e=0.5.15 \u003c0.6.0;\n\ncontract Math {\n    uint256 constant ONE = 10 ** 27;\n\n    function safeAdd(uint x, uint y) public pure returns (uint z) {\n        require((z = x + y) \u003e= x, \"safe-add-failed\");\n    }\n\n    function safeSub(uint x, uint y) public pure returns (uint z) {\n        require((z = x - y) \u003c= x, \"safe-sub-failed\");\n    }\n\n    function safeMul(uint x, uint y) public pure returns (uint z) {\n        require(y == 0 || (z = x * y) / y == x, \"safe-mul-failed\");\n    }\n\n    function safeDiv(uint x, uint y) public pure returns (uint z) {\n        z = x / y;\n    }\n\n    function rmul(uint x, uint y) public pure returns (uint z) {\n        z = safeMul(x, y) / ONE;\n    }\n\n    function rdiv(uint x, uint y) public pure returns (uint z) {\n        require(y \u003e 0, \"division by zero\");\n        z = safeAdd(safeMul(x, ONE), y / 2) / y;\n    }\n\n    function rdivup(uint x, uint y) internal pure returns (uint z) {\n        require(y \u003e 0, \"division by zero\");\n        // always rounds up\n        z = safeAdd(safeMul(x, ONE), safeSub(y, 1)) / y;\n    }\n\n\n}\n"},"note.sol":{"content":"/// note.sol -- the `note\u0027 modifier, for logging calls as events\n\n// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n// GNU General Public License for more details.\n\n// You should have received a copy of the GNU General Public License\n// along with this program.  If not, see \u003chttp://www.gnu.org/licenses/\u003e.\n\npragma solidity \u003e=0.4.23;\n\ncontract DSNote {\n    event LogNote(\n        bytes4   indexed  sig,\n        address  indexed  guy,\n        bytes32  indexed  foo,\n        bytes32  indexed  bar,\n        uint256           wad,\n        bytes             fax\n    ) anonymous;\n\n    modifier note {\n        bytes32 foo;\n        bytes32 bar;\n        uint256 wad;\n\n        assembly {\n            foo := calldataload(4)\n            bar := calldataload(36)\n            wad := callvalue()\n        }\n\n        _;\n\n        emit LogNote(msg.sig, msg.sender, foo, bar, wad, msg.data);\n    }\n}\n"},"tranche.sol":{"content":"// Copyright (C) 2020 Centrifuge\n//\n// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU Affero General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n//\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n// GNU Affero General Public License for more details.\n//\n// You should have received a copy of the GNU Affero General Public License\n// along with this program.  If not, see \u003chttps://www.gnu.org/licenses/\u003e.\n\npragma solidity \u003e=0.5.15 \u003c0.6.0;\npragma experimental ABIEncoderV2;\n\nimport \"./auth.sol\";\nimport \"./math.sol\";\nimport \"./fixed_point.sol\";\n\ninterface ERC20Like {\n    function balanceOf(address) external view returns (uint);\n    function transferFrom(address, address, uint) external returns (bool);\n    function mint(address, uint) external;\n    function burn(address, uint) external;\n    function totalSupply() external view returns (uint);\n    function approve(address usr, uint amount) external;\n}\n\ninterface ReserveLike {\n    function deposit(uint amount) external;\n    function payout(uint amount) external;\n    function totalBalanceAvailable() external returns (uint);\n}\n\ninterface EpochTickerLike {\n    function currentEpoch() external view returns (uint);\n    function lastEpochExecuted() external view returns(uint);\n}\n\ncontract Tranche is Math, Auth, FixedPoint {\n    mapping(uint =\u003e Epoch) public epochs;\n\n    struct Epoch {\n        // denominated in 10^27\n        // percentage ONE == 100%\n        Fixed27 redeemFulfillment;\n        // denominated in 10^27\n        // percentage ONE == 100%\n        Fixed27 supplyFulfillment;\n        // tokenPrice after end of epoch\n        Fixed27 tokenPrice;\n    }\n\n    struct UserOrder {\n        uint orderedInEpoch;\n        uint supplyCurrencyAmount;\n        uint redeemTokenAmount;\n    }\n\n    mapping(address =\u003e UserOrder) public users;\n\n    uint public  totalSupply;\n    uint public  totalRedeem;\n\n    ERC20Like public currency;\n    ERC20Like public token;\n    ReserveLike public reserve;\n    EpochTickerLike public epochTicker;\n\n    // additional requested currency if the reserve could not fulfill a tranche request\n    uint public requestedCurrency;\n    address self;\n\n    bool public waitingForUpdate = false;\n\n    modifier orderAllowed(address usr) {\n        require((users[usr].supplyCurrencyAmount == 0 \u0026\u0026 users[usr].redeemTokenAmount == 0)\n        || users[usr].orderedInEpoch == epochTicker.currentEpoch(), \"disburse required\");\n        _;\n    }\n\n    constructor(address currency_, address token_) public {\n        wards[msg.sender] = 1;\n        token = ERC20Like(token_);\n        currency = ERC20Like(currency_);\n        self = address(this);\n    }\n\n    function balance() external view returns (uint) {\n        return currency.balanceOf(self);\n    }\n\n    function tokenSupply() external view returns (uint) {\n        return token.totalSupply();\n    }\n\n    function depend(bytes32 contractName, address addr) public auth {\n        if (contractName == \"token\") {token = ERC20Like(addr);}\n        else if (contractName == \"currency\") {currency = ERC20Like(addr);}\n        else if (contractName == \"reserve\") {reserve = ReserveLike(addr);}\n        else if (contractName == \"epochTicker\") {epochTicker = EpochTickerLike(addr);}\n        else revert();\n    }\n\n    // supplyOrder function can be used to place or revoke an supply\n    function supplyOrder(address usr, uint newSupplyAmount) public auth orderAllowed(usr) {\n        users[usr].orderedInEpoch = epochTicker.currentEpoch();\n\n        uint currentSupplyAmount = users[usr].supplyCurrencyAmount;\n\n        users[usr].supplyCurrencyAmount = newSupplyAmount;\n\n        totalSupply = safeAdd(safeTotalSub(totalSupply, currentSupplyAmount), newSupplyAmount);\n\n        if (newSupplyAmount \u003e currentSupplyAmount) {\n            uint delta = safeSub(newSupplyAmount, currentSupplyAmount);\n            require(currency.transferFrom(usr, self, delta), \"currency-transfer-failed\");\n            return;\n        }\n        uint delta = safeSub(currentSupplyAmount, newSupplyAmount);\n        if (delta \u003e 0) {\n            _safeTransfer(currency, usr, delta);\n        }\n    }\n\n    // redeemOrder function can be used to place or revoke a redeem\n    function redeemOrder(address usr, uint newRedeemAmount) public auth orderAllowed(usr) {\n        users[usr].orderedInEpoch = epochTicker.currentEpoch();\n\n        uint currentRedeemAmount = users[usr].redeemTokenAmount;\n        users[usr].redeemTokenAmount = newRedeemAmount;\n        totalRedeem = safeAdd(safeTotalSub(totalRedeem, currentRedeemAmount), newRedeemAmount);\n\n        if (newRedeemAmount \u003e currentRedeemAmount) {\n            uint delta = safeSub(newRedeemAmount, currentRedeemAmount);\n            require(token.transferFrom(usr, self, delta), \"token-transfer-failed\");\n            return;\n        }\n\n        uint delta = safeSub(currentRedeemAmount, newRedeemAmount);\n        if (delta \u003e 0) {\n            _safeTransfer(token, usr, delta);\n        }\n    }\n\n    function calcDisburse(address usr) public view returns(uint payoutCurrencyAmount, uint payoutTokenAmount, uint remainingSupplyCurrency, uint remainingRedeemToken) {\n        return calcDisburse(usr, epochTicker.lastEpochExecuted());\n    }\n\n    ///  calculates the current disburse of a user starting from the ordered epoch until endEpoch\n    function calcDisburse(address usr, uint endEpoch) public view returns(uint payoutCurrencyAmount, uint payoutTokenAmount, uint remainingSupplyCurrency, uint remainingRedeemToken) {\n        uint epochIdx = users[usr].orderedInEpoch;\n        uint lastEpochExecuted = epochTicker.lastEpochExecuted();\n\n        // no disburse possible in this epoch\n        if (users[usr].orderedInEpoch == epochTicker.currentEpoch()) {\n            return (payoutCurrencyAmount, payoutTokenAmount, users[usr].supplyCurrencyAmount, users[usr].redeemTokenAmount);\n        }\n\n        if (endEpoch \u003e lastEpochExecuted) {\n            // it is only possible to disburse epochs which are already over\n            endEpoch = lastEpochExecuted;\n        }\n\n        remainingSupplyCurrency = users[usr].supplyCurrencyAmount;\n        remainingRedeemToken = users[usr].redeemTokenAmount;\n        uint amount = 0;\n\n        // calculates disburse amounts as long as remaining tokens or currency is left or the end epoch is reached\n        while(epochIdx \u003c= endEpoch \u0026\u0026 (remainingSupplyCurrency != 0 || remainingRedeemToken != 0 )){\n            if(remainingSupplyCurrency != 0) {\n                amount = rmul(remainingSupplyCurrency, epochs[epochIdx].supplyFulfillment.value);\n                // supply currency payout in token\n                if (amount != 0) {\n                    payoutTokenAmount = safeAdd(payoutTokenAmount, safeDiv(safeMul(amount, ONE), epochs[epochIdx].tokenPrice.value));\n                    remainingSupplyCurrency = safeSub(remainingSupplyCurrency, amount);\n                }\n            }\n\n            if(remainingRedeemToken != 0) {\n                amount = rmul(remainingRedeemToken, epochs[epochIdx].redeemFulfillment.value);\n                // redeem token payout in currency\n                if (amount != 0) {\n                    payoutCurrencyAmount = safeAdd(payoutCurrencyAmount, rmul(amount, epochs[epochIdx].tokenPrice.value));\n                    remainingRedeemToken = safeSub(remainingRedeemToken, amount);\n                }\n            }\n            epochIdx = safeAdd(epochIdx, 1);\n        }\n\n        return (payoutCurrencyAmount, payoutTokenAmount, remainingSupplyCurrency, remainingRedeemToken);\n    }\n\n    // the disburse function can be used after an epoch is over to receive currency and tokens\n    function disburse(address usr) public auth returns (uint payoutCurrencyAmount, uint payoutTokenAmount, uint remainingSupplyCurrency, uint remainingRedeemToken) {\n        return disburse(usr, epochTicker.lastEpochExecuted());\n    }\n\n    function _safeTransfer(ERC20Like erc20, address usr, uint amount) internal returns(uint) {\n        uint max = erc20.balanceOf(self);\n        if(amount \u003e max) {\n            amount = max;\n        }\n        require(erc20.transferFrom(self, usr, amount), \"token-transfer-failed\");\n        return amount;\n    }\n\n    // the disburse function can be used after an epoch is over to receive currency and tokens\n    function disburse(address usr,  uint endEpoch) public auth returns (uint payoutCurrencyAmount, uint payoutTokenAmount, uint remainingSupplyCurrency, uint remainingRedeemToken) {\n        require(users[usr].orderedInEpoch \u003c= epochTicker.lastEpochExecuted(), \"epoch-not-executed-yet\");\n\n        uint lastEpochExecuted = epochTicker.lastEpochExecuted();\n\n        if (endEpoch \u003e lastEpochExecuted) {\n            // it is only possible to disburse epochs which are already over\n            endEpoch = lastEpochExecuted;\n        }\n\n        (payoutCurrencyAmount, payoutTokenAmount,\n        remainingSupplyCurrency, remainingRedeemToken) = calcDisburse(usr, endEpoch);\n        users[usr].supplyCurrencyAmount = remainingSupplyCurrency;\n        users[usr].redeemTokenAmount = remainingRedeemToken;\n        // if lastEpochExecuted is disbursed, orderInEpoch is at the current epoch again\n        // which allows to change the order. This is only possible if all previous epochs are disbursed\n        users[usr].orderedInEpoch = safeAdd(endEpoch, 1);\n\n\n        if (payoutCurrencyAmount \u003e 0) {\n            payoutCurrencyAmount = _safeTransfer(currency, usr, payoutCurrencyAmount);\n        }\n\n        if (payoutTokenAmount \u003e 0) {\n            payoutTokenAmount = _safeTransfer(token, usr, payoutTokenAmount);\n        }\n        return (payoutCurrencyAmount, payoutTokenAmount, remainingSupplyCurrency, remainingRedeemToken);\n    }\n\n\n    // called by epoch coordinator in epoch execute method\n    function epochUpdate(uint epochID, uint supplyFulfillment_, uint redeemFulfillment_, uint tokenPrice_, uint epochSupplyOrderCurrency, uint epochRedeemOrderCurrency) public auth {\n        require(waitingForUpdate == true);\n        waitingForUpdate = false;\n\n        epochs[epochID].supplyFulfillment.value = supplyFulfillment_;\n        epochs[epochID].redeemFulfillment.value = redeemFulfillment_;\n        epochs[epochID].tokenPrice.value = tokenPrice_;\n\n        // currency needs to be converted to tokenAmount with current token price\n        uint redeemInToken = 0;\n        uint supplyInToken = 0;\n        if(tokenPrice_ \u003e 0) {\n            supplyInToken = rdiv(epochSupplyOrderCurrency, tokenPrice_);\n            redeemInToken = safeDiv(safeMul(epochRedeemOrderCurrency, ONE), tokenPrice_);\n        }\n\n        // calculates the delta between supply and redeem for tokens and burn or mint them\n        adjustTokenBalance(epochID, supplyInToken, redeemInToken);\n        // calculates the delta between supply and redeem for currency and deposit or get them from the reserve\n        adjustCurrencyBalance(epochID, epochSupplyOrderCurrency, epochRedeemOrderCurrency);\n\n        // the unfulfilled orders (1-fulfillment) is automatically ordered\n        totalSupply = safeAdd(safeTotalSub(totalSupply, epochSupplyOrderCurrency), rmul(epochSupplyOrderCurrency, safeSub(ONE, epochs[epochID].supplyFulfillment.value)));\n        totalRedeem = safeAdd(safeTotalSub(totalRedeem, redeemInToken), rmul(redeemInToken, safeSub(ONE, epochs[epochID].redeemFulfillment.value)));\n    }\n    function closeEpoch() public auth returns (uint totalSupplyCurrency_, uint totalRedeemToken_) {\n        require(waitingForUpdate == false);\n        waitingForUpdate = true;\n        return (totalSupply, totalRedeem);\n    }\n\n    function safeBurn(uint tokenAmount) internal {\n        uint max = token.balanceOf(self);\n        if(tokenAmount \u003e max) {\n            tokenAmount = max;\n        }\n        token.burn(self, tokenAmount);\n    }\n\n    function safePayout(uint currencyAmount) internal returns(uint payoutAmount) {\n        uint max = reserve.totalBalanceAvailable();\n\n        if(currencyAmount \u003e max) {\n            // currently reserve can\u0027t fulfill the entire request\n            currencyAmount = max;\n        }\n        reserve.payout(currencyAmount);\n        return currencyAmount;\n    }\n\n    function payoutRequestedCurrency() public {\n        if(requestedCurrency \u003e 0) {\n            uint payoutAmount = safePayout(requestedCurrency);\n            requestedCurrency = safeSub(requestedCurrency, payoutAmount);\n        }\n    }\n    // adjust token balance after epoch execution -\u003e min/burn tokens\n    function adjustTokenBalance(uint epochID, uint epochSupplyToken, uint epochRedeemToken) internal {\n        // mint token amount for supply\n\n        uint mintAmount = 0;\n        if (epochs[epochID].tokenPrice.value \u003e 0) {\n            mintAmount = rmul(epochSupplyToken, epochs[epochID].supplyFulfillment.value);\n        }\n\n        // burn token amount for redeem\n        uint burnAmount = rmul(epochRedeemToken, epochs[epochID].redeemFulfillment.value);\n        // burn tokens that are not needed for disbursement\n        if (burnAmount \u003e mintAmount) {\n            uint diff = safeSub(burnAmount, mintAmount);\n            safeBurn(diff);\n            return;\n        }\n        // mint tokens that are required for disbursement\n        uint diff = safeSub(mintAmount, burnAmount);\n        if (diff \u003e 0) {\n            token.mint(self, diff);\n        }\n    }\n\n    // additional minting of tokens produces a dilution of all token holders\n    // interface is required for adapters\n    function mint(address usr, uint amount) public auth {\n        token.mint(usr, amount);\n    }\n\n    // adjust currency balance after epoch execution -\u003e receive/send currency from/to reserve\n    function adjustCurrencyBalance(uint epochID, uint epochSupply, uint epochRedeem) internal {\n        // currency that was supplied in this epoch\n        uint currencySupplied = rmul(epochSupply, epochs[epochID].supplyFulfillment.value);\n        // currency required for redemption\n        uint currencyRequired = rmul(epochRedeem, epochs[epochID].redeemFulfillment.value);\n\n        if (currencySupplied \u003e currencyRequired) {\n            // send surplus currency to reserve\n            uint diff = safeSub(currencySupplied, currencyRequired);\n            currency.approve(address(reserve), diff);\n            reserve.deposit(diff);\n            return;\n        }\n        uint diff = safeSub(currencyRequired, currencySupplied);\n        if (diff \u003e 0) {\n            // get missing currency from reserve\n            uint payoutAmount = safePayout(diff);\n            if(payoutAmount \u003c diff) {\n                // reserve couldn\u0027t fulfill the entire request\n                requestedCurrency = safeAdd(requestedCurrency, safeSub(diff, payoutAmount));\n            }\n        }\n    }\n\n    // recovery transfer can be used by governance to recover funds if tokens are stuck\n    function authTransfer(address erc20, address usr, uint amount) public auth {\n        ERC20Like(erc20).transferFrom(self, usr, amount);\n    }\n\n    // due to rounding in token \u0026 currency conversions currency \u0026 token balances might be off by 1 wei with the totalSupply/totalRedeem amounts.\n    // in order to prevent an underflow error, 0 is returned when amount to be subtracted is bigger then the total value.\n    function safeTotalSub(uint total, uint amount) internal returns (uint) {\n        if (total \u003c amount) {\n            return 0;\n        }\n        return safeSub(total, amount);\n    }\n}\n"}}