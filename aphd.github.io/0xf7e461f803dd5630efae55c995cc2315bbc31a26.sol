# @version 0.2.12
"""
@title StableSwap
@author Curve.Fi
@license Copyright (c) Curve.Fi, 2021 - all rights reserved
@notice 3pool metapool gauge implementation contract
"""

interface LiquidityGauge:
    def lp_token() -> address: view
    def minter() -> address: view
    def crv_token() -> address: view
    def deposit(_value: uint256): nonpayable
    def withdraw(_value: uint256): nonpayable
    def claimable_tokens(addr: address) -> uint256: nonpayable

interface Minter:
    def mint(gauge_addr: address): nonpayable

interface ERC20:
    def transfer(_receiver: address, _amount: uint256): nonpayable
    def transferFrom(_sender: address, _receiver: address, _amount: uint256): nonpayable
    def approve(_spender: address, _amount: uint256): nonpayable
    def balanceOf(_owner: address) -> uint256: view

interface Curve:
    def coins(i: uint256) -> address: view
    def get_virtual_price() -> uint256: view
    def calc_token_amount(amounts: uint256[BASE_N_COINS], deposit: bool) -> uint256: view
    def calc_withdraw_one_coin(_token_amount: uint256, i: int128) -> uint256: view
    def fee() -> uint256: view
    def get_dy(i: int128, j: int128, dx: uint256) -> uint256: view
    def exchange(i: int128, j: int128, dx: uint256, min_dy: uint256): nonpayable
    def add_liquidity(amounts: uint256[BASE_N_COINS], min_mint_amount: uint256): nonpayable
    def remove_liquidity_one_coin(_token_amount: uint256, i: int128, min_amount: uint256): nonpayable

interface Factory:
    def convert_fees() -> bool: nonpayable
    def fee_receiver(_base_pool: address) -> address: view

event Transfer:
    sender: indexed(address)
    receiver: indexed(address)
    value: uint256

event Approval:
    owner: indexed(address)
    spender: indexed(address)
    value: uint256

event TokenExchange:
    buyer: indexed(address)
    sold_id: int128
    tokens_sold: uint256
    bought_id: int128
    tokens_bought: uint256

event TokenExchangeUnderlying:
    buyer: indexed(address)
    sold_id: int128
    tokens_sold: uint256
    bought_id: int128
    tokens_bought: uint256

event AddLiquidity:
    provider: indexed(address)
    token_amounts: uint256[N_COINS]
    fees: uint256[N_COINS]
    invariant: uint256
    token_supply: uint256

event RemoveLiquidity:
    provider: indexed(address)
    token_amounts: uint256[N_COINS]
    fees: uint256[N_COINS]
    token_supply: uint256

event RemoveLiquidityOne:
    provider: indexed(address)
    token_amount: uint256
    coin_amount: uint256
    token_supply: uint256

event RemoveLiquidityImbalance:
    provider: indexed(address)
    token_amounts: uint256[N_COINS]
    fees: uint256[N_COINS]
    invariant: uint256
    token_supply: uint256

event CommitNewAdmin:
    deadline: indexed(uint256)
    admin: indexed(address)

event NewAdmin:
    admin: indexed(address)

event CommitNewFee:
    deadline: indexed(uint256)
    fee: uint256
    admin_fee: uint256

event NewFee:
    fee: uint256
    admin_fee: uint256

event RampA:
    old_A: uint256
    new_A: uint256
    initial_time: uint256
    future_time: uint256

event StopRampA:
    A: uint256
    t: uint256

BASE_POOL: constant(address) = 0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7
BASE_COINS: constant(address[3]) = [
    0x6B175474E89094C44Da98b954EedeAC495271d0F,  # DAI
    0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48,  # USDC
    0xdAC17F958D2ee523a2206206994597C13D831ec7,  # USDT
]

N_COINS: constant(int128) = 2
MAX_COIN: constant(int128) = N_COINS - 1
BASE_N_COINS: constant(int128) = 3
PRECISION: constant(uint256) = 10 ** 18

FEE_DENOMINATOR: constant(uint256) = 10 ** 10
ADMIN_FEE: constant(uint256) = 5000000000

A_PRECISION: constant(uint256) = 100
MAX_A: constant(uint256) = 10 ** 6
MAX_A_CHANGE: constant(uint256) = 10
MIN_RAMP_TIME: constant(uint256) = 86400

admin: public(address)
factory: address

coins: public(address[N_COINS])
balances: public(uint256[N_COINS])
fee: public(uint256)  # fee * 1e10

initial_A: public(uint256)
future_A: public(uint256)
initial_A_time: public(uint256)
future_A_time: public(uint256)

