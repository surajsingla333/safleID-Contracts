pragma solidity 0.5.0;

import "./IStorage.sol";
import "./checkingContract.sol";

contract RegistrarMain is checkingContract{

    uint256 public registrarFees;
    uint256 public inbloxIdFees;
    address public contractOwner;
    address payable  public  walletAddress;
    bool public storageContractAddress;
    bool public inbloxIdRegStatus;

    RegistrarStorage public registrarStorageContractAddress;

    // @dev Modifier to ensure the function caller is the contract owner.
    modifier onlyOwner () {

        require(msg.sender == contractOwner, "msg sender is not a contract owner");
        _;

    }

    // @dev Modifier to ensure the Storage contract address is set.
    modifier checkStorageContractAddress () {

        require(storageContractAddress, "storage address not set");
        _;

    }

    // @dev Modifier to ensure the inbloxId registration is not paused.
    modifier checkRegistrationStatus () {

        require(inbloxIdRegStatus == false, "InbloxId Registration is Paused");
        _;

    }


    /**
    * @dev constructor of the contract
    * @param _walletAddress wallet address to transfer fees
    */
    constructor (address payable _walletAddress) public {

        require(_walletAddress != address(0));
        contractOwner = msg.sender;
        walletAddress = _walletAddress;

    }

    /**
    * @dev Set inbloxId registration fees
    * Only the contract owner can call this function
    * @param _amount fees in wei
    */
    function setInbloxIdFees(uint256 _amount) onlyOwner
    public

    {
        require(_amount >= 0);
        inbloxIdFees = _amount;

    }

    /**
    * @dev Set Registrar registration fees by owner
    * Only the contract owner can call this function
    * @param _amount fees in wei
    */
    function setRegistrarFees(uint256 _amount) onlyOwner
    public

    {
        require(_amount >= 0);
        registrarFees = _amount;

    }

    /**
    * @dev Pause and resume the inbloxId registration
    * Only the contract owner can call this function
    * @return True if paused, else false.
    */
    function toggleRegistrationStatus () external onlyOwner returns (bool){

    if(inbloxIdRegStatus == false){
        inbloxIdRegStatus = true;
    }else{
        inbloxIdRegStatus = false;
    }
     return true;

    }


    /**
    * @dev Register a new Registrar
    * Can be called only if inbloxId registration is not paused and storage contract is set
    * This method is payable.
    * @param _registrarName Registrar name in string
    */
    function registerRegistrar(string memory _registrarName)  checkRegistrationStatus checkStorageContractAddress payable
    public

    {

        require(msg.value >= registrarFees," registration fees not matched");
        require(isInbloxIdValid(_registrarName));
        string memory VNinLowerCase = toLower(_registrarName);
        walletAddress.transfer(msg.value);
        require(registrarStorageContractAddress.registerRegistrar(msg.sender,VNinLowerCase),"storage address error");

    }

    /**
    * @dev Register a user's inbloxId
    * Can be called only if inbloxId registration is not paused and storage contract is set
    * This method is payable.
    * @param _userAddress address of the user
    * @param _inbloxId inbloxId of the user
    */
    function registerInbloxId(address _userAddress, string memory _inbloxId) checkRegistrationStatus checkStorageContractAddress payable
    public

    {

        require(msg.value >= inbloxIdFees,"Fees doesn't Match");
        require(isInbloxIdValid(_inbloxId));
        string memory VNinLowerCase = toLower(_inbloxId);
        walletAddress.transfer(msg.value);
        require(registrarStorageContractAddress.registerInbloxId(msg.sender,_userAddress,VNinLowerCase),"storage error");        

    }

    /**
    * @dev Update an already registered Registrar
    * This method is payable.
    * Can be called only if inbloxId registration is not paused and storage contract is set
    * @param _registrarName string to be taken as a New name of Ragistrar
    */
    function updateRegistrar(string memory _registrarName) checkRegistrationStatus checkStorageContractAddress payable
    public

    {

        require(msg.value >= registrarFees,"registration fees not matched");
        require(isInbloxIdValid(_registrarName));
        string memory VNinLowerCase = toLower(_registrarName);
        walletAddress.transfer(msg.value);
        require(registrarStorageContractAddress.updateRegistrar(msg.sender,VNinLowerCase),"Storage contract fails");

    }

    /**
    * @dev Update the inbloxId of a user
    * Can be called only if inbloxId registration is not paused and storage contract is set
    * This method is payable.
    * @param _userAddress address of a user
    * @param _newInbloxId new inbloxId of the user to update
    */
    function updateInbloxId(address _userAddress, string memory _newInbloxId) checkRegistrationStatus checkStorageContractAddress payable
    public

    {

        require(msg.value >= inbloxIdFees,"registration fees not matched");
        require(isInbloxIdValid(_newInbloxId));
        string memory VNinLowerCase = toLower(_newInbloxId);
        walletAddress.transfer(msg.value);
        require(registrarStorageContractAddress.updateInbloxId(msg.sender,_userAddress,VNinLowerCase),"Storage contract fails");

    }

    /**
    * @dev Set registrar storage contract address
    * Can be called only be the contract owner
    * @param _registrarStorageContract Address of the storage contract
    */
    function setStorageContract(RegistrarStorage _registrarStorageContract) onlyOwner
    public

    {

        registrarStorageContractAddress = _registrarStorageContract;
        storageContractAddress = true;

    }

    /**
    * @dev Update wallet address to collect fees
    * Can be called only by the contract owner
    * This method is payable.
    * @param _walletAddress to redirect fees
    */
    function updateWalletAddress(address payable _walletAddress) onlyOwner
    public

    {
        require(!isContract(_walletAddress));
        walletAddress = _walletAddress;

    }

    /**
    * @dev Create an other coin address mapping
    * @param _indexnumber index of a new coin
    * @param _blockchainName Name of the coin
    * @param _aliasName Alias name in string
    * @return true if successful, else false
    */
   function addCoins(uint256 _indexnumber, string calldata _blockchainName, string calldata _aliasName) external returns (bool){

        string memory lowerBlockchainName = toLower(_blockchainName);
        string memory lowerAliasName = toLower(_aliasName);
        require(_indexnumber != 0);
        require(checkAlphaNumeric(lowerBlockchainName) && checkAlphaNumeric(lowerAliasName),"only alphanumeric allowed in blockchain name and alias name");
        require(registrarStorageContractAddress.addCoin(_indexnumber,lowerBlockchainName,lowerAliasName, msg.sender),"Storage contract fails");
        return true;

   }

    /**
    * @dev  Register a new coin address
    * @param _userAddress public address of a user
    * @param _index index of the blockchain to set the address
    * @param _address Coin address
    * @return true if successful, else false
    */
    function registerCoinAddress(address _userAddress,uint256 _index, string calldata _address) external returns (bool){
        
        string memory lowerAddress = toLower(_address);
        uint8 length = checkLength(_address);
        require(_index != 0 && _userAddress != address(0));
        require(length > 0);
        require(registrarStorageContractAddress.registerCoinAddress(_userAddress,_index,lowerAddress, msg.sender),"Storage contract fail");

    }

    /**
    * @dev Update the coin address of that user
    * @param _userAddress address of the user
    * @param _index index of that blockchain
    * @param _address new address of that coin
    * @return true if successful, else false
    */
    function updateCoinAddress(address _userAddress,uint256 _index, string calldata _address) external returns (bool){

        string memory lowerAddress = toLower(_address);
        uint8 length = checkLength(_address);
        require(_index != 0 && _userAddress != address(0));
        require(length > 0);
        require(registrarStorageContractAddress.updateCoinAddress(_userAddress,_index,lowerAddress, msg.sender),"Storage contract fail");

    }

}

