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

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

     // Example owner-only function to change bet amount
    function setBetAmount(uint256 newAmount) public onlyOwner {
        betAmount = newAmount;
    }
    // A modifier called onlyOwner is defined, which checks if msg.sender (the address calling the function) is the same as owner (the address that deployed the contract). If not, it reverts the transaction with an error message "Caller is not the owner".

    // The onlyOwner modifier is then applied to the setBetAmount function, ensuring that only the contract owner can change the bet amount.

    // You can apply the onlyOwner modifier to any function that should only be callable by the owner, by adding onlyOwner after the public or external visibility specifier.
    
    
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



    // Function to submit a move along with a proof of validity
    function submitMove(uint256 gameId, uint8 fromX, uint8 fromY, uint8 toX, uint8 toY, bytes memory proof) public returns (bool) {
        // Ensure the game ID is valid
        require(gameId < games.length, "Invalid game ID");

        // Ensure the move is within bounds (you already have this part)
        require(fromX < 8 && fromY < 8 && toX < 8 && toY < 8, "Invalid move coordinates");

        // Verify the proof (this is a placeholder, the actual verification will depend on your off-chain setup)
        require(verifyProof(gameId, fromX, fromY, toX, toY, proof), "Invalid move proof");

        // ... rest of your code to update game state and optionally check for a winner or draw ...

        return true;

    }



    //The submitMove function accepts a proof argument, which is supposed to be a proof of the validity of the move.
    // The verifyProof function is supposed to check this proof and return true if the move is valid, or false otherwise.
    // The actual implementation of verifyProof would depend on the specifics of how you generate and format the proof in your off-chain component.
    // ... rest of your code ...




    // Function to distribute payouts
    function distributePayouts(uint256 gameId) public returns (bool) {
        // Ensure the game ID is valid
        require(gameId < games.length, "Invalid game ID");
        
        // Ensure the game has ended
        require(games[gameId]).state != GameState.Ongoing, "Game is still ongoing");
        
        // Distribute payouts based on game outcome
        if (games[gameId].state == GameState.Player1Won) {
            uint256 winnings = games[gameId].betAmount * 2;
            games[gameId].player1.transfer(winnings);
        } else if (games[gameId].state == GameState.Player2Won) {
            uint256 winnings = games[gameId].betAmount * 2;
            games[gameId].player2.transfer(winnings);
        } else if (games[gameId].state == GameState.Draw) {
            // In case of a draw, refund bets
            uint256 refundAmount = games[gameId].betAmount;
            games[gameId].player1.transfer(refundAmount);
            games[gameId].player2.transfer(refundAmount);
        } else if (games[gameId].state == GameState.Aborted) {
            // In case of game abort, transfer all funds to the other player
            if (msg.sender == games[gameId].player1) {
                games[gameId].player2.transfer(games[gameId].betAmount * 2);
            } else {
                games[gameId].player1.transfer(games[gameId].betAmount * 2);
            }
        }
        
        emit PayoutsDistributed(gameId);  // Emit event
        return true;
    }
    
}
}

