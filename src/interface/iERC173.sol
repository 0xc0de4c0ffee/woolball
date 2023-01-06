// SPDX-License-Identifier: WTFPL
pragma solidity >0.8.0;

interface iERC173 {
    function owner() external view returns (address);
    function transferOwnership(address newOwner) external;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);  
    // NOT ERC173
    function acceptOwnership() external;
}