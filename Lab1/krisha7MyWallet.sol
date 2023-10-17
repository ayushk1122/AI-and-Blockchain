// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyWallet {
    address public owner;
    mapping(address => uint256) public allowances;
    address[5] public guardians;
    mapping(address => bool) guardianApprovals;
    uint8 public approvalCount;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this.");
        _;
    }

    constructor(
        address _owner,
        address[5] memory _guardians,
        address[] memory allowedPeople,
        uint256[] memory initialAllowances
    ) {
        owner = _owner;
        guardians = _guardians;

        for (uint i = 0; i < allowedPeople.length; i++) {
            allowances[allowedPeople[i]] = initialAllowances[i];
        }
    }

    function deposit() public payable {}

    function spend(address payable recipient, uint256 amount) public onlyOwner {
        require(address(this).balance >= amount, "Insufficient funds");
        require(
            allowances[recipient] >= amount || recipient == owner,
            "Amount exceeds allowance"
        );
        if (recipient != owner) {
            allowances[recipient] -= amount;
        }
        recipient.transfer(amount);
    }

    function changeGuardian(address oldGuardian, address newGuardian) public onlyOwner {
        for (uint8 i = 0; i < guardians.length; i++) {
            if (guardians[i] == oldGuardian) {
                guardians[i] = newGuardian;
                return;
            }
        }
        revert("Guardian not found");
    }

    function guardianApproveNewOwner(address newOwner) public {
        bool isGuardian = false;
        for (uint8 i = 0; i < guardians.length; i++) {
            if (guardians[i] == msg.sender) {
                isGuardian = true;
                break;
            }
        }

        require(isGuardian, "Only guardians can approve");
        require(!guardianApprovals[msg.sender], "Guardian has already approved");

        guardianApprovals[msg.sender] = true;
        approvalCount++;

        if (approvalCount >= 3) {
            owner = newOwner;
            _resetGuardianApprovals();
        }
    }

    function setAllowance(address person, uint256 amount) public onlyOwner {
        for (uint8 i = 0; i < guardians.length; i++) {
            require(person != guardians[i], "Guardian cannot receive allowance");
        }
        allowances[person] = amount;
    }

    function _resetGuardianApprovals() private {
        for (uint8 i = 0; i < guardians.length; i++) {
            guardianApprovals[guardians[i]] = false;
        }
        approvalCount = 0;
    }
}
