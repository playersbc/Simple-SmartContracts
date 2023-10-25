// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "lib/ERC721A/contracts/ERC721A.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../Interfaces/IPassportController.sol";
import "../Interfaces/IFederalAccount.sol";
import "../Interfaces/IInternationalAccount.sol";
import "../Interfaces/IBaseAccount.sol";

contract PlayersBCsimple is ERC721A, 
IPassportController, 
IFederalAccount,
IInternationalAccount,
IBaseAccount{

    event voteCreated(uint256 indexed _player, bytes32 indexed _voteId, address indexed _to, uint256 _price, address _creator);
    event voted(bytes32 _vote, address _manager);
    event transfered(uint256 indexed _player, address indexed _to, uint256 indexed _price, uint256 _timestamp);

    struct receipt {
        bool _voted;
        uint256 _timestamp;
    }

    struct playerTransfer{
        address _team;
        uint256 _playerId;
        uint256 _price;
        bool _bothAcept;
        bool _teamAccept;
        bool _stakeholderAccept;
    }

    struct voting {
        address _proponent;
        uint _vote;
        bool _executed;
    }


    uint256 constant _24YEARS = 365 days * 24;
    mapping(address => bool) public transferApproved;
    mapping(address => bool) public managers;
    mapping(address => bool) public base;
    mapping(address => bool) public federal;
    mapping(address => bool) public international;
    mapping(address => bool)public passportController;  
    mapping(uint256 => PlayerInfo) public players;
    mapping(uint256 => TrainerInfo[]) public trainers;
    mapping(address => playerTransfer) public transfers;
    mapping(address => receipt) public vote;
    mapping(address => mapping(address => playerTransfer)) acceptTransfers;
    mapping(uint256 => uint256) public _playerCareer;
    IERC20 public COIN;
    string public baseURI;
    mapping(uint256 => string) private _tokenURIs;
    event MetadataUpdate(uint256 _id);


constructor(address _coin)ERC721A("PlayersBC", "PLBC"){
    COIN = IERC20(_coin);
    managers[msg.sender] = true;
}

//passaport ----

function createPlayerPassport(uint256 _birth, 
    address _baseAccount, 
    address _agent) external returns(uint256)
    { //mint for base account
    if(!baseAccountCheck(_baseAccount)) revert("not base account");

    players[_nextTokenId()] = PlayerInfo({
        _birthTimestamp:_birth,
        _creation: block.timestamp,
        _currentBase:_baseAccount,
        _playerController:_agent,
        _retired:false
    });  

    trainers[_nextTokenId()].push(TrainerInfo(_baseAccount, 0, block.timestamp));
    _safeMint(_baseAccount, 1, "");



    return (_nextTokenId());

}


function transferPlayer(uint256 _playerID, address _to, uint256 _price) public returns(bool){
        baseAccountCheck(_to);
        
        PlayerInfo memory _auxPlayer = players[_playerID];
        TrainerInfo memory _auxTrainer = trainers[_playerID][trainers[_playerID].length-1];
        require(!_auxPlayer._retired, "Passport Controller : Player is retired");


        if(block.timestamp - _auxPlayer._birthTimestamp < _24YEARS){
            trainers[_playerID][trainers[_playerID].length-1]._duration = block.timestamp - _auxTrainer._timestamp;
            _playerCareer[_playerID] += block.timestamp - _auxTrainer._timestamp;

            TrainerInfo memory _newTrainer = TrainerInfo({
                    _trainer : _to,
                    _duration : 0,
                    _timestamp : block.timestamp
            });
            trainers[_playerID].push(_newTrainer);

        }else if(_auxTrainer._duration == 0){
            uint256 _auxDuration = _auxPlayer._birthTimestamp + _24YEARS - _auxTrainer._timestamp;

            trainers[_playerID][trainers[_playerID].length-1]._duration = _auxDuration;
            _playerCareer[_playerID] += _auxDuration;

        }
        
        
        players[_playerID]._currentBase = _to;

        _solidarityMechanism(_playerID,_price);

        if(federal[msg.sender]|| managers[msg.sender]){
            address teamTransferPLayerFromBase = players[_playerID]._currentBase; 
            safeTransferFrom(_to, teamTransferPLayerFromBase, _playerID);
        }else{
            transferFrom(msg.sender, _to, _playerID);
        }



        return true;
}

function getPlayerInfo(uint256 _playerID) external view returns(PlayerInfo memory){
    return players[_playerID];
}

function _solidarityMechanism(uint256 _playerID, uint256 _price) internal{
    TrainerInfo[] memory _aux = trainers[_playerID];
    uint loop = _aux.length;
    uint duration = _playerCareer[_playerID];
    require(COIN.balanceOf(address(this))>= _price,"Passport Controller : Didn't receive 5%");
    for(uint256 i = 0; i < loop;){
        if(loop == 1){
        COIN.transfer(_aux[i]._trainer, _price);
        }else {
            uint256 _amount = (_aux[i]._duration*_price)/duration;
            if(!COIN.transfer(_aux[i]._trainer, _amount ))
            revert("Passport Controller : Payment didn't go through");
        }
        unchecked {
            ++i;
        }
    }

        // if(COIN.balanceOf(address(this)) > 0 && _aux[_aux.length-1]._duration == 0){
        //     if(!COIN.transfer(_aux[_aux.length-2]._trainer, COIN.balanceOf(address(this)) ))
        //     revert("Passport Controller : Payment didn't go through");
        // }else if(COIN.balanceOf(address(this)) > 0 && _aux[_aux.length-1]._duration > 0){
        //     if(!COIN.transfer(_aux[_aux.length-1]._trainer, COIN.balanceOf(address(this)) ))
        //     revert("Passport Controller : Payment didn't go through");
        // }
    }





// function _solidarityMechanism(uint _value, address _base, address _team) internal {
//     unchecked {
//         uint256 fivePercentBase = _value*5/100; //5%
//     uint amountTransfer = _value - fivePercentBase;
//     IERC20(COIN).transfer( _base, fivePercentBase);
//     IERC20(COIN).transfer(_team, amountTransfer);
//     }


// }



//internationalccounts ----


function addiInternational(address _international) public {
    _isManager();
    international[_international] = true;
}

function addFederalAccount(address _federal) external{
    require(international[msg.sender]|| managers[msg.sender], "your not stakeholder or manager");
    federal[_federal]=true;
}

function addBaseAccount(address _baseAccount) external{
    require(federal[msg.sender]|| managers[msg.sender], "your not stakeholder or manager");
    base[_baseAccount]=true;
}

function generatePlayerRequestInternational(uint _playerID, address _base, address _transferTo, uint256 _price) external{
    require(international[msg.sender]|| managers[msg.sender], "your not stakeholder or manager");
    if(!_exists(_playerID)) revert("not exist player");
    acceptTransfers[msg.sender][_base]._stakeholderAccept = true;
    transfers[msg.sender] = playerTransfer({_team: _transferTo, _playerId: _playerID, _price: _price,
    _bothAcept: false, _teamAccept: false, _stakeholderAccept: true});
}

function acceptVoteInternacional(uint _playerID, address _base) external{
    require(international[msg.sender]|| managers[msg.sender], "your not stakeholder or manager");
    if(!_exists(_playerID)) revert("not exist player");
    if(acceptTransfers[msg.sender][_base]._teamAccept){
        acceptTransfers[msg.sender][_base]._bothAcept = true;
    } else {
        revert("team not Request transfer this player");
    }
}

function changeManagerInternational(address _newinternational) external{
    require(international[msg.sender]|| managers[msg.sender], "your not stakeholder or manager");
    addiInternational(_newinternational);
}


//federalaccounts ----


function generatePlayerRequestFederal(uint _playerID, address _base, address _transferTo, uint256 _price) external{
    require(federal[msg.sender]|| managers[msg.sender], "your not stakeholder or manager");
    if(!_exists(_playerID)) revert("not exist player");
    if(!baseAccountCheck(_base))
    acceptTransfers[msg.sender][_base]._stakeholderAccept = true;
    transfers[msg.sender] = playerTransfer({_team: _transferTo, _playerId: _playerID, _price: _price,
    _bothAcept: false, _teamAccept: false, _stakeholderAccept: true});
   

}

function acceptBaseandExecute(uint _playersID, address _stakeholderRequest, address _transferTo) external{
    if(!baseAccountCheck(msg.sender))
    if(!_exists(_playersID)) revert("not exist player");
    acceptTransfers[_stakeholderRequest][msg.sender]._bothAcept = true;
    uint256 price = transfers[_stakeholderRequest]._price;
    transferPlayer(_playersID, _transferTo, price);
    // _solidarityMechanism(price, msg.sender, _transferTo);
}

function acceptVoteFederal(uint _playerID, address _base) external{
    if(!baseAccountCheck(_base))
    require(federal[msg.sender]|| managers[msg.sender], "your not stakeholder or manager");
    if(!_exists(_playerID)) revert("not exist player");
     if(acceptTransfers[msg.sender][_base]._teamAccept){
    acceptTransfers[msg.sender][_base]._bothAcept = true;
    } else {
        revert("team not Request transfer this player");
    }
}

    
    
function executeTransactionFederal(uint _playerID, address _base) external{
    require(federal[msg.sender]|| managers[msg.sender], "your not stakeholder or manager");
    if(!acceptTransfers[msg.sender][_base]._bothAcept) revert("not both accept transfer player");
    uint price = transfers[_base]._price;
    transferPlayer(_playerID, _base,price);
    // address teamTransferPLayerFromBase = players[_playerID]._currentBase; 
    // safeTransferFrom(_base, teamTransferPLayerFromBase, _playerID);
    // _solidarityMechanism(price, _base, teamTransferPLayerFromBase);
    
}

   
function removeBaseAccount(address _baseAccount) external{
   require(federal[msg.sender]|| managers[msg.sender], "your not stakeholder or manager");
    base[_baseAccount]=false;
}




//baseaccounts ----

function generatePlayerRequestBase(uint256 _playerID, address _transferTo, uint256 _price, address _stakeholder) external{
    require(baseAccountCheck(_transferTo) && baseAccountCheck(msg.sender), "addresses not interested in base teams");
    if(!_exists(_playerID)) revert("not exist player");
    require(federal[_stakeholder]|| managers[_stakeholder] || international[_stakeholder], "not stakeholder");
    acceptTransfers[_stakeholder][msg.sender]._teamAccept = true;

    transfers[msg.sender] = playerTransfer({_team: _transferTo, _playerId: _playerID, _price: _price,
     _bothAcept: false, _teamAccept: true, _stakeholderAccept: false});

}

function executeTransactionBase(uint _playersID, address _stakeholder, address _transferTo) external{
    if(!baseAccountCheck(msg.sender)) revert("not base account");
    if(!_exists(_playersID)) revert("not exist player");
    require(acceptTransfers[_stakeholder][msg.sender]._bothAcept == true, "not both accept transfer player");
    uint256 price = transfers[msg.sender]._price;
    transferPlayer(_playersID, _transferTo,price);

}

    
function changeManager(address _manager) external{
    if(!managers[msg.sender]) revert("You're not a manager");
    managers[_manager]=true;
}

    
function transferOutsider(address _to, uint256 _amount) external returns(bool){
    if(!managers[msg.sender]) revert("You're not a manager");
    unchecked {
    COIN.transfer(_to, _amount);
    }
    return true;
}

    
function changePaymentToken(address _paymentToken) external returns(bool){
    if(!managers[msg.sender]) revert("You're not a manager");
    COIN = IERC20(_paymentToken);
    return true;
}


    ///manager

function managementCheck(address _address) external view{   
    if(!managers[_address]) revert("You're not a manager");
}

function addManager(address _newManager) external {
    _isManager();
    managers[_newManager] = true;
}
    
function baseAccountCheck(address _address) internal view returns(bool){
    if(!base[_address]) revert("You're not a base account");
    return true;
}

function _isPassport() internal view {
    if(!passportController[msg.sender]) revert("You're not passport controller");
}

function _isManager() internal view {
    if(!managers[msg.sender]) revert("You're not a manager");
}
function _isFederal() internal view {
    if(!federal[msg.sender]) revert("You're not a federal shareholder");
}
function _isInternational() internal view {
    if(!international[msg.sender]) revert("You're not an international shareholder");
}

//image passaport
function tokenURI(uint256 tokenId) public view virtual override(ERC721A) returns (string memory) {
    if (!_exists(tokenId)) revert URIQueryForNonexistentToken();
    string memory _tokenURI = _tokenURIs[tokenId];
    string memory baset = _baseURI();
    // If there is no base URI, return the token URI.
    if (bytes(baset).length == 0) {
        return _tokenURI;
    }
    // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
    if (bytes(_tokenURI).length > 0) {
        return string(abi.encodePacked(baset, _tokenURI));
    }
    return super.tokenURI(tokenId);
    // return
    //     bytes(baseURI).length > 0
    //         ? string(abi.encodePacked(ERC721URIStorage.tokenURI(tokenId), tokenId.toString()))
    //         : baseURI;
}
function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
    require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
    _tokenURIs[tokenId] = _tokenURI;
    emit MetadataUpdate(tokenId);
}
function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
}
    //control trasnfer passaport

function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId
) public payable virtual override {
    require(federal[to]|| managers[to] || international[to] || base[to]);
    safeTransferFrom(from, to, tokenId, '');
}


function deposit(uint256 _amount) external returns(bool) {
    _isManager();
    require(IERC20(COIN).allowance(msg.sender, address(this)) >= _amount, "Base Account : Not enough allowance");
    return IERC20(COIN).transferFrom(msg.sender, address(this), _amount);
}

function withdraw(uint256 _amount) external returns(bool){
    _isManager();
    return IERC20(COIN).transfer(msg.sender, _amount);
}

}