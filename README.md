# Fenix Finance audit details
- Total Prize Pool: $16,000 in USDC
  - HM awards: $12,600 in USDC
  - QA awards: $500 in USDC
  - Judge awards: $2,400 in USDC
  - Scout awards: $500 in USDC
- [Read our guidelines for more details](https://docs.code4rena.com/roles/wardens)
- Starts September 18, 2024 20:00 UTC
- Ends September 25, 2024 20:00 UTC

## This is a Private audit

This audit repo and its Discord channel are accessible to **certified wardens only.** Participation in private audits is bound by:

1. Code4rena's [Certified Contributor Terms and Conditions](https://github.com/code-423n4/code423n4.com/blob/main/_data/pages/certified-contributor-terms-and-conditions.md)
2. C4's [Certified Contributor Code of Professional Conduct](https://code4rena.notion.site/Code-of-Professional-Conduct-657c7d80d34045f19eee510ae06fef55)

*All discussions regarding private audits should be considered private and confidential, unless otherwise indicated.*

Please review the following confidentiality requirements carefully, and if anything is unclear, ask questions in the private audit channel in the C4 Discord.

## Automated Findings / Publicly Known Issues

The 4naly3er report can be found [here](https://github.com/code-423n4/2024-09-fenix-finance/blob/main/4naly3er-report.md).



_Note for C4 wardens: Anything included in this `Automated Findings / Publicly Known Issues` section is considered a publicly known issue and is ineligible for awards._

- Centralized risk
- Initialize front-running
- User mistake
- Lack of storage reservation slots, for future contracts inheritors
- Failure to call an epoch change method for a significant amount of time, which will lead to skipping epochs
- Locking veNFT vote strength updates during the distribution window 
- Freezing the user's voting power at the time of voting at the beginning of the epoch, which gives them more voting power than they will have actually at the end of the epoch
- The ability to provide arbitrary addresses in the claimBribes, claimRewards, aggregateClaim methods, which will lead to calling certain methods on behalf of VoterUpgradeable
- Stuck emission allocated by the epoch, in case there were no votes during epoch
- Carelessly changing important contract addresses, which can lead to various problems and out-of-sync data between contracts
- The problem of upgrading already deployed contracts to V2 (this will not happen through an upgrade, just new deploy)
- Not supporting the deployment of contracts for other networks other than Blast as they are, the need to remove Blast features

# Overview
The `Fenix` protocol is an advanced evolution of the `Chronos & Thena` protocols, introducing a series of innovations and optimizations to enhance performance, security, and user experience. At its core, the protocol is based on the `ve(3,3)` model, with a modernized set of integrations and a features that adapts to the needs of the ecosystem.

The scope of this audit includes two key components of the ve(3,3) system within the protocol: `VotingEscrowUpgradeableV2` (veNFT) and `VoterUpgradeableV2` (Voter). These contracts are upgraded versions of the `VotingEscrowUpgradeableV1_2` and `VoterUpgradeableV1_2` contracts. The updates were introduced to reduce contract size, minimize gas costs, eliminate code duplication, fix bugs identified in previous audits, and simplify the contract structure while maintaining essential functionality.

### veNFT

The `VotingEscrowUpgradeableV2` (veNFT) contract enables users to lock their FNX tokens in exchange for veFNX NFTs. These NFTs represent voting power, which can be used in the `VoterUpgradeableV2` contract for governance and reward distribution. In addition to standard token locking and voting power calculation, the `veNFT` contract includes several new features:
- **Permanent Lock:** Users can permanently lock their veFNX tokens, ensuring that their voting power remains at the maximum level without any decay over time. Upon unlocking, the veNFT will remain locked for the maximum period of **182 days**.
- **mVeNFT (Managed Voting NFT):** Users have the option to delegate their veFNX voting power to a specialized mVeNFT. This managed NFT automatically votes on behalf of the users, optimally distributing voting power across pools and managing reward collection without requiring the user’s active participation. 
- **veBoost:** The feature encourages locking for a longer period and a larger amount, as this will result in additional rewards or FNX to the user's deposit

**Key Functionalities:**
- **FNX Token Locking:** Users lock their FNX tokens in exchange for veFNX, with their voting power determined by the amount and duration of the lock. The maximum locking period is **182 days**
  - When locking, the end date is rounded to an epoch, the minimum blocking time is 1 epoch
- **Voting Power Calculation:** The longer the FNX tokens are locked, the greater the voting power that the veNFT holds, decaying over time unless permanently locked. 
  - Voter power decreases linearly from the moment of blocking
  - In the case of permanent lock, the vote power is always kept at the maximum level
  -  mVeNft always keeps the vote power at the maximum level


### Voter

The `VoterUpgradeableV2` contract is responsible for managing the voting process, gauge emissions, and reward distribution for pools. veNFT holders can vote on liquidity pools (fenix v2, fenix v3) to influence the distribution of emissions and rewards among various gauges. It also notifies other contracts that are responsible for calculating the strength of the vote and rewarding the user for his participation

- **Distribution Window:** A designated time window is reserved for operation activites. During this period, regular users are restricted from voting, reset, poke actions. Which makes it possible to vote mVeNft correctly and distribute the reward among users
  
- **AggregateClaim:** This feature allows users to claim multiple rewards across different pools and gauges in a single transaction, significantly reducing the complexity and gas costs associated with claiming rewards individually. This enhancement improves the user experience

- **Custom Gauge:** Provides the ability to create a Gauge not only for the pool but also for specific functionality(pools, contracts, etc), which allows extend the creation of gauges not only for v2/v3 pools

**Key Functionalities:**

- **Gauge Management:** The contract allows users to vote on gauges, determining how emissions are distributed across different pools.
- **Reward Distribution:** Based on the voting results, emission are allocated to the corresponding pools and rewards can be claimed by veNFT holders who participated in the voting process.


## Links

- **Previous audits:** Hats Finance audit:  [Hats website](https://app.hats.finance/audit-competitions/fenix-finance-0x83dbe5aa378f3ce160ed084daf85f621289fb92f/scope), [Fenix's website](https://docs.fenixfinance.io/fenix/additional-information/security-and-audits)
- **Documentation:** https://docs.fenixfinance.io
- **Website:** https://www.fenixfinance.io/
- **X/Twitter:**  https://twitter.com/fenixfinance
- **Discord:** https://discord.com/invite/fenixfi

---


# Scope

*See [scope.txt](https://github.com/code-423n4/2024-09-fenix-finance/blob/main/scope.txt)*

### Files in scope


| File   | Logic Contracts | Interfaces | nSLOC | Purpose | Libraries used |
| ------ | --------------- | ---------- | ----- | -----   | ------------ |
| /contracts/core/VotingEscrowUpgradeableV2.sol | 1| **** | 425 | |@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol<br>@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol<br>@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol<br>@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol|
| /contracts/core/VoterUpgradeableV2.sol | 1| **** | 457 | |@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol<br>@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol<br>@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol<br>@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol<br>@cryptoalgebra/integral-core/contracts/interfaces/IAlgebraFactory.sol|
| /contracts/core/libraries/LibVotingEscrowValidation.sol | 1| **** | 102 | ||
| **Totals** | **3** | **** | **984** | | |

### Files out of scope

Any file not listed in the scope table above.
*See also [out_of_scope.txt](https://github.com/code-423n4/2024-09-fenix-finance/blob/main/out_of_scope.txt)*

## Scoping Q &amp; A

### General questions


| Question                                | Answer                       |
| --------------------------------------- | ---------------------------- |
| ERC20 used by the protocol              |      FNX, WETH, USDB, BLAST             |
| Test coverage                           |   ~97% of statements (see table at the bottom)                      |
| ERC721 used  by the protocol            |            None              |
| ERC777 used by the protocol             |           None                |
| ERC1155 used by the protocol            |              None            |
| Chains the protocol will be deployed on | Blast  |

### External integrations (e.g., Uniswap) behavior in scope:


| Question                                                  | Answer |
| --------------------------------------------------------- | ------ |
| Enabling/disabling fees (e.g. Blur disables/enables fees) | No   |
| Pausability (e.g. Uniswap pool gets paused)               |  No   |
| Upgradeability (e.g. Uniswap gets upgraded)               |   No  |


### EIP compliance checklist

| Contract                                | EIPs                       |
| --------------------------------------- | ---------------------------- |
| `contracts/core/VotingEscrowUpgradeableV2.sol`   | ERC721                |


# Additional context

## Main invariants

- The user gained more voting power than expected by his actions
- Attaching veNFT to mVeNFT resulted in the complete loss of the user's veNFT
- The user has blocked the distribution in gauge by his actions
- The user has blocked other users in mVeNft by their actions
- An action that should have been available only from the owner's side was called from a third-party user
- Incorrect distribution of emissions between gauges


## Attack ideas (where to focus for bugs)
- Security of user funds 
- Calculation of voting power in combination with permanent lock
- Distribution of emissions between gauge/pools
- VeNFT states and allowed actions during these states
- Detachment and attachment to the mVeNFT
- Permanent lock/unlock
- Simple user DoS of other users in certain actions

## All trusted roles in the protocol

| Role                                        | Description                       |
| ---------------------------------------       | ---------------------------- |
| Owner (VotingEscrowUpgradeableV2.sol)         | Manages the update of critical parameters in the VotingEscrowUpgradeableV2 contract |
| Owner (ProxyAdmin)                            | Controls the upgrade process for all protocol contracts. |
| GOVERNANCE_ROLE (VoterUpgradeableV2.sol)      | Responsible for adding, managing, and disabling gauges for pools |
| VOTER_ADMIN_ROLE (VoterUpgradeableV2.sol)     | Manages the configuration and setting of critical parameters within the VoterUpgradeableV2 contract |
| DEFAULT_ADMIN_ROLE (VoterUpgradeableV2.sol)   | Oversees the management of roles within the contract |

## Describe any novel or unique curve logic or mathematical models implemented in the contracts:

N/A

## Setup


### Running basic tests
To run the existing tests, also need to compile the artifacts of the fenix-dex-v3 library
```sh
# clone repo
git clone https://github.com/code-423n4/2024-09-fenix-finance.git --recursive -j8 
cd 2024-09-fenix-finance

# install dependencies and compile artifacts for root folder and fenix-dex-v3 library
npm i &&
cd lib/fenix-dex-v3 && npm install && 
cd src/core && npm install  && npx hardhat compile && cd ../.. &&
cd src/periphery && npm install && npx hardhat compile && cd ../../../.. 
```
run tests command
```sh
npm run test
```
or
```sh
npx hardhat test
```

To run code coverage
```sh
npx hardhat coverage
```

Coverage output:
File                                                    |  % Stmts | % Branch |  % Funcs |  % Lines |Uncovered Lines |
--------------------------------------------------------|----------|----------|----------|----------|----------------|
 core/                                                  |  
  VoterUpgradeableV2.sol                                |    92.82 |    75.68 |    91.67 |    90.57 |... 731,745,803 |
  VotingEscrowUpgradeableV2.sol                         |      100 |    87.01 |      100 |    97.55 |... 589,610,613 |
 core/libraries/                                        |   
  LibVotingEscrowValidation.sol                         |      100 |       90 |      100 |       96 |        152,208 |


## Miscellaneous
Employees of Fenix Finance and employees' family members are ineligible to participate in this audit.

Code4rena's rules cannot be overridden by the contents of this README. In case of doubt, please check with C4 staff.
