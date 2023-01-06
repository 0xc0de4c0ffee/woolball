// SPDX-License-Identifier: WTFPL
pragma solidity ^0.8.0;

error DiamondPaused();
error OnlyGovContract(address);
error DuplicateContract(address _contract);
error DuplicateFunction(bytes4 _function, address _contract);
error InvalidFunctionLength(uint _length, bytes4[] _functions);
error InvalidFunction(bytes4);
error ContractNotActive(address _contract);
error ContractLocked(address _contract);
error DelegateCallFailed(address _contract, bytes _input, bytes _error);
error StaticCallFailed(bytes _input, bytes _error);
error GovLock(uint64 _since);

struct DATA {
    bool lock; // lock gov
    address GOV;
    address NewGov;
    
    //function to proxy contract
    mapping(bytes4 => address) toContract;
    // proxy contract lock
    mapping(address => bool) isLocked;

    // proxy contract to functions list 
    mapping(address => bytes4[]) functions;
    
    // list of all contracts 
    // * have to filter inactive contracts in louper view
    // * as this list ALL contains 
    address[] contracts;
}

abstract contract Base {
    // List of all storage positions
    bytes32 public immutable DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");
    bytes32 public immutable WOOLBALL_STORAGE_POSITION = keccak256("diamond.standard.wollball.storage");
}

/**
 * List of main events for base contract 
 */
abstract contract _events {
    event ContractAdded(address indexed _contract, bytes4[] _functions);
    event ContractRemoved(address indexed _contract);
    event FunctionsAdded(address indexed _contract, bytes4[] _functions);
    event FunctionsRemoved(address indexed _contract, bytes4[] _functions);

    //ERC173
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}

