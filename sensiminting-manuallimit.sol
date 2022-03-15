// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract senshiNFT is ERC721Pausable, Ownable  {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenId;

    string _name = "SENSHI NFT";
    string _symbol = "SENSHI";
    uint256 _pricePerMint;
    string private _baseUriExtended;
    uint256 _startTime;
    uint256 _endTime;
    uint256 immutable public _maxSupply = 10000;
    bool _openForWhitelisted = true;
    mapping (address => bool) _isWhiteListed;

    uint256 mintingPrice;
    uint256 mintingLimit;
  
    
    constructor () ERC721(_name , _symbol) {}

    function mint(uint256 nftAmount) external whenNotPaused payable {
        require(msg.sender != address(0), "Address cannot be 0");
        require(block.timestamp > _startTime && block.timestamp < _endTime, "sale is not live");
        require(currentSupply() + nftAmount <= mintingLimit , "max limit reached");
        require(msg.value == mintingPrice * nftAmount, "check price per nft");

        if(_openForWhitelisted) {
            require(_isWhiteListed[msg.sender], " Not Whitelisted");
        }
        for (uint256 indx = 1; indx <= nftAmount; indx++) {
            _tokenId.increment();
            uint256 tokenId = _tokenId.current();
            _mint(msg.sender , tokenId);
        }
    }

    function currentSupply() public view returns(uint256) {
        return _tokenId.current();
    }

    function withdrawEth(uint256 amount) external onlyOwner {
        require(amount <= address(this).balance, "Not enough balance");
        payable(msg.sender).transfer(amount);
    }

    function addWhitelistUser(address[] memory addresses) external onlyOwner {
        for(uint i = 0; i < addresses.length; i++) {
            _isWhiteListed[addresses[i]] = true;
        }
    }

    function isWhitelisted(address user) public view returns(bool) {
        return _isWhiteListed[user];
    }

    function blacklistUser(address user) external onlyOwner {
        _isWhiteListed[user] = false;
    }

    function setStartTime(uint256 startTime) external onlyOwner {
        _startTime = startTime;
    }

    function setEndTime(uint256 endTime) external onlyOwner {
        _endTime = endTime;
    }
    
    function setBaseURI(string memory baseURI_) external onlyOwner {
        require(bytes(baseURI_).length > 0, "Cannot be null");
        _baseUriExtended = baseURI_;
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseUriExtended;
    }

    function toggleWhiteListingStatus() external onlyOwner returns(bool) {
        _openForWhitelisted = !_openForWhitelisted;
        return _openForWhitelisted;
    }

    function updateTokenPrice(uint256 newPrice) external onlyOwner {
        _pricePerMint = newPrice;
    }

    function pricePerMint() external view returns(uint256) {
        return _pricePerMint;
    }

    function pause() public whenNotPaused onlyOwner{
        _pause();
    }

    function unpause() public whenPaused onlyOwner{
        _unpause();
    }

    function changeMintingPrice(uint256 _price)
    external
    onlyOwner
    {
        mintingPrice = _price;
    }

    function changeMintingLimit(uint256 _limit)
    external
    onlyOwner
    {
        require(_limit <= _maxSupply, "cannot be more than maxsupply");
        mintingLimit = _limit;
    }
    function checkPrice()
    public
    view
    returns(uint256)
    {
        return mintingPrice;
    }

    
}
