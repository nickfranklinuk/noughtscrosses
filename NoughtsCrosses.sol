contract NoughtsCrosses
{
    struct GameState
    {
        uint turn; // 1 - challenger, 2 - responder.
        uint winner; // 0 - draw 1 - challenger, 2 - responder.
        address challenger;
        address responder;
        // We will store 0 - empty, 1 - challenger, 2 - responder.
        uint[] board;
    }

    mapping(address => GameState) games;

    function getCurrentTurn(address challenger) returns(uint retvalue){
        GameState g = games[challenger];
        return g.turn;
    }

    function getBoard(address challenger) returns(uint[] retvalue){
        GameState g = games[challenger];
        return g.board;
    }

    function getWinner(address challenger) returns(address retvalue){
        uint winner = checkWinner(challenger);
        if(winner==1){
            // return the address of the challenger (winner)
            return challenger;
        }
        if(winner==2){
            // return the address of the responer (winner)
            return games[challenger].responder;
        }
        // we do not have a winner yet, the game is ongoing or is a draw
        // TODO: this should return the empty address, does it?
    }

    function startGame() returns (bool retvalue){
        // check if the user is already playing a game, if they are
        // then we need to return false and they will have to exit that
        // game and try this again, else create game and return true.
        GameState g = games[msg.sender];
        g.challenger = msg.sender;
        g.board = [0,0,0,0,0,0,0,0,0];
        if(g.responder!=0) {
            // we are already playing.
            return false;
        }
        return true;
    }

    function joinGame(address challenger) returns (uint retvalue){
        // returns 0 for fail, or 1 for challenger 1st or 2 for responder 1st
        GameState g = games[challenger];
        if(msg.sender == challenger){
            // you cannot play yourself
            return 0;
        }
        if (g.responder!=0) {
            // we cannot join a game with 2 players already!
            return 0;
        }
        else {
            // player 2 has entered the game.
            g.responder = msg.sender;
            g.turn = 1;
            return g.turn;
        }
    }

    // list 8 winning states and compare current state to win state.
    uint[][] winstates = [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]];

    function checkWinner(address challenger) returns (uint retvalue) {
        // return address of winner for game[challenger].
        GameState g = games[challenger];
        for(uint i = 0; i < 8; i++){
            bool challengerLoses = false;
            bool responderLoses = false;
            for(uint j = 0; j < 3; j++) {
                if(g.board[winstates[i][j]] != 1){
                    challengerLoses = true;
                }
                if(g.board[winstates[i][j]] != 2){
                    responderLoses = true;
                }
            }
            // if either of the above booleans are true that player has won.
            if(!challengerLoses){
                return 1;
            }
            if(!responderLoses){
                return 2;
            }
            // TODO: handle draw. this would return 3
            // make sure to change above getWinner function too.

            // if neither are true but none of the boxes are empty we have a draw.
        }


        // for each state in win states, see if current state matches, if so declare
        // current player the winner.

        // whoever took the last turn is the winner if states match.
    }

    function makeMove(address challenger, uint box) returns (bool retvalue){
        GameState g = games[challenger];
        if (msg.sender != g.challenger && msg.sender != g.responder) {
            // this is a stranger, don't let them play!
            return false;
        }
        if (msg.sender == g.challenger && g.turn == 2) {
            // not the challengers move.
            return false;
        }
        if (msg.sender == g.responder && g.turn == 1) {
            // not the responders move.
            return false;
        }
        if(box < 9){
            // we have a valid square, lets's see if it's blank.
            if(g.board[box] == 0){
                // the square is blank, let's move.
                g.board[box] = g.turn;
                // lets check if we have a winner
                g.winner = checkWinner(challenger);
                // update turn.
                if(g.turn == 1){
                    // if it's  challengers turn, make it responders turn.
                    g.turn = 2;
                }
                else {
                    // if it's responders turn, make it challengers  turn.
                    g.turn = 1;
                }
                return true;
            }
            else {
                // the square is occupied, invalid move.
                return false;
            }

        }
        else {
            // the user did not specify a valid row or column.
            return false;
        }

    }

}