rate_multiplier: uint256

name: public(String[64])
symbol: public(String[32])

balanceOf: public(HashMap[address, uint256])
allowance: public(HashMap[address, HashMap[address, uint256]])
totalSupply: public(uint256)

gauge: public(address)

crv_integral: uint256
crv_integral_for: HashMap[address, uint256]
claimable_crv: public(HashMap[address, uint256])

# [uint216 claimable balance][uint40 timestamp]
last_claim_data: uint256

@external
def __init__():
    # we do this to prevent the implementation contract from being used as a pool
    self.fee = 31337


@external
def initialize(
    _name: String[32],
    _symbol: String[10],
    _coin: address,
    _decimals: uint256,
    _A: uint256,
    _fee: uint256,
    _admin: address,
	_gauge: address,
):
    """
    @notice Contract initializer
    @param _name Name of the new pool
    @param _symbol Token symbol
    @param _coin Addresses of ERC20 conracts of coins
    @param _decimals Number of decimals in `_coin`
    @param _A Amplification coefficient multiplied by n * (n - 1)
    @param _fee Fee to charge for exchanges
    @param _admin Admin address
    """
    #  # things break if a token has >18 decimals
    assert _decimals < 19
    # fee must be between 0.04% and 1%
    assert _fee >= 4000000
    assert _fee <= 100000000
    # check if fee was already set to prevent initializing contract twice
    assert self.fee == 0

    A: uint256 = _A * A_PRECISION
    self.coins = [_coin, 0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490]
    self.rate_multiplier = 10 ** (36 - _decimals)
    self.initial_A = A
    self.future_A = A
    self.fee = _fee
    self.admin = _admin
    self.factory = msg.sender

    self.name = concat("Curve.fi Factory USD Metapool: ", _name)
    self.symbol = concat(_symbol, "3CRV-f")

    for coin in BASE_COINS:
        ERC20(coin).approve(BASE_POOL, MAX_UINT256)

    # fire a transfer event so block explorers identify the contract as an ERC20
    log Transfer(ZERO_ADDRESS, self, 0)
    
    ERC20(LiquidityGauge(_gauge).lp_token()).approve(_gauge, MAX_UINT256)
    self.gauge = _gauge

### Gauge Functionality ###

@internal
def _checkpoint(_user_addresses: address[2]):
    claim_data: uint256 = self.last_claim_data
    I: uint256 = self.crv_integral

    if block.timestamp != claim_data % 2**40:
        last_claimable: uint256 = shift(claim_data, -40)
        claimable: uint256 = LiquidityGauge(self.gauge).claimable_tokens(self)
        d_reward: uint256 = claimable - last_claimable
        total_balance: uint256 = self.totalSupply
        if total_balance > 0:
            I += 10 ** 18 * d_reward / total_balance
            self.crv_integral = I
        self.last_claim_data = block.timestamp + shift(claimable, 40)

    for addr in _user_addresses:
        if addr in [ZERO_ADDRESS]:
            # do not calculate an integral for the vault to ensure it cannot ever claim
            continue
        user_integral: uint256 = self.crv_integral_for[addr]
        if user_integral < I:
            user_balance: uint256 = self.balanceOf[addr]
            self.claimable_crv[addr] += user_balance * (I - user_integral) / 10 ** 18
            self.crv_integral_for[addr] = I


@external
def user_checkpoint(addr: address) -> bool:
    """
    @notice Record a checkpoint for `addr`
    @param addr User address
    @return bool success
    """
    self._checkpoint([addr, ZERO_ADDRESS])
    return True


@external
def claimable_tokens(addr: address) -> uint256:
    """
    @notice Get the number of claimable tokens per user
    @dev This function should be manually changed to "view" in the ABI
    @return uint256 number of claimable tokens per user
    """
    self._checkpoint([addr, ZERO_ADDRESS])

    return self.claimable_crv[addr]


@external
@nonreentrant('lock')
def claim_tokens(addr: address = msg.sender):
    """
    @notice Claim mintable CRV
    @param addr Address to claim for
    """
    self._checkpoint([addr, ZERO_ADDRESS])

    crv_token: address = LiquidityGauge(self.gauge).crv_token()
    claimable: uint256 = self.claimable_crv[addr]
    self.claimable_crv[addr] = 0

    if ERC20(crv_token).balanceOf(self) < claimable:
        Minter(LiquidityGauge(self.gauge).minter()).mint(self.gauge)
        self.last_claim_data = block.timestamp

    ERC20(crv_token).transfer(addr, claimable)
    
### ERC20 Functionality ###

