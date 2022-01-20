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
    ) public override returns (bool success) {
        require(allowed[_from][_to] >= _tokens);
        require(balances[_from] >= _tokens);

        balances[_from] -= _tokens;
        balances[_to] += _tokens;
        allowed[_from][_to] -= _tokens;

        return true;
    }
}
