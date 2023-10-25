// SPDX-License-Identifier: MIT
pragma solidity >=0.8.15;


import "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";


contract BaseAccountBeacon is UpgradeableBeacon{
    constructor(address _impl) UpgradeableBeacon(_impl){}
}

contract FederalAccountBeacon is UpgradeableBeacon{
    constructor(address _impl) UpgradeableBeacon(_impl){}
}

contract InternationalAccountBeacon is UpgradeableBeacon{
    constructor(address _impl) UpgradeableBeacon(_impl){}
}


contract UUPSPassport is ERC1967Proxy{


    constructor(address _impl,bytes memory _data) ERC1967Proxy(_impl, _data){}
}
