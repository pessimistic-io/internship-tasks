// This code snippet is provided by Pessimistic company.
// To apply for the internship opportunity at Pessimistic company,
// please fill out the form by visiting the following link: https://forms.gle/SUTcGi8X86yNoFnG7

// Caution: This code is intended for educational purposes only
// and should not be used in production environments.

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

/// @title IERC2981Royalties
/// @dev Interface for the ERC2981 - Token Royalty standard
interface IERC2981Royalties {
    
    function royaltyInfo(uint256 _tokenId, uint256 _value)
        external
        view
        returns (address _receiver, uint256 _royaltyAmount);
}

/// @dev This is a contract used to add ERC2981 support to ERC721 and 1155
abstract contract ERC2981Base is ERC165, IERC2981Royalties {
    struct RoyaltyData {
        address recipient;
        uint24 amount;
    }

    /// @inheritdoc ERC165
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return
            interfaceId == type(IERC2981Royalties).interfaceId ||
            super.supportsInterface(interfaceId);
    
}}

library LibPart {
    bytes32 public constant TYPE_HASH = keccak256("Part(address account,uint96 value)");

    struct Part {
        address payable account;
        uint96 value;
    }

    function hash(Part memory part) internal pure returns (bytes32) {
        return keccak256(abi.encode(TYPE_HASH, part.account, part.value));
    }
}

pragma abicoder v2;
interface IRoyaltiesProvider {
    function getRoyalties(address token, uint tokenId) external returns (LibPart.Part[] memory);
}

library LibRoyaltiesV2 {
    /*
     * bytes4(keccak256('getRaribleV2Royalties(uint256)')) == 0xcad96cca
     */
    bytes4 constant _INTERFACE_ID_ROYALTIES = 0xcad96cca;
}

interface RoyaltiesV2 {
     event RoyaltiesSet(uint256 tokenId, LibPart.Part[] royalties);
     function getRaribleV2Royalties(uint256 id) external view returns (LibPart.Part[] memory);
}

abstract contract AbstractRoyalties {
    mapping (uint256 => LibPart.Part[]) public royalties;

    function _saveRoyalties(uint256 _id, LibPart.Part[] memory _royalties) internal {
        for (uint i = 0; i < _royalties.length; i++) {
            require(_royalties[i].account != address(0x0), "Recipient should be present");
            require(_royalties[i].value != 0, "Royalty value should be positive");
            royalties[_id].push(_royalties[i]);
        }
        _onRoyaltiesSet(_id, _royalties);
    }

    function _updateAccount(uint256 _id, address _from, address _to) internal {
        uint length = royalties[_id].length;
        for(uint i = 0; i < length; i++) {
            if (royalties[_id][i].account == _from) {
                royalties[_id][i].account = payable(address(uint160(_to)));
            }
        }
    }

    function _onRoyaltiesSet(uint256 _id, LibPart.Part[] memory _royalties) virtual internal;
}

contract RoyaltiesV2Impl is AbstractRoyalties, RoyaltiesV2 {

    function getRaribleV2Royalties(uint256 id) override external view returns (LibPart.Part[] memory) {
        return royalties[id];
    }

    function _onRoyaltiesSet(uint256 id, LibPart.Part[] memory _royalties) override internal {
        emit RoyaltiesSet(id, _royalties);
    }
}

