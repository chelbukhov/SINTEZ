pragma solidity ^0.4.23;

contract test {
    event LogStateSwitch(State newState);

    enum State { 
        PreSale, 
        PreICO, 
        CrowdSale, 
        Refunding,
        Work }
    //State choice;
    State public currentState = State.PreSale;

    function setState(State _s) internal {
          currentState = _s;
          emit LogStateSwitch(_s);
    }
    
    function nextState() public {
        require(uint(currentState) != 4);
        currentState = State(uint(currentState) + 1);
        emit LogStateSwitch(currentState);
    }

    function nextState2() public {
        setState(State(uint(currentState) + 1));
    }
    
    function setPreICO() public {
        setState(State.PreICO);
    }

    function setPreSale() public {
        setState(State.PreSale);
    }


    function ifCrowdsale() public view returns(bool){
        return currentState == State.CrowdSale;
    }



}