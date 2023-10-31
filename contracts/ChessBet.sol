SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ChessBet {
    // State variables
    address public owner;
    uint256 public betAmount;
    
    // Enum to represent the game state
    enum GameState { Ongoing, Player1Won, Player2Won, Draw }
    
    // Struct to represent each game
    struct Game {
        address player1;
        address player2;
        GameState state;
        uint256 betAmount;
    }
    
    // Array to store all games
    Game[] public games;
    
    // Constructor function
    constructor() {
        owner = msg.sender;
    }
    
    // Function to create a new game
    function createGame(address _player2) public payable returns (uint256) {
        require(msg.value > 0, "Bet amount must be greater than 0");
        Game memory newGame = Game({
            player1: msg.sender,
            player2: _player2,
            state: GameState.Ongoing,
            betAmount: msg.value
        });
        games.push(newGame);
        return games.length - 1;  // Return the game ID
    }
    

function placeBet(uint256 gameId) public payable returns (bool) {
    // Ensure the game ID is valid
    require(gameId < games.length, "Invalid game ID");
    
    // Ensure the bet amount is positive
    require(msg.value > 0, "Bet amount must be greater than 0");

    // Update the bet amount for the specified game
    games[gameId].betAmount += msg.value;
    
    return true;
}

}