@view
@external
def decimals() -> uint256:
    """
    @notice Get the number of decimals for this token
    @dev Implemented as a view method to reduce gas costs
    @return uint256 decimal places
    """
    return 18


@internal
def _transfer(_from: address, _to: address, _value: uint256):
    # NOTE: vyper does not allow underflows
    #       so the following subtraction would revert on insufficient balance
    self.balanceOf[_from] -= _value
    self.balanceOf[_to] += _value

    log Transfer(_from, _to, _value)


@external
def transfer(_to : address, _value : uint256) -> bool:
    """
    @dev Transfer token for a specified address
    @param _to The address to transfer to.
    @param _value The amount to be transferred.
    """
    self._transfer(msg.sender, _to, _value)
    return True


@external
def transferFrom(_from : address, _to : address, _value : uint256) -> bool:
    """
     @dev Transfer tokens from one address to another.
     @param _from address The address which you want to send tokens from
     @param _to address The address which you want to transfer to
     @param _value uint256 the amount of tokens to be transferred
    """
    self._transfer(_from, _to, _value)

    _allowance: uint256 = self.allowance[_from][msg.sender]
    if _allowance != MAX_UINT256:
        self.allowance[_from][msg.sender] = _allowance - _value

    return True


@external
def approve(_spender : address, _value : uint256) -> bool:
    """
    @notice Approve the passed address to transfer the specified amount of
            tokens on behalf of msg.sender
    @dev Beware that changing an allowance via this method brings the risk that
         someone may use both the old and new allowance by unfortunate transaction
         ordering: https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    @param _spender The address which will transfer the funds
    @param _value The amount of tokens that may be transferred
    @return bool success
    """
    self.allowance[msg.sender][_spender] = _value

    log Approval(msg.sender, _spender, _value)
    return True


### StableSwap Functionality ###

@view
@internal
def _A() -> uint256:
    """
    Handle ramping A up or down
    """
    t1: uint256 = self.future_A_time
    A1: uint256 = self.future_A

    if block.timestamp < t1:
        A0: uint256 = self.initial_A
        t0: uint256 = self.initial_A_time
        # Expressions in uint256 cannot have negative numbers, thus "if"
        if A1 > A0:
            return A0 + (A1 - A0) * (block.timestamp - t0) / (t1 - t0)
        else:
            return A0 - (A0 - A1) * (block.timestamp - t0) / (t1 - t0)

    else:  # when t1 == 0 or block.timestamp >= t1
        return A1

@view
@external
def admin_fee() -> uint256:
    return ADMIN_FEE

@view
@external
def A() -> uint256:
    return self._A() / A_PRECISION

@view
@external
def A_precise() -> uint256:
    return self._A()

@pure
@internal
def _xp_mem(_rates: uint256[N_COINS], _balances: uint256[N_COINS]) -> uint256[N_COINS]:
    result: uint256[N_COINS] = empty(uint256[N_COINS])
    for i in range(N_COINS):
        result[i] = _rates[i] * _balances[i] / PRECISION
    return result

@pure
@internal
def get_D(_xp: uint256[N_COINS], _amp: uint256) -> uint256:
    S: uint256 = 0
    Dprev: uint256 = 0
    for x in _xp:
        S += x
    if S == 0:
        return 0

    D: uint256 = S
    Ann: uint256 = _amp * N_COINS
    for i in range(255):
        D_P: uint256 = D
        for x in _xp:
            D_P = D_P * D / (x * N_COINS)  # If division by 0, this will be borked: only withdrawal will work. And that is good
        Dprev = D
        D = (Ann * S / A_PRECISION + D_P * N_COINS) * D / ((Ann - A_PRECISION) * D / A_PRECISION + (N_COINS + 1) * D_P)
        # Equality with the precision of 1
        if D > Dprev:
            if D - Dprev <= 1:
                return D
        else:
            if Dprev - D <= 1:
                return D
    # convergence typically occurs in 4 rounds or less, this should be unreachable!
    # if it does happen the pool is borked and LPs can withdraw via `remove_liquidity`
    raise


@view
@internal
def get_D_mem(_rates: uint256[N_COINS], _balances: uint256[N_COINS], _amp: uint256) -> uint256:
    xp: uint256[N_COINS] = self._xp_mem(_rates, _balances)
    return self.get_D(xp, _amp)


@view
@external
def get_virtual_price() -> uint256:
    """
    @notice The current virtual price of the pool LP token
    @dev Useful for calculating profits
    @return LP token virtual price normalized to 1e18
    """
    amp: uint256 = self._A()
    rates: uint256[N_COINS] = [self.rate_multiplier, Curve(BASE_POOL).get_virtual_price()]
    xp: uint256[N_COINS] = self._xp_mem(rates, self.balances)
    D: uint256 = self.get_D(xp, amp)
    # D is in the units similar to DAI (e.g. converted to precision 1e18)
    # When balanced, D = n * x_u - total virtual value of the portfolio
    return D * PRECISION / self.totalSupply


