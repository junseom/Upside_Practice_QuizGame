// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Quiz {
    struct Quiz_item {
      uint id;
      string question;
      string answer;
      uint min_bet;
      uint max_bet;
   }

    address public owner;
    mapping(address => uint256) public balances;
    
    mapping(uint => Quiz_item) public quizzes;
    uint public quizCount = 0;
    mapping(address => uint256)[] public bets;
    uint public vault_balance;

    constructor () {
        owner = msg.sender;
        Quiz_item memory q;
        q.id = 1;   
        q.question = "1+1=?";
        q.answer = "2";
        q.min_bet = 1 ether;
        q.max_bet = 2 ether;
        addQuiz(q);
    }

    function addQuiz(Quiz_item memory q) public {
        require(msg.sender == owner, "Not authorized");
        quizCount++;
        quizzes[quizCount] = q;
        bets.push();
    }

    function getAnswer(uint quizId) public view returns (string memory){
        return quizzes[quizId].answer;
    }

    function getQuiz(uint quizId) public view returns (Quiz_item memory) {
        Quiz_item memory q =  quizzes[quizId];
        q.answer = "";
        return q;
    }

    function getQuizNum() public view returns (uint){
        return quizCount;
    }
    
    function betToPlay(uint quizId) public payable {
        Quiz_item memory q = quizzes[quizId];
        uint amount = bets[quizId-1][msg.sender] + msg.value;
        require(amount >= q.min_bet && amount <= q.max_bet, "Bet amount is not in the range");
        bets[quizId-1][msg.sender] = amount;
    }

    function solveQuiz(uint quizId, string memory ans) public returns (bool) {
        Quiz_item memory q = quizzes[quizId];
        bool isSolved = keccak256(abi.encode(ans)) == keccak256(abi.encode(q.answer));
        if (isSolved) {
            balances[msg.sender] += bets[quizId-1][msg.sender] * 2;
            bets[quizId-1][msg.sender] = 0;
        } else {
            vault_balance += bets[quizId-1][msg.sender];
            bets[quizId-1][msg.sender] = 0;
        }
        return isSolved;
    }

    function claim() public {
        uint price = balances[msg.sender];
        balances[msg.sender] = 0;
        (bool success, ) = payable(msg.sender).call{value: price}("");
        require(success, "Transfer failed.");
    }

    receive() external payable {
    }
}
