// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Import the console module for logging (uncomment for local testing)
// import "hardhat/console.sol";

/**
 * @title Lock
 * @dev This contract allows an owner to lock funds until a specified unlock time.
 */
contract Lock {
    uint public unlockTime;         // The time after which funds can be withdrawn
    address payable public owner;    // The address of the owner who can withdraw funds

    // Event that is emitted when funds are withdrawn
    event Withdrawal(uint amount, uint when);

    /**
     * @dev Constructor that initializes the lock with an unlock time.
     * @param _unlockTime The timestamp (in seconds) until which funds are locked.
     */
    constructor(uint _unlockTime) payable {
        require(
            block.timestamp < _unlockTime,
            "Unlock time should be in the future"
        );

        unlockTime = _unlockTime;
        owner = payable(msg.sender);
    }

    /**
     * @dev Allows the owner to withdraw funds once the unlock time is reached.
     */
    function withdraw() public {
        // Uncomment this line, and the import of "hardhat/console.sol", to print a log in your terminal
        // console.log("Unlock time is %o and block timestamp is %o", unlockTime, block.timestamp);
        
        // Check if the current block timestamp is greater than or equal to the unlock time
        require(block.timestamp >= unlockTime, "You can't withdraw yet");
        
        // Check if the caller is the owner of the contract
        require(msg.sender == owner, "You aren't the owner");

        // Emit a withdrawal event before transferring funds
        emit Withdrawal(address(this).balance, block.timestamp);

        // Transfer the contract's balance to the owner
        owner.transfer(address(this).balance);
    }
}