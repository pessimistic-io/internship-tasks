// This code snippet is provided by Pessimistic company.
// To apply for the internship opportunity at Pessimistic company,
// please fill out the form by visiting the following link: https://forms.gle/SUTcGi8X86yNoFnG7

// Caution: This code is intended for educational purposes only
// and should not be used in production environments.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol';
import '@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';
import {SignatureChecker} from '@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol';
import '@openzeppelin/contracts-upgradeable/utils/structs/BitMapsUpgradeable.sol';

contract Token is Initializable, ERC721Upgradeable, AccessControlUpgradeable, UUPSUpgradeable {
    using BitMapsUpgradeable for BitMapsUpgradeable.BitMap;
    using ECDSAUpgradeable for bytes32;
    using SignatureChecker for address;

    struct SignatureData {
        address signer;
        address account;
        uint256 nonce;
        bytes signature;
    }
    uint256 chainId;

    bytes32 public constant PROVIDER_ROLE = keccak256('PROVIDER_ROLE');

    mapping(address => uint256) public nonces;

    function initialize(uint256 _chainId) initializer public {
        __ERC721_init('Token Name', 'TOKEN');
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(PROVIDER_ROLE, msg.sender);
        chainId = _chainId;
    }

    function _authorizeUpgrade(address newImplementation) internal override {}

    function mintTo(
        SignatureData calldata signatureData,
        uint256 tokenId
    ) external
      signerVerification(tokenId, signatureData) {
       require(balanceOf(signatureData.account) == 0, 'The token has already been minted!');

       _mint(signatureData.account, tokenId);
       nonces[signatureData.account]++;
    }


    function burn(
        uint256 tokenId,
        SignatureData calldata signatureData
    ) external signerVerification(tokenId, signatureData) {
        require(balanceOf(signatureData.account) > 0, 'Nothing to burn');
        _burn(tokenId);
        nonces[signatureData.account] += 1;
        require(balanceOf(signatureData.account) == 0, 'The token has not been burnt!');
    }

    modifier signerVerification(
      uint256 tokenId,
      SignatureData calldata signature
    ) {
        require(nonces[signature.signer] == signature.nonce, 'Invalid Nonce');
        require(hasRole(PROVIDER_ROLE, msg.sender), 'Invalid Provider');

        bytes32 hash = keccak256(
          abi.encodePacked(
            '\x19\x01',
            keccak256(abi.encode(
                signature.signer,
                address(this),
                signature.account,
                tokenId,
                nonces[signature.signer],
                chainId
            ))
          )
        ).toEthSignedMessageHash();

        require(
          signature.signer.isValidSignatureNow(hash, signature.signature),
          'Invalid Signer'
        );
        _;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 amount
    ) internal override {
        require(
          (from == address(0) && to != address(0)) || (from != address(0) && to == address(0)),
          'Only mint or burn transfers are allowed'
        );
        super._beforeTokenTransfer(from, to, tokenId, amount);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721Upgradeable, AccessControlUpgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
