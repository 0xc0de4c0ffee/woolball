// SPDX-License-Identifier: WTFPL
pragma solidity >0.8.0;
import "./Base.sol";
import "../interface/iERC165.sol";
import "../interface/iERC173.sol";
abstract contract Utils is Base, iERC165, iERC173 {
    function supportsInterface(bytes4 interfaceId) external view returns(bool) {
        DATA storage DS;
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            DS.slot := position
        }
        return (DS.toContract[interfaceId] != address(0) || interfaceId == iERC165.supportsInterface.selector);
    }

    function owner() external view returns(address){
        DATA storage DS;
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            DS.slot := position
        }
        return DS.GOV;
    }

    function transferOwnership(address newGov) external {
        DATA storage DS;
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            DS.slot := position
        }
        if (msg.sender != DS.GOV) {
            revert OnlyGovContract(DS.GOV);
        }
        DS.NewGov = newGov;
        // signal only
        emit OwnershipTransferred(msg.sender, newGov);
    }


    /// @dev Not part of ERC173
    function acceptOwnership() external {
        DATA storage DS;
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            DS.slot := position
        }
        if (msg.sender != DS.NewGov) {
            revert OnlyGovContract(DS.NewGov);
        }
        emit OwnershipTransferred(DS.GOV, msg.sender);
        DS.GOV = msg.sender;
    }
}