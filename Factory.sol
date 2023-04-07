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

contract Factory {
    address _owner;
    address _storekeeper;
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
        _only(_owner, "storekeeper");
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

    function changeOwner(address newOwner) external restricted_own {
        _owner = newOwner;
    }

    function changeStorekeeper(address newStorekeeper) external restricted_own {
        _storekeeper = newStorekeeper;
    }

    // function createToken(
    //     string memory name_,
    //     string memory symbol_,
    //     string[] memory spec_,
    //     uint[] memory spec_types_, // 0 - number, 1 - date, 2 - string
    //     string[] memory spec_vals_
    // ) public restricted_own {
    //     try Registry(_registry).getTokenBySymbol(symbol_) returns (address res_token, string memory, bool){
    //         if(res_token != 0x0000000000000000000000000000000000000000) {
    //             revert("Token already exists.");
    //         }
    //     } catch {
    //         address contractAddress; //= address(new ABT(name_, symbol_, _registry, spec_, spec_types_, spec_vals_));
    //         Registry(_registry).addToken(symbol_, contractAddress, 'ABT');
    //     }
    // }

    function queryApplications() external view returns (string[] memory) {
        return applicationKeys;
    }

    function queryApplication(string memory appId) public view returns (address, string memory, uint256, uint) {
        TApplication memory app = application[appId];
        return (app.clientAddress, app.symbol, app.amount, app.status);
    }

    function sendApplicaiton(string memory appId, string memory in_symbol, uint256 in_add_amount) public {
        Registry(_registry).getTokenBySymbol(in_symbol);
        application[appId] = TApplication(msg.sender, in_symbol, in_add_amount, 0);
        if(ifNotExists(applicationKeys, appId)) applicationKeys.push(appId);
    }

    function acceptApplicaiton(string memory appId) public restricted_sk {
        TApplication memory app = application[appId];
        require(app.status == 0, 'Wrong status.');
        (address res_token, string memory contract_name,) = Registry(_registry).getTokenBySymbol(app.symbol);
        if(keccak256(abi.encodePacked('ABT'))  == keccak256(abi.encodePacked(contract_name))) {
            ABT(res_token).emitToken(_storekeeper, app.amount);
        }
        app.status = 1;
        application[appId] = app;
    }

    function rejectApplicaiton(string memory appId) public restricted_sk {
        TApplication memory app = application[appId];
        require(app.status == 0, 'Wrong status.');
        app.status = 3;
        application[appId] = app;
    }

    function revokeApplicaiton(string memory appId) public {
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

    function sendRedeemApplicaiton(string memory appId, string memory in_symbol, uint256 in_add_amount) public {
        Registry(_registry).getTokenBySymbol(in_symbol);
        redeemApplication[appId] = TApplication(msg.sender, in_symbol, in_add_amount, 0);
        if(ifNotExists(redeemApplicationKeys, appId)) redeemApplicationKeys.push(appId);
    }

    function acceptRedeemApplicaiton(string memory appId) public restricted_sk {
        TApplication memory app = redeemApplication[appId];
        require(app.status == 0, 'Wrong status.');
        (address res_token, string memory contract_name,) = Registry(_registry).getTokenBySymbol(app.symbol);
        if(keccak256(abi.encodePacked('ABT'))  == keccak256(abi.encodePacked(contract_name))) {
            ABT(res_token).burnToken(_storekeeper, app.amount);
        }
        app.status = 1;
        redeemApplication[appId] = app;
    }

    function rejectRedeemApplicaiton(string memory appId) public restricted_sk {
        TApplication memory app = redeemApplication[appId];
        require(app.status == 0, 'Wrong status.');
        app.status = 3;
        redeemApplication[appId] = app;
    }

    function revokeRedeemApplicaiton(string memory appId) public {
        TApplication memory app = redeemApplication[appId];
        require(app.status == 0, 'Wrong status.');
        require(app.clientAddress == msg.sender, 'Only the client can run revoke.');
        app.status = 3;
        redeemApplication[appId] = app;
    }
}