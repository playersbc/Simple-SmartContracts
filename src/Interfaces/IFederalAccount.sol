// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;


interface IFederalAccount {
    ///@dev Function to generate new base accounts under this federal entity
    ///@param _manager is the manager of the base account
    //function generateBaseAccount(address _manager) external;

    ///@dev Function that generates a transfer request
    ///@param _player is the voting to be approved
    ///@notice only a base account can create
    function generatePlayerRequestFederal(uint _player, address _team, address _transferTo, uint256 _price) external;

    ///@dev Function to accept a transfer request
    ///@param _player  is the transfer to be approved
    function acceptVoteFederal(uint _player, address _base) external;

    ///@dev Function to execute the transaction
    ///@param _player is the transaction ID
    ///@notice only international account can trigger that
    function executeTransactionFederal(uint _player, address _base) external;

    ///@dev Function to add a new base account under this entity accepted addresses of base accounts
    ///@param _baseAccount is the base account address to be added
    function addBaseAccount(address _baseAccount) external;

    ///@dev Function to remove a base account address from the accepted ones
    ///@param _baseAccount is the base account to be taken off
    function removeBaseAccount(address _baseAccount) external;

    ///@dev Function to change the single manager of the federal entity
    ///@param _manager is the new manager address
    //function changeManager(address _manager) external;
    
}