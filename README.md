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

[ ⭐️ SPONSORS: add info here ]

The `Fenix` protocol is a modified version of `Chronos & Thena`, introducing innovations and changes

At its core, the protocol is based on the `ve(3,3)` concept, with a new set of integrations and a variable set of rules.


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
| ERC20 used by the protocol              |    ✅   FNX, WETH, USDB, BLAST             |
| Test coverage                           | ✅ SCOUTS: Please populate this after running the test coverage command                          |
| ERC721 used  by the protocol            |            None              |
| ERC777 used by the protocol             |           None                |
| ERC1155 used by the protocol            |              None            |
| Chains the protocol will be deployed on | Blast  |

### ERC20 token behaviors in scope

| Question                                                                                                                                                   | Answer |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ |
| [Missing return values](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#missing-return-values)                                                      |   Out of scope  |
| [Fee on transfer](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#fee-on-transfer)                                                                  |  Out of scope  |
| [Balance changes outside of transfers](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#balance-modifications-outside-of-transfers-rebasingairdrops) | Out of scope    |
| [Upgradeability](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#upgradable-tokens)                                                                 |   Out of scope  |
| [Flash minting](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#flash-mintable-tokens)                                                              | Out of scope    |
| [Pausability](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#pausable-tokens)                                                                      | Out of scope    |
| [Approval race protections](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#approval-race-protections)                                              | Out of scope    |
| [Revert on approval to zero address](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-approval-to-zero-address)                            | In scope    |
| [Revert on zero value approvals](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-zero-value-approvals)                                    | In scope    |
| [Revert on zero value transfers](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-zero-value-transfers)                                    | Out of scope    |
| [Revert on transfer to the zero address](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-transfer-to-the-zero-address)                    | In scope    |
| [Revert on large approvals and/or transfers](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-large-approvals--transfers)                  | Out of scope    |
| [Doesn't revert on failure](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#no-revert-on-failure)                                                   |  Out of scope   |
| [Multiple token addresses](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-zero-value-transfers)                                          | Out of scope    |
| [Low decimals ( < 6)](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#low-decimals)                                                                 |   In scope  |
| [High decimals ( > 18)](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#high-decimals)                                                              | In scope    |
| [Blocklists](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#tokens-with-blocklists)                                                                | Out of scope    |

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
- An action that should have been available only from the owner's side was called from a third-party user



## Attack ideas (where to focus for bugs)
- Security of user funds 
- Calculation of voting power in combination with permanent lock
- Distribution of emissions between gauge/pools
- VeNFT states and allowed actions during these states
- Detachment and attachment to the mVeNFT
- Permanent lock/unlock


## All trusted roles in the protocol

[ ⭐️ SPONSORS: please fill in the description column here ]


| Role                                        | Description                       |
| ---------------------------------------       | ---------------------------- |
| Owner (VotingEscrowUpgradeableV2.sol)         |                        |
| Owner (ProxyAdmin)                            |                        |
| GOVERNANCE_ROLE (VoterUpgradeableV2.sol)      |                        |
| VOTER_ADMIN_ROLE (VoterUpgradeableV2.sol)     |                        |

## Describe any novel or unique curve logic or mathematical models implemented in the contracts:

N/A

## Running tests

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




## Miscellaneous
Employees of Fenix Finance and employees' family members are ineligible to participate in this audit.

Code4rena's rules cannot be overridden by the contents of this README. In case of doubt, please check with C4 staff.