@view
@external
def calc_token_amount(_amounts: uint256[N_COINS], _is_deposit: bool) -> uint256:
    """
    @notice Calculate addition or reduction in token supply from a deposit or withdrawal
    @dev This calculation accounts for slippage, but not fees.
         Needed to prevent front-running, not for precise calculations!
    @param _amounts Amount of each coin being deposited
    @param _is_deposit set True for deposits, False for withdrawals
    @return Expected amount of LP tokens received
    """
    amp: uint256 = self._A()
    rates: uint256[N_COINS] = [self.rate_multiplier, Curve(BASE_POOL).get_virtual_price()]
    balances: uint256[N_COINS] = self.balances

    D0: uint256 = self.get_D_mem(rates, balances, amp)
    for i in range(N_COINS):
        amount: uint256 = _amounts[i]
        if _is_deposit:
            balances[i] += amount
        else:
            balances[i] -= amount
    D1: uint256 = self.get_D_mem(rates, balances, amp)
    diff: uint256 = 0
    if _is_deposit:
        diff = D1 - D0
    else:
        diff = D0 - D1
    return diff * self.totalSupply / D0


@external
@nonreentrant('lock')
def add_liquidity(
    _amounts: uint256[N_COINS],
    _min_mint_amount: uint256,
    _receiver: address = msg.sender
) -> uint256:
    """
    @notice Deposit coins into the pool
    @param _amounts List of amounts of coins to deposit
    @param _min_mint_amount Minimum amount of LP tokens to mint from the deposit
    @param _receiver Address that owns the minted LP tokens
    @return Amount of LP tokens received by depositing
    """
    amp: uint256 = self._A()
    rates: uint256[N_COINS] = [self.rate_multiplier, Curve(BASE_POOL).get_virtual_price()]

    # Initial invariant
    old_balances: uint256[N_COINS] = self.balances
    D0: uint256 = self.get_D_mem(rates, old_balances, amp)
    new_balances: uint256[N_COINS] = old_balances

    total_supply: uint256 = self.totalSupply
    for i in range(N_COINS):
        amount: uint256 = _amounts[i]
        if total_supply == 0:
            assert amount > 0  # dev: initial deposit requires all coins
        new_balances[i] += amount

    # Invariant after change
    D1: uint256 = self.get_D_mem(rates, new_balances, amp)
    assert D1 > D0

    # We need to recalculate the invariant accounting for fees
    # to calculate fair user's share
    fees: uint256[N_COINS] = empty(uint256[N_COINS])
    mint_amount: uint256 = 0
    if total_supply > 0:
        # Only account for fees if we are not the first to deposit
        base_fee: uint256 = self.fee * N_COINS / (4 * (N_COINS - 1))
        for i in range(N_COINS):
            ideal_balance: uint256 = D1 * old_balances[i] / D0
            difference: uint256 = 0
            new_balance: uint256 = new_balances[i]
            if ideal_balance > new_balance:
                difference = ideal_balance - new_balance
            else:
                difference = new_balance - ideal_balance
            fees[i] = base_fee * difference / FEE_DENOMINATOR
            self.balances[i] = new_balance - (fees[i] * ADMIN_FEE / FEE_DENOMINATOR)
            new_balances[i] -= fees[i]
        D2: uint256 = self.get_D_mem(rates, new_balances, amp)
        mint_amount = total_supply * (D2 - D0) / D0
    else:
        self.balances = new_balances
        mint_amount = D1  # Take the dust if there was any

    assert mint_amount >= _min_mint_amount

    # Take coins from the sender
    for i in range(N_COINS):
        amount: uint256 = _amounts[i]
        if amount > 0:
            ERC20(self.coins[i]).transferFrom(msg.sender, self, amount)  # dev: failed transfer
    
    if _amounts[MAX_COIN] > 0:
        LiquidityGauge(self.gauge).deposit(_amounts[MAX_COIN])
    
    # Mint pool tokens
    total_supply += mint_amount
    self.balanceOf[_receiver] += mint_amount
    self.totalSupply = total_supply
    log Transfer(ZERO_ADDRESS, _receiver, mint_amount)
    
    self._checkpoint([msg.sender, ZERO_ADDRESS])

    log AddLiquidity(msg.sender, _amounts, fees, D1, total_supply)

    return mint_amount


