pragma solidity ^0.4.3;

import "./Plans.sol";
import "./base/Ownable.sol";

/** @title Contains all the data required for a user's active subscription */

contract Subscriptions is Ownable {

    struct Subscription {

        address owner; // The owner of the subscription. Cannot be modified once set (unlike the plan).

        bytes32 planHash; // Plan indentifier

        uint startDate; // When the subscription starts
        uint terminationDate; // Epoch time for when the plan is terminated by the vendor

        uint interval; // Measured in days (required). Cannot be modified once set.
        uint amount; // Measured in cents (required). Cannot be modified once set.

        string data; // Optional data that a user may want to include

    }

    mapping (bytes32 => Subscription) public subscriptions; // A mapping containing all the plans

    Plans public PLAN_CONTRACT;

    event Created(bytes32 identifier);
    event Updated(bytes32 identifier);
    event Terminated(bytes32 identifier, uint terminationDate);

    /**
      * Modifiers
    */

    modifier isOwnerOfSubscription(bytes32 _subscription) {
        require(msg.sender == subscriptions[_subscription].owner);
        _;
    }

    modifier shouldEmitChanges(bytes32 _subscription) {
        _;
        emit Updated(_subscription);
    }

    /**
      * External functions
    */

    function terminateSubscription(bytes32 _subscription, uint _terminationDate)
        isOwnerOfSubscription(_subscription)
        external {
        require(_terminationDate >= block.timestamp);
        require(subscriptions[_subscription].terminationDate == 0); // If it's already been set then we don't want it to be modified
        subscriptions[_subscription].terminationDate = _terminationDate;
        emit Terminated(_subscription, _terminationDate);
    }

    /**
      * Public functions
    */

    /** @dev Constructor function
    */

    function Subscriptions(address _plan) public {
        owner = msg.sender;
        PLAN_CONTRACT = Plans(_plan);
    }

    /** dev This is the function for creating a new subscription
      * @param _owner the address which owns this contract (will be the user in this case)
      * @param _startDate the date from which this subscription should start
      * @param _planHash a reference to the plan they would like to subscribe to
      * @param _data any extra data they'd like to store
    */

    function createSubscription(
        address _owner,
        bytes32 _planHash,
        uint _startDate,
        string _data
    )
        public
        returns (bytes32 _newSubscriptionHash)
    {
        require(_owner != 0x0);
        require(_startDate >= block.timestamp);

        uint planInterval = PLAN_CONTRACT.getPlanInterval(_planHash);
        uint planAmount = PLAN_CONTRACT.getPlanAmount(_planHash);

        bytes32 newSubscriptionHash = keccak256(_owner, _planHash);

        require(subscriptions[newSubscriptionHash].owner == 0x0);
        require(planInterval > 0); // If an invalid hash isn't provided then it will be 0
        require(planAmount > 0); // If an invalid hash isn't provided then it will be 0

        Subscription memory newSubscription = Subscription({
            owner: _owner, 
            planHash: _planHash, 
            startDate: _startDate, 
            terminationDate: 0,
            interval: planInterval,
            amount: planAmount,
            data: _data
        });

        subscriptions[newSubscriptionHash] = newSubscription;

        emit Created(newSubscriptionHash);

        return newSubscriptionHash;
    }

    /** @dev Updates the contract plan
      * @param _plan the address which they want to update it to
    */

    function setPlan(address _plan) 
        onlyOwner
        public {
        PLAN_CONTRACT = Plans(_plan);
    }

    /** @dev Updates the data field which can be used to store anything extra
      * @param _subscription is the hash of the user's address + identifier
      * @param _data the data which they want to update it to
    */

    function setSubscriptionData(bytes32 _subscription, string _data) 
        isOwnerOfSubscription(_subscription)
        shouldEmitChanges(_subscription)
        public {
        subscriptions[_subscription].data = _data;
    }

     /** @dev Get the termination date for the subscription
      * @param _subscription is the hash of the user's address + identifier
    */

    function getSubscriptionTerminationDate(bytes32 _subscription)
        public
        view 
        returns (uint _terminationDate) {
        return subscriptions[_subscription].terminationDate;
    }
    
    /** @dev Get the extra data for the plan
      * @param _subscription is the hash of the user's address + identifier
    */

    function getSubscriptionData(bytes32 _subscription)
        public
        view 
        returns (string _data) {
        return subscriptions[_subscription].data;
    }

    /**
      * Internal functions
    */

    /**
      * Private functions
    */

}