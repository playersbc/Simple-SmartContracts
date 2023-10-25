// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IPassportController{

    ///@dev Struct that stores the trainers info
    ///@param _trainer is the new added trainer
    ///@param _duration is the amount of time the player stayed in the _trainer
    ///@param _timestamp is the timestamp of the transfer to that team
    struct TrainerInfo{
        address _trainer;
        uint256 _duration;
        uint256 _timestamp;
    }

    ///@dev Struct to store the player's info
    ///@param _birthTimestamp is the player's birth timestamp
    ///@param _creation is the timestamp of the player's file creation
    ///@param _currentBase is the current base account the player is on
    ///@param _playerController is the controller account of the player, like agent address
    ///@param _retired is if the player is retired or not
    struct PlayerInfo {
        uint256 _birthTimestamp;
        uint256 _creation;
        address _currentBase;
        address _playerController;
        bool _retired;
    }

    ///@dev Function to create new player in the passport controller
    ///@param _birth is the timestamp of the player's birth
    ///@param _baseAccount is the player's base account current position
    ///@param _agent is the address of the wallet that will control the player's decisions
    function createPlayerPassport(uint256 _birth, address _baseAccount, address _agent) external returns(uint256);


    ///@dev Function to transfer a player between 2 base accounts
    ///@param _playerID is the player identification to be transfered
    ///@param _to is the address of the receiver base account
    //function transferPlayer(uint256 _playerID, address _to) external;


}