@view
@internal
def get_y(i: int128, j: int128, x: uint256, xp: uint256[N_COINS]) -> uint256:
    # x in the input is converted to the same price/precision

    assert i != j       # dev: same coin
    assert j >= 0       # dev: j below zero
    assert j < N_COINS  # dev: j above N_COINS

    # should be unreachable, but good for safety
    assert i >= 0
    assert i < N_COINS

    amp: uint256 = self._A()
    D: uint256 = self.get_D(xp, amp)
    S_: uint256 = 0
    _x: uint256 = 0
    y_prev: uint256 = 0
    c: uint256 = D
    Ann: uint256 = amp * N_COINS

    for _i in range(N_COINS):
        if _i == i:
            _x = x
        elif _i != j:
            _x = xp[_i]
        else:
            continue
        S_ += _x
        c = c * D / (_x * N_COINS)

    c = c * D * A_PRECISION / (Ann * N_COINS)
    b: uint256 = S_ + D * A_PRECISION / Ann  # - D
    y: uint256 = D

    for _i in range(255):
        y_prev = y
        y = (y*y + c) / (2 * y + b - D)
        # Equality with the precision of 1
        if y > y_prev:
            if y - y_prev <= 1:
                return y
        else:
            if y_prev - y <= 1:
                return y
    raise


@view
@external
def get_dy(i: int128, j: int128, dx: uint256) -> uint256:
    """
    @notice Calculate the current output dy given input dx
    @dev Index values can be found via the `coins` public getter method
    @param i Index value for the coin to send
    @param j Index valie of the coin to recieve
    @param dx Amount of `i` being exchanged
    @return Amount of `j` predicted
    """
    rates: uint256[N_COINS] = [self.rate_multiplier, Curve(BASE_POOL).get_virtual_price()]
    xp: uint256[N_COINS] = self.balances
    xp = self._xp_mem(rates, xp)

    x: uint256 = xp[i] + (dx * rates[i] / PRECISION)
    y: uint256 = self.get_y(i, j, x, xp)
    dy: uint256 = xp[j] - y - 1
    fee: uint256 = self.fee * dy / FEE_DENOMINATOR
    return (dy - fee) * PRECISION / rates[j]


@view
@external
def get_dy_underlying(i: int128, j: int128, dx: uint256) -> uint256:
    """
    @notice Calculate the current output dy given input dx on underlying
    @dev Index values can be found via the `coins` public getter method
    @param i Index value for the coin to send
    @param j Index valie of the coin to recieve
    @param dx Amount of `i` being exchanged
    @return Amount of `j` predicted
    """
    rates: uint256[N_COINS] = [self.rate_multiplier, Curve(BASE_POOL).get_virtual_price()]
    xp: uint256[N_COINS] = self.balances
    xp = self._xp_mem(rates, xp)
    base_pool: address = BASE_POOL

    x: uint256 = 0
    base_i: int128 = 0
    base_j: int128 = 0
    meta_i: int128 = 0
    meta_j: int128 = 0

    if i != 0:
        base_i = i - MAX_COIN
        meta_i = 1
    if j != 0:
        base_j = j - MAX_COIN
        meta_j = 1

    if i == 0:
        x = xp[i] + dx * (rates[0] / 10**18)
    else:
        if j == 0:
            # i is from BasePool
            # At first, get the amount of pool tokens
            base_inputs: uint256[BASE_N_COINS] = empty(uint256[BASE_N_COINS])
            base_inputs[base_i] = dx
            # Token amount transformed to underlying "dollars"
            x = Curve(base_pool).calc_token_amount(base_inputs, True) * rates[1] / PRECISION
            # Accounting for deposit/withdraw fees approximately
            x -= x * Curve(base_pool).fee() / (2 * FEE_DENOMINATOR)
            # Adding number of pool tokens
            x += xp[MAX_COIN]
        else:
            # If both are from the base pool
            return Curve(base_pool).get_dy(base_i, base_j, dx)

    # This pool is involved only when in-pool assets are used
    y: uint256 = self.get_y(meta_i, meta_j, x, xp)
    dy: uint256 = xp[meta_j] - y - 1
    dy = (dy - self.fee * dy / FEE_DENOMINATOR)

    # If output is going via the metapool
    if j == 0:
        dy /= (rates[0] / 10**18)
    else:
        # j is from BasePool
        # The fee is already accounted for
        dy = Curve(base_pool).calc_withdraw_one_coin(dy * PRECISION / rates[1], base_j)

    return dy


