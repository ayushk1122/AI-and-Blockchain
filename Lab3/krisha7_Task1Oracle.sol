pragma solidity >=0.4.21 <0.6.0;

contract Task1Oracle {
    Request[] requests; //list of requests made to the contract
    uint currentId = 0; //increasing request id
    uint minQuorum = 3; //minimum number of responses to receive before declaring final result
    uint totalOracleCount = 5; // Hardcoded oracle count

    // defines a general api request
    struct Request {
        uint id;                            //request id
        string urlToQuery;                  //API url
        string attributeToFetch;            //json attribute (key) to retrieve in the response
        string agreedValue;                 //value from key
        mapping(uint => string) answers;    //answers provided by the oracles
        mapping(address => uint) quorum;    //oracles which will query the answer (1=oracle hasn't voted, 2=oracle has voted)
    }

    //event that triggers oracle outside of the blockchain
    event NewRequest (
        uint id,
        string urlToQuery,
        string attributeToFetch
    );

    //triggered when there's a consensus on the final result
    event UpdatedRequest (
        uint id,
        string urlToQuery,
        string attributeToFetch,
        string agreedValue
    );

    function createRequest(
        string memory _urlToQuery,
        string memory _attributeToFetch
    )
        public
    {
        requests.push(Request(currentId, _urlToQuery, _attributeToFetch, ""));
        uint length = requests.length;
        Request storage r = requests[length-1];

        // Hardcoded oracles address
        r.quorum[address(0x6c2339b46F41a06f09CA0051ddAD54D1e582bA77)] = 1;
        r.quorum[address(0xb5346CF224c02186606e5f89EACC21eC25398077)] = 1;
        r.quorum[address(0xa2997F1CA363D11a0a35bB1Ac0Ff7849bc13e914)] = 1;

        // launch an event to be detected by oracle outside of blockchain
        emit NewRequest(
            currentId,
            _urlToQuery,
            _attributeToFetch
        );

        // increase request id
        currentId++;
    }

    //called by the oracle to record its answer
    function updateRequest(
        uint _id,
        string memory _valueRetrieved
    ) 
        public 
    {
        Request storage currRequest = requests[_id];

        //check if oracle is in the list of trusted oracles
        //and if the oracle hasn't voted yet
        if(currRequest.quorum[address(msg.sender)] == 1) {

            //marking that this address has voted
            currRequest.quorum[msg.sender] = 2;

            //iterate through "array" of answers until a position is free and save the retrieved value
            uint tmpI = 0;
            bool found = false;
            while(!found) {
                //find first empty slot
                if(bytes(currRequest.answers[tmpI]).length == 0) {
                    found = true;
                    currRequest.answers[tmpI] = _valueRetrieved;
                }
                tmpI++;
            }

            uint[] memory values = new uint[](totalOracleCount);
            uint valueCount = 0;
            uint currentQuorum = 0;

            //iterate through oracle list and check if enough oracles (minimum quorum)
            //have voted the same answer as the current one
            for(uint i = 0; i < totalOracleCount; i++) {
                if(bytes(currRequest.answers[i]).length != 0) {
                    uint numericAnswer = stringToUint(currRequest.answers[i]);
                    // Assume 0 is not a valid answer or indicative of error in conversion
                    if(numericAnswer != 0) {
                        values[valueCount] = numericAnswer;
                        valueCount++;
                    }
                }
                bytes memory a = bytes(currRequest.answers[i]);
                bytes memory b = bytes(_valueRetrieved);

                if(keccak256(a) == keccak256(b)) {
                    currentQuorum++;
                }
            }

            if(currentQuorum >= minQuorum) {
                // calculate the median of the collected values
                uint medianValue = calculateMedian(values, valueCount);
                currRequest.agreedValue = uintToString(medianValue);
                emit UpdatedRequest (
                    currRequest.id,
                    currRequest.urlToQuery,
                    currRequest.attributeToFetch,
                    currRequest.agreedValue
                );
            }
        }
    }

    // Helper function to convert string to uint
    function stringToUint(string memory s) internal pure returns (uint) {
        bytes memory b = bytes(s);
        uint result = 0;
        for (uint i = 0; i < b.length; i++) {
            if (b[i] >= 0x30 && b[i] <= 0x39) {
                result = result * 10 + (uint8(b[i]) - 0x30);
            }
        }
        return result;
    }

    // Helper function to convert uint to string
    function uintToString(uint v) internal pure returns (string memory) {
        if (v == 0) {
            return "0";
        }
        uint j = v;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (v != 0) {
            bstr[k--] = byte(uint8(48 + v % 10));
            v /= 10;
        }
        return string(bstr);
    }

    // Helper function to calculate the median value of an array of uints
    function calculateMedian(uint[] memory array, uint length) internal pure returns(uint) {
        // First we sort the array
        sort(array, 0, length - 1);
        uint middleIndex = length / 2;
        // If there are an odd number of elements, return the middle one
        if(length % 2 != 0) {
            return array[middleIndex];
        } else {
            // If there are an even number of elements, return the average of the middle two
            return (array[middleIndex] + array[middleIndex - 1]) / 2;
        }
    }

    // Helper function to perform a quicksort on an array of uints
    function sort(uint[] memory arr, uint left, uint right) internal pure {
        uint i = left;
        uint j = right;
        if (i == j) return;
        uint pivot = arr[left + (right - left) / 2];
        while (i <= j) {
            while (arr[i] < pivot) i++;
            while (pivot < arr[j]) j--;
            if (i <= j) {
                (arr[i], arr[j]) = (arr[j], arr[i]);
                i++;
                j--;
            }
        }
        if (left < j)
            sort(arr, left, j);
        if (i < right)
            sort(arr, i, right);
    }
}

