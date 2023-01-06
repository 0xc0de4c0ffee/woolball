# Prototype *WARNING*!
1) Proxy is EIP2535 *like* patterns, it's unofficial implementation without "Diamond Industry" jargons & it's not fully compatible with EIP2535 events. 
2) Need more tests, still WIP
____
____
# File Types
* Prefix `xFilename.sol` is Diamond compatible extension modules
* Prefix `iFilename.sol` is interface
* Suffix `Filename.lib.sol` is library used by extensions 
____
____

# Zenga Tower
0) Foundation : `./proxy/Diamond.sol`
1) Manager/Lookup : `./proxy/xManager.sol`, `./proxy/xLoupe.sol`  
1) Base : `./xWollBall.sol`
2) 1st Module : ERC1155
3) .... 