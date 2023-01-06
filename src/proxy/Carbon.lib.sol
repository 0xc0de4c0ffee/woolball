// SPDX-License-Identifier: WTFPL v6.9
pragma solidity ^0.8.0;
import "./Base.sol";
/**
 * Fake Diamond Proxy implementation
 */
library Carbon {

    event ContractAdded(address indexed _contract, bytes4[] _functions);
    event ContractRemoved(address indexed _contract);
    event FunctionsAdded(address indexed _contract, bytes4[] _functions);
    event FunctionsRemoved(address indexed _contract, bytes4[] _functions);

    function newContract(DATA storage DS, address _contract, bytes4[] calldata _functions) internal {
        if ((DS.functions[_contract].length) != 0) {
            revert DuplicateContract(_contract);
        }
        for (uint i = 0; i < _functions.length; i++) {
            if ((DS.toContract[_functions[i]]) != address(0)) {
                revert DuplicateFunction(_functions[i], DS.toContract[_functions[i]]);
            }
            DS.toContract[_functions[i]] = _contract;
        }
        DS.functions[_contract] = _functions;
        DS.contracts.push(_contract);
        emit ContractAdded(_contract, _functions);
    }

    function removeContract(DATA storage DS, address _contract) internal {
        if (DS.isLocked[_contract]) {
            revert ContractLocked(_contract);
        }
        bytes4[] memory _functions = DS.functions[_contract];
        if ((_functions.length) == 0) {
            revert ContractNotActive(_contract);
        }
        for (uint i = 0; i < _functions.length; i++) {
            if (DS.toContract[_functions[i]] == _contract) {
                delete DS.toContract[_functions[i]];
            }
        }
        delete DS.functions[_contract];
        emit ContractRemoved(_contract);
    }

    function replaceContract(DATA storage DS, address _old, address _new) internal {
        if (DS.isLocked[_old]) {
            revert ContractLocked(_old);
        }
        if ((DS.functions[_old].length) == 0) {
            revert ContractNotActive(_old);
        }
        if ((DS.functions[_new].length) != 0) {
            revert DuplicateContract(_new);
        }
        bytes4[] memory _functions = DS.functions[_old];
        for (uint i = 0; i < _functions.length; i++) {
            if (DS.toContract[_functions[i]] == _old) {
                DS.toContract[_functions[i]] = _new;
                DS.functions[_new].push(_functions[i]);
            }
        }
        delete DS.functions[_old];
        emit ContractRemoved(_old);
        emit ContractAdded(_new, DS.functions[_new]);
    }

    function addFunctions(DATA storage DS, address _contract, bytes4[] calldata _functions) internal {
        if (DS.isLocked[_contract]) {
            revert ContractLocked(_contract);
        }
        bytes4[] storage _list = DS.functions[_contract];
        if ((_list.length) == 0) {
            revert ContractNotActive(_contract);
        }
        for (uint i = 0; i < _functions.length; i++) {
            if ((DS.toContract[_functions[i]]) != address(0)) {
                revert DuplicateFunction(_functions[i], DS.toContract[_functions[i]]);
            }
            DS.toContract[_functions[i]] = _contract;
            _list.push(_functions[i]);
        }
        emit FunctionsAdded(_contract, _functions);
    }

    function removeFunctions(DATA storage DS, address _contract, bytes4[] calldata _functions) internal {
        if (DS.isLocked[_contract]) {
            revert ContractLocked(_contract);
        }
        for (uint i = 0; i < _functions.length; i++) {
            if ((DS.toContract[_functions[i]]) != _contract) {
                revert DuplicateFunction(_functions[i], DS.toContract[_functions[i]]);
            }
            delete DS.toContract[_functions[i]];
        }
        emit FunctionsRemoved(_contract, _functions);
    }

    function replaceFunctions(DATA storage DS, address _old, address _new, bytes4[] calldata _functions) internal {
        if (DS.isLocked[_old]) {
            revert ContractLocked(_old);
        }
        if ((DS.functions[_old].length) == 0) {
            revert ContractNotActive(_old);
        }
        if ((DS.functions[_new].length) != 0) {
            revert DuplicateContract(_new);
        }
        for (uint i = 0; i < _functions.length; i++) {
            if (DS.toContract[_functions[i]] != _old) {
                revert InvalidFunction(_functions[i]);
            }
            DS.toContract[_functions[i]] = _new;
        }
        //delete DS.functions[_old];
        DS.functions[_new] = _functions;
        emit ContractRemoved(_old);
        emit ContractAdded(_new, DS.functions[_new]);
    }
}