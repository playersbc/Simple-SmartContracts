// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IBaseAccount {
    ///@dev Function to generate player transfer request
    ///@param _player is the playerID in the passport smart contract
    ///@param _transferTo is the base account address that will be receiving the player
    function generatePlayerRequestBase(uint256 _player, address _transferTo, uint256 _amount, address _stakeholder) external;

    ///@dev Function to execute a transfer
    ///@param _playersID is the transaction hash of that transfer
    ///@notice only a federal account can trigger that
    function executeTransactionBase(uint _playersID, address _stakeholder, address _transferTo) external;

    ///@dev Function to change the single manager of the base account
    //function changeManagerBase(address _manager) external;

    ///@dev Function to deposit amounts for future transactions
    ///@param _amount is the amount to be deposited
    function deposit(uint256 _amount) external returns(bool);

    ///@dev Function to withdraw money that has been received or spare in the account
    ///@param _amount is the amount to withdraw
    function withdraw(uint256 _amount) external returns(bool);

    ///@dev Function to approve other base account to move money on a transfer
    ///@param _spender is the address of the base account that will move the money
    ///@param _amount is the amount of money that the _spender can move
    function transferOutsider(address _spender, uint256 _amount) external returns(bool);

    ///@dev Function to change the payment token
    ///@param _paymentToken is the new payment token
    function changePaymentToken(address _paymentToken) external returns(bool);
}
