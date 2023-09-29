// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.10;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {ICollectionConnector} from "../interfaces/ICollectionConnector.sol";
import {ISVSCollectionConnector} from "../interfaces/ISVSCollectionConnector.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Errors} from "../libraries/Errors.sol";
import {IAddressesRegistry} from "../interfaces/IAddressesRegistry.sol";
import {IAccessManager} from "../interfaces/IAccessManager.sol";
import {IVault1155} from "../interfaces/IVault1155.sol";
import {IVaultBase} from "../interfaces/IVaultBase.sol";

/**
 * @title SVSCollectionConnector
 * @author Souq.Finance
 * @notice The ERC1155 Collection Connector
 * @notice License: https://souq-peripherals.s3.amazonaws.com/LICENSE.md
 */
contract SVSCollectionConnector is ISVSCollectionConnector, Initializable, OwnableUpgradeable, UUPSUpgradeable {
    uint256 public version;
    address public addressesRegistry;
    //attributes mapping to convert token ids or subpool ids to a rarity score or maturity etc if it needs manual setting
    mapping(address => mapping(uint256 => uint256)) internal attributes;

    /// @inheritdoc ICollectionConnector
    function initialize(address _addressesRegistry) external initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();
        require(_addressesRegistry != address(0), Errors.ADDRESS_IS_ZERO);
        addressesRegistry = _addressesRegistry;
        version = 1;
    }

    /**
     * @dev modifier for when the the msg sender has the connector admin role in access manager
     */
    modifier onlyAdmin() {
        require(
            IAccessManager(IAddressesRegistry(addressesRegistry).getAccessManager()).isConnectorAdmin(msg.sender),
            Errors.ADDRESS_NOT_CONNECTOR_ADMIN
        );
        _;
    }

    /// @inheritdoc ICollectionConnector
    function getAttribute(address collection, uint256 _id) external view returns (uint256) {
        return IVault1155(collection).getLockupStart(_id);
    }

    /// @inheritdoc ICollectionConnector
    function getAttributeLocal(address collection, uint256 _id) external view returns (uint256) {
        return attributes[collection][_id];
    }

    /// @inheritdoc ICollectionConnector
    function setAttribute(address collection, uint256 _id, uint256 _attribute) external onlyAdmin {
        require(collection != address(0), Errors.ADDRESS_IS_ZERO);
        attributes[collection][_id] = _attribute;
    }

    /// @inheritdoc ICollectionConnector
    function setAttributeBatch(address collection, uint256[] calldata _ids, uint256[] calldata _attributes) external onlyAdmin {
        require(_ids.length == _attributes.length, Errors.ARRAY_NOT_SAME_LENGTH);
        require(collection != address(0), Errors.ADDRESS_IS_ZERO);
        for (uint256 i = 0; i < _ids.length; ++i) {
            attributes[collection][_ids[i]] = _attributes[i];
        }
    }

    /// @inheritdoc ICollectionConnector
    function getBalance(address _add, uint256 _id, address _account) external view returns (uint256) {
        return IERC1155(_add).balanceOf(_account, _id);
    }

    /// @inheritdoc ICollectionConnector
    function getApproved(address _add, address _account) external view returns (bool) {
        return IERC1155(_add).isApprovedForAll(_account, msg.sender);
    }

    /// @inheritdoc ICollectionConnector
    function transfer(address _add, address _account, uint256 _id, uint256 _amount) external {
        IERC1155(_add).safeTransferFrom(_account, msg.sender, _id, _amount, bytes(""));
    }

    /// @inheritdoc ICollectionConnector
    function transferBatch(address _add, address _account, uint256[] calldata _ids, uint256[] calldata _amounts) external {
        IERC1155(_add).safeBatchTransferFrom(_account, msg.sender, _ids, _amounts, bytes(""));
    }

    /// @inheritdoc ISVSCollectionConnector
    function getVITs(address collection) external view returns (address[] memory VITs, uint256[] memory amounts) {
        (VITs, amounts) = IVault1155(collection).getVITComposition();
    }

    /// @inheritdoc ISVSCollectionConnector
    function getLockupTimes(address collection) external view returns (uint256[] memory lockupTimes) {
        lockupTimes = IVaultBase(collection).getLockupTimes();
    }

    /// @inheritdoc ISVSCollectionConnector
    function getLockupTime(address collection, uint256 tokenId) external view returns (uint256) {
        return IVault1155(collection).getLockupTime(tokenId);
    }

    /**
     * @dev Internal function to permit the upgrade of the proxy.
     * @param newImplementation The new implementation contract address used for the upgrade.
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {
        require(newImplementation != address(0), Errors.ADDRESS_IS_ZERO);
        ++version;
    }
}
