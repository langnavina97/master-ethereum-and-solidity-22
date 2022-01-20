// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

contract Lottery {
    address payable[] public players;
    address public manager;

    constructor() {
        manager = msg.sender;
        players.push(payable(manager));
    }

    receive() external payable {
        require(manager != msg.sender);
        require(msg.value > 0.00000000000000001 ether);

        players.push(payable(msg.sender));
    }

    function getBalance() public view returns(uint) {
        require(msg.sender == manager);
        return address(this).balance;
    }

    function random() public view returns(uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
    }


    function pickWinner() public {
        require(msg.sender == manager || players.length >= 10);
        require(players.length >= 3);

        uint r = random();
        address payable winner;

        uint index = r % players.length;
        winner = players[index];

        winner.transfer(getBalance());
        players = new address payable[](0); // resetting the lottery
    }
}