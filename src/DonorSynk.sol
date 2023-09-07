// SPDX-License-Identifier:MIT

pragma solidity ^0.8.17;


contract DonorSynk{

    struct Hospital{
        string  uri;
        mapping(uint256 => Donors) donorsData;
        uint256[] allDonorsId;
        uint256 ID;

    }


    struct Donors{
       bytes32 GovernmentId;
       string DonorURI;
       bool Status;
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
        nameExit[_generatedURI] =true;
        Hospital storage newHospital = hospitalAdmin[_admin];
        Hospital storage stringHospital = showHospital[_hospitalName];
        newHospital.uri = _generatedURI;
        
    }

    function bookDonorAppointment(string memory _hospitalName, uint _id, bytes32 _governmentId, string memory _donorURI) public{
        Hospital storage stringHospital = showHospital[_hospitalName];
        Donors memory newDonor = Donors(_governmentId,_donorURI, false);
        showHospital[_hospitalName].donorsData[_id] = newDonor;
        showHospital[_hospitalName].allDonorsId.push(_id);
        uint dataId = showHospital[_hospitalName].ID;
        showHospital[_hospitalName].ID = dataId +1;

    }

    function getAllHospital() public view returns (string[] memory){
        return AllHospital;
    }

    function showMyHospital() public returns(string memory uri, Donors memory, uint256[] memory _allDonorsId){

    }

}