@external
@nonreentrant('lock')
def exchange(
    i: int128,
    j: int128,
    dx: uint256,
    min_dy: uint256,
    _receiver: address = msg.sender,
) -> uint256:
    """
    @notice Perform an exchange between two coins
    @dev Index values can be found via the `coins` public getter method
    @param i Index value for the coin to send
    @param j Index valie of the coin to recieve
    @param dx Amount of `i` being exchanged
    @param min_dy Minimum amount of `j` to receive
    @param _receiver Address that receives `j`
    @return Actual amount of `j` received
    """
    rates: uint256[N_COINS] = [self.rate_multiplier, Curve(BASE_POOL).get_virtual_price()]

    old_balances: uint256[N_COINS] = self.balances
    xp: uint256[N_COINS] = self._xp_mem(rates, old_balances)

    x: uint256 = xp[i] + dx * rates[i] / PRECISION
    y: uint256 = self.get_y(i, j, x, xp)

    dy: uint256 = xp[j] - y - 1  # -1 just in case there were some rounding errors
    dy_fee: uint256 = dy * self.fee / FEE_DENOMINATOR

    # Convert all to real units
    dy = (dy - dy_fee) * PRECISION / rates[j]
    assert dy >= min_dy

    dy_admin_fee: uint256 = dy_fee * ADMIN_FEE / FEE_DENOMINATOR
    dy_admin_fee = dy_admin_fee * PRECISION / rates[j]

    # Change balances exactly in same way as we change actual ERC20 coin amounts
    self.balances[i] = old_balances[i] + dx
    # When rounding errors happen, we undercharge admin fee in favor of LP
    self.balances[j] = old_balances[j] - dy - dy_admin_fee

    ERC20(self.coins[i]).transferFrom(msg.sender, self, dx)
	
    if j == MAX_COIN:
        LiquidityGauge(self.gauge).withdraw(dy)
        
    ERC20(self.coins[j]).transfer(_receiver, dy)

    log TokenExchange(msg.sender, i, dx, j, dy)

    return dy


@external
@nonreentrant('lock')
def exchange_underlying(
    i: int128,
    j: int128,
    dx: uint256,
    min_dy: uint256,
    _receiver: address = msg.sender,
) -> uint256:
    """
    @notice Perform an exchange between two underlying coins
    @dev Index values can be found via the `underlying_coins` public getter method
    @param i Index value for the underlying coin to send
    @param j Index valie of the underlying coin to recieve
    @param dx Amount of `i` being exchanged
    @param min_dy Minimum amount of `j` to receive
    @param _receiver Address that receives `j`
    @return Actual amount of `j` received
    """
    rates: uint256[N_COINS] = [self.rate_multiplier, Curve(BASE_POOL).get_virtual_price()]
    old_balances: uint256[N_COINS] = self.balances
    xp: uint256[N_COINS] = self._xp_mem(rates, old_balances)

    base_pool: address = BASE_POOL
    base_coins: address[3] = BASE_COINS

    dy: uint256 = 0
    base_i: int128 = 0
    base_j: int128 = 0
    meta_i: int128 = 0
    meta_j: int128 = 0
    x: uint256 = 0
    input_coin: address = ZERO_ADDRESS
    output_coin: address = ZERO_ADDRESS

    if i == 0:
        input_coin = self.coins[0]
    else:
        base_i = i - MAX_COIN
        meta_i = 1
        input_coin = base_coins[base_i]
    if j == 0:
        output_coin = self.coins[0]
    else:
        base_j = j - MAX_COIN
        meta_j = 1
        output_coin = base_coins[base_j]

    # Handle potential Tether fees
    dx_w_fee: uint256 = dx
    if j == 3:
        dx_w_fee = ERC20(input_coin).balanceOf(self)

    ERC20(input_coin).transferFrom(msg.sender, self, dx)

    # Handle potential Tether fees
    if j == 3:
        dx_w_fee = ERC20(input_coin).balanceOf(self) - dx_w_fee

    if i == 0 or j == 0:
        if i == 0:
            x = xp[i] + dx_w_fee * rates[i] / PRECISION
        else:
            # i is from BasePool
            # At first, get the amount of pool tokens
            base_inputs: uint256[BASE_N_COINS] = empty(uint256[BASE_N_COINS])
            base_inputs[base_i] = dx_w_fee
            coin_i: address = self.coins[MAX_COIN]
            # Deposit and measure delta
            x = ERC20(coin_i).balanceOf(self)
            Curve(base_pool).add_liquidity(base_inputs, 0)
            # Need to convert pool token to "virtual" units using rates
            # dx is also different now
            dx_w_fee = ERC20(coin_i).balanceOf(self) - x
            x = dx_w_fee * rates[MAX_COIN] / PRECISION
            # Adding number of pool tokens
            x += xp[MAX_COIN]

        y: uint256 = self.get_y(meta_i, meta_j, x, xp)

        # Either a real coin or token
        dy = xp[meta_j] - y - 1  # -1 just in case there were some rounding errors
        dy_fee: uint256 = dy * self.fee / FEE_DENOMINATOR

        # Convert all to real units
        # Works for both pool coins and real coins
        dy = (dy - dy_fee) * PRECISION / rates[meta_j]

        dy_admin_fee: uint256 = dy_fee * ADMIN_FEE / FEE_DENOMINATOR
        dy_admin_fee = dy_admin_fee * PRECISION / rates[meta_j]

        # Change balances exactly in same way as we change actual ERC20 coin amounts
        self.balances[meta_i] = old_balances[meta_i] + dx_w_fee
        # When rounding errors happen, we undercharge admin fee in favor of LP
        self.balances[meta_j] = old_balances[meta_j] - dy - dy_admin_fee

        # Withdraw from the base pool if needed
        if j > 0:
            out_amount: uint256 = ERC20(output_coin).balanceOf(self)
            LiquidityGauge(self.gauge).withdraw(dy)
            Curve(base_pool).remove_liquidity_one_coin(dy, base_j, 0)
            dy = ERC20(output_coin).balanceOf(self) - out_amount

        assert dy >= min_dy

    else:
        # If both are from the base pool
        dy = ERC20(output_coin).balanceOf(self)
        Curve(base_pool).exchange(base_i, base_j, dx_w_fee, min_dy)
        dy = ERC20(output_coin).balanceOf(self) - dy

    ERC20(output_coin).transfer(_receiver, dy)

    log TokenExchangeUnderlying(msg.sender, i, dx, j, dy)

    return dy


