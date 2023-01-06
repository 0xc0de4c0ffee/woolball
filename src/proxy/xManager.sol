// SPDX-License-Identifier: WTFPL
pragma solidity ^0.8.0;
import "./Base.sol";
import "./Utils.sol";
import "../library/Carbon.lib.sol";

contract xManager is Base, Utils {
    using Carbon for DATA;

    function toggle() external {
        DATA storage DS;
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            DS.slot := position
        }
        if (msg.sender != DS.GOV) revert OnlyGovContract(DS.GOV);
        DS.lock = !DS.lock;
    }
    function newContract(address _contract, bytes4[] calldata _functions) external {
        DATA storage DS;
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            DS.slot := position
        }
        if (DS.lock) revert DiamondPaused();
        if (msg.sender != DS.GOV) revert OnlyGovContract(DS.GOV);
        DS.newContract(_contract, _functions);
    }

    function removeContract(address _contract) external {
        DATA storage DS;
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            DS.slot := position
        }
        if (DS.lock) revert DiamondPaused();
        if (msg.sender != DS.GOV) revert OnlyGovContract(DS.GOV);
        DS.removeContract(_contract);
    }

    function replaceContract(address _old, address _new) external {
        DATA storage DS;
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            DS.slot := position
        }
        if (DS.lock) revert DiamondPaused();
        if (msg.sender != DS.GOV) revert OnlyGovContract(DS.GOV);
        DS.replaceContract(_old, _new);
    }

    function addFunctions(address _contract, bytes4[] calldata _functions) external {
        DATA storage DS;
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            DS.slot := position
        }
        if (DS.lock) revert DiamondPaused();
        if (msg.sender != DS.GOV) revert OnlyGovContract(DS.GOV);
        DS.addFunctions(_contract, _functions);
    }

    function removeFunctions(address _contract, bytes4[] calldata _functions) external {
        DATA storage DS;
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            DS.slot := position
        }
        if (DS.lock) revert DiamondPaused();
        if (msg.sender != DS.GOV) revert OnlyGovContract(DS.GOV);
        DS.removeFunctions(_contract, _functions);
    }

    function replaceFunctions(address _old, address _new, bytes4[] calldata _functions) external {
        DATA storage DS;
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            DS.slot := position
        }
        if (DS.lock) revert DiamondPaused();
        if (msg.sender != DS.GOV) revert OnlyGovContract(DS.GOV);
        DS.replaceFunctions(_old, _new, _functions);
    }
}