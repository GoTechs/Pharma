pragma solidity ^0.5.0;

import "../pharmaAccesControl/Roles.sol";
import "../pharmaAccesControl/RoleDistributor.sol";
import "../pharmaAccesControl/RoleProducer.sol";
import "../pharmaAccesControl/RoleClient.sol";
import "../pharmaCore/Ownable.sol";

// Define a contract 'Supplychain'

contract PharmaSupplyChain is RoleProducer, RoleDistributor, RoleClient {

  // Define 'owner'
  address payable owner;

  // Define a variable called 'upc' for Universal Product Code (UPC)
  uint  upc;

  // Define a variable called 'sku' for Stock Keeping Unit (SKU)
  uint  sku;

  // Define a public mapping 'articles' that maps the UPC to an article.
 
  mapping (uint => Article) articles;

  // Define a public mapping 'medicinesHistory' that maps the UPC to an array of TxHash, 
  // that track its journey through the supply chain -- to be sent from DApp.
 // mapping (uint => string[]) medicinesHistory;
  mapping (uint => string[]) articlesHistory;
  
  // PROJET:
  enum State2
  {
    ArticleBatchProducedByProducer, // 0
    ArticleBatchSoldByProducer, // 1
    ArticleBatchAcquiredByDistributor, // 2
    ArticleBatchSentByProducer, // 3
    ArticleBatchReceivedByDistributor, // 4
    ArticleBatchPreparedByDistributor, // 5
    ArticlePreparedByDistributor, // 6
    ArticleSoldByDistributor, // 7
    ArticleAcquiredByClient, // 8
    ArticleSentByDistributor, // 9
    ArticleReceivedByClient // 10
  }

// PROJET SIMPLIFIÉ:
  enum State
  {
    ArticleProducedByProducer, // 0
    ArticleOnSaleByProducer, // 1
    ArticleOrderedByDistributor, // 2
    ArticleReceivedByDistributor, // 3
    ArticleOnSaleByDistributor, // 4
    ArticleOrderedByClient, // 5
    ArticleReceivedByClient // 6
  }


  State constant defaultState = State.ArticleProducedByProducer;

 
  // Define a struct 'Article' with the following fields PROJET:
  struct Article{
    uint    sku;  // Stock Keeping Unit (SKU)
    uint    upc; // Universal Product Code (UPC), generated by the Manufacturer, goes on the package, can be verified by the Patient
    address ownerID;  // Metamask-Ethereum address of the current owner as the medicine moves through 8 stages
    address producerID; // Metamask-Ethereum address of the Manufacturer
    string  producerName; // Manufacturer Name
    string  producerInformation;  // Manufacturer Information
    uint    articleID;  // Product ID potentially a combination of upc + sku
    string  articleNotes; // Product Notes
    State  articleState;  // Product State as represented in the enum above
    address distributorID;  // Metamask-Ethereum address of the Distributor
    string distributorName; // distributor Name
    address clientID; // Metamask-Ethereum address of the Patient
  }

  // Define 8 events with the same 8 state values and accept 'upc' as input argument
  event Made(uint upc);
  event Packed(uint upc);
  event ForSale(uint upc);
  event Sold(uint upc);
  event Shipped(uint upc);
  event Received(uint upc);
  event Purchased(uint upc);

// PROJET:
// Define 11 events with the same 11 state values and accept 'upc' as input argument
  event ArticleProducedByProducer(uint upc);
  event ArticleBatchSold(uint upc);
  event ArticleBatchAcquired(uint upc);
  event ArticleBatchSent(uint upc);
  event ArticleBatchReceived(uint upc);
  event ArticleBatchPrepared(uint upc);
  event ArticlePrepared(uint upc);
  event ArticleSold(uint upc);
  event ArticleAcquired(uint upc);
  event ArticleSent(uint upc);
  event ArticleReceived(uint upc);
 

 // PROJET SIMPLIFIÉ:
 // Define 7 events with the same 7 state values and accept 'upc' as input argument
  
  event evArticleProducedByProducer(uint upc); // 0
  event evArticleOnSaleByProducer(uint upc); // 1
  event evArticleOrderedByDistributor(uint upc); // 2
  event evArticleSentToDistributor(uint upc); // 3
  event evArticleOnSaleByDistributor(uint upc); // 4
  event evArticleOrderedByClient(uint upc); // 5
  event evArticleReceivedByClient(uint upc); // 6 (a verifier)

// adapter les modifiers

  // Define a modifier that checks to see if msg.sender == owner of the contract
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  // Define a modifier that verifies the Caller
  modifier verifyCaller (address _address) {
    require(msg.sender == _address); 
    _;
  }

  // Define a modifier that checks if the paid amount is sufficient to cover the price
//  modifier paidEnough(uint _price) { 
//    require(msg.value >= _price); 
//    _;
//  }
  
  // Define a modifier that checks the price and refunds the remaining balance
//  modifier checkValue(uint _upc) {
//    _;
//    uint _price = medicines[_upc].medicinePrice;
//    uint amountToReturn = msg.value - _price;
//    medicines[_upc].patientID.transfer(amountToReturn);
//  }

  // PROJET:

  // PROJET SIMPLIFIÉ:
    // Define a modifier that checks if an article.state  a upc is produced
  modifier articleProducedByProducer(uint _upc) {
    require(articles[_upc].articleState == State.ArticleProducedByProducer);
    _;
  }

  // PROJET:
 // PROJET SIMPLIFIÉ: ArticleOnSaleByProducer
  // Define a modifier that checks if an article.state or a article of a upc is On Sale By Producer
  
  modifier articleOnSaleByProducer(uint _upc) {
    require(articles[_upc].articleState == State.ArticleOnSaleByProducer);
    _;
  }


  
 // PROJET:
 // PROJET SIMPLIFIÉ: ArticleOrderedByDistributor
  // Define a modifier that checks if an article.state of a upc is Ordered By Distributor
  
  modifier articleOrderedByDistributor(uint _upc) {
    require(articles[_upc].articleState == State.ArticleOrderedByDistributor);
    _;
  }

  // PROJET:
 // PROJET SIMPLIFIÉ: ArticleReceivedByDistributor
   // Define a modifier that checks if an article.state of a upc is Received By Distributor
  
  modifier articleReceivedByDistributor(uint _upc) {
    require(articles[_upc].articleState == State.ArticleReceivedByDistributor);
    _;
  }

 // PROJET:
 // PROJET SIMPLIFIÉ: ArticleSoldByDistributor
  // Define a modifier that checks if an article.state of a upc is Sold By Distributor

  modifier articleOnSaleByDistributor(uint _upc) {
    require(articles[_upc].articleState == State.ArticleOnSaleByDistributor);
    _;
  }

 // PROJET:
 // PROJET SIMPLIFIÉ: ArticleOrderedByClient

  // Define a modifier that checks if an article.state of a upc is Ordered By Client
  modifier articleOrderedByClient(uint _upc) {
    require(articles[_upc].articleState == State.ArticleOrderedByClient);
    _;
  }


 // PROJET:
 // PROJET SIMPLIFIÉ: ArticleReceivedByClient
 
 // Define a modifier that checks if an article.state of a upc is Received By Client
  modifier articleReceivedByClient(uint _upc) {
    require(articles[_upc].articleState == State.ArticleReceivedByClient);
    _;
  }

  // PROJET:
 // PROJET SIMPLIFIÉ:  constructor ok
  // In the constructor set 'owner' to the address that instantiated the contract
  // and set 'sku' to 1
  // and set 'upc' to 1
  constructor() public payable {
    owner = msg.sender;
    sku = 0;
    upc = 0;
  }

// PROJET:
 // PROJET SIMPLIFIÉ: contract terminator ok
  // Define a function 'kill' if required
  function kill() public {
    if (msg.sender == owner) {
      selfdestruct(owner);
    }
  }


 // PROJET: FUNCTIONS
 // PROJET SIMPLIFIÉ:
 
 
// PROJET:
 // PROJET SIMPLIFIÉ: produceArticleByProducer()  // 1
  function produceArticleByProducer(uint _upc, address _producerID, string memory _producerName, string memory _producerInformation,  string memory _articleNotes) public

  onlyProducer

  {
    // Add the new article as part of articles
    Article memory temp_article = Article({
      sku:sku + 1,
      upc:_upc,
      ownerID:_producerID,
      producerID:_producerID,
      producerName:_producerName,
      producerInformation:_producerInformation,
      articleID:sku+_upc,
      articleNotes:_articleNotes,
      articleState:State.ArticleProducedByProducer,
      distributorID:0x0000000000000000000000000000000000000000,
      distributorName:'0',      
      clientID:0x0000000000000000000000000000000000000000
      });
      
    articles[_upc] = temp_article;
    articles[_upc].articleState = State.ArticleProducedByProducer;

    // Increment sku
    sku = sku + 1;
    // Emit the appropriate event

    emit evArticleProducedByProducer(_upc);
  }
 // PROJET:
 // PROJET SIMPLIFIÉ:
 
  // Define a function 'packMedicine' that allows a manufacturer to mark an medicine 'Packed'
  function sellArticleByProducer(uint _upc) public 
  // Call modifier to check if upc has passed previous supply chain stage
  articleProducedByProducer(_upc)
  // Call modifier to verify caller of this function
  onlyProducer
  {
    // Update the appropriate fields
    articles[_upc].articleState = State.ArticleOnSaleByProducer;

    // Emit the appropriate event
    emit evArticleOnSaleByProducer(_upc);
  }


 // PROJET:
 // PROJET SIMPLIFIÉ: sellArticleByProducer()   // 2
 
 // PROJET:
 // PROJET SIMPLIFIÉ:  orderArticleByDistributor()

  // Define a function ' orderArticleByDistributor' that allows the disributor to mark an article  ordered ?
  //
  
  //function orderArticleByDistributor(uint _upc, address _distributorID, string _distributorName) public 
  
  function orderArticleByDistributor(uint _upc) public 
    // Call modifier to check if upc has passed previous supply chain stage
    articleOnSaleByProducer(_upc)
    
    //limit to distributers , no end consumers are allowed to buy from producer.
    onlyDistributor
    {

      // Update the appropriate fields - ownerID, distributorID, articleState
     // articles[_upc].ownerID = _distributorID;
      //articles[_upc].distributorID = _distributorID; //address
      //articles[_upc].distributorName = _distributorName;
      articles[_upc].articleState = State.ArticleOrderedByDistributor;
     
      // emit the appropriate event
      emit evArticleOrderedByDistributor(_upc);
    }

 // PROJET:
 // PROJET SIMPLIFIÉ: receiveArticleByDistributor()  // 3

 // PROJET:
 // PROJET SIMPLIFIÉ:
 
  // Define a function 'shipMedicine' that allows the distributor to mark an medicine 'Shipped'
  // Use the above modifers to check if the medicine is sold
  function sendArticleToDistributor(uint _upc) public 
    // Call modifier to check if upc has passed previous supply chain stage
    articleOrderedByDistributor(_upc)
    // Call modifier to verify caller of this function
    onlyProducer
    {
      //check if the factory is the one making this medicine.
      require(articles[_upc].producerID == msg.sender,"Producers can ship only medicines by them");
      // Update the appropriate fields
      articles[_upc].articleState = State.ArticleReceivedByDistributor;
      // Emit the appropriate event
      emit evArticleSentToDistributor(_upc);
    }

// PROJET:
 // PROJET SIMPLIFIÉ: receiveArticleBatchByDistributor() // 4

 // PROJET:
 // PROJET SIMPLIFIÉ:
// Define a function 'sellArticleByDistributor' that allows a distributor to mark an article 'ArticleOnSaleByDistributor'
  function sellArticleByDistributor(uint _upc) public 
  // Call modifier to check if upc has passed previous supply chain stage
  articleReceivedByDistributor(_upc)
  // Call modifier to verify caller of this function
  onlyDistributor
  {
    // Update the appropriate fields
    articles[_upc].articleState = State.ArticleOnSaleByDistributor;

    // Emit the appropriate event
    emit evArticleOnSaleByDistributor(_upc);
  }


 
  // Define a function 'receiveMedicine' that allows the pharmacist to mark an medicine 'Received'
  

// PROJET:
 // PROJET SIMPLIFIÉ: sellArticleByDistributor() // 5

 // PROJET:
 // PROJET SIMPLIFIÉ:
 
  
 // PROJET:
 // PROJET SIMPLIFIÉ:

 // PROJET:
 // PROJET SIMPLIFIÉ: orderArticleByClient() // 6
 // Define a function ' orderArticleByClient' that allows the disributor to mark an article  ordered ?
  //
  
  function orderArticleByClient(uint _upc, address _clientID) public 
    // Call modifier to check if upc has passed previous supply chain stage
    articleOnSaleByDistributor(_upc)
    
    //limit to distributers , no end consumers are allowed to buy from producer.
    onlyClient
    {

      // Update the appropriate fields - ownerID, distributorID, articleState
      articles[_upc].ownerID = _clientID;
      articles[_upc].clientID = _clientID;
      articles[_upc].articleState = State.ArticleOrderedByClient;
     
      // emit the appropriate event
      emit evArticleOrderedByClient(_upc);
    }

 
 
   function sendArticleToClient(uint _upc) public 
    // Call modifier to check if upc has passed previous supply chain stage
    articleOrderedByClient(_upc)
    // Call modifier to verify caller of this function
    onlyDistributor
    {
      //check if the distributor is the one making this medicine.
      require(articles[_upc].distributorID == msg.sender,"Distributors can ship only articles to clients");
      // Update the appropriate fields
      articles[_upc].articleState = State.ArticleReceivedByClient;
      // Emit the appropriate event
      emit evArticleReceivedByClient(_upc);
    }


 // PROJET:
 // PROJET SIMPLIFIÉ:

 // PROJET:
 // PROJET SIMPLIFIÉ: receiveArticleByClient()  // 7

 // Recupération information
 // PROJET SIMPLIFIÉ: articleTraceProducer() articleTraceDistributor() articleTraceClient() remplacerait les fetch
 
  // Define a function 'fetchMedicineBufferOne' that fetches the data
  function articleTraceProducer(uint _upc) public view returns 
  (
    uint    articleSKU,
    uint    articleUPC,
    address ownerID,
    address producerID,
    string memory producerName,
    string memory producerInformation
    //string  originFactoryLatitude
    // producerName; // Manufacturer Name
    //string  producerInformation
    // string  originFactoryLongitude
    ) 
  {
  // Assign values to the 7 parameters
  

  return 
  (
    articles[_upc].sku,
    articles[_upc].upc,
    articles[_upc].ownerID,
    articles[_upc].producerID,
    articles[_upc].producerName,
    articles[_upc].producerInformation
    //medicines[_upc].originFactoryLatitude
    // medicines[_upc].originFactoryLongitude
    );
}

 // PROJET:
 // PROJET SIMPLIFIÉ:
 
  // Define a function 'fetcharticleBufferTwo' that fetches the data
  function articleTraceDistributor(uint _upc) public view returns 
  (
    uint    articleSKU,
    uint    articleUPC,
    uint    articleID,
    
    string memory articleNotes,
    State    articleState,
    address distributorID,
    address clientID
    ) 
  {
    // Assign values to the 7 parameters
//string  producerName; // Manufacturer Name
//string  producerInformation;  // Manufacturer Information
//uint    articleID;  // Product ID potentially a combination of upc + sku
//string  articleNotes; // Product Notes
//State  articleState;  // Product State as represented in the enum above
//address distributorID;  // Metamask-Ethereum address of the Distributor
//string distributorName; // distributor Name
//address clientID; // Metamask-Ethereum address of the Patient
  
    
 // PROJET:
 
 
    return 
    (
      articles[_upc].sku,
      articles[_upc].upc,
      articles[_upc].articleID,
      articles[_upc].articleNotes,
      articles[_upc].articleState,
      articles[_upc].distributorID,
      articles[_upc].clientID
      );
  }

  // Define a function 'fetcharticleBufferThree' that fetches the data
  function fetcharticleBufferThree(uint _upc) public view returns 
  (
    uint    articleSKU,
    uint    articleUPC,
    uint    articleID
    ) 
  {
    // Assign values to the 3 parameters

    
    return 
    (
      articles[_upc].sku,
      articles[_upc].upc,
      articles[_upc].articleID
      
      );
  }


}