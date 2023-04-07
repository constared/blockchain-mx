// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./ABT.sol";
import "./registry.sol";

struct TApplication {
    address clientAddress;
    string symbol;
    uint256 amount;
    uint status; // 0 -create(SEND), 1 - accept, 2 - revoke, 3 - reject
}

contract Applications {
    address _owner;
    address _storekeeper;
    address[] _supplier;
    address _registry;

    mapping(string => TApplication) application;
    string[] applicationKeys;
    mapping(string => TApplication) redeemApplication;
    string[] redeemApplicationKeys;

    function _only(address own, string memory str) private view {
        require(
        msg.sender == own,
        string(abi.encodePacked("This function is restricted to the contract's ",str))
        );
    }

    modifier restricted_own() {
        _only(_owner, "owner");
        _;
    }

    modifier restricted_sk() {
        _only(_storekeeper, "storekeeper");
        _;
    }

    modifier restricted_supplier() {
        bool isExists = false;
        for (uint i; i < _supplier.length; i++) {
            if (_supplier[i] == msg.sender) {
                isExists = true;
            }
        }
        if(isExists) {
            _only(msg.sender, "supplier");
        } else {
            _only(0x0000000000000000000000000000000000000000, "supplier");
        }
        _;
    }

    constructor(address in_registry) {
        _owner = msg.sender;
        _storekeeper = msg.sender;
        _registry = in_registry;
    }

    function ifNotExists(string[] memory in_arr, string memory value) public pure returns (bool) {
        bool _isNotExists = true;
        for (uint i; i < in_arr.length; i++) {
            if(keccak256(abi.encodePacked(in_arr[i])) == keccak256(abi.encodePacked(value))) {
                _isNotExists = false;
                break;
            }
        }
        return _isNotExists;
    }

    function addSupplier(address supplier_) public restricted_own {
        require(_storekeeper!=supplier_, " Supplier should not be equal to the storekeeper");
        bool isExists = false;
        for (uint i; i < _supplier.length; i++) {
            if (_supplier[i] == supplier_) {
                isExists = true;
            }
        }
        require(!isExists, "Supplier already exists");
        _supplier.push(supplier_);
    }

    function deleteSupplier(address supplier_) public restricted_own {
        uint index;
        for (uint i; i < _supplier.length; i++) {
            if (_supplier[i] == supplier_) {
                index = i;
            }
        }
        if (index >= _supplier.length) return;
        for (uint i = index; i<_supplier.length-1; i++){
            _supplier[i] = _supplier[i+1];
        }
        _supplier.pop();
    }

    function querySuppliers() external view returns (address[] memory) {
        return _supplier;
    }

    function queryOwner() external view returns (address) {
        return _owner;
    }

    function queryStorekeeper() external view returns (address) {
        return _storekeeper;
    }

    function changeOwner(address newOwner) external restricted_own {
        _owner = newOwner;
    }

    function changeStorekeeper(address newStorekeeper) external restricted_own {
        _storekeeper = newStorekeeper;
    }

    function queryApplications() external view returns (string[] memory) {
        return applicationKeys;
    }

    function queryApplication(string memory appId) public view returns (address, string memory, uint256, uint) {
        TApplication memory app = application[appId];
        return (app.clientAddress, app.symbol, app.amount, app.status);
    }

    function sendApplication(string memory appId, string memory in_symbol, uint256 in_add_amount) public restricted_supplier {
        Registry(_registry).getTokenBySymbol(in_symbol);
        application[appId] = TApplication(msg.sender, in_symbol, in_add_amount, 0);
        if(ifNotExists(applicationKeys, appId)) applicationKeys.push(appId);
    }

    function acceptApplication(string memory appId) public restricted_sk {
        TApplication memory app = application[appId];
        require(app.status == 0, 'Wrong status.');
        (address res_token, string memory contract_name,) = Registry(_registry).getTokenBySymbol(app.symbol);
        if(keccak256(abi.encodePacked('ABT'))  == keccak256(abi.encodePacked(contract_name))) {
            ABT(res_token).emitToken(app.clientAddress, app.amount);
        }
        app.status = 1;
        application[appId] = app;
    }

    function rejectApplication(string memory appId) public restricted_sk {
        TApplication memory app = application[appId];
        require(app.status == 0, 'Wrong status.');
        app.status = 3;
        application[appId] = app;
    }

    function revokeApplication(string memory appId) public {
        TApplication memory app = application[appId];
        require(app.status == 0, 'Wrong status.');
        require(app.clientAddress == msg.sender, 'Only the client can run revoke.');
        app.status = 3;
        application[appId] = app;
    }

    function queryRedeemApplications() external view returns (string[] memory) {
        return redeemApplicationKeys;
    }

    function queryRedeemApplication(string memory appId) public view returns (address, string memory, uint256, uint) {
        TApplication memory app = redeemApplication[appId];
        return (app.clientAddress, app.symbol, app.amount, app.status);
    }

    function sendRedeemApplication(string memory appId, string memory in_symbol, uint256 in_add_amount) public restricted_supplier {
        Registry(_registry).getTokenBySymbol(in_symbol);
        redeemApplication[appId] = TApplication(msg.sender, in_symbol, in_add_amount, 0);
        if(ifNotExists(redeemApplicationKeys, appId)) redeemApplicationKeys.push(appId);
    }

    function acceptRedeemApplication(string memory appId) public restricted_sk {
        TApplication memory app = redeemApplication[appId];
        require(app.status == 0, 'Wrong status.');
        (address res_token, string memory contract_name,) = Registry(_registry).getTokenBySymbol(app.symbol);
        if(keccak256(abi.encodePacked('ABT'))  == keccak256(abi.encodePacked(contract_name))) {
            ABT(res_token).burnToken(app.clientAddress, app.amount);
        }
        app.status = 1;
        redeemApplication[appId] = app;
    }

    function rejectRedeemApplication(string memory appId) public restricted_sk {
        TApplication memory app = redeemApplication[appId];
        require(app.status == 0, 'Wrong status.');
        app.status = 3;
        redeemApplication[appId] = app;
    }

    function revokeRedeemApplication(string memory appId) public {
        TApplication memory app = redeemApplication[appId];
        require(app.status == 0, 'Wrong status.');
        require(app.clientAddress == msg.sender, 'Only the client can run revoke.');
        app.status = 3;
        redeemApplication[appId] = app;
    }
}