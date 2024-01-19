// This code snippet is provided by Pessimistic company.
// To apply for the internship opportunity at Pessimistic company,
// please fill out the form by visiting the following link: https://forms.gle/SUTcGi8X86yNoFnG7

// Caution: This code is intended for educational purposes only
// and should not be used in production environments.

pragma solidity ^0.8.17;

contract Signature {
    address public signedAddress;

    constructor (address _signedAddress) {
        signedAddress = _signedAddress;
    }

    function checkSignature(bytes32 hash, bytes memory sig) external view returns (bool){
        require(sig.length == 65, "Invalid signature length");
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := mload(add(sig, 96))
        }
        v = uint8(v);
        require(v == 27 || v == 28, "Incorrect v value");
        
        address signer = ecrecover(hash, v, r, s);
        return signer == signedAddress;
    }
}
