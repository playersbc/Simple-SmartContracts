// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";


import "forge-std/console.sol";
import "../src/simple/PlayersBCsimple.sol";
import "../test/Utils/MockERC20.sol";

contract Deploy is Script {

    
   PlayersBCsimple public playersBCsimple;
    mockERC20 public payment;

    address owner;
    uint256 ownerPrivateKey;
    address user;
    uint256 userPrivateKey;
    address managerBase;
    uint256 manager1PrivateKey;
    address managerFederal;
    uint256 manager2PrivateKey;
    address manager;
    uint256 manager3PrivateKey;
    address managerInter;
    uint256 manager4PrivateKey;

    function setUp() public {
      //  managers.push(0x2271b1FBb0126F79b54b45f4787733286D035fe5);
        
    }

    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        payment = new mockERC20("Payment", "P2P");
        playersBCsimple = new PlayersBCsimple(address(payment));
      

        vm.stopBroadcast();
    }
}
