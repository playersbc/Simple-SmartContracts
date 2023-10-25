// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;


interface IInternationalAccount{

    ///@dev Function to generate a new Federal account
    ///@param _manager is the single manager of the federal account
    function addFederalAccount(address _manager) external;

    ///@dev Function to generate player transfer voting
    ///@param _PlayerID is the transfer transaction ID
    ///@notice only a federal account can create
    function generatePlayerRequestInternational(uint _PlayerID, address _base, address _transferTo, uint256 _price) external;

    ///@dev Function to accept the transaction
    ///@param _PlayerID is the transaction ID
    function acceptVoteInternacional(uint _PlayerID, address _team) external;

    ///@dev Function to change the single manager of the international account
    ///@param _manager is the new manager address
    //function changeManagerInternational(address _manager) external;
}