# Report


## Gas Optimizations


| |Issue|Instances|
|-|:-|:-:|
| [GAS-1](#GAS-1) | Don't use `_msgSender()` if not supporting EIP-2771 | 20 |
| [GAS-2](#GAS-2) | `a = a + b` is more gas effective than `a += b` for state variables (excluding arrays and mappings) | 21 |
| [GAS-3](#GAS-3) | Use assembly to check for `address(0)` | 1 |
| [GAS-4](#GAS-4) | Cache array length outside of loop | 10 |
| [GAS-5](#GAS-5) | State variables should be cached in stack variables rather than re-reading them from storage | 4 |
| [GAS-6](#GAS-6) | Use calldata instead of memory for function arguments that do not get mutated | 7 |
| [GAS-7](#GAS-7) | For Operations that will not overflow, you could use unchecked | 111 |
| [GAS-8](#GAS-8) | Use Custom Errors instead of Revert Strings to save Gas | 1 |
| [GAS-9](#GAS-9) | Functions guaranteed to revert when called by normal users can be marked `payable` | 16 |
| [GAS-10](#GAS-10) | `++i` costs less gas compared to `i++` or `i += 1` (same for `--i` vs `i--` or `i -= 1`) | 12 |
| [GAS-11](#GAS-11) | Increments/decrements can be unchecked in for-loops | 12 |
| [GAS-12](#GAS-12) | Use != 0 instead of > 0 for unsigned integer comparison | 23 |
| [GAS-13](#GAS-13) | `internal` functions not called by the contract should be removed | 11 |
### <a name="GAS-1"></a>[GAS-1] Don't use `_msgSender()` if not supporting EIP-2771
Use `msg.sender` if the code does not implement [EIP-2771 trusted forwarder](https://eips.ethereum.org/EIPS/eip-2771) support

*Instances (20)*:
```solidity
File: ./contracts/core/VoterUpgradeableV2.sol

128:         if (!IVotingEscrowV2(votingEscrow).isApprovedOrOwner(_msgSender(), tokenId_)) {

153:         _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());

380:         if (_msgSender() != minter) {

383:         IERC20Upgradeable(token).safeTransferFrom(_msgSender(), address(this), amount_);

388:         emit NotifyReward(_msgSender(), token, amount_);

504:             IGauge(_gauges[i]).getReward(_msgSender());

528:             IBribe(_bribes[i]).getRewardForAddress(_msgSender(), _tokens[i]);

595:                 require(merkl_.users[i] == _msgSender(), "users containes no only caller");

603:             IVeFnxSplitMerklAidrop(veFnxMerklAidrop).claimFor(_msgSender(), splitMerklAidrop_.amount, splitMerklAidrop_.proofs);

648:                 emit DistributeReward(_msgSender(), gauge_, claimable);

674:         emit GaugeCreated(gauge_, _msgSender(), internalBribe_, externalBribe_, pool_);

754:             emit Voted(_msgSender(), tokenId_, votePowerForPool);

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VoterUpgradeableV2.sol)

```solidity
File: ./contracts/core/VotingEscrowUpgradeableV2.sol

79:         if (!_isApprovedOrOwner(_msgSender(), tokenId_)) {

90:         if (managedNFTManager != _msgSender()) {

174:         IERC20Upgradeable(token).safeTransfer(_msgSender(), LibVotingEscrowUtils.toUint256(state.locked.amount));

210:         emit LockPermanent(_msgSender(), tokenId_);

221:         emit UnlockPermanent(_msgSender(), tokenId_);

256:         if (voter != _msgSender()) {

476:             IERC20Upgradeable(token).safeTransferFrom(_msgSender(), address(this), amount_);

483:         emit Deposit(_msgSender(), tokenId_, amount_, newLocked.end, depositType_, block.timestamp);

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VotingEscrowUpgradeableV2.sol)

### <a name="GAS-2"></a>[GAS-2] `a = a + b` is more gas effective than `a += b` for state variables (excluding arrays and mappings)
This saves **16 gas per instance.**

*Instances (21)*:
```solidity
File: ./contracts/core/VoterUpgradeableV2.sol

386:             index += (amount_ * 1e18) / weightAt;

636:                         gaugesState[gauge_].claimable += amount;

705:                         totalVotePowerForPools += votePowerForPool;

733:             totalVotesWeight += weights_[i];

750:             weightsPerEpoch[time][pool] += votePowerForPool;

751:             totalVoterPower += votePowerForPool;

757:         totalWeightsPerEpoch[time] += totalVoterPower;

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VoterUpgradeableV2.sol)

```solidity
File: ./contracts/core/VotingEscrowUpgradeableV2.sol

208:         permanentTotalSupply += LibVotingEscrowUtils.toUint256(state.locked.amount);

285:         permanentTotalSupply += cAmount;

346:             t_i += WEEK;

357:             last_point.slope += d_slope;

465:         newLocked.amount += LibVotingEscrowUtils.toInt128(boostedValue);

468:         supply += diff;

470:             permanentTotalSupply += amount_;

574:                 t_i += WEEK;

582:                 last_point.slope += d_slope;

594:                 _epoch += 1;

607:             last_point.slope += (u_new.slope - u_old.slope);

608:             last_point.bias += (u_new.bias - u_old.bias);

621:                 oldDslope += u_old.slope;

633:             nftStates[tokenId_].pointEpoch += 1;

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VotingEscrowUpgradeableV2.sol)

### <a name="GAS-3"></a>[GAS-3] Use assembly to check for `address(0)`
*Saves 6 gas per instance*

*Instances (1)*:
```solidity
File: ./contracts/core/VotingEscrowUpgradeableV2.sol

453:         if (address(veBoostCached) != address(0) && shouldBoosted_) {

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VotingEscrowUpgradeableV2.sol)

### <a name="GAS-4"></a>[GAS-4] Cache array length outside of loop
If not cached, the solidity compiler will always read the length of the array during each iteration. That is, if it is a storage array, this is an extra sload operation (100 additional extra gas for each iteration except for the first) and if it is a memory array, this is an extra mload operation (3 additional gas for each iteration except for the first).

*Instances (10)*:
```solidity
File: ./contracts/core/VoterUpgradeableV2.sol

397:         for (uint256 i; i < gauges_.length; i++) {

437:         for (uint256 i; i < gauges_.length; i++) {

503:         for (uint256 i; i < _gauges.length; i++) {

516:         for (uint256 i; i < _bribes.length; i++) {

527:         for (uint256 i; i < _bribes.length; i++) {

594:             for (uint256 i; i < merkl_.users.length; ) {

615:         for (uint256 i; i < _poolVote.length; ) {

694:         for (uint256 i; i < votesPools.length; i++) {

728:         for (uint256 i; i < pools_.length; i++) {

737:         for (uint256 i; i < pools_.length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VoterUpgradeableV2.sol)

### <a name="GAS-5"></a>[GAS-5] State variables should be cached in stack variables rather than re-reading them from storage
The instances below point to the second+ access of a state variable within a function. Caching of a state variable replaces each Gwarmaccess (100 gas) with a much cheaper stack read. Other less obvious fixes/optimizations include having local memory caches of state variable structs, or having local caches of state variable contracts/addresses.

*Saves 100 gas per instance*

*Instances (4)*:
```solidity
File: ./contracts/core/VoterUpgradeableV2.sol

388:         emit NotifyReward(_msgSender(), token, amount_);

647:                 IGauge(gauge_).notifyRewardAmount(token, claimable);

756:         if (totalVoterPower > 0) IVotingEscrowV2(votingEscrow).votingHook(tokenId_, true);

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VoterUpgradeableV2.sol)

```solidity
File: ./contracts/core/VotingEscrowUpgradeableV2.sol

479:                 IERC20Upgradeable(token).safeTransferFrom(address(veBoostCached), address(this), boostedValue);

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VotingEscrowUpgradeableV2.sol)

### <a name="GAS-6"></a>[GAS-6] Use calldata instead of memory for function arguments that do not get mutated
When a function with a `memory` array is called externally, the `abi.decode()` step has to use a for-loop to copy each index of the `calldata` to the `memory` index. Each iteration of this for-loop costs at least 60 gas (i.e. `60 * <mem_array>.length`). Using `calldata` directly bypasses this loop. 

If the array is passed to an `internal` function which passes the array to another internal function where the array is modified and therefore `memory` is used in the `external` call, it's still more gas-efficient to use `calldata` when the `external` function uses modifiers, since the modifiers may prevent the internal functions from being called. Structs have the same overhead as an array of length one. 

 *Saves 60 gas per instance*

*Instances (7)*:
```solidity
File: ./contracts/core/VoterUpgradeableV2.sol

168:     function updateAddress(string memory key_, address value_) external onlyRole(_VOTER_ADMIN_ROLE) {

357:         string memory externalBribesName_,

358:         string memory internalBribesName_

502:     function claimRewards(address[] memory _gauges) public {

515:     function claimBribes(address[] memory _bribes, address[][] memory _tokens, uint256 tokenId_) public onlyNftApprovedOrOwner(tokenId_) {

526:     function claimBribes(address[] memory _bribes, address[][] memory _tokens) public {

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VoterUpgradeableV2.sol)

```solidity
File: ./contracts/core/VotingEscrowUpgradeableV2.sol

227:     function updateAddress(string memory key_, address value_) external onlyOwner {

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VotingEscrowUpgradeableV2.sol)

### <a name="GAS-7"></a>[GAS-7] For Operations that will not overflow, you could use unchecked

*Instances (111)*:
```solidity
File: ./contracts/core/VoterUpgradeableV2.sol

4: import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

5: import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

6: import {SafeERC20Upgradeable, IERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

7: import {IERC20MetadataUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";

8: import {IAlgebraFactory} from "@cryptoalgebra/integral-core/contracts/interfaces/IAlgebraFactory.sol";

9: import {BlastGovernorClaimableSetup} from "../integration/BlastGovernorClaimableSetup.sol";

10: import {IPairIntegrationInfo} from "../integration/interfaces/IPairIntegrationInfo.sol";

11: import {IVotingEscrowV2} from "./interfaces/IVotingEscrowV2.sol";

12: import {IPairFactory} from "../dexV2/interfaces/IPairFactory.sol";

13: import {IGaugeFactory} from "../gauges/interfaces/IGaugeFactory.sol";

14: import {IBribeFactory} from "../bribes/interfaces/IBribeFactory.sol";

15: import {IMinter} from "./interfaces/IMinter.sol";

16: import {IVoterV2} from "./interfaces/IVoterV2.sol";

17: import {IVeFnxSplitMerklAidrop} from "./interfaces/IVeFnxSplitMerklAidrop.sol";

18: import {IMerklDistributor} from "../integration/interfaces/IMerklDistributor.sol";

19: import {IManagedNFTManager} from "../nest/interfaces/IManagedNFTManager.sol";

20: import {IBribe} from "../bribes/interfaces/IBribe.sol";

21: import {IGauge} from "../gauges/interfaces/IGauge.sol";

22: import "./libraries/LibVoterErrors.sol";

239:         totalWeightsPerEpoch[epochTimestamp] -= weightsPerEpoch[epochTimestamp][state.pool];

320:         string memory symbol = string.concat(IERC20MetadataUpgradeable(token0).symbol(), "/", IERC20MetadataUpgradeable(token1).symbol());

384:         uint256 weightAt = totalWeightsPerEpoch[_epochTimestamp() - _WEEK]; // minter call notify after updates active_period, loads votes - 1 week

386:             index += (amount_ * 1e18) / weightAt;

397:         for (uint256 i; i < gauges_.length; i++) {

412:         for (uint256 i; i < length; i++) {

425:         for (uint256 i = start_; i < finish_; i++) {

437:         for (uint256 i; i < gauges_.length; i++) {

503:         for (uint256 i; i < _gauges.length; i++) {

516:         for (uint256 i; i < _bribes.length; i++) {

527:         for (uint256 i; i < _bribes.length; i++) {

597:                     i++;

618:                 i++;

630:             uint256 totalVotesWeight = weightsPerEpoch[currentTimestamp - _WEEK][state.pool];

632:                 uint256 delta = index - state.index;

634:                     uint256 amount = (totalVotesWeight * delta) / 1e18;

636:                         gaugesState[gauge_].claimable += amount;

694:         for (uint256 i; i < votesPools.length; i++) {

700:                     weightsPerEpoch[time][pool] -= votePowerForPool;

705:                         totalVotePowerForPools += votePowerForPool;

712:             totalWeightsPerEpoch[time] -= totalVotePowerForPools;

728:         for (uint256 i; i < pools_.length; i++) {

733:             totalVotesWeight += weights_[i];

737:         for (uint256 i; i < pools_.length; i++) {

740:             uint256 votePowerForPool = (weights_[i] * nftVotePower) / totalVotesWeight;

750:             weightsPerEpoch[time][pool] += votePowerForPool;

751:             totalVoterPower += votePowerForPool;

757:         totalWeightsPerEpoch[time] += totalVoterPower;

765:         lastVotedTimestamps[tokenId_] = _epochTimestamp() + 1;

781:         if (block.timestamp <= (block.timestamp - (block.timestamp % _WEEK) + distributionWindowDuration)) {

791:         if (block.timestamp >= (block.timestamp - (block.timestamp % _WEEK) + _WEEK - distributionWindowDuration)) {

802:         if (block.timestamp < lastVotedTimestamps[tokenId_] + voteDelay) {

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VoterUpgradeableV2.sol)

```solidity
File: ./contracts/core/VotingEscrowUpgradeableV2.sol

4: import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";

5: import "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";

6: import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

7: import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

8: import "../integration/BlastGovernorClaimableSetup.sol";

9: import "../nest/interfaces/IManagedNFTManager.sol";

10: import "./interfaces/IVotingEscrowV2.sol";

11: import "./interfaces/IVeArtProxyUpgradeable.sol";

12: import "./interfaces/IVeBoost.sol";

13: import "./libraries/LibVotingEscrowValidation.sol";

14: import "./libraries/LibVotingEscrowErrors.sol";

15: import "./libraries/LibVotingEscrowConstants.sol";

16: import "./libraries/LibVotingEscrowUtils.sol";

160:         uint256 unlockTimestamp = LibVotingEscrowUtils.roundToWeek(block.timestamp + lockDuration_);

208:         permanentTotalSupply += LibVotingEscrowUtils.toUint256(state.locked.amount);

219:         permanentTotalSupply -= LibVotingEscrowUtils.toUint256(state.locked.amount);

247:         managedNftId = ++lastMintedTokenId;

280:             permanentTotalSupply -= cAmount;

285:         permanentTotalSupply += cAmount;

287:         _updateNftLocked(managedTokenId_, LockedBalance(oldLocked.amount + amount, oldLocked.end, oldLocked.isPermanentLocked));

307:         permanentTotalSupply -= (newBalance_ < permanentTotalSupply ? newBalance_ : permanentTotalSupply);

312:         newManagedLocked.amount -= amount < newManagedLocked.amount ? amount : newManagedLocked.amount;

344:         uint256 t_i = (last_point.ts / WEEK) * WEEK;

345:         for (uint256 i; i < 255; ++i) {

346:             t_i += WEEK;

353:             last_point.bias -= last_point.slope * int128(int256(t_i - last_point.ts));

357:             last_point.slope += d_slope;

364:         return LibVotingEscrowUtils.toUint256(last_point.bias + last_point.permanent);

410:         uint256 unlockTimestamp = LibVotingEscrowUtils.roundToWeek(block.timestamp + lockDuration_);

414:         uint256 newTokenId = ++lastMintedTokenId;

446:             oldLocked_.amount + LibVotingEscrowUtils.toInt128(amount_),

456:                     (LibVotingEscrowUtils.roundToWeek(block.timestamp + veBoostCached.getMinLockedTimeForBoost()) <= newLocked.end ||

465:         newLocked.amount += LibVotingEscrowUtils.toInt128(boostedValue);

466:         uint256 diff = LibVotingEscrowUtils.toUint256(newLocked.amount - oldLocked_.amount);

468:         supply += diff;

470:             permanentTotalSupply += amount_;

484:         emit Supply(supplyBefore, supplyBefore + diff);

510:         supply -= amount;

513:         emit Supply(supplyBefore, supplyBefore - amount);

542:                 u_old.slope = oldLocked_.amount / I128_MAX_LOCK_TIME;

543:                 u_old.bias = u_old.slope * LibVotingEscrowUtils.toInt128(oldLocked_.end - block.timestamp);

546:                 u_new.slope = newLocked_.amount / I128_MAX_LOCK_TIME;

547:                 u_new.bias = u_new.slope * LibVotingEscrowUtils.toInt128(newLocked_.end - block.timestamp);

565:         uint256 block_slope; // dblock/dt

567:             block_slope = (1e18 * (block.number - last_point.blk)) / (block.timestamp - last_point.ts);

571:             for (uint256 i; i < 255; ++i) {

574:                 t_i += WEEK;

581:                 last_point.bias -= last_point.slope * int128(int256(t_i - last_checkpoint));

582:                 last_point.slope += d_slope;

593:                 last_point.blk = initial_last_point.blk + (block_slope * (t_i - initial_last_point.ts)) / 1e18;

594:                 _epoch += 1;

607:             last_point.slope += (u_new.slope - u_old.slope);

608:             last_point.bias += (u_new.bias - u_old.bias);

621:                 oldDslope += u_old.slope;

623:                     oldDslope -= u_new.slope; // It was a new deposit, not extension

629:                     newDslope -= u_new.slope; // old slope disappeared at this point

633:             nftStates[tokenId_].pointEpoch += 1;

654:             lastPoint.bias -= lastPoint.slope * int128(int256(timestamp_) - int256(lastPoint.ts));

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VotingEscrowUpgradeableV2.sol)

```solidity
File: ./contracts/core/libraries/LibVotingEscrowValidation.sol

4: import "../interfaces/IVotingEscrowV2.sol";

5: import "./LibVotingEscrowErrors.sol";

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/libraries/LibVotingEscrowValidation.sol)

### <a name="GAS-8"></a>[GAS-8] Use Custom Errors instead of Revert Strings to save Gas
Custom errors are available from solidity version 0.8.4. Custom errors save [**~50 gas**](https://gist.github.com/IllIllI000/ad1bd0d29a0101b25e57c293b4b0c746) each time they're hit by [avoiding having to allocate and store the revert string](https://blog.soliditylang.org/2021/04/21/custom-errors/#errors-in-depth). Not defining the strings also save deployment gas

Additionally, custom errors can be used inside and outside of contracts (including interfaces and libraries).

Source: <https://blog.soliditylang.org/2021/04/21/custom-errors/>:

> Starting from [Solidity v0.8.4](https://github.com/ethereum/solidity/releases/tag/v0.8.4), there is a convenient and gas-efficient way to explain to users why an operation failed through the use of custom errors. Until now, you could already use strings to give more information about failures (e.g., `revert("Insufficient funds.");`), but they are rather expensive, especially when it comes to deploy cost, and it is difficult to use dynamic information in them.

Consider replacing **all revert strings** with custom errors in the solution, and particularly those that have multiple occurrences:

*Instances (1)*:
```solidity
File: ./contracts/core/VoterUpgradeableV2.sol

595:                 require(merkl_.users[i] == _msgSender(), "users containes no only caller");

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VoterUpgradeableV2.sol)

### <a name="GAS-9"></a>[GAS-9] Functions guaranteed to revert when called by normal users can be marked `payable`
If a function modifier such as `onlyOwner` is used, the function will revert if a normal user tries to pay the function. Marking the function as `payable` will lower the gas cost for legitimate callers because the compiler will not include checks for whether a payment was provided.

*Instances (16)*:
```solidity
File: ./contracts/core/VoterUpgradeableV2.sol

168:     function updateAddress(string memory key_, address value_) external onlyRole(_VOTER_ADMIN_ROLE) {

200:     function setDistributionWindowDuration(uint256 distributionWindowDuration_) external onlyRole(_VOTER_ADMIN_ROLE) {

212:     function setVoteDelay(uint256 newVoteDelay_) external onlyRole(_VOTER_ADMIN_ROLE) {

227:     function killGauge(address gauge_) external onlyRole(_GOVERNANCE_ROLE) {

250:     function reviveGauge(address gauge_) external onlyRole(_GOVERNANCE_ROLE) {

447:     function reset(uint256 tokenId_) external nonReentrant onlyNftApprovedOrOwner(tokenId_) {

460:     function poke(uint256 tokenId_) external nonReentrant onlyNftApprovedOrOwner(tokenId_) {

515:     function claimBribes(address[] memory _bribes, address[][] memory _tokens, uint256 tokenId_) public onlyNftApprovedOrOwner(tokenId_) {

539:     function attachToManagedNFT(uint256 tokenId_, uint256 managedTokenId_) external nonReentrant onlyNftApprovedOrOwner(tokenId_) {

553:     function dettachFromManagedNFT(uint256 tokenId_) external nonReentrant onlyNftApprovedOrOwner(tokenId_) {

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VoterUpgradeableV2.sol)

```solidity
File: ./contracts/core/VotingEscrowUpgradeableV2.sol

157:     function increase_unlock_time(uint256 tokenId_, uint256 lockDuration_) external override nonReentrant onlyNftApprovedOrOwner(tokenId_) {

170:     function withdraw(uint256 tokenId_) external override nonReentrant onlyNftApprovedOrOwner(tokenId_) {

205:     function lockPermanent(uint256 tokenId_) external override nonReentrant onlyNftApprovedOrOwner(tokenId_) {

216:     function unlockPermanent(uint256 tokenId_) external override nonReentrant onlyNftApprovedOrOwner(tokenId_) {

227:     function updateAddress(string memory key_, address value_) external onlyOwner {

246:     function createManagedNFT(address recipient_) external override onlyManagedNFTManager returns (uint256 managedNftId) {

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VotingEscrowUpgradeableV2.sol)

### <a name="GAS-10"></a>[GAS-10] `++i` costs less gas compared to `i++` or `i += 1` (same for `--i` vs `i--` or `i -= 1`)
Pre-increments and pre-decrements are cheaper.

For a `uint256 i` variable, the following is true with the Optimizer enabled at 10k:

**Increment:**

- `i += 1` is the most expensive form
- `i++` costs 6 gas less than `i += 1`
- `++i` costs 5 gas less than `i++` (11 gas less than `i += 1`)

**Decrement:**

- `i -= 1` is the most expensive form
- `i--` costs 11 gas less than `i -= 1`
- `--i` costs 5 gas less than `i--` (16 gas less than `i -= 1`)

Note that post-increments (or post-decrements) return the old value before incrementing or decrementing, hence the name *post-increment*:

```solidity
uint i = 1;  
uint j = 2;
require(j == i++, "This will be false as i is incremented after the comparison");
```
  
However, pre-increments (or pre-decrements) return the new value:
  
```solidity
uint i = 1;  
uint j = 2;
require(j == ++i, "This will be true as i is incremented before the comparison");
```

In the pre-increment case, the compiler has to create a temporary variable (when used) for returning `1` instead of `2`.

Consider using pre-increments and pre-decrements where they are relevant (meaning: not where post-increments/decrements logic are relevant).

*Saves 5 gas per instance*

*Instances (12)*:
```solidity
File: ./contracts/core/VoterUpgradeableV2.sol

397:         for (uint256 i; i < gauges_.length; i++) {

412:         for (uint256 i; i < length; i++) {

425:         for (uint256 i = start_; i < finish_; i++) {

437:         for (uint256 i; i < gauges_.length; i++) {

503:         for (uint256 i; i < _gauges.length; i++) {

516:         for (uint256 i; i < _bribes.length; i++) {

527:         for (uint256 i; i < _bribes.length; i++) {

597:                     i++;

618:                 i++;

694:         for (uint256 i; i < votesPools.length; i++) {

728:         for (uint256 i; i < pools_.length; i++) {

737:         for (uint256 i; i < pools_.length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VoterUpgradeableV2.sol)

### <a name="GAS-11"></a>[GAS-11] Increments/decrements can be unchecked in for-loops
In Solidity 0.8+, there's a default overflow check on unsigned integers. It's possible to uncheck this in for-loops and save some gas at each iteration, but at the cost of some code readability, as this uncheck cannot be made inline.

[ethereum/solidity#10695](https://github.com/ethereum/solidity/issues/10695)

The change would be:

```diff
- for (uint256 i; i < numIterations; i++) {
+ for (uint256 i; i < numIterations;) {
 // ...  
+   unchecked { ++i; }
}  
```

These save around **25 gas saved** per instance.

The same can be applied with decrements (which should use `break` when `i == 0`).

The risk of overflow is non-existent for `uint256`.

*Instances (12)*:
```solidity
File: ./contracts/core/VoterUpgradeableV2.sol

397:         for (uint256 i; i < gauges_.length; i++) {

412:         for (uint256 i; i < length; i++) {

425:         for (uint256 i = start_; i < finish_; i++) {

437:         for (uint256 i; i < gauges_.length; i++) {

503:         for (uint256 i; i < _gauges.length; i++) {

516:         for (uint256 i; i < _bribes.length; i++) {

527:         for (uint256 i; i < _bribes.length; i++) {

694:         for (uint256 i; i < votesPools.length; i++) {

728:         for (uint256 i; i < pools_.length; i++) {

737:         for (uint256 i; i < pools_.length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VoterUpgradeableV2.sol)

```solidity
File: ./contracts/core/VotingEscrowUpgradeableV2.sol

345:         for (uint256 i; i < 255; ++i) {

571:             for (uint256 i; i < 255; ++i) {

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VotingEscrowUpgradeableV2.sol)

### <a name="GAS-12"></a>[GAS-12] Use != 0 instead of > 0 for unsigned integer comparison

*Instances (23)*:
```solidity
File: ./contracts/core/VoterUpgradeableV2.sol

233:         if (state.claimable > 0) {

385:         if (weightAt > 0) {

584:         if (gauges_.length > 0) {

587:         if (bribes_.bribes.length > 0) {

590:         if (bribesByTokenId_.bribes.length > 0) {

593:         if (merkl_.users.length > 0) {

602:         if (splitMerklAidrop_.amount > 0) {

631:             if (totalVotesWeight > 0) {

633:                 if (delta > 0) {

644:             if (claimable > 0 && state.isAlive) {

697:             if (votePowerForPool > 0) {

744:             if (votes[tokenId_][pool] > 0) {

756:         if (totalVoterPower > 0) IVotingEscrowV2(votingEscrow).votingHook(tokenId_, true);

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VoterUpgradeableV2.sol)

```solidity
File: ./contracts/core/VotingEscrowUpgradeableV2.sol

475:         if (amount_ > 0 && depositType_ != DepositType.MERGE_TYPE) {

477:             if (boostedValue > 0) {

539:         if (tokenId_ > 0) {

541:             if (oldLocked_.end > block.timestamp && oldLocked_.amount > 0) {

545:             if (newLocked_.end > block.timestamp && newLocked_.amount > 0) {

560:         if (_epoch > 0) {

604:         if (tokenId_ > 0) {

618:         if (tokenId_ > 0) {

649:         if (pointEpoch > 0) {

651:             if (lastPoint.permanent > 0) {

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VotingEscrowUpgradeableV2.sol)

### <a name="GAS-13"></a>[GAS-13] `internal` functions not called by the contract should be removed
If the functions are required by an interface, the contract should inherit from that interface and use the `override` keyword

*Instances (11)*:
```solidity
File: ./contracts/core/libraries/LibVotingEscrowValidation.sol

17:     function withdrawCheck(IVotingEscrowV2.TokenState memory self_) internal view {

41:     function increaseUnlockCheck(IVotingEscrowV2.TokenState memory self_) internal view {

53:     function depositCheck(IVotingEscrowV2.TokenState memory self_) internal view {

64:     function transferCheck(IVotingEscrowV2.TokenState memory self_) internal pure {

74:     function mergeCheckFrom(IVotingEscrowV2.TokenState memory self_) internal view {

86:     function mergeCheckTo(IVotingEscrowV2.TokenState memory self_) internal view {

96:     function lockPermanentCheck(IVotingEscrowV2.TokenState memory self_) internal view {

108:     function unlockPermanentCheck(IVotingEscrowV2.TokenState memory self_) internal pure {

119:     function attachToManagedNftCheck(IVotingEscrowV2.TokenState memory self_) internal view {

130:     function dettachFromManagedNftCheck(IVotingEscrowV2.TokenState memory self_) internal pure {

217:     function checkNoValueZero(uint256 value_) internal pure {

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/libraries/LibVotingEscrowValidation.sol)


## Non Critical Issues


| |Issue|Instances|
|-|:-|:-:|
| [NC-1](#NC-1) | Missing checks for `address(0)` when assigning values to address state variables | 16 |
| [NC-2](#NC-2) | Array indices should be referenced via `enum`s rather than via numeric literals | 2 |
| [NC-3](#NC-3) | Use `string.concat()` or `bytes.concat()` instead of `abi.encodePacked` | 2 |
| [NC-4](#NC-4) | `constant`s should be defined rather than using magic numbers | 3 |
| [NC-5](#NC-5) | Control structures do not follow the Solidity Style Guide | 10 |
| [NC-6](#NC-6) | Events that mark critical parameter changes should contain both the old and the new value | 4 |
| [NC-7](#NC-7) | Function ordering does not follow the Solidity style guide | 2 |
| [NC-8](#NC-8) | Functions should not be longer than 50 lines | 64 |
| [NC-9](#NC-9) | Change int to int256 | 9 |
| [NC-10](#NC-10) | Lack of checks in setters | 4 |
| [NC-11](#NC-11) | Missing Event for critical parameters change | 1 |
| [NC-12](#NC-12) | Incomplete NatSpec: `@param` is missing on actually documented functions | 14 |
| [NC-13](#NC-13) | Incomplete NatSpec: `@return` is missing on actually documented functions | 4 |
| [NC-14](#NC-14) | Consider using named mappings | 3 |
| [NC-15](#NC-15) | Adding a `return` statement when the function defines a named return variable, is redundant | 2 |
| [NC-16](#NC-16) | Take advantage of Custom Error's return value property | 39 |
| [NC-17](#NC-17) | Avoid the use of sensitive terms | 1 |
| [NC-18](#NC-18) | Use Underscores for Number Literals (add an underscore every 3 digits) | 2 |
| [NC-19](#NC-19) | Internal and private variables and functions names should begin with an underscore | 19 |
### <a name="NC-1"></a>[NC-1] Missing checks for `address(0)` when assigning values to address state variables

*Instances (16)*:
```solidity
File: ./contracts/core/VoterUpgradeableV2.sol

154:         votingEscrow = votingEscrow_;

155:         _ve = votingEscrow_;

171:             minter = value_;

173:             bribeFactory = value_;

175:             merklDistributor = value_;

177:             veFnxMerklAidrop = value_;

179:             managedNFTManager = value_;

181:             v2PoolFactory = value_;

183:             v3PoolFactory = value_;

185:             v2GaugeFactory = value_;

187:             v3GaugeFactory = value_;

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VoterUpgradeableV2.sol)

```solidity
File: ./contracts/core/VotingEscrowUpgradeableV2.sol

116:         token = token_;

230:             artProxy = value_;

232:             veBoost = value_;

234:             managedNFTManager = value_;

236:             voter = value_;

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VotingEscrowUpgradeableV2.sol)

### <a name="NC-2"></a>[NC-2] Array indices should be referenced via `enum`s rather than via numeric literals

*Instances (2)*:
```solidity
File: ./contracts/core/VotingEscrowUpgradeableV2.sol

117:         supplyPointsHistory[0].blk = block.number;

118:         supplyPointsHistory[0].ts = block.timestamp;

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VotingEscrowUpgradeableV2.sol)

### <a name="NC-3"></a>[NC-3] Use `string.concat()` or `bytes.concat()` instead of `abi.encodePacked`
Solidity version 0.8.4 introduces `bytes.concat()` (vs `abi.encodePacked(<bytes>,<bytes>)`)

Solidity version 0.8.12 introduces `string.concat()` (vs `abi.encodePacked(<str>,<str>), which catches concatenation errors (in the event of a `bytes` data mixed in the concatenation)`)

*Instances (2)*:
```solidity
File: ./contracts/core/VoterUpgradeableV2.sol

169:         bytes32 key = keccak256(abi.encodePacked(key_));

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VoterUpgradeableV2.sol)

```solidity
File: ./contracts/core/VotingEscrowUpgradeableV2.sol

228:         bytes32 key = keccak256(abi.encodePacked(key_));

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VotingEscrowUpgradeableV2.sol)

### <a name="NC-4"></a>[NC-4] `constant`s should be defined rather than using magic numbers
Even [assembly](https://github.com/code-423n4/2022-05-opensea-seaport/blob/9d7ce4d08bf3c3010304a0476a785c70c0e90ae7/contracts/lib/TokenTransferrer.sol#L35-L39) can benefit from using readable constants instead of hex/numeric literals

*Instances (3)*:
```solidity
File: ./contracts/core/VoterUpgradeableV2.sol

157:         distributionWindowDuration = 3600;

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VoterUpgradeableV2.sol)

```solidity
File: ./contracts/core/VotingEscrowUpgradeableV2.sol

345:         for (uint256 i; i < 255; ++i) {

571:             for (uint256 i; i < 255; ++i) {

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VotingEscrowUpgradeableV2.sol)

### <a name="NC-5"></a>[NC-5] Control structures do not follow the Solidity Style Guide
See the [control structures](https://docs.soliditylang.org/en/latest/style-guide.html#control-structures) section of the Solidity Style Guide

*Instances (10)*:
```solidity
File: ./contracts/core/VoterUpgradeableV2.sol

121:                              Modifiers

384:         uint256 weightAt = totalWeightsPerEpoch[_epochTimestamp() - _WEEK]; // minter call notify after updates active_period, loads votes - 1 week

388:         emit NotifyReward(_msgSender(), token, amount_);

647:                 IGauge(gauge_).notifyRewardAmount(token, claimable);

756:         if (totalVoterPower > 0) IVotingEscrowV2(votingEscrow).votingHook(tokenId_, true);

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VoterUpgradeableV2.sol)

```solidity
File: ./contracts/core/VotingEscrowUpgradeableV2.sol

371:         if (nftStates[tokenId_].lastTranferBlock == block.number) return 0;

455:                 if (

466:         uint256 diff = LibVotingEscrowUtils.toUint256(newLocked.amount - oldLocked_.amount);

468:         supply += diff;

484:         emit Supply(supplyBefore, supplyBefore + diff);

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VotingEscrowUpgradeableV2.sol)

### <a name="NC-6"></a>[NC-6] Events that mark critical parameter changes should contain both the old and the new value
This should especially be done if the new value is not required to be different from the old value

*Instances (4)*:
```solidity
File: ./contracts/core/VoterUpgradeableV2.sol

168:     function updateAddress(string memory key_, address value_) external onlyRole(_VOTER_ADMIN_ROLE) {
             bytes32 key = keccak256(abi.encodePacked(key_));
             if (key == 0x39eb9ec2059d897c44a17440c762c429de204f6fddd727156ca52b8da086a6f7) {
                 minter = value_;
             } else if (key == 0xf23a19003b02ccc6ddd73a13c071e09977c34bfd7b5318a44fe456d9a77dd0af) {
                 bribeFactory = value_;
             } else if (key == 0x18c95c463f9590b3f298aef56c7cfb639672452cd99ac8d92a9fc0e2ef46ab55) {
                 merklDistributor = value_;
             } else if (key == 0xbbbfaae454470f56db24caaffaae3a4d3d0ed7a761421871150faa442416ea83) {
                 veFnxMerklAidrop = value_;
             } else if (key == 0x8ba8cbf9a47db7b5e8ae6c0bff072ed6faefec4a0722891b09f22b7ac343fd4f) {
                 managedNFTManager = value_;
             } else if (key == 0xa0238e972eab1b5ee9c4988c955a7165a662b3206031ac6ac27a3066d669a28d) {
                 v2PoolFactory = value_;
             } else if (key == 0xb8e13a5900588d0607f820e1a839eb41b418c77b9db23e333bcc679d611dbc9b) {
                 v3PoolFactory = value_;
             } else if (key == 0xe8ee2fdef59c2203ee9a363d82083446f25f27a1aff8fc1f0f3f79b83d30305c) {
                 v2GaugeFactory = value_;
             } else if (key == 0x7ebf69e1e15f4a4db2cb161251ab5c47f9f68d65713eba9542fedffbe59b7931) {
                 v3GaugeFactory = value_;
             } else {
                 revert InvalidAddressKey();
             }
             emit UpdateAddress(key_, value_);

200:     function setDistributionWindowDuration(uint256 distributionWindowDuration_) external onlyRole(_VOTER_ADMIN_ROLE) {
             distributionWindowDuration = distributionWindowDuration_;
             emit SetDistributionWindowDuration(distributionWindowDuration_);

212:     function setVoteDelay(uint256 newVoteDelay_) external onlyRole(_VOTER_ADMIN_ROLE) {
             if (newVoteDelay_ > _WEEK) {
                 revert VoteDelayTooBig();
             }
             emit SetVoteDelay(voteDelay, newVoteDelay_);

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VoterUpgradeableV2.sol)

```solidity
File: ./contracts/core/VotingEscrowUpgradeableV2.sol

227:     function updateAddress(string memory key_, address value_) external onlyOwner {
             bytes32 key = keccak256(abi.encodePacked(key_));
             if (key == 0x34fb3939438707b8405f1d19ae6b2db288ef3f256b5793b8060f559c5b7f5655) {
                 artProxy = value_;
             } else if (key == 0x3c62d7a9b63882751ce8976c553986336ef81d8ee74e2be6c26ac3d210f62677) {
                 veBoost = value_;
             } else if (key == 0x8ba8cbf9a47db7b5e8ae6c0bff072ed6faefec4a0722891b09f22b7ac343fd4f) {
                 managedNFTManager = value_;
             } else if (key == 0xcd157ad64ba4487a43c0029709fe8958bbe8ff3d254a9ac569005f257b8dd4d8) {
                 voter = value_;
             } else {
                 revert InvalidAddressKey();
             }
             emit UpdateAddress(key_, value_);

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VotingEscrowUpgradeableV2.sol)

### <a name="NC-7"></a>[NC-7] Function ordering does not follow the Solidity style guide
According to the [Solidity style guide](https://docs.soliditylang.org/en/v0.8.17/style-guide.html#order-of-functions), functions should be laid out in the following order :`constructor()`, `receive()`, `fallback()`, `external`, `public`, `internal`, `private`, but the cases below do not follow this pattern

*Instances (2)*:
```solidity
File: ./contracts/core/VoterUpgradeableV2.sol

1: 
   Current order:
   external initialize
   external updateAddress
   external setDistributionWindowDuration
   external setVoteDelay
   external killGauge
   external reviveGauge
   external createV2Gauge
   external createV3Gauge
   external createCustomGauge
   external notifyRewardAmount
   external distributeFees
   external distributeAll
   external distribute
   external distribute
   external reset
   external poke
   external vote
   public claimRewards
   public claimBribes
   public claimBribes
   external attachToManagedNFT
   external dettachFromManagedNFT
   external aggregateClaim
   internal _poke
   internal _distribute
   internal _registerCreatedGauge
   public _epochTimestamp
   internal _reset
   internal _vote
   internal _updateLastVotedTimestamp
   internal _checkVoteWindow
   internal _checkStartVoteWindow
   internal _checkEndVoteWindow
   internal _checkVoteDelay
   
   Suggested order:
   external initialize
   external updateAddress
   external setDistributionWindowDuration
   external setVoteDelay
   external killGauge
   external reviveGauge
   external createV2Gauge
   external createV3Gauge
   external createCustomGauge
   external notifyRewardAmount
   external distributeFees
   external distributeAll
   external distribute
   external distribute
   external reset
   external poke
   external vote
   external attachToManagedNFT
   external dettachFromManagedNFT
   external aggregateClaim
   public claimRewards
   public claimBribes
   public claimBribes
   public _epochTimestamp
   internal _poke
   internal _distribute
   internal _registerCreatedGauge
   internal _reset
   internal _vote
   internal _updateLastVotedTimestamp
   internal _checkVoteWindow
   internal _checkStartVoteWindow
   internal _checkEndVoteWindow
   internal _checkVoteDelay

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VoterUpgradeableV2.sol)

```solidity
File: ./contracts/core/VotingEscrowUpgradeableV2.sol

1: 
   Current order:
   external initialize
   external create_lock_for
   external create_lock_for_without_boost
   external deposit_for
   external deposit_for_without_boost
   external increase_unlock_time
   external withdraw
   external merge
   external lockPermanent
   external unlockPermanent
   external updateAddress
   external createManagedNFT
   external votingHook
   external onAttachToManagedNFT
   external onDettachFromManagedNFT
   external isApprovedOrOwner
   public tokenURI
   external votingPowerTotalSupply
   public balanceOfNFT
   public balanceOfNftIgnoreOwnershipChange
   internal _deposit
   internal _createLock
   internal _proccessLockChange
   internal _beforeTokenTransfer
   internal _withdrawClearNftInfo
   internal _updateNftLocked
   internal _checkpoint
   internal _balanceOfNFT
   
   Suggested order:
   external initialize
   external create_lock_for
   external create_lock_for_without_boost
   external deposit_for
   external deposit_for_without_boost
   external increase_unlock_time
   external withdraw
   external merge
   external lockPermanent
   external unlockPermanent
   external updateAddress
   external createManagedNFT
   external votingHook
   external onAttachToManagedNFT
   external onDettachFromManagedNFT
   external isApprovedOrOwner
   external votingPowerTotalSupply
   public tokenURI
   public balanceOfNFT
   public balanceOfNftIgnoreOwnershipChange
   internal _deposit
   internal _createLock
   internal _proccessLockChange
   internal _beforeTokenTransfer
   internal _withdrawClearNftInfo
   internal _updateNftLocked
   internal _checkpoint
   internal _balanceOfNFT

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VotingEscrowUpgradeableV2.sol)

### <a name="NC-8"></a>[NC-8] Functions should not be longer than 50 lines
Overly complex code can make understanding functionality more difficult, try to further modularize your code to ensure readability 

*Instances (64)*:
```solidity
File: ./contracts/core/VoterUpgradeableV2.sol

149:     function initialize(address blastGovernor_, address votingEscrow_) external initializer {

168:     function updateAddress(string memory key_, address value_) external onlyRole(_VOTER_ADMIN_ROLE) {

200:     function setDistributionWindowDuration(uint256 distributionWindowDuration_) external onlyRole(_VOTER_ADMIN_ROLE) {

212:     function setVoteDelay(uint256 newVoteDelay_) external onlyRole(_VOTER_ADMIN_ROLE) {

227:     function killGauge(address gauge_) external onlyRole(_GOVERNANCE_ROLE) {

250:     function reviveGauge(address gauge_) external onlyRole(_GOVERNANCE_ROLE) {

379:     function notifyRewardAmount(uint256 amount_) external {

396:     function distributeFees(address[] calldata gauges_) external {

423:     function distribute(uint256 start_, uint256 finish_) external nonReentrant {

435:     function distribute(address[] calldata gauges_) external nonReentrant {

447:     function reset(uint256 tokenId_) external nonReentrant onlyNftApprovedOrOwner(tokenId_) {

460:     function poke(uint256 tokenId_) external nonReentrant onlyNftApprovedOrOwner(tokenId_) {

502:     function claimRewards(address[] memory _gauges) public {

515:     function claimBribes(address[] memory _bribes, address[][] memory _tokens, uint256 tokenId_) public onlyNftApprovedOrOwner(tokenId_) {

526:     function claimBribes(address[] memory _bribes, address[][] memory _tokens) public {

539:     function attachToManagedNFT(uint256 tokenId_, uint256 managedTokenId_) external nonReentrant onlyNftApprovedOrOwner(tokenId_) {

553:     function dettachFromManagedNFT(uint256 tokenId_) external nonReentrant onlyNftApprovedOrOwner(tokenId_) {

660:     function _registerCreatedGauge(address gauge_, address pool_, address internalBribe_, address externalBribe_) internal {

681:     function _epochTimestamp() public view returns (uint256) {

723:     function _vote(uint256 tokenId_, address[] memory pools_, uint256[] memory weights_) internal {

764:     function _updateLastVotedTimestamp(uint256 tokenId_) internal {

801:     function _checkVoteDelay(uint256 tokenId_) internal view {

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VoterUpgradeableV2.sol)

```solidity
File: ./contracts/core/VotingEscrowUpgradeableV2.sol

110:     function initialize(address blastGovernor_, address token_) external initializer {

125:     function create_lock_for(uint256 amount_, uint256 lockDuration_, address to_) external override nonReentrant returns (uint256) {

143:     function deposit_for(uint256 tokenId_, uint256 amount_) external override nonReentrant {

150:     function deposit_for_without_boost(uint256 tokenId_, uint256 amount_) external override nonReentrant {

157:     function increase_unlock_time(uint256 tokenId_, uint256 lockDuration_) external override nonReentrant onlyNftApprovedOrOwner(tokenId_) {

170:     function withdraw(uint256 tokenId_) external override nonReentrant onlyNftApprovedOrOwner(tokenId_) {

205:     function lockPermanent(uint256 tokenId_) external override nonReentrant onlyNftApprovedOrOwner(tokenId_) {

216:     function unlockPermanent(uint256 tokenId_) external override nonReentrant onlyNftApprovedOrOwner(tokenId_) {

227:     function updateAddress(string memory key_, address value_) external onlyOwner {

246:     function createManagedNFT(address recipient_) external override onlyManagedNFTManager returns (uint256 managedNftId) {

255:     function votingHook(uint256 tokenId_, bool state_) external override {

319:     function isApprovedOrOwner(address spender, uint256 tokenId) external view virtual override returns (bool) {

326:     function tokenURI(uint256 tokenId_) public view override returns (string memory) {

341:     function votingPowerTotalSupply() external view override returns (uint256) {

370:     function balanceOfNFT(uint256 tokenId_) public view override returns (uint256) {

378:     function balanceOfNftIgnoreOwnershipChange(uint256 tokenId_) public view override returns (uint256) {

390:     function _deposit(uint256 tokenId_, uint256 amount_, bool shouldBoosted_) internal {

408:     function _createLock(uint256 amount_, uint256 lockDuration_, address to_, bool shouldBoosted_) internal returns (uint256) {

492:     function _beforeTokenTransfer(address from_, address to_, uint256 firstTokenId_, uint256 batchSize_) internal virtual override {

507:     function _withdrawClearNftInfo(uint256 tokenId_, TokenState memory state_) internal {

521:     function _updateNftLocked(uint256 tokenId_, LockedBalance memory newLocked_) internal {

532:     function _checkpoint(uint256 tokenId_, LockedBalance memory oldLocked_, LockedBalance memory newLocked_) internal {

647:     function _balanceOfNFT(uint256 tokenId_, uint256 timestamp_) internal view returns (uint256 balance) {

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VotingEscrowUpgradeableV2.sol)

```solidity
File: ./contracts/core/libraries/LibVotingEscrowValidation.sol

17:     function withdrawCheck(IVotingEscrowV2.TokenState memory self_) internal view {

29:     function checkExpired(IVotingEscrowV2.TokenState memory self_) internal view {

41:     function increaseUnlockCheck(IVotingEscrowV2.TokenState memory self_) internal view {

53:     function depositCheck(IVotingEscrowV2.TokenState memory self_) internal view {

64:     function transferCheck(IVotingEscrowV2.TokenState memory self_) internal pure {

74:     function mergeCheckFrom(IVotingEscrowV2.TokenState memory self_) internal view {

86:     function mergeCheckTo(IVotingEscrowV2.TokenState memory self_) internal view {

96:     function lockPermanentCheck(IVotingEscrowV2.TokenState memory self_) internal view {

108:     function unlockPermanentCheck(IVotingEscrowV2.TokenState memory self_) internal pure {

119:     function attachToManagedNftCheck(IVotingEscrowV2.TokenState memory self_) internal view {

130:     function dettachFromManagedNftCheck(IVotingEscrowV2.TokenState memory self_) internal pure {

139:     function checkNotVoted(IVotingEscrowV2.TokenState memory self_) internal pure {

150:     function checkExist(IVotingEscrowV2.TokenState memory self_) internal pure {

161:     function checkNotExpired(IVotingEscrowV2.TokenState memory self_) internal view {

173:     function checkPermanentLocked(IVotingEscrowV2.TokenState memory self_) internal pure {

184:     function checkNotPermanentLocked(IVotingEscrowV2.TokenState memory self_) internal pure {

195:     function checkNotAttached(IVotingEscrowV2.TokenState memory self_) internal pure {

206:     function checkAttached(IVotingEscrowV2.TokenState memory self_) internal pure {

217:     function checkNoValueZero(uint256 value_) internal pure {

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/libraries/LibVotingEscrowValidation.sol)

### <a name="NC-9"></a>[NC-9] Change int to int256
Throughout the code base, some variables are declared as `int`. To favor explicitness, consider changing all instances of `int` to `int256`

*Instances (9)*:
```solidity
File: ./contracts/core/VotingEscrowUpgradeableV2.sol

343:         Point memory last_point = supplyPointsHistory[epoch];

533:         Point memory u_old;

534:         Point memory u_new;

559:         Point memory last_point = Point({bias: 0, slope: 0, ts: block.timestamp, blk: block.number, permanent: 0});

561:             last_point = supplyPointsHistory[_epoch];

563:         uint256 last_checkpoint = last_point.ts;

564:         Point memory initial_last_point = last_point;

591:                 last_checkpoint = t_i;

650:             Point memory lastPoint = nftPointHistory[tokenId_][pointEpoch];

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VotingEscrowUpgradeableV2.sol)

### <a name="NC-10"></a>[NC-10] Lack of checks in setters
Be it sanity checks (like checks against `0`-values) or initial setting checks: it's best for Setter functions to have them

*Instances (4)*:
```solidity
File: ./contracts/core/VoterUpgradeableV2.sol

200:     function setDistributionWindowDuration(uint256 distributionWindowDuration_) external onlyRole(_VOTER_ADMIN_ROLE) {
             distributionWindowDuration = distributionWindowDuration_;
             emit SetDistributionWindowDuration(distributionWindowDuration_);

447:     function reset(uint256 tokenId_) external nonReentrant onlyNftApprovedOrOwner(tokenId_) {
             _checkVoteDelay(tokenId_);
             _checkVoteWindow();
             _reset(tokenId_);
             IVotingEscrowV2(votingEscrow).votingHook(tokenId_, false);
             _updateLastVotedTimestamp(tokenId_);

764:     function _updateLastVotedTimestamp(uint256 tokenId_) internal {
             lastVotedTimestamps[tokenId_] = _epochTimestamp() + 1;

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VoterUpgradeableV2.sol)

```solidity
File: ./contracts/core/VotingEscrowUpgradeableV2.sol

521:     function _updateNftLocked(uint256 tokenId_, LockedBalance memory newLocked_) internal {
             _checkpoint(tokenId_, nftStates[tokenId_].locked, newLocked_);
             nftStates[tokenId_].locked = newLocked_;

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VotingEscrowUpgradeableV2.sol)

### <a name="NC-11"></a>[NC-11] Missing Event for critical parameters change
Events help non-contract tools to track changes, and events prevent users from being surprised by changes.

*Instances (1)*:
```solidity
File: ./contracts/core/VoterUpgradeableV2.sol

447:     function reset(uint256 tokenId_) external nonReentrant onlyNftApprovedOrOwner(tokenId_) {
             _checkVoteDelay(tokenId_);
             _checkVoteWindow();
             _reset(tokenId_);
             IVotingEscrowV2(votingEscrow).votingHook(tokenId_, false);
             _updateLastVotedTimestamp(tokenId_);

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VoterUpgradeableV2.sol)

### <a name="NC-12"></a>[NC-12] Incomplete NatSpec: `@param` is missing on actually documented functions
The following functions are missing `@param` NatSpec comments.

*Instances (14)*:
```solidity
File: ./contracts/core/VotingEscrowUpgradeableV2.sol

122:     /**
          * @dev See {IVotingEscrowV2-create_lock_for}.
          */
         function create_lock_for(uint256 amount_, uint256 lockDuration_, address to_) external override nonReentrant returns (uint256) {

129:     /**
          * @dev See {IVotingEscrowV2-create_lock_for_without_boost}.
          */
         function create_lock_for_without_boost(
             uint256 amount_,
             uint256 lockDuration_,
             address to_

140:     /**
          * @dev See {IVotingEscrowV2-deposit_for}.
          */
         function deposit_for(uint256 tokenId_, uint256 amount_) external override nonReentrant {

147:     /**
          * @dev See {IVotingEscrowV2-deposit_for_without_boost}.
          */
         function deposit_for_without_boost(uint256 tokenId_, uint256 amount_) external override nonReentrant {

154:     /**
          * @dev See {IVotingEscrowV2-increase_unlock_time}.
          */
         function increase_unlock_time(uint256 tokenId_, uint256 lockDuration_) external override nonReentrant onlyNftApprovedOrOwner(tokenId_) {

167:     /**
          * @dev See {IVotingEscrowV2-withdraw}.
          */
         function withdraw(uint256 tokenId_) external override nonReentrant onlyNftApprovedOrOwner(tokenId_) {

177:     /**
          * @dev See {IVotingEscrowV2-merge}.
          */
         function merge(
             uint256 tokenFromId_,
             uint256 tokenToId_

202:     /**
          * @dev See {IVotingEscrowV2-lockPermanent}.
          */
         function lockPermanent(uint256 tokenId_) external override nonReentrant onlyNftApprovedOrOwner(tokenId_) {

213:     /**
          * @dev See {IVotingEscrowV2-unlockPermanent}.
          */
         function unlockPermanent(uint256 tokenId_) external override nonReentrant onlyNftApprovedOrOwner(tokenId_) {

224:     /**
          * @dev See {IVotingEscrowV2-updateAddress}.
          */
         function updateAddress(string memory key_, address value_) external onlyOwner {

243:     /**
          * @dev See {IVotingEscrowV2-createManagedNFT}.
          */
         function createManagedNFT(address recipient_) external override onlyManagedNFTManager returns (uint256 managedNftId) {

252:     /**
          * @dev See {IVotingEscrowV2-votingHook}.
          */
         function votingHook(uint256 tokenId_, bool state_) external override {

262:     /**
          * @dev See {IVotingEscrowV2-onAttachToManagedNFT}.
          */
         function onAttachToManagedNFT(
             uint256 tokenId_,
             uint256 managedTokenId_

292:     /**
          * @dev See {IVotingEscrowV2-onDettachFromManagedNFT}.
          */
         function onDettachFromManagedNFT(
             uint256 tokenId_,
             uint256 managedTokenId_,
             uint256 newBalance_

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VotingEscrowUpgradeableV2.sol)

### <a name="NC-13"></a>[NC-13] Incomplete NatSpec: `@return` is missing on actually documented functions
The following functions are missing `@return` NatSpec comments.

*Instances (4)*:
```solidity
File: ./contracts/core/VotingEscrowUpgradeableV2.sol

122:     /**
          * @dev See {IVotingEscrowV2-create_lock_for}.
          */
         function create_lock_for(uint256 amount_, uint256 lockDuration_, address to_) external override nonReentrant returns (uint256) {

129:     /**
          * @dev See {IVotingEscrowV2-create_lock_for_without_boost}.
          */
         function create_lock_for_without_boost(
             uint256 amount_,
             uint256 lockDuration_,
             address to_
         ) external override nonReentrant returns (uint256) {

243:     /**
          * @dev See {IVotingEscrowV2-createManagedNFT}.
          */
         function createManagedNFT(address recipient_) external override onlyManagedNFTManager returns (uint256 managedNftId) {

262:     /**
          * @dev See {IVotingEscrowV2-onAttachToManagedNFT}.
          */
         function onAttachToManagedNFT(
             uint256 tokenId_,
             uint256 managedTokenId_
         ) external override nonReentrant onlyManagedNFTManager returns (uint256) {

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VotingEscrowUpgradeableV2.sol)

### <a name="NC-14"></a>[NC-14] Consider using named mappings
Consider moving to solidity version 0.8.18 or later, and using [named mappings](https://ethereum.stackexchange.com/questions/51629/how-to-name-the-arguments-in-mapping/145555#145555) to make it easier to understand the purpose of each mapping

*Instances (3)*:
```solidity
File: ./contracts/core/VoterUpgradeableV2.sol

112:     mapping(uint256 tokenId => mapping(address => uint256)) public votes;

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VoterUpgradeableV2.sol)

```solidity
File: ./contracts/core/VotingEscrowUpgradeableV2.sol

68:     mapping(uint256 => Point) public supplyPointsHistory;

71:     mapping(uint256 => int128) public slope_changes;

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VotingEscrowUpgradeableV2.sol)

### <a name="NC-15"></a>[NC-15] Adding a `return` statement when the function defines a named return variable, is redundant

*Instances (2)*:
```solidity
File: ./contracts/core/VotingEscrowUpgradeableV2.sol

641:     /**
          * @notice Internal function to get the balance of an NFT at a specific timestamp.
          * @param tokenId_ The ID of the NFT.
          * @param timestamp_ The timestamp to query.
          * @return balance of the NFT at the specified timestamp.
          */
         function _balanceOfNFT(uint256 tokenId_, uint256 timestamp_) internal view returns (uint256 balance) {
             uint256 pointEpoch = nftStates[tokenId_].pointEpoch;
             if (pointEpoch > 0) {
                 Point memory lastPoint = nftPointHistory[tokenId_][pointEpoch];
                 if (lastPoint.permanent > 0) {
                     return LibVotingEscrowUtils.toUint256(lastPoint.permanent);
                 }
                 lastPoint.bias -= lastPoint.slope * int128(int256(timestamp_) - int256(lastPoint.ts));
                 return lastPoint.bias >= 0 ? LibVotingEscrowUtils.toUint256(lastPoint.bias) : 0;

641:     /**
          * @notice Internal function to get the balance of an NFT at a specific timestamp.
          * @param tokenId_ The ID of the NFT.
          * @param timestamp_ The timestamp to query.
          * @return balance of the NFT at the specified timestamp.
          */
         function _balanceOfNFT(uint256 tokenId_, uint256 timestamp_) internal view returns (uint256 balance) {
             uint256 pointEpoch = nftStates[tokenId_].pointEpoch;
             if (pointEpoch > 0) {
                 Point memory lastPoint = nftPointHistory[tokenId_][pointEpoch];
                 if (lastPoint.permanent > 0) {
                     return LibVotingEscrowUtils.toUint256(lastPoint.permanent);

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VotingEscrowUpgradeableV2.sol)

### <a name="NC-16"></a>[NC-16] Take advantage of Custom Error's return value property
An important feature of Custom Error is that values such as address, tokenID, msg.value can be written inside the () sign, this kind of approach provides a serious advantage in debugging and examining the revert details of dapps such as tenderly.

*Instances (39)*:
```solidity
File: ./contracts/core/VoterUpgradeableV2.sol

129:             revert AccessDenied();

189:             revert InvalidAddressKey();

214:             revert VoteDelayTooBig();

230:             revert GaugeAlreadyKilled();

252:             revert GaugeNotKilled();

272:             revert GaugeForPoolAlreadyExists();

275:             revert PoolNotCreatedByFactory();

312:             revert GaugeForPoolAlreadyExists();

317:             revert PoolNotCreatedByFactory();

361:             revert GaugeForPoolAlreadyExists();

381:             revert AccessDenied();

483:             revert ArrayLengthMismatch();

489:             revert DisabledManagedNft();

731:                 revert GaugeAlreadyKilled();

742:                 revert ZeroPowerForPool();

745:                 revert NoResetBefore();

782:             revert DistributionWindow();

792:             revert DistributionWindow();

803:             revert VoteDelay();

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VoterUpgradeableV2.sol)

```solidity
File: ./contracts/core/VotingEscrowUpgradeableV2.sol

80:             revert AccessDenied();

91:             revert AccessDenied();

162:             revert InvalidLockDuration();

185:             revert MergeTokenIdsTheSame();

238:             revert InvalidAddressKey();

257:             revert AccessDenied();

272:             revert ZeroVotingPower();

275:             revert NotManagedNft();

303:             revert NotManagedNft();

412:             revert InvalidLockDuration();

494:             revert ManagedNftTransferDisabled();

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VotingEscrowUpgradeableV2.sol)

```solidity
File: ./contracts/core/libraries/LibVotingEscrowValidation.sol

32:             revert TokenNoExpired();

141:             revert TokenVoted();

152:             revert TokenNotExist();

164:             revert TokenExpired();

175:             revert NotPermanentLocked();

186:             revert PermanentLocked();

197:             revert TokenAttached();

208:             revert TokenNotAttached();

219:             revert ValueZero();

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/libraries/LibVotingEscrowValidation.sol)

### <a name="NC-17"></a>[NC-17] Avoid the use of sensitive terms
Use [alternative variants](https://www.zdnet.com/article/mysql-drops-master-slave-and-blacklist-whitelist-terminology/), e.g. allowlist/denylist instead of whitelist/blacklist

*Instances (1)*:
```solidity
File: ./contracts/core/VoterUpgradeableV2.sol

491:         if (!managedNFTManagerCache.isWhitelistedNFT(tokenId_)) {

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VoterUpgradeableV2.sol)

### <a name="NC-18"></a>[NC-18] Use Underscores for Number Literals (add an underscore every 3 digits)

*Instances (2)*:
```solidity
File: ./contracts/core/VoterUpgradeableV2.sol

43:     uint256 internal constant _WEEK = 604800;

157:         distributionWindowDuration = 3600;

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VoterUpgradeableV2.sol)

### <a name="NC-19"></a>[NC-19] Internal and private variables and functions names should begin with an underscore
According to the Solidity Style Guide, Non-`external` variable and function names should begin with an [underscore](https://docs.soliditylang.org/en/latest/style-guide.html#underscore-prefix-for-non-external-functions-and-variables)

*Instances (19)*:
```solidity
File: ./contracts/core/libraries/LibVotingEscrowValidation.sol

17:     function withdrawCheck(IVotingEscrowV2.TokenState memory self_) internal view {

29:     function checkExpired(IVotingEscrowV2.TokenState memory self_) internal view {

41:     function increaseUnlockCheck(IVotingEscrowV2.TokenState memory self_) internal view {

53:     function depositCheck(IVotingEscrowV2.TokenState memory self_) internal view {

64:     function transferCheck(IVotingEscrowV2.TokenState memory self_) internal pure {

74:     function mergeCheckFrom(IVotingEscrowV2.TokenState memory self_) internal view {

86:     function mergeCheckTo(IVotingEscrowV2.TokenState memory self_) internal view {

96:     function lockPermanentCheck(IVotingEscrowV2.TokenState memory self_) internal view {

108:     function unlockPermanentCheck(IVotingEscrowV2.TokenState memory self_) internal pure {

119:     function attachToManagedNftCheck(IVotingEscrowV2.TokenState memory self_) internal view {

130:     function dettachFromManagedNftCheck(IVotingEscrowV2.TokenState memory self_) internal pure {

139:     function checkNotVoted(IVotingEscrowV2.TokenState memory self_) internal pure {

150:     function checkExist(IVotingEscrowV2.TokenState memory self_) internal pure {

161:     function checkNotExpired(IVotingEscrowV2.TokenState memory self_) internal view {

173:     function checkPermanentLocked(IVotingEscrowV2.TokenState memory self_) internal pure {

184:     function checkNotPermanentLocked(IVotingEscrowV2.TokenState memory self_) internal pure {

195:     function checkNotAttached(IVotingEscrowV2.TokenState memory self_) internal pure {

206:     function checkAttached(IVotingEscrowV2.TokenState memory self_) internal pure {

217:     function checkNoValueZero(uint256 value_) internal pure {

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/libraries/LibVotingEscrowValidation.sol)


## Low Issues


| |Issue|Instances|
|-|:-|:-:|
| [L-1](#L-1) | `approve()`/`safeApprove()` may revert if the current approval is not zero | 1 |
| [L-2](#L-2) | Some tokens may revert when zero value transfers are made | 6 |
| [L-3](#L-3) | Missing checks for `address(0)` when assigning values to address state variables | 16 |
| [L-4](#L-4) | `abi.encodePacked()` should not be used with dynamic types when passing the result to a hash function such as `keccak256()` | 2 |
| [L-5](#L-5) | Deprecated approve() function | 1 |
| [L-6](#L-6) | Division by zero not prevented | 5 |
| [L-7](#L-7) | External calls in an un-bounded `for-`loop may result in a DOS | 1 |
| [L-8](#L-8) | Initializers could be front-run | 12 |
| [L-9](#L-9) | Signature use at deadlines should be allowed | 8 |
| [L-10](#L-10) | Prevent accidentally burning tokens | 13 |
| [L-11](#L-11) | NFT ownership doesn't support hard forks | 1 |
| [L-12](#L-12) | Possible rounding issue | 1 |
| [L-13](#L-13) | Loss of precision | 5 |
| [L-14](#L-14) | Solidity version 0.8.20+ may not work on other chains due to `PUSH0` | 3 |
| [L-15](#L-15) | File allows a version of solidity that is susceptible to an assembly optimizer bug | 1 |
| [L-16](#L-16) | `symbol()` is not a part of the ERC-20 standard | 2 |
| [L-17](#L-17) | Unsafe ERC20 operation(s) | 1 |
| [L-18](#L-18) | Upgradeable contract is missing a `__gap[50]` storage variable to allow for new storage variables in later versions | 26 |
| [L-19](#L-19) | Upgradeable contract not initialized | 40 |
### <a name="L-1"></a>[L-1] `approve()`/`safeApprove()` may revert if the current approval is not zero
- Some tokens (like the *very popular* USDT) do not work when changing the allowance from an existing non-zero allowance value (it will revert if the current approval is not zero to protect against front-running changes of approvals). These tokens must first be approved for zero and then the actual allowance can be approved.
- Furthermore, OZ's implementation of safeApprove would throw an error if an approve is attempted from a non-zero value (`"SafeERC20: approve from non-zero to non-zero allowance"`)

Set the allowance to zero immediately before each of the existing allowance calls

*Instances (1)*:
```solidity
File: ./contracts/core/VoterUpgradeableV2.sol

661:         IERC20Upgradeable(token).approve(gauge_, type(uint256).max);

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VoterUpgradeableV2.sol)

### <a name="L-2"></a>[L-2] Some tokens may revert when zero value transfers are made
Example: https://github.com/d-xo/weird-erc20#revert-on-zero-value-transfers.

In spite of the fact that EIP-20 [states](https://github.com/ethereum/EIPs/blob/46b9b698815abbfa628cd1097311deee77dd45c5/EIPS/eip-20.md?plain=1#L116) that zero-valued transfers must be accepted, some tokens, such as LEND will revert if this is attempted, which may cause transactions that involve other tokens (such as batch operations) to fully revert. Consider skipping the transfer if the amount is zero, which will also save gas.

*Instances (6)*:
```solidity
File: ./contracts/core/VoterUpgradeableV2.sol

234:             IERC20Upgradeable(token).safeTransfer(minter, state.claimable);

383:         IERC20Upgradeable(token).safeTransferFrom(_msgSender(), address(this), amount_);

638:                         IERC20Upgradeable(token).safeTransfer(minter, amount);

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VoterUpgradeableV2.sol)

```solidity
File: ./contracts/core/VotingEscrowUpgradeableV2.sol

174:         IERC20Upgradeable(token).safeTransfer(_msgSender(), LibVotingEscrowUtils.toUint256(state.locked.amount));

476:             IERC20Upgradeable(token).safeTransferFrom(_msgSender(), address(this), amount_);

479:                 IERC20Upgradeable(token).safeTransferFrom(address(veBoostCached), address(this), boostedValue);

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VotingEscrowUpgradeableV2.sol)

### <a name="L-3"></a>[L-3] Missing checks for `address(0)` when assigning values to address state variables

*Instances (16)*:
```solidity
File: ./contracts/core/VoterUpgradeableV2.sol

154:         votingEscrow = votingEscrow_;

155:         _ve = votingEscrow_;

171:             minter = value_;

173:             bribeFactory = value_;

175:             merklDistributor = value_;

177:             veFnxMerklAidrop = value_;

179:             managedNFTManager = value_;

181:             v2PoolFactory = value_;

183:             v3PoolFactory = value_;

185:             v2GaugeFactory = value_;

187:             v3GaugeFactory = value_;

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VoterUpgradeableV2.sol)

```solidity
File: ./contracts/core/VotingEscrowUpgradeableV2.sol

116:         token = token_;

230:             artProxy = value_;

232:             veBoost = value_;

234:             managedNFTManager = value_;

236:             voter = value_;

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VotingEscrowUpgradeableV2.sol)

### <a name="L-4"></a>[L-4] `abi.encodePacked()` should not be used with dynamic types when passing the result to a hash function such as `keccak256()`
Use `abi.encode()` instead which will pad items to 32 bytes, which will [prevent hash collisions](https://docs.soliditylang.org/en/v0.8.13/abi-spec.html#non-standard-packed-mode) (e.g. `abi.encodePacked(0x123,0x456)` => `0x123456` => `abi.encodePacked(0x1,0x23456)`, but `abi.encode(0x123,0x456)` => `0x0...1230...456`). "Unless there is a compelling reason, `abi.encode` should be preferred". If there is only one argument to `abi.encodePacked()` it can often be cast to `bytes()` or `bytes32()` [instead](https://ethereum.stackexchange.com/questions/30912/how-to-compare-strings-in-solidity#answer-82739).
If all arguments are strings and or bytes, `bytes.concat()` should be used instead

*Instances (2)*:
```solidity
File: ./contracts/core/VoterUpgradeableV2.sol

169:         bytes32 key = keccak256(abi.encodePacked(key_));

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VoterUpgradeableV2.sol)

```solidity
File: ./contracts/core/VotingEscrowUpgradeableV2.sol

228:         bytes32 key = keccak256(abi.encodePacked(key_));

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VotingEscrowUpgradeableV2.sol)

### <a name="L-5"></a>[L-5] Deprecated approve() function
Due to the inheritance of ERC20's approve function, there's a vulnerability to the ERC20 approve and double spend front running attack. Briefly, an authorized spender could spend both allowances by front running an allowance-changing transaction. Consider implementing OpenZeppelin's `.safeApprove()` function to help mitigate this.

*Instances (1)*:
```solidity
File: ./contracts/core/VoterUpgradeableV2.sol

661:         IERC20Upgradeable(token).approve(gauge_, type(uint256).max);

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VoterUpgradeableV2.sol)

### <a name="L-6"></a>[L-6] Division by zero not prevented
The divisions below take an input parameter which does not have any zero-value checks, which may lead to the functions reverting when zero is passed.

*Instances (5)*:
```solidity
File: ./contracts/core/VoterUpgradeableV2.sol

386:             index += (amount_ * 1e18) / weightAt;

740:             uint256 votePowerForPool = (weights_[i] * nftVotePower) / totalVotesWeight;

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VoterUpgradeableV2.sol)

```solidity
File: ./contracts/core/VotingEscrowUpgradeableV2.sol

542:                 u_old.slope = oldLocked_.amount / I128_MAX_LOCK_TIME;

546:                 u_new.slope = newLocked_.amount / I128_MAX_LOCK_TIME;

567:             block_slope = (1e18 * (block.number - last_point.blk)) / (block.timestamp - last_point.ts);

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VotingEscrowUpgradeableV2.sol)

### <a name="L-7"></a>[L-7] External calls in an un-bounded `for-`loop may result in a DOS
Consider limiting the number of iterations in for-loops that make external calls

*Instances (1)*:
```solidity
File: ./contracts/core/VoterUpgradeableV2.sol

748:             poolVote[tokenId_].push(pool);

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VoterUpgradeableV2.sol)

### <a name="L-8"></a>[L-8] Initializers could be front-run
Initializers could be front-run, allowing an attacker to either set their own values, take ownership of the contract, and in the best case forcing a re-deployment

*Instances (12)*:
```solidity
File: ./contracts/core/VoterUpgradeableV2.sol

139:         __BlastGovernorClaimableSetup_init(blastGovernor_);

149:     function initialize(address blastGovernor_, address votingEscrow_) external initializer {

150:         __BlastGovernorClaimableSetup_init(blastGovernor_);

151:         __ReentrancyGuard_init();

152:         __AccessControl_init();

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VoterUpgradeableV2.sol)

```solidity
File: ./contracts/core/VotingEscrowUpgradeableV2.sol

101:         __BlastGovernorClaimableSetup_init(blastGovernor_);

110:     function initialize(address blastGovernor_, address token_) external initializer {

111:         __BlastGovernorClaimableSetup_init(blastGovernor_);

112:         __ReentrancyGuard_init();

113:         __Ownable2Step_init();

114:         __ERC721Enumerable_init();

115:         __ERC721_init("veFenix", "veFNX");

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VotingEscrowUpgradeableV2.sol)

### <a name="L-9"></a>[L-9] Signature use at deadlines should be allowed
According to [EIP-2612](https://github.com/ethereum/EIPs/blob/71dc97318013bf2ac572ab63fab530ac9ef419ca/EIPS/eip-2612.md?plain=1#L58), signatures used on exactly the deadline timestamp are supposed to be allowed. While the signature may or may not be used for the exact EIP-2612 use case (transfer approvals), for consistency's sake, all deadlines should follow this semantic. If the timestamp is an expiration rather than a deadline, consider whether it makes more sense to include the expiration timestamp as a valid timestamp, as is done for deadlines.

*Instances (8)*:
```solidity
File: ./contracts/core/VotingEscrowUpgradeableV2.sol

411:         if (unlockTimestamp <= block.timestamp || unlockTimestamp > LibVotingEscrowUtils.maxUnlockTimestamp()) {

541:             if (oldLocked_.end > block.timestamp && oldLocked_.amount > 0) {

545:             if (newLocked_.end > block.timestamp && newLocked_.amount > 0) {

576:                 if (t_i > block.timestamp) {

619:             if (oldLocked_.end > block.timestamp) {

627:             if (newLocked_.end > block.timestamp) {

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VotingEscrowUpgradeableV2.sol)

```solidity
File: ./contracts/core/libraries/LibVotingEscrowValidation.sol

31:         if (locked.isPermanentLocked || locked.end > block.timestamp) {

163:         if ((!locked.isPermanentLocked && locked.end < block.timestamp) && !self_.isAttached) {

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/libraries/LibVotingEscrowValidation.sol)

### <a name="L-10"></a>[L-10] Prevent accidentally burning tokens
Minting and burning tokens to address(0) prevention

*Instances (13)*:
```solidity
File: ./contracts/core/VoterUpgradeableV2.sol

234:             IERC20Upgradeable(token).safeTransfer(minter, state.claimable);

410:         IMinter(minter).update_period();

410:         IMinter(minter).update_period();

424:         IMinter(minter).update_period();

424:         IMinter(minter).update_period();

436:         IMinter(minter).update_period();

436:         IMinter(minter).update_period();

638:                         IERC20Upgradeable(token).safeTransfer(minter, amount);

682:         return IMinter(minter).active_period();

682:         return IMinter(minter).active_period();

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VoterUpgradeableV2.sol)

```solidity
File: ./contracts/core/VotingEscrowUpgradeableV2.sol

248:         _mint(recipient_, managedNftId);

415:         _mint(to_, newTokenId);

511:         _burn(tokenId_);

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VotingEscrowUpgradeableV2.sol)

### <a name="L-11"></a>[L-11] NFT ownership doesn't support hard forks
To ensure clarity regarding the ownership of the NFT on a specific chain, it is recommended to add `require(block.chainid == 1, "Invalid Chain")` or the desired chain ID in the functions below.

Alternatively, consider including the chain ID in the URI itself. By doing so, any confusion regarding the chain responsible for owning the NFT will be eliminated.

*Instances (1)*:
```solidity
File: ./contracts/core/VotingEscrowUpgradeableV2.sol

326:     function tokenURI(uint256 tokenId_) public view override returns (string memory) {
             _requireMinted(tokenId_);
             LockedBalance memory locked = nftStates[tokenId_].locked;
             return

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VotingEscrowUpgradeableV2.sol)

### <a name="L-12"></a>[L-12] Possible rounding issue
Division by large numbers may result in the result being zero, due to solidity not supporting fractions. Consider requiring a minimum amount for the numerator to ensure that it is always larger than the denominator. Also, there is indication of multiplication and division without the use of parenthesis which could result in issues.

*Instances (1)*:
```solidity
File: ./contracts/core/VoterUpgradeableV2.sol

740:             uint256 votePowerForPool = (weights_[i] * nftVotePower) / totalVotesWeight;

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VoterUpgradeableV2.sol)

### <a name="L-13"></a>[L-13] Loss of precision
Division by large numbers may result in the result being zero, due to solidity not supporting fractions. Consider requiring a minimum amount for the numerator to ensure that it is always larger than the denominator

*Instances (5)*:
```solidity
File: ./contracts/core/VoterUpgradeableV2.sol

740:             uint256 votePowerForPool = (weights_[i] * nftVotePower) / totalVotesWeight;

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VoterUpgradeableV2.sol)

```solidity
File: ./contracts/core/VotingEscrowUpgradeableV2.sol

344:         uint256 t_i = (last_point.ts / WEEK) * WEEK;

542:                 u_old.slope = oldLocked_.amount / I128_MAX_LOCK_TIME;

546:                 u_new.slope = newLocked_.amount / I128_MAX_LOCK_TIME;

567:             block_slope = (1e18 * (block.number - last_point.blk)) / (block.timestamp - last_point.ts);

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VotingEscrowUpgradeableV2.sol)

### <a name="L-14"></a>[L-14] Solidity version 0.8.20+ may not work on other chains due to `PUSH0`
The compiler for Solidity 0.8.20 switches the default target EVM version to [Shanghai](https://blog.soliditylang.org/2023/05/10/solidity-0.8.20-release-announcement/#important-note), which includes the new `PUSH0` op code. This op code may not yet be implemented on all L2s, so deployment on these chains will fail. To work around this issue, use an earlier [EVM](https://docs.soliditylang.org/en/v0.8.20/using-the-compiler.html?ref=zaryabs.com#setting-the-evm-version-to-target) [version](https://book.getfoundry.sh/reference/config/solidity-compiler#evm_version). While the project itself may or may not compile with 0.8.20, other projects with which it integrates, or which extend this project may, and those projects will have problems deploying these contracts/libraries.

*Instances (3)*:
```solidity
File: ./contracts/core/VoterUpgradeableV2.sol

2: pragma solidity =0.8.19;

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VoterUpgradeableV2.sol)

```solidity
File: ./contracts/core/VotingEscrowUpgradeableV2.sol

2: pragma solidity =0.8.19;

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VotingEscrowUpgradeableV2.sol)

```solidity
File: ./contracts/core/libraries/LibVotingEscrowValidation.sol

2: pragma solidity ^0.8.0;

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/libraries/LibVotingEscrowValidation.sol)

### <a name="L-15"></a>[L-15] File allows a version of solidity that is susceptible to an assembly optimizer bug
In solidity versions 0.8.13 and 0.8.14, there is an [optimizer bug](https://github.com/ethereum/solidity-blog/blob/499ab8abc19391be7b7b34f88953a067029a5b45/_posts/2022-06-15-inline-assembly-memory-side-effects-bug.md) where, if the use of a variable is in a separate `assembly` block from the block in which it was stored, the `mstore` operation is optimized out, leading to uninitialized memory. The code currently does not have such a pattern of execution, but it does use `mstore`s in `assembly` blocks, so it is a risk for future changes. The affected solidity versions should be avoided if at all possible.

*Instances (1)*:
```solidity
File: ./contracts/core/libraries/LibVotingEscrowValidation.sol

2: pragma solidity ^0.8.0;

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/libraries/LibVotingEscrowValidation.sol)

### <a name="L-16"></a>[L-16] `symbol()` is not a part of the ERC-20 standard
The `symbol()` function is not a part of the [ERC-20 standard](https://eips.ethereum.org/EIPS/eip-20), and was added later as an [optional extension](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/IERC20Metadata.sol). As such, some valid ERC20 tokens do not support this interface, so it is unsafe to blindly cast all tokens to this interface, and then call this function.

*Instances (2)*:
```solidity
File: ./contracts/core/VoterUpgradeableV2.sol

280:         string memory symbol = IERC20MetadataUpgradeable(pool_).symbol();

320:         string memory symbol = string.concat(IERC20MetadataUpgradeable(token0).symbol(), "/", IERC20MetadataUpgradeable(token1).symbol());

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VoterUpgradeableV2.sol)

### <a name="L-17"></a>[L-17] Unsafe ERC20 operation(s)

*Instances (1)*:
```solidity
File: ./contracts/core/VoterUpgradeableV2.sol

661:         IERC20Upgradeable(token).approve(gauge_, type(uint256).max);

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VoterUpgradeableV2.sol)

### <a name="L-18"></a>[L-18] Upgradeable contract is missing a `__gap[50]` storage variable to allow for new storage variables in later versions
See [this](https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps) link for a description of this storage variable. While some contracts may not currently be sub-classed, adding the variable now protects against forgetting to add it in the future.

*Instances (26)*:
```solidity
File: ./contracts/core/VoterUpgradeableV2.sol

4: import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

5: import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

6: import {SafeERC20Upgradeable, IERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

7: import {IERC20MetadataUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";

33: contract VoterUpgradeableV2 is IVoterV2, AccessControlUpgradeable, BlastGovernorClaimableSetup, ReentrancyGuardUpgradeable {

34:     using SafeERC20Upgradeable for IERC20Upgradeable;

234:             IERC20Upgradeable(token).safeTransfer(minter, state.claimable);

280:         string memory symbol = IERC20MetadataUpgradeable(pool_).symbol();

320:         string memory symbol = string.concat(IERC20MetadataUpgradeable(token0).symbol(), "/", IERC20MetadataUpgradeable(token1).symbol());

383:         IERC20Upgradeable(token).safeTransferFrom(_msgSender(), address(this), amount_);

638:                         IERC20Upgradeable(token).safeTransfer(minter, amount);

661:         IERC20Upgradeable(token).approve(gauge_, type(uint256).max);

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VoterUpgradeableV2.sol)

```solidity
File: ./contracts/core/VotingEscrowUpgradeableV2.sol

4: import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";

5: import "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";

6: import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

7: import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

11: import "./interfaces/IVeArtProxyUpgradeable.sol";

24: contract VotingEscrowUpgradeableV2 is

26:     Ownable2StepUpgradeable,

27:     ERC721EnumerableUpgradeable,

28:     ReentrancyGuardUpgradeable,

32:     using SafeERC20Upgradeable for IERC20Upgradeable;

174:         IERC20Upgradeable(token).safeTransfer(_msgSender(), LibVotingEscrowUtils.toUint256(state.locked.amount));

330:             IVeArtProxyUpgradeable(artProxy).tokenURI(

476:             IERC20Upgradeable(token).safeTransferFrom(_msgSender(), address(this), amount_);

479:                 IERC20Upgradeable(token).safeTransferFrom(address(veBoostCached), address(this), boostedValue);

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VotingEscrowUpgradeableV2.sol)

### <a name="L-19"></a>[L-19] Upgradeable contract not initialized
Upgradeable contracts are initialized via an initializer function rather than by a constructor. Leaving such a contract uninitialized may lead to it being taken over by a malicious user

*Instances (40)*:
```solidity
File: ./contracts/core/VoterUpgradeableV2.sol

4: import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

5: import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

6: import {SafeERC20Upgradeable, IERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

7: import {IERC20MetadataUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";

33: contract VoterUpgradeableV2 is IVoterV2, AccessControlUpgradeable, BlastGovernorClaimableSetup, ReentrancyGuardUpgradeable {

34:     using SafeERC20Upgradeable for IERC20Upgradeable;

139:         __BlastGovernorClaimableSetup_init(blastGovernor_);

140:         _disableInitializers();

149:     function initialize(address blastGovernor_, address votingEscrow_) external initializer {

150:         __BlastGovernorClaimableSetup_init(blastGovernor_);

151:         __ReentrancyGuard_init();

152:         __AccessControl_init();

234:             IERC20Upgradeable(token).safeTransfer(minter, state.claimable);

280:         string memory symbol = IERC20MetadataUpgradeable(pool_).symbol();

320:         string memory symbol = string.concat(IERC20MetadataUpgradeable(token0).symbol(), "/", IERC20MetadataUpgradeable(token1).symbol());

383:         IERC20Upgradeable(token).safeTransferFrom(_msgSender(), address(this), amount_);

638:                         IERC20Upgradeable(token).safeTransfer(minter, amount);

661:         IERC20Upgradeable(token).approve(gauge_, type(uint256).max);

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VoterUpgradeableV2.sol)

```solidity
File: ./contracts/core/VotingEscrowUpgradeableV2.sol

4: import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";

5: import "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";

6: import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

7: import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

11: import "./interfaces/IVeArtProxyUpgradeable.sol";

24: contract VotingEscrowUpgradeableV2 is

26:     Ownable2StepUpgradeable,

27:     ERC721EnumerableUpgradeable,

28:     ReentrancyGuardUpgradeable,

32:     using SafeERC20Upgradeable for IERC20Upgradeable;

101:         __BlastGovernorClaimableSetup_init(blastGovernor_);

102:         _disableInitializers();

110:     function initialize(address blastGovernor_, address token_) external initializer {

111:         __BlastGovernorClaimableSetup_init(blastGovernor_);

112:         __ReentrancyGuard_init();

113:         __Ownable2Step_init();

114:         __ERC721Enumerable_init();

115:         __ERC721_init("veFenix", "veFNX");

174:         IERC20Upgradeable(token).safeTransfer(_msgSender(), LibVotingEscrowUtils.toUint256(state.locked.amount));

330:             IVeArtProxyUpgradeable(artProxy).tokenURI(

476:             IERC20Upgradeable(token).safeTransferFrom(_msgSender(), address(this), amount_);

479:                 IERC20Upgradeable(token).safeTransferFrom(address(veBoostCached), address(this), boostedValue);

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VotingEscrowUpgradeableV2.sol)


## Medium Issues


| |Issue|Instances|
|-|:-|:-:|
| [M-1](#M-1) | Contracts are vulnerable to fee-on-transfer accounting-related issues | 3 |
| [M-2](#M-2) | `block.number` means different things on different L2s | 7 |
| [M-3](#M-3) | Centralization Risk for trusted owners | 9 |
| [M-4](#M-4) | `_safeMint()` should be used rather than `_mint()` wherever possible | 2 |
### <a name="M-1"></a>[M-1] Contracts are vulnerable to fee-on-transfer accounting-related issues
Consistently check account balance before and after transfers for Fee-On-Transfer discrepancies. As arbitrary ERC20 tokens can be used, the amount here should be calculated every time to take into consideration a possible fee-on-transfer or deflation.
Also, it's a good practice for the future of the solution.

Use the balance before and after the transfer to calculate the received amount instead of assuming that it would be equal to the amount passed as a parameter. Or explicitly document that such tokens shouldn't be used and won't be supported

*Instances (3)*:
```solidity
File: ./contracts/core/VoterUpgradeableV2.sol

383:         IERC20Upgradeable(token).safeTransferFrom(_msgSender(), address(this), amount_);

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VoterUpgradeableV2.sol)

```solidity
File: ./contracts/core/VotingEscrowUpgradeableV2.sol

476:             IERC20Upgradeable(token).safeTransferFrom(_msgSender(), address(this), amount_);

479:                 IERC20Upgradeable(token).safeTransferFrom(address(veBoostCached), address(this), boostedValue);

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VotingEscrowUpgradeableV2.sol)

### <a name="M-2"></a>[M-2] `block.number` means different things on different L2s
On Optimism, `block.number` is the L2 block number, but on Arbitrum, it's the L1 block number, and `ArbSys(address(100)).arbBlockNumber()` must be used. Furthermore, L2 block numbers often occur much more frequently than L1 block numbers (any may even occur on a per-transaction basis), so using block numbers for timing results in inconsistencies, especially when voting is involved across multiple chains. As of version 4.9, OpenZeppelin has [modified](https://blog.openzeppelin.com/introducing-openzeppelin-contracts-v4.9#governor) their governor code to use a clock rather than block numbers, to avoid these sorts of issues, but this still requires that the project [implement](https://docs.openzeppelin.com/contracts/4.x/governance#token_2) a [clock](https://eips.ethereum.org/EIPS/eip-6372) for each L2.

*Instances (7)*:
```solidity
File: ./contracts/core/VotingEscrowUpgradeableV2.sol

117:         supplyPointsHistory[0].blk = block.number;

371:         if (nftStates[tokenId_].lastTranferBlock == block.number) return 0;

497:         nftStates[firstTokenId_].lastTranferBlock = block.number;

559:         Point memory last_point = Point({bias: 0, slope: 0, ts: block.timestamp, blk: block.number, permanent: 0});

567:             block_slope = (1e18 * (block.number - last_point.blk)) / (block.timestamp - last_point.ts);

596:                     last_point.blk = block.number;

635:             u_new.blk = block.number;

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VotingEscrowUpgradeableV2.sol)

### <a name="M-3"></a>[M-3] Centralization Risk for trusted owners

#### Impact:
Contracts have owners with privileged rights to perform admin tasks and need to be trusted to not perform malicious updates or drain funds.

*Instances (9)*:
```solidity
File: ./contracts/core/VoterUpgradeableV2.sol

168:     function updateAddress(string memory key_, address value_) external onlyRole(_VOTER_ADMIN_ROLE) {

200:     function setDistributionWindowDuration(uint256 distributionWindowDuration_) external onlyRole(_VOTER_ADMIN_ROLE) {

212:     function setVoteDelay(uint256 newVoteDelay_) external onlyRole(_VOTER_ADMIN_ROLE) {

227:     function killGauge(address gauge_) external onlyRole(_GOVERNANCE_ROLE) {

250:     function reviveGauge(address gauge_) external onlyRole(_GOVERNANCE_ROLE) {

270:     ) external nonReentrant onlyRole(_GOVERNANCE_ROLE) returns (address gauge, address internalBribe, address externalBribe) {

310:     ) external nonReentrant onlyRole(_GOVERNANCE_ROLE) returns (address gauge, address internalBribe, address externalBribe) {

359:     ) external nonReentrant onlyRole(_GOVERNANCE_ROLE) returns (address gauge, address internalBribe, address externalBribe) {

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VoterUpgradeableV2.sol)

```solidity
File: ./contracts/core/VotingEscrowUpgradeableV2.sol

227:     function updateAddress(string memory key_, address value_) external onlyOwner {

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VotingEscrowUpgradeableV2.sol)

### <a name="M-4"></a>[M-4] `_safeMint()` should be used rather than `_mint()` wherever possible
`_mint()` is [discouraged](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/d4d8d2ed9798cc3383912a23b5e8d5cb602f7d4b/contracts/token/ERC721/ERC721.sol#L271) in favor of `_safeMint()` which ensures that the recipient is either an EOA or implements `IERC721Receiver`. Both open [OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/d4d8d2ed9798cc3383912a23b5e8d5cb602f7d4b/contracts/token/ERC721/ERC721.sol#L238-L250) and [solmate](https://github.com/Rari-Capital/solmate/blob/4eaf6b68202e36f67cab379768ac6be304c8ebde/src/tokens/ERC721.sol#L180) have versions of this function so that NFTs aren't lost if they're minted to contracts that cannot transfer them back out.

Be careful however to respect the CEI pattern or add a re-entrancy guard as `_safeMint` adds a callback-check (`_checkOnERC721Received`) and a malicious `onERC721Received` could be exploited if not careful.

Reading material:

- <https://blocksecteam.medium.com/when-safemint-becomes-unsafe-lessons-from-the-hypebears-security-incident-2965209bda2a>
- <https://samczsun.com/the-dangers-of-surprising-code/>
- <https://github.com/KadenZipfel/smart-contract-attack-vectors/blob/master/vulnerabilities/unprotected-callback.md>

*Instances (2)*:
```solidity
File: ./contracts/core/VotingEscrowUpgradeableV2.sol

248:         _mint(recipient_, managedNftId);

415:         _mint(to_, newTokenId);

```
[Link to code](https://github.com/code-423n4/2024-09-fenix-finance/tree/main/contracts/core/VotingEscrowUpgradeableV2.sol)

