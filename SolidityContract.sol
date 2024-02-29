// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./ERC1155.sol";

contract Profi is ERC20{

    event SellNftt(uint256 indexed sellid, uint256 indexed nftID, address seller);
    event newUser(uint256 indexed userId, address userAddress, string userName);
    event NewNFT(uint256 indexed nftID, uint256 price, uint256 value);
    event StartAuctions(uint256 indexed  AuctionId, uint256 indexed idCollect, uint256 startTTime, uint256 StoopTime);
    event StartAuctionsTwo(uint256 maxPricee, uint256 StartPricee);
    modifier OnlyOwner(){
        require(msg.sender == Owner);
        _;
    }

    // Структура пользователя
    struct User {
        uint256 userId; 
        string userName; 
        address userAddress;
        uint256 userTokens; 
        string userRefCode; 
        bool refCodeIsActivated; 
        bool refCodeIsAlreadyCreated; 
        uint8 userRefCodePercentBonus; 
        bool userExists;
    }

    // Структура nft
    struct nft {
        uint256 id; 
        uint256 idcolections; 
        address OwnerNFT; 
        string name; 
        string descript; 
        string pathFile; 
        uint256 price; 
        uint256 value; 
        uint256 timeCreate; 
        bool sellExits;
        bool exits;     
    }

    // Структура коллекции
    struct collection{
        uint256 idCollections; 
        address OwnerCollections; 
        string name; 
        string descript; 
        uint256[] nftId;  
        uint256[] value; 
        bool inAuctions;
        bool exits;
    }

    // структруа для продажи nft
    struct sellNft {
        uint256 idsell;
        uint256 nftId;
        uint256 collectionId;
        uint256 value;
        uint256 priceOnOne;
        address seller;
        bool exits;
        bool sellActive;
    }

    // структура для аукциона
    struct Auction{
        uint256 idAuction;
        uint256 idCollection;
        uint256 timeStart;
        uint256 stopTime;
        uint256 startPrice;
        uint256 maxPrice;
        uint256[] bids;
        address[] bidsAdress;
        address seller;
        bool create;
        bool endl;
        bool exits;

    }

    mapping (uint256 => Auction) Auctions;
    uint256[] public idAuctions;

    mapping(uint256 => sellNft) sellnfts;
    uint256[] public idSellNft;

    mapping(uint256 => mapping(address => nft)) nfts;
    mapping(uint256 => mapping(uint256 => mapping(address => nft))) nftscolnfts;
    uint256[] public idNft;

    mapping(address => User) users;
    mapping(string => User) usersref;
    address[] public usersAdresses;

    mapping (uint256 => collection) collections;
    uint256[] public idCollection;
 
    address public Owner;
    address public Tom = 0xfE3abC989BE4f32f2dcce163CeccCA5E4b96aa85;
    address public Max = 0xEC5d100652eF59ECAEF69621B8Be3a5C73cb0c75;
    address public Jack = 0x189C918729EE40B2c83F32417F0BaD74680Af10d;
    uint256 public userCounter = 4;
    uint256 public tokenPrice = 1 ether;
    

    
    mapping(uint256 => mapping(address => uint256)) private _balances;


    constructor() payable ERC20("Porfisional", "PROFI") {
        Owner = msg.sender;
        users[Owner] = User(0, "Owner", Owner, 100000, "ref",false,false, 0, false);
        emit newUser(0, Owner, "Owner");
        usersAdresses.push(Owner);
        users[Tom] = User(1, "Tom", Tom, 200000, "",false,false, 0, true);
        emit newUser(1, Tom, "Tom");
        usersAdresses.push(Tom);
        users[Max] = User(2, "Max", Max, 300000, "",false,false, 0, true);
        emit newUser(2, Max, "Max");
        usersAdresses.push(Max);
        users[Jack] = User(3, "Jack", Jack, 400000, "",false,false, 0, true);
        emit newUser(3, Jack, "Jack");
        usersAdresses.push(Jack);

        giveStartTokensToStartUsers();

        nfts[0][Owner] = nft(0, 0, Owner, "cat", "cat eating", "../img/first.jpg", 10, 1, block.timestamp, false, true);
        idNft.push(0);


        nfts[1][Owner] = nft(1, 0, Owner, "dog", "dog eating", "../img/second.jpg", 10, 1, block.timestamp, false, true);
        idNft.push(1);
 

        nfts[2][Owner] = nft(2, 0, Owner, "ss", "ss eating", "../img/third.jpeg", 10, 1, block.timestamp, false, true);
        idNft.push(2);

        nfts[3][Owner] = nft(3, 0, Owner, "man", "man eating", "../img/four.jpg", 10, 1, block.timestamp, false, true);
        idNft.push(3);


        idCollection.push(0);
    }

    function getBidsLength(uint256 auctionId) public view returns(uint256[] memory) {
        return Auctions[auctionId].bids;
    }
    function referalBonus(address userAddress) public view returns(uint256) {
        return users[userAddress].userRefCodePercentBonus;
    } 

   function nftIdsSender() public view returns(uint256[] memory nftIds) {
    uint256[] memory tempIds = new uint256[](idNft.length);
    uint256 count;
    for(uint256 i = 0; i < idNft.length; i++) {
        if (nfts[idNft[i]][msg.sender].OwnerNFT == msg.sender) {
            tempIds[count++] = idNft[i];
        }
    }
    nftIds = new uint256[](count);
    for(uint256 i = 0; i < count; i++) {
        nftIds[i] = tempIds[i];
    }
    return nftIds;
}

//  function a() public view returns(uint256[] memory nftIds) {
//     uint256[] memory tempIds = new uint256[](idNft.length);
//     uint256 count;
//     for(uint256 i = 0; i < idNft.length; i++) {
//         if (nfts[idNft[i]][msg.sender].OwnerNFT == msg.sender) {
//             tempIds[count++] = idNft[i];
//         }
//     }
//     nftIds = new uint256[](count);
//     for(uint256 i = 0; i < count; i++) {
//         nftIds[i] = tempIds[i];
//     }
//     return nftIds;
// }

    function getNftImg(uint256 nftId) public view returns(string memory) {
        require(nfts[nftId][msg.sender].OwnerNFT == msg.sender, "Err01");
        return nfts[nftId][msg.sender].pathFile;
    }


    function totalSupply() public view   override returns (uint256 suplay)  { 
        return 1000000; 
    }


    function giveStartTokensToStartUsers() private {
        _mint(Owner, 100000000000);
        _mint(Tom, 200000000000);
        _mint(Jack, 400000000000);
        _mint(Max, 300000000000);
    }

// Активировать реферальный код друга
// Проверка рефералки не через цикл, а с помощью новго мапинга
function activateRefcode(string memory refCode) public payable {
    require(msg.sender != Owner, "Owner can't activate refCode");
    string storage userRefCode = users[msg.sender].userRefCode;
    require(keccak256(abi.encodePacked(userRefCode)) != keccak256(abi.encodePacked(refCode)), "You can't use your refCode");
    require(users[msg.sender].userExists, "You are not registered");
    require(!users[msg.sender].refCodeIsActivated, "You have already entered the referral code");
    require(usersref[refCode].userExists == true, "You entered the wrong referral code");

    if (usersref[refCode].userRefCodePercentBonus < 3) {
        users[msg.sender].refCodeIsActivated = true;
        usersref[refCode].userRefCodePercentBonus += 1;
            users[msg.sender].userTokens += 100;
            _mint(msg.sender, 100 *(10**6));
        
    } else {

            users[msg.sender].refCodeIsActivated = true;
            users[msg.sender].userTokens += 100;
            _mint(msg.sender, 100 *(10**decimals()));
    }
}

    function buyToken (uint256 value) public payable { 
        require(msg.sender != Owner, "Owner can't buy tokens"); 
        require(value > 0, "You can't buy less than one token"); 
        require(users[Owner].userTokens >= value, "The Owner does not have enough tokens"); 
        require(msg.value >= value, "You entered the data incorrectly"); 
        approve(msg.sender, value); 
        _transfer(Owner, msg.sender, value*(10**decimals())); 
        payable(Owner).transfer(value * tokenPrice); 
        users[Owner].userTokens -= value; 
        users[msg.sender].userTokens += value; 
    } 

    function sellToken(uint256 value) public payable { 
        require(msg.sender != Owner, "Owner can't sell tokens"); 
        require(value > 0, "You can't sell less than one token"); 
        require(users[msg.sender].userTokens >= value, "You don't have that many tokens"); 
        require(Owner.balance >= value * tokenPrice, "Owner not have enough ETH"); 
        require(address(this).balance >= value * tokenPrice, "Contract does not have enough ETH balance"); 
        approve(msg.sender, value); 
        _transfer(msg.sender, Owner,  value*(10**decimals())); 
        users[Owner].userTokens += value; 
        users[msg.sender].userTokens -= value; 
        payable(msg.sender).transfer(value * tokenPrice); 
    }

    function check(address adr) public view returns (string memory){
        return(users[adr].userRefCode);
    }

    function decimals() public override view returns (uint8) {
        return 6;
    }

    function createCode(string memory refCode) public {
        users[msg.sender].userRefCode = refCode;
        usersref[refCode] = users[msg.sender];
        usersref[refCode].userExists = true;
    }




        function nftCollectionsSendId() public view returns(uint256[] memory nftIds) {
    uint256[] memory tempIds = new uint256[](idCollection.length);
    uint256 count;
    for(uint256 i = 0; i < idCollection.length; i++) {
        if (collections[i].OwnerCollections == msg.sender) {
            tempIds[count++] = idCollection[i];
        }
    }
        }
    function showNftCollection(uint256 collectionId) public view returns(uint256[] memory) {
        require(collections[collectionId].OwnerCollections == msg.sender, "Err1");
        return collections[collectionId].nftId;
    }

    function createNFT(string memory name, string memory descript ,string memory pathFile, uint256 price, uint256 value) OnlyOwner public {
        nfts[idNft.length][msg.sender] = nft(idNft.length, 0, Owner, name, descript, pathFile, price, value, block.timestamp, false, true);
        emit NewNFT(idNft.length,price,value);
        idNft.push(idNft.length);
    }

    function createCollections( string memory name, string memory descript, uint256[] memory nftid, uint256[] memory value) public {
        for (uint256 i = 0; i < nftid.length; i++)
        {
            require(nfts[nftid[i]][msg.sender].exits == true, "NFT don'cretate");
            require(value[i] > 0, "invalid 0 value");
            require(nfts[nftid[i]][msg.sender].OwnerNFT == msg.sender, "You no Owner NFT");
            require(nfts[nftid[i]][msg.sender].idcolections == 0, "NFT in collections");
            require(nfts[nftid[i]][msg.sender].sellExits == false, "Nft sell");
            require(nfts[nftid[i]][msg.sender].value >= value[i], "You don't have nft value");
        }
        require(nftid.length ==  value.length, "lenght nftid == value");
        collections[idCollection.length] = collection(idCollection.length, msg.sender, name, descript, nftid, value, false, true);
        for (uint256 i = 0; i < nftid.length; i++){
            if (nfts[nftid[i]][msg.sender].value == value[i]){
                nftscolnfts[nftid[i]][idCollection.length][msg.sender] = nfts[nftid[i]][msg.sender];
                nfts[nftid[i]][msg.sender].exits = false;
            }
            else{
            nftscolnfts[nftid[i]][idCollection.length][msg.sender] = nfts[nftid[i]][msg.sender];
            nftscolnfts[nftid[i]][idCollection.length][msg.sender].value = value[i];
            nfts[nftid[i]][msg.sender].value -= value[i];
            }

        }
        idCollection.push(idCollection.length);
    }//nftscol

    // Продажа nft
    // Просто добавляю nft в струткуру salle NFT
function sellNfs(uint idnft, uint value, uint PrcieOnOne, uint collection) public {
    if (collection == 0) {
        require(nfts[idnft][msg.sender].exits == true, "NFT not created");
        require(value > 0, "Invalid value (must be greater than zero)");
        require(nfts[idnft][msg.sender].OwnerNFT == msg.sender, "You are not the owner of the NFT");
        require(nfts[idnft][msg.sender].sellExits == false, "NFT is already on sale");
        require(nfts[idnft][msg.sender].value >= value, "You don't have enough NFT value");

        sellnfts[idSellNft.length] = sellNft(idSellNft.length, idnft, 0, value, PrcieOnOne, msg.sender, true, true);
        emit SellNftt(idSellNft.length, idnft, msg.sender);
        idSellNft.push(idSellNft.length);
        nfts[idnft][msg.sender].sellExits = true;
    } else {
        require(nftscolnfts[idnft][collection][msg.sender].exits == true, "The collection does not exist");
        require(nftscolnfts[idnft][collection][msg.sender].OwnerNFT == msg.sender, "NFT");
        require(nftscolnfts[idnft][collection][msg.sender].exits == true, "NFT not created");
        require(value > 0, "Invalid value (must be greater than zero)");
        require(nftscolnfts[idnft][collection][msg.sender].OwnerNFT == msg.sender, "You are not the owner of the NFT");
        require(nftscolnfts[idnft][collection][msg.sender].sellExits == false, "NFT is already on sale");
        require(nftscolnfts[idnft][collection][msg.sender].value >= value, "You don't have enough NFT value");

        sellnfts[idSellNft.length] = sellNft(idSellNft.length, idnft, collection, value, PrcieOnOne, msg.sender, true, true);
        emit SellNftt(idSellNft.length, idnft, msg.sender);
        idSellNft.push(idSellNft.length);
        nftscolnfts[idnft][collection][msg.sender].sellExits = true;
    }
}

function getSellNFTsCount() public view returns (uint256) {
    return idSellNft.length;
}

// Вывожу все NFT на продаже(Что то типо тп)
// Создаю кучу массивов, а после в них записываю даннеы из структур, а после по очереди вывожу
function getAllNFTsForSale(uint256 i) public view returns (uint256,uint256, uint256, uint256, uint256, bool) {
    uint256 collectionIds;
    uint256 ids;
    uint256 idSelf;
    uint256 values;
    uint256 fullPrice;
    bool sellActive;

        collectionIds = sellnfts[i].collectionId;
        ids = sellnfts[i].nftId;
        idSelf = i;
        values = sellnfts[i].value;
        fullPrice = sellnfts[i].value * sellnfts[i].priceOnOne;
        sellActive = sellnfts[i].sellActive;
        return (ids, idSelf,collectionIds, values, fullPrice, sellActive);
}
            
    
    // Отменить продажу
    function canelsell(uint idsell) public {
        require(sellnfts[idsell].exits == true, "Sell nft don't create");
        require(sellnfts[idsell].sellActive == true, "Nft selled");
        require(sellnfts[idsell].seller == msg.sender, "You no seller nft");
        sellnfts[idsell].sellActive = false;
        nfts[sellnfts[idsell].nftId][msg.sender].sellExits = false;
    }


    // Покупка NFT
    // Со скидкой
function byNft(uint idsell) public {
    uint256 price;
    if (users[msg.sender].userRefCodePercentBonus > 0){
        price = price - ((users[msg.sender].userRefCodePercentBonus/100)*price);
    }
    else {
        price = sellnfts[idsell].priceOnOne * sellnfts[idsell].value;
    }

    require(sellnfts[idsell].seller != msg.sender, "You are the seller of this NFT");
    require(sellnfts[idsell].exits == true, "NFT sale not created");
    require(sellnfts[idsell].sellActive == true, "NFT is not for sale");
    require(users[msg.sender].userTokens >= price, "Insufficient token balance");

    if (sellnfts[idsell].collectionId == 0) {
        require(nfts[sellnfts[idsell].nftId][sellnfts[idsell].seller].value == sellnfts[idsell].value, "NFT value mismatch");

        sellnfts[idsell].sellActive = false;
        nfts[sellnfts[idsell].nftId][sellnfts[idsell].seller].sellExits = false;
        nfts[sellnfts[idsell].nftId][sellnfts[idsell].seller].OwnerNFT = msg.sender;

        _transfer(msg.sender, sellnfts[idsell].seller, price);
    } else {
        require(nftscolnfts[sellnfts[idsell].nftId][sellnfts[idsell].collectionId][sellnfts[idsell].seller].value == sellnfts[idsell].value, "NFT value mismatch");

        sellnfts[idsell].sellActive = false;

        nftscolnfts[sellnfts[idsell].nftId][sellnfts[idsell].collectionId][msg.sender].OwnerNFT = msg.sender;

        sellnfts[idsell].sellActive = false;
    }

    users[msg.sender].userTokens -= price;
}


// function CreateAuction(uint256 idCollections, uint256 StartPrice, uint256 MaxPrice, uint256 startedTime, uint256 stopedTime) public {
//     require(collections[idCollections].OwnerCollections != address(0), "The collection does not exist");
//     require(collections[idCollections].OwnerCollections == msg.sender, "You are not the owner of the collection");
//     require(!collections[idCollections].inAuctions, "The collection is already in the auction");

//     uint256 auctionId = idAuctions.length; // Получаем следующий доступный индекс для нового аукциона

//     uint256[] memory emptyUintArray;
//     address[] memory emptyAddressArray;

//     Auctions[auctionId] = Auction(
//         auctionId,
//         idCollections,
//         block.timestamp + (startedTime * 1 minutes),
//         block.timestamp + (startedTime * 1 minutes) + (stopedTime * 1 minutes),
//         StartPrice,
//         MaxPrice,
//         emptyUintArray,
//         emptyAddressArray,
//         msg.sender,
//         true,
//         false,
//         true
//     );

//     collections[idCollections].inAuctions = true;
//     idAuctions.push(auctionId);

//     emit StartAuctions(auctionId, Auctions[auctionId].idCollection, block.timestamp + (startedTime * 1 minutes), block.timestamp + (startedTime * 1 minutes) + (stopedTime * 1 minutes));
//     emit StartAuctionsTwo(Auctions[auctionId].maxPrice, Auctions[auctionId].startPrice);
// }
 function CreateAuction(uint256 idCollections, uint256 StartPrcie, uint256 MaxPrice) public returns(uint256 auctionId){
        require(collections[idCollections].exits, "The collection does not exist");
        require(collections[idCollections].OwnerCollections == msg.sender, "you are not the owner of the collection");
        require(collections[idCollections].inAuctions == false, "the collection is already in the auction");
        Auctions[idAuctions.length].idAuction = idAuctions.length;
        Auctions[idAuctions.length].idCollection = idCollections;
        Auctions[idAuctions.length].startPrice = StartPrcie;
        Auctions[idAuctions.length].maxPrice = MaxPrice;
        Auctions[idAuctions.length].seller = msg.sender;
        Auctions[idAuctions.length].create = true;
        collections[idCollections].inAuctions = true;
        idAuctions.push(idAuctions.length);
        return idAuctions.length;
    }
    

    function StartAuction (uint256 idAuction, uint256 startTime,uint256 stopTimes) public {
        require(Auctions[idAuction].create, "The auction was not created with this id");
        require(Auctions[idAuction].seller == msg.sender, "You are not the owner of the created auction");
        require(Auctions[idAuction].exits == false, "Such an auction already exists");
        require(Auctions[idAuction].endl == false, "Such an auction existed and has already ended");
        uint256 createdTime = block.timestamp;
        Auctions[idAuction].timeStart = createdTime + (startTime * 1 minutes);
        Auctions[idAuction].stopTime = Auctions[idAuction].timeStart + (stopTimes * 1 minutes);
        Auctions[idAuction].exits = true;
        emit StartAuctions(idAuction,  Auctions[idAuction].idCollection, block.timestamp, stopTimes);
        emit StartAuctionsTwo(Auctions[idAuction].maxPrice, Auctions[idAuction].startPrice);
    }


    function placeBid(uint256 _auctionId, uint256 _bidAmount) public payable  {
        require(Auctions[_auctionId].seller != msg.sender, "your seller");
        require(Auctions[_auctionId].exits, "Auction does not exist");
        require(users[msg.sender].userTokens >= _bidAmount, "There are not enough tokens");
        for(uint256 i = 0; i < Auctions[_auctionId].bidsAdress.length; i++){
            require(Auctions[_auctionId].bidsAdress[i] != msg.sender, "you have already placed a bet");
        }

        require(block.timestamp <= (Auctions[_auctionId].stopTime +Auctions[_auctionId].timeStart) , "Auction has ended");
        require(_bidAmount > Auctions[_auctionId].startPrice, "Bid amount must be higher than start price");
        require(_bidAmount <= Auctions[_auctionId].maxPrice, "Bid amount exceeds max price");

        users[msg.sender].userTokens -= _bidAmount;
        Auctions[_auctionId].bids.push(_bidAmount);
        Auctions[_auctionId].bidsAdress.push(msg.sender);
        _transfer(msg.sender, address(this), _bidAmount);
        users[msg.sender].userTokens -= _bidAmount;
    }


    function updateBid(uint256 _auctionId, uint256 _bidnew) public payable {
        bool Check = false;
        uint256 IndexUser;
        require(Auctions[_auctionId].seller != msg.sender, "your seller");
        require(Auctions[_auctionId].exits, "Auction does not exist");
        for(uint256 i = 0; i < Auctions[_auctionId].bidsAdress.length; i++){ 
            if (Auctions[_auctionId].bidsAdress[i] == msg.sender){
                Check = true;
                IndexUser = i;
                break;
                }
            
            else{
                Check = false;}}

        require(Auctions[_auctionId].bids[IndexUser] != _bidnew, "You cannot place the same bet");
        require(Check, "You didn't place a bet");
        require(users[msg.sender].userTokens >= _bidnew, "There are not enough tokens");
        require(block.timestamp <= (Auctions[_auctionId].stopTime + Auctions[_auctionId].timeStart) , "Auction has ended");
        require(_bidnew <= Auctions[_auctionId].maxPrice, "Bid amount exceeds max price");
        if (_bidnew > 0) {
            if ((_bidnew <  Auctions[_auctionId].startPrice)){
                bool s = false;
                require(s, "the bid must be equal to 0 or be higher than the starting price"); }
            else {
                _transfer(address(this), msg.sender, Auctions[_auctionId].bids[IndexUser]);
                users[msg.sender].userTokens += _bidnew;
                _transfer(msg.sender, address(this), _bidnew);
                Auctions[_auctionId].bids[IndexUser] = _bidnew;
                users[msg.sender].userTokens -= _bidnew;
                }}
            
            else {
                _transfer(address(this), msg.sender, Auctions[_auctionId].bids[IndexUser]);
                _transfer(msg.sender, address(this), _bidnew);
                users[msg.sender].userTokens += _bidnew;
                Auctions[_auctionId].bids[IndexUser] = _bidnew;
            }
                }

function checkbid(uint256 AuctionId) public view returns (uint256[] memory, address[] memory) {
    require(block.timestamp <= (Auctions[AuctionId].stopTime + Auctions[AuctionId].timeStart), "The auction time is over");
    require(Auctions[AuctionId].exits == true, "The auction is not");
    uint256[] memory sortedBids = new uint256[](Auctions[AuctionId].bids.length);
    address[] memory sortedBidAddresses = new address[](Auctions[AuctionId].bidsAdress.length);

    for (uint256 i = 0; i < Auctions[AuctionId].bids.length; i++) {
        sortedBids[i] = Auctions[AuctionId].bids[i];
        sortedBidAddresses[i] = Auctions[AuctionId].bidsAdress[i];
    }

    for (uint256 i = 0; i < sortedBids.length; i++) {
        for (uint256 j = i + 1; j < sortedBids.length; j++) {
            if (sortedBids[i] < sortedBids[j]) {
                uint256 tempBid = sortedBids[i];
                sortedBids[i] = sortedBids[j];
                sortedBids[j] = tempBid;

                address tempAddress = sortedBidAddresses[i];
                sortedBidAddresses[i] = sortedBidAddresses[j];
                sortedBidAddresses[j] = tempAddress;
            }
        }
    }

    return (sortedBids, sortedBidAddresses);

}

function OverkillOfBets(uint256 AuctionId) internal virtual {
    uint256 maxBid = 0;
    uint256 Index;
    for (uint256 i = 0; i < Auctions[AuctionId].bidsAdress.length; i++) {
        if (Auctions[AuctionId].bids[i] != 0) {
            if (maxBid < Auctions[AuctionId].bids[i]) {
                maxBid = Auctions[AuctionId].bids[i];
                Index = i;
            }
        }
    }
    
    if (maxBid > 0) {
        for (uint256 i = 0; i < Auctions[AuctionId].bidsAdress.length; i++) {
            if (i != Index) {
                _transfer(address(this), Auctions[AuctionId].bidsAdress[i], Auctions[AuctionId].bids[i]);
            } else {
                _transfer(address(this), Auctions[AuctionId].seller, Auctions[AuctionId].bids[i]);
                collections[Auctions[AuctionId].idCollection].OwnerCollections = Auctions[AuctionId].bidsAdress[i];
                Auctions[AuctionId].exits = false;
                Auctions[AuctionId].endl = true;
                collections[Auctions[AuctionId].idCollection].inAuctions = false;
            }
        }
    } else {
        Auctions[AuctionId].exits = false;
        Auctions[AuctionId].endl = true;
    }
}

function StopAuctions(uint256 AuctionId) OnlyOwner public {
    require(Auctions[AuctionId].exits, "The auction does not exist");
    require(Auctions[AuctionId].bidsAdress.length > 0, "No bids were placed on the auction");
    require(!Auctions[AuctionId].endl, "The auction has already ended");
    
    OverkillOfBets(AuctionId);
}
function cheackAuctions(uint256 AuctionId) public returns (bool){
    require(Auctions[AuctionId].exits, "The auction is not");
    require(Auctions[AuctionId].endl == false, "The auction has already ended");
    if (block.timestamp <= (Auctions[AuctionId].stopTime + Auctions[AuctionId].timeStart)){
        return (Auctions[AuctionId].endl);
    }
    else {
        OverkillOfBets(AuctionId);
        return (Auctions[AuctionId].endl);
    }
}
}


