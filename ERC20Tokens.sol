// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

interface ERC20Interface {
    function totalSupply() external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function transfer(address _to, uint256 _value)
        external
        returns (bool success);

    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256 remaining);

    function approve(address _spender, uint256 _value)
        external
        returns (bool success);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
}

contract Cryptos is ERC20Interface {
    string public name = "Cryptos";
    string public symbol = "CRPT";
    uint256 public decimals = 0; // 18
    uint256 public override totalSupply;

    address public founder;
    mapping(address => uint256) public balances;
    // balances[Ox1111...] = 100;

    mapping(address => mapping(address => uint256)) allowed;

    // Ox1111... (owner) allows Ox2222... (the spender) ---- 100 tokens
    // allowed[Ox1111][Ox2222] = 100;

    constructor() {
        totalSupply = 1000000;
        founder = msg.sender;
        balances[founder] = totalSupply;
    }

    function balanceOf(address _owner)
        public
        view
        override
        returns (uint256 balance)
    {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _tokens)
        public
        virtual
        override
        returns (bool success)
    {
        // wil return false on failure
        require(balances[msg.sender] >= _tokens);

        balances[_to] += _tokens;
        balances[msg.sender] -= _tokens;
        emit Transfer(msg.sender, _to, _tokens);

        return true;
    }

    function allowance(address _owner, address _spender)
        public
        view
        override
        returns (uint256)
    {
        return allowed[_owner][_spender];
    }

    function approve(address _spender, uint256 _tokens)
        public
        override
        returns (bool success)
    {
        require(balances[msg.sender] >= _tokens);
        require(_tokens > 0);

        allowed[msg.sender][_spender] = _tokens;

        emit Approval(msg.sender, _spender, _tokens);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokens
    ) public virtual override returns (bool success) {
        require(allowed[_from][_to] >= _tokens);
        require(balances[_from] >= _tokens);

        balances[_from] -= _tokens;
        balances[_to] += _tokens;
        allowed[_from][_to] -= _tokens;

        return true;
    }
}

contract CryptoICO is Cryptos {
    address public admin;
    address payable public deposit;
    uint256 tokenPrice = 0.001 ether; // 1ETH = 1000 CRPT, 1CRPT = 0.001ETH
    uint256 public hardCap = 300 ether;
    uint256 public raisedAmount;
    uint256 public saleStart = block.timestamp;
    uint256 public saleEnd = block.timestamp + 604800; // ico ends in one week
    uint256 public tokenTradeStart = saleEnd + 604800; // transferable in a week after sale
    uint256 public maxInvestment = 5 ether;
    uint256 public minInvestment = 0.1 ether;

    enum State {
        beforeStart,
        running,
        afterEnd,
        halted
    }
    State public icoState;

    constructor(address payable _deposit) {
        deposit = _deposit;
        admin = msg.sender;
        icoState = State.beforeStart;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }

    function halt() public onlyAdmin {
        icoState = State.halted;
    }

    function resume() public onlyAdmin {
        icoState = State.running;
    }

    function changeDepositAddress(address payable newDeposit) public onlyAdmin {
        deposit = newDeposit;
    }

    function getCurrentState() public view returns (State) {
        if (icoState == State.halted) {
            return State.halted;
        } else if (block.timestamp < saleStart) {
            return State.beforeStart;
        } else if (block.timestamp >= saleStart && block.timestamp <= saleEnd) {
            return State.running;
        } else {
            return State.afterEnd;
        }
    }

    event Invest(address investor, uint256 value, uint256 tokens);

    function invest() public payable returns (bool) {
        icoState = getCurrentState();
        require(icoState == State.running);

        require(msg.value >= minInvestment && msg.value <= maxInvestment);
        raisedAmount += msg.value;
        require(raisedAmount <= hardCap);

        uint256 tokens = msg.value / tokenPrice;

        balances[msg.sender] += tokens;
        balances[founder] -= tokens;
        deposit.transfer(msg.value);

        emit Invest(msg.sender, msg.value, tokens);

        return true;
    }

    receive() external payable {
        invest();
    }

    function transfer(address _to, uint256 _tokens)
        public
        virtual
        override
        returns (bool success)
    {
        require(block.timestamp > tokenTradeStart);
        Cryptos.transfer(_to, _tokens); // same as super.transfer(_to, _tokens);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokens
    ) public override returns (bool success) {
        require(block.timestamp > tokenTradeStart);
        Cryptos.transferFrom(_from, _to, _tokens);
        return true;
    }

    function burn() public returns (bool) {
        icoState = getCurrentState();
        require(icoState == State.afterEnd);
        balances[founder] = 0;
        return true;
    }
}
