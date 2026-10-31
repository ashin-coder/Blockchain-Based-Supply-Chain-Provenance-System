// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ISupplyChain} from "./interfaces/ISupplyChain.sol";

/// @title SupplyChain (draft)
/// @notice Records each product's journey on-chain with role-based access.
/// @dev Implemented: onboarding, product registration, lookups.
///      Other functions are placeholders that revert with NotImplemented().
contract SupplyChain is ISupplyChain, AccessControl {
    bytes32 public constant PRODUCER_ROLE    = keccak256("PRODUCER_ROLE");
    bytes32 public constant DISTRIBUTOR_ROLE = keccak256("DISTRIBUTOR_ROLE");
    bytes32 public constant RETAILER_ROLE    = keccak256("RETAILER_ROLE");
    bytes32 public constant REGULATOR_ROLE   = keccak256("REGULATOR_ROLE");

    uint256 public productCount;
    mapping(uint256 => Product) private products;
    mapping(uint256 => Checkpoint[]) private history;
    mapping(address => string) public participantNames;

    error ProductNotFound(uint256 productId);
    error NotImplemented();

    modifier exists(uint256 productId) {
        if (productId == 0 || productId > productCount) revert ProductNotFound(productId);
        _;
    }

    /// The deployer is the admin.
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function registerParticipant(address account, bytes32 role, string calldata name)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        _grantRole(role, account);
        participantNames[account] = name;
        emit ParticipantRegistered(account, role, name);
    }

    /// @dev TODO: block duplicate batch IDs.
    function registerProduct(
        string calldata name,
        string calldata batchId,
        string calldata origin,
        bytes32 metadataHash
    ) external onlyRole(PRODUCER_ROLE) returns (uint256 productId) {
        productId = ++productCount;
        products[productId] = Product({
            id: productId,
            name: name,
            batchId: batchId,
            origin: origin,
            producer: msg.sender,
            currentOwner: msg.sender,
            pendingOwner: address(0),
            status: Status.Created,
            metadataHash: metadataHash,
            certified: false,
            createdAt: block.timestamp
        });

        history[productId].push(Checkpoint(Status.Created, msg.sender, origin, block.timestamp));
        emit ProductRegistered(productId, msg.sender, batchId);
    }

    /// @dev TODO: owner only; set InTransit and pendingOwner.
    function shipProduct(uint256 productId, address to, string calldata location) external {
        productId; to; location;
        revert NotImplemented();
    }

    /// @dev TODO: pendingOwner only; transfer ownership, set Received.
    function receiveProduct(uint256 productId, string calldata location) external {
        productId; location;
        revert NotImplemented();
    }

    /// @dev TODO: retailer who owns it; set Delivered.
    function deliverProduct(uint256 productId, string calldata location) external {
        productId; location;
        revert NotImplemented();
    }

    /// @dev TODO: regulator only; mark certified.
    function certifyProduct(uint256 productId, bytes32 certificateHash) external {
        productId; certificateHash;
        revert NotImplemented();
    }

    /// @dev TODO: regulator only; set Recalled (final).
    function recallProduct(uint256 productId, string calldata reason) external {
        productId; reason;
        revert NotImplemented();
    }

    function getProduct(uint256 productId) external view exists(productId) returns (Product memory) {
        return products[productId];
    }

    function getHistory(uint256 productId) external view exists(productId) returns (Checkpoint[] memory) {
        return history[productId];
    }

    /// @dev TODO: certified and not recalled.
    function verifyProduct(uint256 productId) external pure returns (bool) {
        productId;
        revert NotImplemented();
    }

    // Planned: storage stage, IoT sensor readings, IPFS documents.
}
