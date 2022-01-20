// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

// cannot be deployed on the blockchain
abstract contract BaseContract {
    int256 public x;
    address public owner;

    constructor() {
        x = 5;
        owner = msg.sender;
    }

    function setX(int256 _x) public {
        x = _x;
    }
}

// can derived from the abstract contract
contract A is BaseContract {
    int256 public y = 3;

    // function cannnot be overridden
}

interface BaseContract2 {
    function setX(int256 _x) external;
}

contract B is BaseContract2 {
    int256 public x;

    function setX(int256 _x) public override {
        x = _x * 2;
    }
}