/// @title A simple NFT contract
contract Nft is ERC721, ERC721Enumerable, ERC721URIStorage, Pausable, AccessControl, ERC721Burnable, RoyaltiesV2Impl, ERC2981Base  {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    //Roles and Owner
    bytes32 public constant CEO = keccak256("CEO");
    bytes32 public constant CLEVEL = keccak256("CLEVEL");
    address public owner;

    //Meta data url parts
    //string private baseUri = "https://codadev.s3.us-east-2.amazonaws.com/surfdev/";
    string private baseUri = "https://d3cyw651c4t2lt.cloudfront.net/surfdev/";
    string private suffix = ".json";

    // Set the summoning variables
    address public utilityToken;
    address public governanceToken;
    uint256 public maxSummoningCount = 5;
    uint32 public summoningLock = 2 minutes;
    mapping (address => mapping (uint => uint)) public summoningCosts;
    bool public summoningEnabled = false;

    // ERC2981 Royalties
    RoyaltyData private _royalties;
    address public royaltyAddress;
    uint256 public royaltyBase = 400;


    struct Item {
        uint256 dob;
        uint256 summonCount;
        uint256 lastSummoned;
        uint256 summonedFrom;
        bool summoned;
    }

    Item[] public items;

    event AdminMinted(address indexed _from, address indexed _to, uint256 _tokenId);
    event Summoned(address indexed _from, address indexed _to, uint256 _tokenId);

    constructor() ERC721("Nft", "NFT") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(CLEVEL, msg.sender);
        _setupRole(CEO, msg.sender);
        owner = msg.sender;

        // 2981 Royalties
        _setRoyalties(msg.sender , royaltyBase);
        // Rarible Royalties
        setRoyalties(0, payable(msg.sender), uint96(royaltyBase));
    }

    function pause() public onlyRole(CLEVEL) {
        _pause();
    }

    function unpause() public onlyRole(CEO) {
        _unpause();
    }
    
    function safeMint(address _to) public whenNotPaused onlyRole(CLEVEL) {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(_to, tokenId);
        items.push(Item(block.timestamp, 0, 0, 0, false));
        emit AdminMinted(msg.sender, _to, tokenId);
    }
    
    function summon(address _to, uint256 _tokenId) external whenNotPaused payable {

        require(summoningEnabled, 'Summoning is currently disabled');
        require(_exists(_tokenId), 'Token does not exist');
        require(ownerOf(_tokenId) == msg.sender, 'Sender is not the token owner');
        require(items[_tokenId].lastSummoned + summoningLock < block.timestamp, 'Need to wait to summon');
        require(items[_tokenId].summonCount < maxSummoningCount, 'Exceeded Summoning Count');
        

        uint256 utilitySummoningFee = summoningCosts[utilityToken][items[_tokenId].summonCount];
        uint256 governanceSummoningFee = summoningCosts[governanceToken][items[_tokenId].summonCount];

        if(utilitySummoningFee > 0) {
            require(ERC20(address(utilityToken)).transferFrom(msg.sender, address(this), utilitySummoningFee), "Transfer failed");    
        }

        if(governanceSummoningFee > 0) {
            require(ERC20(address(governanceToken)).transferFrom(msg.sender, address(this), governanceSummoningFee), "Transfer failed");
        }
        
        // Mint the new summoned token        
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(_to, tokenId);

        // Push a summoned token to the items array
        items.push(Item(block.timestamp, 0, 0, _tokenId, true));
        items[_tokenId].summonCount++;
        items[_tokenId].lastSummoned = block.timestamp;
        
        emit Summoned(msg.sender, _to, tokenId);
    }

    function _beforeTokenTransfer(address _from, address _to, uint256 _tokenId, uint256 batchSize)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(_from, _to, _tokenId, batchSize);
    }

    // The following functions are overrides required by Solidity.
    function _burn(uint256 _tokenId) internal whenNotPaused override(ERC721, ERC721URIStorage) onlyRole(CLEVEL) {
        super._burn(_tokenId);
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        string memory _str = Strings.toString(_tokenId);
        return string(abi.encodePacked(baseUri, _str, suffix));
    }

    function supportsInterface(bytes4 _interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage, AccessControl, ERC2981Base)
        returns (bool)
    {
        // Added fo Rarible
        if(_interfaceId == LibRoyaltiesV2._INTERFACE_ID_ROYALTIES) {
            return true;
        }

        return super.supportsInterface(_interfaceId);
    }

    /// @dev base uri used for metadata
    function _baseURI() internal view override returns (string memory) {
        return baseUri;
    }

    /// @param _prefix the new url prefix for metadata
    /// @dev update metadata urls prefix, like baseuri
    function updatePrefix(string memory _prefix) public onlyRole(CLEVEL) {
        baseUri = _prefix;
    }

    /// @param _suffix the new url suffix for metadata
    /// @dev update metadata urls suffix, like baseuri
    function updateSuffix(string memory _suffix) public onlyRole(CLEVEL) {
        suffix = _suffix;
    }

    /// @param _address the new token address
    /// @dev allows for setting a token address used for summoning
    function updateUtilityAddress(address _address) external onlyRole(CLEVEL) {
        utilityToken = _address;
    }

    /// @param _address the new token address
    /// @dev allows for setting a token address used for summoning
    function updateGovernanceAddress(address _address) external onlyRole(CLEVEL) {
        governanceToken = _address;
    }

    /// @param _count the new summoning count
    /// @dev allows for setting the summoning count
    function updateMaxSummoningCount(uint256 _count) external onlyRole(CLEVEL) {
        maxSummoningCount = _count;
    }

    /// @param _value the summoning status
    /// @dev allows enabling/disabling summoning
    function updateSummoningEnabled(bool _value) external onlyRole(CLEVEL) {
        summoningEnabled = _value;
    }

    /// @param _value the summoning lock time
    /// @dev allows to update summoning lock
    function updateSummoningLock(uint32 _value) external onlyRole(CLEVEL) {
        summoningLock = _value;
    }

    function updateSummoningFee(address _address, uint _count, uint _amount) external onlyRole(CLEVEL) {
        summoningCosts[_address][_count] = _amount;
    }

    /// @dev collection metadata, not the same as tokenuri
    function contractURI() public view returns (string memory) {
        return string(abi.encodePacked(baseUri, "contract", suffix));
    }

    /// @dev owner needs to be set to edit collection info in marketplaces
    function setOwner(address _owner) external onlyRole(CEO) {
        owner = _owner;
    }

    /// @dev owner can withdraw ERC20 tokens sent to the contract
    function withdrawTokens(IERC20 _token) public onlyRole(CLEVEL) {
        uint256 balance = _token.balanceOf(address(this));
        require(balance != 0);
        require(_token.transfer(msg.sender, balance), "Transfer failed");
    }

    /// @dev owner can withdraw Ether sent to the contract
    function withdraw() public onlyRole(CEO) {
        uint256 balance = address(this).balance;
        require(balance != 0);
        payable(msg.sender).transfer(balance);
    }

   // 2981 royalties
    // Value is in basis points so 10000 = 100% , 100 = 1% etc
    function _setRoyalties(address recipient, uint256 value) public onlyRole(CEO) {
        require(value <= 10000, 'ERC2981Royalties: Too high');
        _royalties = RoyaltyData(recipient, uint24(value));
    }

    // Added for Rarible royalties
    function setRoyalties(uint _tokenId, address payable _royaltiesReceipientAddress, uint96 _percentageBasisPoints) public onlyRole(CEO) {
        LibPart.Part[] memory _rarRoyalties = new LibPart.Part[](1);
        _rarRoyalties[0].value = _percentageBasisPoints;
        _rarRoyalties[0].account = _royaltiesReceipientAddress;
        _saveRoyalties(_tokenId, _rarRoyalties);
    }

    // Get the royalty data
    function royaltyInfo(uint256, uint256 value)
        external
        view
        override
        returns (address receiver, uint256 royaltyAmount)
    {
        RoyaltyData memory royalties = _royalties;
        receiver = royalties.recipient;
        royaltyAmount = (value * royalties.amount) / 10000;
    }

    /// @param _address the new royalty address
    /// @dev allows for setting a token address used for summoning
    function updateRoyaltyAddress(address _address) external onlyRole(CLEVEL) {
        royaltyAddress = _address;
        // 2981 Royalties
        _setRoyalties(royaltyAddress, royaltyBase);
        // Rarible Royalties
        setRoyalties(0, payable(royaltyAddress), uint96(royaltyBase));
    }

    function updateRoyaltyAmount(uint256 _amount) external onlyRole(CLEVEL) {
        royaltyBase = _amount;
        // 2981 Royalties
        _setRoyalties(royaltyAddress, royaltyBase);
        // Rarible Royalties
        setRoyalties(0, payable(royaltyAddress), uint96(royaltyBase));
    }
}