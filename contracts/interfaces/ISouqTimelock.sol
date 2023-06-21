// SPDX-License-Identifier: BUSL
pragma solidity 0.8.10;

/**
 * @title ISouqTimelock
 * @author Souq.Finance
 * @notice Defines the interface of the timelock contract
 * @notice License: https://souq-nft-amm-v1.s3.amazonaws.com/LICENSE.md
 */

interface ISouqTimelock {
    function queueTransaction(
        address target,
        uint value,
        string calldata signature,
        bytes calldata data,
        uint eta
    ) external returns (bytes32);

    function cancelTransaction(address target, uint value, string calldata signature, bytes calldata data, uint eta) external;

    function executeTransaction(
        address target,
        uint value,
        string calldata signature,
        bytes calldata data,
        uint eta
    ) external payable returns (bytes memory);

    function setPendingAdmin(address pendingAdmin_) external;
}
