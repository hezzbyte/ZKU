// SPDX-License-Identifier: MIT

//Set the compiler versions
pragma solidity >=0.8.0 <0.9.0;

//@Dev implements voting process along with vote delegation

contract Ballot {
    struct Voter {
        uint weight; // weight is accumulated by delegation
        bool voted; // voting status of voter, if true, that person already voted
        address delegate; // person delegated to
        uint vote; // index of the voted proposal
    }
    
    //Proposal here means condidate
    struct Proposal {
        // This is candidate variable and properties
        bytes32 name; // the name of the Candidates in type bytes32
        uint voteCount; // total number of accumulated votes
    }

    address public chairperson;
    
    //map the addresses passed in to the Voter struct
    mapping(address => Voter) public voters;

    Proposal[] public candidates;
//declare state variable startTime and set to block.timestamp
    uint startTime = block.timestamp;

//Added modifier
    modifier voteEnded() {
        require(
            //output error when time lapse exceeds 5 minutes
            block.timestamp - startTime <= 5 minutes,
            "voting period is over"
        );
        _;
    }

    constructor(bytes32[] memory proposalNames) {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;

        for (uint i = 0; i < proposalNames.length; i++) {
            // 'Proposal({...})' creates an instance of the struct
            // Proposal and 'candidates.push(...)'
            // appends it to the end of candidates array stored as 'candidates'.
            candidates.push(
                Proposal({name: proposalNames[i], voteCount: 0})
            );
        }
    }

    //This function gives 'voter' the right to vote on this ballot.
    //Function can only be called by 'chairperson'.
     
    function giveRightToVote(address voter) public {
        require(
            msg.sender == chairperson,
            "Only chairperson can give right to vote."
        );
        require(!voters[voter].voted, "The voter already voted.");
        require(voters[voter].weight == 0);
        voters[voter].weight = 1;
    }

    //This function allows a voter to delegate their vote(weight) to someone else

    function delegate(address to) public {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "You already voted."); //This ensures that they have not yet voted already
        require(to != msg.sender, "Self-delegation is disallowed.");

        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate;

            // We found a loop in the delegation, not allowed.
            require(to != msg.sender, "Found loop in delegation.");
        }
        sender.voted = true; //This prevents the sender from voting or delegating again.
        sender.delegate = to;
        Voter storage delegate_ = voters[to];
        if (delegate_.voted) {
            // If the delegate already voted,
            // directly add to the number of votes
            candidates[delegate_.vote].voteCount += sender.weight;
        } else {
            // If the delegate did not vote yet,
            // add to their weight.
            delegate_.weight += sender.weight;
        }
    }

   /*
     * @dev Give your vote (including votes delegated to you) to proposal 'proposals[proposal].name'.
     * @param proposal index of proposal in the proposals array
     */

     //vote function with the "voteEnded" modifier

    function vote(uint candidate) public voteEnded {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Has no right to vote");
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = candidate;

        // If 'proposal' is out of the range of the array,
        // this will throw automatically and revert all changes.
        candidates[candidate].voteCount += sender.weight;
    }

    //This function loops through the candidates array and
    //returns the index of one with the highest voteCount
    function winningCandidate()
        public
        view
        returns (uint winningCandidate_)
    {
        uint winningVoteCount = 0;
        for (uint j = 0; j < candidates.length; j++) {
            if (candidates[j].voteCount > winningVoteCount) {
                winningVoteCount = candidates[j].voteCount;
                winningCandidate_ = j;
            }
        }
    }

    //This calls winningProposal() function to get the index of the winner contained in the proposals array and then
    // return winnerName_ the name of the winner
    function winnerName() public view returns (bytes32 winnerName_) {
        winnerName_ = candidates[winningCandidate()].name;
    }
}
