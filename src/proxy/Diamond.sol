// SPDX-License-Identifier: WTFPL
pragma solidity ^0.8.0;

/** 
 * "Based" on EIP-2535 Diamond Standard: https://eips.ethereum.org/EIPS/eip-2535
 * This is NOT compatible with EIP2535
 * 
 */ 
import "./Base.sol";
import "./xManager.sol";
import "./Carbon.lib.sol";

contract Carbon {
    bytes32 public immutable DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");

    constructor() {
        DATA storage DS;
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            DS.slot := position
        }

        DS.GOV = msg.sender;

        address _addr = address(new xManager());
        DS.isLocked[_addr] = true;
        DS.contracts.push(_addr);

        DS.toContract[xManager.newContract.selector] = _addr;
        DS.toContract[xManager.removeContract.selector] = _addr;
        DS.toContract[xManager.replaceContract.selector] = _addr;

        DS.toContract[xManager.addFunctions.selector] = _addr;
        DS.toContract[xManager.removeFunctions.selector] = _addr;
        DS.toContract[xManager.replaceFunctions.selector] = _addr;

        DS.functions[_addr] = [
            xManager.newContract.selector,
            xManager.removeContract.selector,
            xManager.replaceContract.selector,
            xManager.addFunctions.selector,
            xManager.removeFunctions.selector,
            xManager.replaceFunctions.selector
        ];
    }

/* Not tested && NOT sure
    function multiview(bytes[] calldata _inputs) external view returns(bytes[] memory _output) {
        _output = new bytes[](_inputs.length);
        bool ok;
        for (uint i; i < _inputs.length; i++) {
            (ok, _output[i]) = address(this).staticcall(_inputs[i]);
            if (!ok) {
                revert StaticCallFailed(_inputs[i], _output[i]);
            }
        }
    }

    function multicall(bytes[] calldata _inputs) external {
        DATA storage DS;
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            DS.slot := position
        }
        if (!DS.active) {
            revert DiamondPaused();
        }
        bytes4 _function;
        for (uint i; i < _inputs.length; i++) {
            bytes memory _input = _inputs[i];
            assembly {
                _function := mload(add(_input, 4))
            }
            address _contract = DS.toContract[_function];
            if (_contract == address(0)) {
                revert InvalidFunction(_function);
            }
            (bool ok, bytes memory _error) = _contract.delegatecall(_input);
            if (!ok) {
                revert DelegateCallFailed(_contract, _input, _error);
            }
        }
    }
*/
    fallback() external payable {
        DATA storage DS;
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            DS.slot := position
        }
        //if (!DS.active) {
        //    revert DiamondPaused();
        //} 
        address _contract = DS.toContract[msg.sig];
        if (_contract == address(0)) {
            revert InvalidFunction(msg.sig);
        }
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), _contract, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return (0, returndatasize())
            }
        }
    }

    receive() external payable {
        revert();
    }
}