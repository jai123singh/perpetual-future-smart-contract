// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

struct Data {
    int256 perpPrice;
    int256 correspondingTime;
}

struct CircularVector {
    Data[10] data;
    uint8 currentIndex;
}

library CircularVectorLib {
    function push(
        CircularVector storage self,
        int256 perpPrice,
        int256 correspondingTime
    ) internal {
        self.data[self.currentIndex] = Data(perpPrice, correspondingTime);
        if (self.currentIndex < 9) {
            self.currentIndex++;
        } else {
            self.currentIndex = 0;
        }
    }

    function getPerpPriceVectorAndTimestampVector(
        CircularVector storage self
    )
        internal
        view
        returns (
            int256[10] memory perpPriceVector,
            int256[10] memory timestampVector
        )
    {
        for (uint256 i = 0; i < 10; i++) {
            perpPriceVector[i] = self.data[i].perpPrice;
            if (i == 0) {
                timestampVector[i] =
                    int256(block.timestamp) -
                    self.data[i].correspondingTime;
            } else {
                timestampVector[i] =
                    self.data[i - 1].correspondingTime -
                    self.data[i].correspondingTime;
            }
        }
        return (perpPriceVector, timestampVector);
    }
}
