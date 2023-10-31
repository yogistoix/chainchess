// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ChessBet {
    // State variables
    address public owner;
    uint256 public betAmount;

    // Enum to represent the game state
    enum GameState { Ongoing, Player1Won, Player2Won, Draw }

    // Struct to represent each game
    struct Game {
        address payable player1;
        address payable player2;
        GameState state;
        uint256 betAmount;
    }

    // Array to store all games
    Game[] public games;

    // Events
    event GameCreated(uint256 gameId, address player1, address player2, uint256 betAmount);
    event MoveMade(uint256 gameId, uint8 fromX, uint8 fromY, uint8 toX, uint8 toY);
    event PayoutsDistributed(uint256 gameId);

    // Constructor function
    constructor() {
        owner = msg.sender;
    }

    // Function to create a new game
    function createGame(address payable _player2) public payable returns (uint256) {
        require(msg.value > 0, "Bet amount must be greater than 0");
        Game memory newGame = Game({
            player1: payable(msg.sender),
            player2: _player2,
            state: GameState.Ongoing,
            betAmount: msg.value
        });
        games.push(newGame);
        emit GameCreated(games.length - 1, msg.sender, _player2, msg.value);  // Emit event
        return games.length - 1;  // Return the game ID
    }

    // Function to make a move
    function makeMove(uint256 gameId, uint8 fromX, uint8 fromY, uint8 toX, uint8 toY) public returns (bool) {
        // Ensure the game ID is valid
        require(gameId < games.length, "Invalid game ID");
        
        // Ensure the move is valid (simplified check for example)
        require(fromX < 8 && fromY < 8 && toX < 8 && toY < 8, "Invalid move coordinates");
        
        // TODO: Update game state based on the move
        
        // Optionally, check for a winner or draw
        // checkForWinnerOrDraw(gameId);
        
        emit MoveMade(gameId, fromX, fromY, toX, toY);  // Emit event
        return true;
    }

    // Function to check for winner or draw
    function checkForWinnerOrDraw(uint256 gameId) internal returns (GameState) {
        // TODO: Implement logic to determine if there's a winner or a draw
        // For now, this example just randomly sets a game state
        uint8 random = uint8(block.timestamp % 4);
        GameState newState = GameState(random);
        games[gameId].state = newState;
        return newState;
    }

    // Function to distribute payouts
    function distributePayouts(uint256 gameId) public returns (bool) {
        // Ensure the game ID is valid
        require(gameId < games.length, "Invalid game ID");
        
        // Ensure the game has ended
        require(games[gameId].state != GameState.Ongoing, "Game is still ongoing");
        
        // Distribute payouts based on game outcome (simplified)
        if (games[gameId].state == GameState.Player1Won) {
            games[gameId].player1.transfer(games[gameId].betAmount);
        } else if (games[gameId].state == GameState.Player2Won) {
            games[gameId].player2.transfer(games[gameId].betAmount);
        } else {
            // In case of a draw, refund bets
            uint256 refundAmount = games[gameId].betAmount / 2;
            games[gameId].player1.transfer(refundAmount);
            games[gameId].player2.transfer(refundAmount);
        }
        
        emit PayoutsDistributed(gameId);  // Emit event
        return true;
    }
}

