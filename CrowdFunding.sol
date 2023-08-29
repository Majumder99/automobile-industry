// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract CrowdFunding {
    address public creator;
    uint256 public goal;
    uint256 public deadline;
    mapping(address => uint256) public contributions;
    uint256 public totalContributions;
    bool public isFunded;
    bool public isCompleted;

    event GoalReached(uint256 totalContributions);
    event FundTransfer(address backer, uint256 amount);
    event DeadlineReached(uint256 totalContributions);

    constructor(uint256 fundingGoalInEther, uint256 durationInMinutes) {
        creator = msg.sender;
        goal = fundingGoalInEther * 1 ether;
        deadline = block.timestamp + durationInMinutes * 1 minutes;
        isFunded = false;
        isCompleted = false;
    }

    modifier onlyCreator() {
        require(msg.sender == creator, "Only creator can call this function");
        _;
    }

    // The payable keyword in the contribute() function in Solidity indicates that this function can receive Ether.
    // This means that when a user calls this function, they can send Ether along with the function call.
    // The Ether will then be stored in the contract's balance.
    function contribute() public payable {
        require(block.timestamp < deadline, "Deadline has passed");
        require(!isCompleted, "Project is completed");

        uint256 contribution = msg.value;
        contributions[msg.sender] += contribution;
        totalContributions += contribution;

        if (totalContributions >= goal) {
            isFunded = true;
            emit GoalReached(totalContributions);
        }

        emit FundTransfer(msg.sender, contribution);
    }

    function withdrawFund() public {
        require(isFunded, "Project is not funded");
        require(!isCompleted, "Project is completed");

        isCompleted = true;
        payable(creator).transfer(totalContributions);
    }

    function getRefund() public {
        require(block.timestamp >= deadline, "Deadline has not passed");
        require(!isFunded, "Project is funded");
        require(contributions[msg.sender] > 0, "No contribution found");

        uint256 contribution = contributions[msg.sender];
        contributions[msg.sender] = 0;
        totalContributions -= contribution;
        payable(msg.sender).transfer(contribution);
        emit FundTransfer(msg.sender, contribution);
    }

    function getCurrentBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function extendedDeadline(uint256 durationInMinutes) public onlyCreator {
        require(!isCompleted, "Project is completed");
        deadline += durationInMinutes * 1 minutes;
    }
}
