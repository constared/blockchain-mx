// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

contract Storage {
    address[] _owner;

    mapping(bytes32 => address) v_address;
    mapping(bytes32 => string) v_string;
    mapping(bytes32 => uint) v_uint;
    mapping(bytes32 => bool) v_bool;

    mapping(bytes32 => address[]) vr_address;
    mapping(bytes32 => string[]) vr_string;
    mapping(bytes32 => uint[]) vr_uint;
    mapping(bytes32 => bool[]) vr_bool;

    modifier restricted() {
        bool isExists = false;
        for (uint i; i < _owner.length; i++) {
            if (_owner[i] == msg.sender) {
                isExists = true;
            }
        }
        require(
        isExists,
        "This function is restricted to the contract's owner"
        );
        _;
    }

    constructor() {
        _owner.push(msg.sender);
    }

    function addOwner(address in_owner) public restricted {
        _owner.push(in_owner);
    }

    function delOwner(address in_owner) public restricted {
        require(_owner.length == 1, "Unable to remove single owner.");
        uint index;
        for (uint i; i < _owner.length; i++) {
            if (_owner[i] == in_owner) {
                index = i;
            }
        }
        require(index == 0, "There must be owner.");
        if (index >= _owner.length) return;

        for (uint i = index; i<_owner.length-1; i++){
            _owner[i] = _owner[i+1];
        }
        _owner.pop();
    }

    function getAddress(bytes32 in_key) public view returns (address) {
        return v_address[in_key];
    }

    function getString(bytes32 in_key) public view returns (string memory) {
        return v_string[in_key];
    }

    function getUint(bytes32 in_key) public view returns (uint) {
        return v_uint[in_key];
    }

    function getBool(bytes32 in_key) public view returns (bool) {
        return v_bool[in_key];
    }

    function setAddress(bytes32 in_key, address in_value) public restricted {
        v_address[in_key] = in_value;
    }

    function setString(bytes32 in_key, string memory in_value) public restricted {
        v_string[in_key] = in_value;
    }

    function setUint(bytes32 in_key, uint in_value) public restricted {
        v_uint[in_key] = in_value;
    }

    function setBool(bytes32 in_key, bool in_value) public restricted {
        v_bool[in_key] = in_value;
    }

//////////////////////////

    function getArrayOfAddress(bytes32 in_key) public view returns (address[] memory) {
        return vr_address[in_key];
    }

    function getArrayOfString(bytes32 in_key) public view returns (string[] memory) {
        return vr_string[in_key];
    }

    function getArrayOfUint(bytes32 in_key) public view returns (uint[] memory) {
        return vr_uint[in_key];
    }

    function getArrayOfBool(bytes32 in_key) public view returns (bool[] memory) {
        return vr_bool[in_key];
    }

    function pushItemOfAddressToArray(bytes32 in_key, address in_value) public restricted {
        vr_address[in_key].push(in_value);
    }

    function pushItemOfStringToArray(bytes32 in_key, string memory in_value) public restricted {
        vr_string[in_key].push(in_value);
    }

    function pushUintOfStringToArray(bytes32 in_key, uint in_value) public restricted {
        vr_uint[in_key].push(in_value);
    }

    function pushBoolOfStringToArray(bytes32 in_key, bool in_value) public restricted {
        vr_bool[in_key].push(in_value);
    }

    function delItemOfAddressToArray(bytes32 in_key, uint index) public restricted {
        for (uint i = index; i < vr_address[in_key].length - 1; i++) {
            vr_address[in_key][i] = vr_address[in_key][i+1];
        }
        vr_address[in_key].pop();
    }

    function delItemOfStringToArray(bytes32 in_key, uint index) public restricted {
        for (uint i = index; i < vr_string[in_key].length - 1; i++) {
            vr_string[in_key][i] = vr_string[in_key][i+1];
        }
        vr_string[in_key].pop();
    }

    function delItemOfUintToArray(bytes32 in_key, uint index) public restricted {
        for (uint i = index; i < vr_uint[in_key].length - 1; i++) {
            vr_uint[in_key][i] = vr_uint[in_key][i+1];
        }
        vr_uint[in_key].pop();
    }

    function delItemOfBoolToArray(bytes32 in_key, uint index) public restricted {
        for (uint i = index; i < vr_bool[in_key].length - 1; i++) {
            vr_bool[in_key][i] = vr_bool[in_key][i+1];
        }
        vr_bool[in_key].pop();
    }
}