// SPDX-License-Identifier: MIT
pragma solidity > 0.8 .0 < 0.9 .0;

import {
    ERC1155
} from "./ERC1155.sol";
/**
 * @dev Woolball Default Link Resolver Interface
 */
contract xWoolball is ERC1155 {
    struct Name {
        address owner;
        address resolver;
        uint64 ttl;
        uint32 linkout;
        uint32 linkin;
    }

    // todo: should we skip threads?
    /*struct Thread {
      address resolver;
      address controller;
    }
    */

    struct Link {
        //bytes32: to;
        mapping(bytes => Thread) threads;
        // do we need a way to map to this
        //string: alias;
        address resolver;
        address controller;
    }

    mapping(bytes32 => Name) names; // nameID to Name
    mapping(bytes32 => mapping(bytes32 => Link)) nameID; // (from) to a mapping of linkID to Link;

    /**
     * @dev Constructs a new Woolball registry.
     */
    constructor() ERC721("Woolball", "WOOL") {
        
    }

    /**
     * @dev Sets the record for a name.
     * @param _nameID The id to update.
     * @param _owner The address of the new owner.
     * @param _resolver The address of the resolver.
     * @param _ttl The TTL in seconds.
     */
    function setRecord(
        bytes32 _nameID,
        address _owner,
        address _resolver,
        uint64 _ttl
    ) external virtual override {
        setOwner(_nameID, _owner);
        _setResolverAndTTL(_nameID, _resolver, _ttl);
    }

    /**
     * @dev registers a new name. May only be called by the owner of the registry.
     * @param name The name to register.
     * @param owner the new name.
     */
    function newName(
        string _nameID, 
        address _owner
    ) public registryOwner(msg.sender) {
        bytes32 nameId = sha256(_nameID);
        _setOwner(_nameID, _owner);
        emit Transfer(_nameID, _owner);
    }

    /**
     * @dev Transfers ownership of a name to a new address. May only be called by the current owner of the name.
     * @param name The name to transfer ownership of.
     * @param owner The address of the new owner.
     */
    function transferName(bytes32 _nameID, address _owner)
    public
    authorised(_nameID) {
        _setOwner(_nameID, _owner);
        emit Transfer(_nameID, _owner);
    }

    /**
     * @dev Sets the resolver address for the specified name.
     * @param name The name to update.
     * @param resolver The address of the resolver.
     */
    function setResolver(
        bytes32 _nameID, 
        address _resolver
    ) public authorised(_nameID) {
        emit NewResolver(_nameID, _resolver);
        names[name].resolver = _resolver;
    }

    /**
     * @dev Sets the TTL for the specified name.
     * @param name The name to update.
     * @param ttl The TTL in seconds.
     */
    function setTTL(bytes32 _nameID, uint64 _ttl)
    public
    authorised(_nameID) {
        emit NewTTL(_nameID, _ttl);
        names[name].ttl = _ttl;
    }

    /**
     * @dev Enable or disable approval for a third party ("operator") to manage
     *  all of `msg.sender`'s ENS names. Emits the ApprovalForAll event.
     * @param operator Address to add to the set of authorized operators.
     * @param approved True if the operator is approved, false to revoke approval.
     */
    function setApprovalForAll(
        address _operator, 
        bool _approved
    ) external {
        operators[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    /**
     * @dev Returns the address that owns the specified name.
     * @param name The specified name.
     * @return address of the owner.
     */
    function owner(
        bytes32 _nameID
    ) public view returns(address) {
        address addr = names[_nameID].owner;
        if (addr == address(this)) {
            return address(0x0);
        }

        return addr;
    }

    /**
     * @dev Returns the address of the resolver for the specified name.
     * @param name The specified name.
     * @return address of the resolver.
     */
    function resolver(bytes32 _nameID) public view returns(address) {
        return names[_nameID].resolver;
    }

    /**
     * @dev Returns the TTL of a name.
     * @param name The specified name.
     * @return ttl of the name.
     */
    function ttl(bytes32 _nameID) public view virtual override returns(uint64) {
        return names[_nameID].ttl;
    }

    /**
     * @dev Returns whether a record has been imported to the registry.
     * @param name The specified name.
     * @return Bool if record exists
     */
    function recordExists(bytes32 _nameID) public view returns(bool) {
        return names[_nameID].owner != address(0x0);
    }

    /**
     * @dev Query if an address is an authorized operator for another address.
     * @param owner The address that owns the names.
     * @param operator The address that acts on behalf of the owner.
     * @return True if `operator` is an approved operator for `owner`, false otherwise.
     */
    function isApprovedForAll(
        address _owner, 
        address _operator
    ) external view returns(bool) {
        return operators[_owner][_operator];
    }

    function _setOwner(bytes32 _nameID, address _owner) internal {
        names[_nameID].owner = _owner;
    }

    function _setResolverAndTTL(
        bytes32 _nameID,
        address _resolver,
        uint64 _ttl
    ) internal {
        if (_resolver != names[_nameID].resolver) {
            names[_nameID].resolver = resolver;
            emit NewResolver(_nameID, _resolver);
        }

        if (_ttl != names[_nameID].ttl) {
            names[_nameID].ttl = _ttl;
            emit NewTTL(_nameID, _ttl);
        }
    }

    function newLink(bytes32 _nameID, bytes32 _to) {
        bytes32 linkID = sha256(_nameID, _to); //actually, this should be done in the registrar level
        links[_nameID][linkID].to = _to;
        names[_nameID].linkout += 1;
        names[_to].linkin += 1;

        // add a way for _to to know who linked him -- or maybe it's from the graph?
    }

    function getLinkCount(bytes32 _nameID) {
        return names[_nameID].linkout;
    }

    function getInBoundLinkCount(bytes32 _nameID) {
        return names[_nameID].linkin;
    }

    function newThread(bytes32 _linkID, bytes32 _threadID, address _resolver) {
        // make a new thread for _linkID
    }

    function closeLink(bytes32 _from, bytes32 _linkID) {
        //first try to close all threads -- if fail, don't close the link
        //if all threads are closed, close the link
    }

    function closeThread() {
        //call the close function of the thread contract
    }

    function trasnferLink() {
        //first try to transfer all the threads -- if fail, don't transfer the link
        //if all threads are transferred, then transfer the link
    }

    function transferThread() {
        //call the transfer function of the thread contract
    }

    function unlink() {
        //TBD
    }

    function unthread() {
        //TBD
    }

}