@external
@nonreentrant('lock')
def remove_liquidity(
    _burn_amount: uint256,
    _min_amounts: uint256[N_COINS],
    _receiver: address = msg.sender
) -> uint256[N_COINS]:
    """
    @notice Withdraw coins from the pool
    @dev Withdrawal amounts are based on current deposit ratios
    @param _burn_amount Quantity of LP tokens to burn in the withdrawal
    @param _min_amounts Minimum amounts of underlying coins to receive
    @param _receiver Address that receives the withdrawn coins
    @return List of amounts of coins that were withdrawn
    """
    total_supply: uint256 = self.totalSupply
    amounts: uint256[N_COINS] = empty(uint256[N_COINS])

    for i in range(N_COINS):
        old_balance: uint256 = self.balances[i]
        value: uint256 = old_balance * _burn_amount / total_supply
        assert value >= _min_amounts[i]
        self.balances[i] = old_balance - value
        amounts[i] = value
        if i == MAX_COIN:
            LiquidityGauge(self.gauge).withdraw(value)
        ERC20(self.coins[i]).transfer(_receiver, value)

    total_supply -= _burn_amount
    self.balanceOf[msg.sender] -= _burn_amount
    self.totalSupply = total_supply
    log Transfer(msg.sender, ZERO_ADDRESS, _burn_amount)

    log RemoveLiquidity(msg.sender, amounts, empty(uint256[N_COINS]), total_supply)

    return amounts


@external
@nonreentrant('lock')
def remove_liquidity_imbalance(
    _amounts: uint256[N_COINS],
    _max_burn_amount: uint256,
    _receiver: address = msg.sender
) -> uint256:
    """
    @notice Withdraw coins from the pool in an imbalanced amount
    @param _amounts List of amounts of underlying coins to withdraw
    @param _max_burn_amount Maximum amount of LP token to burn in the withdrawal
    @param _receiver Address that receives the withdrawn coins
    @return Actual amount of the LP token burned in the withdrawal
    """

    amp: uint256 = self._A()
    rates: uint256[N_COINS] = [self.rate_multiplier, Curve(BASE_POOL).get_virtual_price()]
    old_balances: uint256[N_COINS] = self.balances
    D0: uint256 = self.get_D_mem(rates, old_balances, amp)

    new_balances: uint256[N_COINS] = old_balances
    for i in range(N_COINS):
        new_balances[i] -= _amounts[i]
    D1: uint256 = self.get_D_mem(rates, new_balances, amp)

    fees: uint256[N_COINS] = empty(uint256[N_COINS])
    base_fee: uint256 = self.fee * N_COINS / (4 * (N_COINS - 1))
    for i in range(N_COINS):
        ideal_balance: uint256 = D1 * old_balances[i] / D0
        difference: uint256 = 0
        new_balance: uint256 = new_balances[i]
        if ideal_balance > new_balance:
            difference = ideal_balance - new_balance
        else:
            difference = new_balance - ideal_balance
        fees[i] = base_fee * difference / FEE_DENOMINATOR
        self.balances[i] = new_balance - (fees[i] * ADMIN_FEE / FEE_DENOMINATOR)
        new_balances[i] -= fees[i]
    D2: uint256 = self.get_D_mem(rates, new_balances, amp)

    total_supply: uint256 = self.totalSupply
    burn_amount: uint256 = ((D0 - D2) * total_supply / D0) + 1
    assert burn_amount > 1  # dev: zero tokens burned
    assert burn_amount <= _max_burn_amount

    total_supply -= burn_amount
    self.totalSupply = total_supply
    self.balanceOf[msg.sender] -= burn_amount
    log Transfer(msg.sender, ZERO_ADDRESS, burn_amount)

    for i in range(N_COINS):
        amount: uint256 = _amounts[i]
        if i == MAX_COIN:
                LiquidityGauge(self.gauge).withdraw(amount)
        if amount != 0:    
            ERC20(self.coins[i]).transfer(_receiver, amount)

    log RemoveLiquidityImbalance(msg.sender, _amounts, fees, D1, total_supply)

    return burn_amount


