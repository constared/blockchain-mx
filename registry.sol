// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

contract Registry {
    address[] _owner;
    string[] _symbols;
    address[] _tokens;
    string[] _types;
    bool[] _isDeprecated;

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

    function getOwners() public view returns (address[] memory) {
        return _owner;
    }

    function addOwner(address owner_) public restricted {
        bool isExists = false;
        for (uint i; i < _owner.length; i++) {
            if (_owner[i] == owner_) {
                isExists = true;
            }
        }
        require(!isExists, "Owner already exists");
        _owner.push(owner_);
    }

    function deleteOwner(address owner_) public restricted {
        uint index;
        for (uint i; i < _owner.length; i++) {
            if (_owner[i] == owner_) {
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

    function addToken(string memory symbol, address contract_address, string memory contract_name) public restricted {
        if(!(isExistsSymbol(symbol)&&isExistsToken(contract_address)&&isExistsCN(contract_name))) {
            _symbols.push(symbol);
            _tokens.push(contract_address);
            _types.push(contract_name);
            _isDeprecated.push(false);
        } else {
            revert("Token already exists.");
        }
    }

    function isExistsToken(address contract_address) private view returns (bool) {
        for (uint i = 0; i < _tokens.length; i++) {
            if(_tokens[i] == contract_address) {
                return true;
            }
        }
        return false;
    }

    function isExistsSymbol(string memory symbol) private view returns (bool) {
        for (uint i = 0; i < _symbols.length; i++) {
            if(keccak256(abi.encodePacked(_symbols[i])) == keccak256(abi.encodePacked(symbol))) {
                return true;
            }
        }
        return false;
    }

    function isExistsCN(string memory contract_name) private view returns (bool) {
        for (uint i = 0; i < _types.length; i++) {
            if(keccak256(abi.encodePacked(_types[i])) == keccak256(abi.encodePacked(contract_name))) {
                return true;
            }
        }
        return false;
    }

    function setDeprecated(address contract_address) public restricted {
        for (uint i=0; i<_tokens.length; i++) {
            if(_tokens[i] == contract_address) {
                _isDeprecated[i] = true;
            }
        }
    }

    function getAllTokens() public view returns (string[] memory, address[] memory, string[] memory, bool[] memory) {
        return (_symbols, _tokens, _types, _isDeprecated);
    }

    function getTokenBySymbol(string memory symbol) public view returns (address, string memory, bool) {
        bool flg = false;

        address res_token = 0x0000000000000000000000000000000000000000;
        string memory res_type = "empty";
        bool res_eprecated = false;
        require(_symbols.length!=0, "List of Tokens is empty.");
        for (uint i=0; i<_symbols.length; i++) {
            if(keccak256(abi.encodePacked(_symbols[i])) == keccak256(abi.encodePacked(symbol))&&!_isDeprecated[i]) {
                res_token = _tokens[i];
                res_type = _types[i];
                res_eprecated = _isDeprecated[i];
                break;
            } else if ((i+1)==_symbols.length) {
                flg = true;
            }
        }
        if(flg) revert("Token does not found.");
        return (res_token, res_type, res_eprecated);
    }

    function getSymbolByToken(address token) public view returns (string memory, string memory, bool) {
        bool flg = false;

        string memory res_symbol = "empty";
        string memory res_type = "empty";
        bool res_eprecated = false;
        require(_symbols.length!=0, "List of Tokens is empty.");
        for (uint i=0; i<_tokens.length; i++) {
            if(_tokens[i] == token && !_isDeprecated[i]) {
                res_symbol = _symbols[i];
                res_type = _types[i];
                res_eprecated = _isDeprecated[i];
                break;
            } else if ((i+1)==_tokens.length) {
                flg = true;
            }
        }
        if(flg) revert("Token does not found.");
        return (res_symbol, res_type, res_eprecated);
    }
}