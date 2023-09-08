// SPDX-License-Identifier:MIT

pragma solidity ^0.8.17;
import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";


contract DonorSynk is ERC20{

    constructor(string memory name, string memory symbol)ERC20( name, symbol){

    }

    struct Hospital{
        address owner;
        string hospitalName;
        string  uri;
        mapping(uint256 => Donors) donorsData;
        uint256[] allDonorsId;
        uint256 ID;
        BloodType bloodtypes;
    }


    struct Donors{
       bytes32 GovernmentId;
       string DonorURI;
       bool Status;
    }

    struct BloodType{
        uint256 volumeAplus;
        uint256 volumeANegative;
        uint256 volumeBPlus;
        uint256 volumeBNegative;
        uint256 volumeABPlus;
        uint256 volumeABNegative;
        uint256 volumeOPlus;
        uint256 volumeONegative;

    }

    // to show the status of the hospital
    mapping(address => bool) registeredHospitalStatus;

    mapping(address => Hospital) hospitalAdmin;

    mapping(string => Hospital) showHospital;
    string[] AllHospital;

    // mapping to hospital name does not exit
    mapping(string => bool) nameExit;

// incentives of Donors
    mapping(address => uint256) donorsBalance;

    enum Error{
        NAME_ALREADY_EXIST,
        ADDRRESS_REGISTERED,
        NOT_OWNER
    }

// enum CheckUp{

// }


    // EVENT

/**
*@dev to register hospital
* generatedURI is gotten from ipfs
* the uri contains all the hospital detail needed
*_hospitalName name of the hospital
 */
    function registerHospital(string memory _generatedURI, string memory _hospitalName, address _admin) public{
        require(_admin == msg.sender, 'NOT_OWNER');
        require(nameExit[_hospitalName] == false, 'NAME_ALREADY_EXIST');
        require(registeredHospitalStatus[msg.sender] == false, 'ADDRRESS_REGISTERED');
        registeredHospitalStatus[_admin] = true;
        nameExit[_hospitalName] =true;
        Hospital storage newHospital = hospitalAdmin[_admin];
        Hospital storage stringHospital = showHospital[_hospitalName];
        newHospital.uri = _generatedURI;
        newHospital.owner = msg.sender;
        stringHospital.uri = _generatedURI;
        stringHospital.owner= msg.sender;


        AllHospital.push(_hospitalName);
        
    }

    function bookDonorAppointment(string memory _hospitalName,  string memory _governmentId, string memory _donorURI) public{
        Hospital storage stringHospital = showHospital[_hospitalName];
        bytes memory GId = bytes(_governmentId);
        bytes32 _GId = bytes32(GId);
        Donors memory newDonor = Donors(_GId,_donorURI, false);
        uint _id = stringHospital.ID;
        showHospital[_hospitalName].donorsData[_id] = newDonor;
        showHospital[_hospitalName].allDonorsId.push(_id);
        uint dataId = showHospital[_hospitalName].ID;
        showHospital[_hospitalName].ID = dataId +1;

    }

    function getAllHospital() public view returns (string[] memory){
        return AllHospital;
    }

    function showMyHospital(address _admin) public view returns(string memory uri){
        uri = hospitalAdmin[_admin].uri;
    }

   

    function showAllDonors(string memory _name) public view returns (Donors[] memory) {
    Hospital storage fetchDonor = showHospital[_name];
    uint256[] storage DonorsId = fetchDonor.allDonorsId;

    Donors[] memory result = new Donors[](DonorsId.length);
    
    for (uint256 i = 0; i < DonorsId.length; i++) {
        result[i] = fetchDonor.donorsData[DonorsId[i]];
    }  

    return result;
}

function confirmBloodDonation(string memory _name, uint _id, uint8 _bloodType, uint256 newVolume, address _donor) public{
    Hospital storage fetchDonor = showHospital[_name];
    require(fetchDonor.owner == msg.sender, 'NOT_OWNER');
    fetchDonor.donorsData[_id].Status = true;
    if(_bloodType == 0) fetchDonor.bloodtypes.volumeAplus += newVolume;
    else if(_bloodType == 1) fetchDonor.bloodtypes.volumeANegative += newVolume;
    else if(_bloodType == 2) fetchDonor.bloodtypes.volumeBPlus += newVolume;
    else if(_bloodType == 3) fetchDonor.bloodtypes.volumeBNegative += newVolume;
    else if(_bloodType == 4) fetchDonor.bloodtypes.volumeABPlus += newVolume;
    else if(_bloodType == 5) fetchDonor.bloodtypes.volumeABNegative += newVolume;
    else if(_bloodType == 6) fetchDonor.bloodtypes.volumeOPlus += newVolume;
    else fetchDonor.bloodtypes.volumeONegative += newVolume;
    _mint(_donor, 10*1e18);

}

function deductTokenForCheckUp(uint256 tokenToDeduct,address _checkUp) public{

    // donorsBalance[_checkUp] -=tokenToDeduct;
    require(registeredHospitalStatus[msg.sender], 'HOSPITAL_NOT_REGISTERED');
    _burn(_checkUp, tokenToDeduct);
    _mint(msg.sender, tokenToDeduct);

}

function checkAvailableBlood() public view returns(string[] memory , BloodType[] memory) {
    string[] memory _allHospitalName = AllHospital;
    string[] memory _uri = new string[](_allHospitalName.length);
    BloodType[] memory allAvailableBlood = new BloodType[](_allHospitalName.length);

    for(uint i = 0; i < _allHospitalName.length; i++) {
        Hospital storage fetchHospital = showHospital[_allHospitalName[i]];
        _uri[i] = fetchHospital.uri;
        allAvailableBlood[i] = fetchHospital.bloodtypes;
    }

    return (_uri, allAvailableBlood);
}

}