@view
@internal
def get_y_D(A: uint256, i: int128, xp: uint256[N_COINS], D: uint256) -> uint256:
    """
    Calculate x[i] if one reduces D from being calculated for xp to D

    Done by solving quadratic equation iteratively.
    x_1**2 + x1 * (sum' - (A*n**n - 1) * D / (A * n**n)) = D ** (n + 1) / (n ** (2 * n) * prod' * A)
    x_1**2 + b*x_1 = c

    x_1 = (x_1**2 + c) / (2*x_1 + b)
    """
    # x in the input is converted to the same price/precision

    assert i >= 0  # dev: i below zero
    assert i < N_COINS  # dev: i above N_COINS

    S_: uint256 = 0
    _x: uint256 = 0
    y_prev: uint256 = 0
    c: uint256 = D
    Ann: uint256 = A * N_COINS

    for _i in range(N_COINS):
        if _i != i:
            _x = xp[_i]
        else:
            continue
        S_ += _x
        c = c * D / (_x * N_COINS)

    c = c * D * A_PRECISION / (Ann * N_COINS)
    b: uint256 = S_ + D * A_PRECISION / Ann
    y: uint256 = D

    for _i in range(255):
        y_prev = y
        y = (y*y + c) / (2 * y + b - D)
        # Equality with the precision of 1
        if y > y_prev:
            if y - y_prev <= 1:
                return y
        else:
            if y_prev - y <= 1:
                return y
    raise


@external
def ramp_A(_future_A: uint256, _future_time: uint256):
    assert msg.sender == self.admin  # dev: only owner
    assert block.timestamp >= self.initial_A_time + MIN_RAMP_TIME
    assert _future_time >= block.timestamp + MIN_RAMP_TIME  # dev: insufficient time

    _initial_A: uint256 = self._A()
    _future_A_p: uint256 = _future_A * A_PRECISION

    assert _future_A > 0 and _future_A < MAX_A
    if _future_A_p < _initial_A:
        assert _future_A_p * MAX_A_CHANGE >= _initial_A
    else:
        assert _future_A_p <= _initial_A * MAX_A_CHANGE

    self.initial_A = _initial_A
    self.future_A = _future_A_p
    self.initial_A_time = block.timestamp
    self.future_A_time = _future_time

    log RampA(_initial_A, _future_A_p, block.timestamp, _future_time)


@external
def stop_ramp_A():
    assert msg.sender == self.admin  # dev: only owner

    current_A: uint256 = self._A()
    self.initial_A = current_A
    self.future_A = current_A
    self.initial_A_time = block.timestamp
    self.future_A_time = block.timestamp
    # now (block.timestamp < t1) is always False, so we return saved A

    log StopRampA(current_A, block.timestamp)


@view
@external
def admin_balances(i: uint256) -> uint256:
    return ERC20(self.coins[i]).balanceOf(self) - self.balances[i]


@external
def withdraw_admin_fees():
    factory: address = self.factory

    # transfer coin 0 to Factory and call `convert_fees` to swap it for coin 1
    coin: address = self.coins[0]
    amount: uint256 = ERC20(coin).balanceOf(self) - self.balances[0]
    if amount > 0:
        ERC20(coin).transfer(factory, amount)
        Factory(factory).convert_fees()

    # transfer coin 1 to the receiver
    coin = self.coins[1]
    amount = ERC20(coin).balanceOf(self) - self.balances[1]
    if amount > 0:
        receiver: address = Factory(factory).fee_receiver(BASE_POOL)
        ERC20(coin).transfer(receiver, amount)