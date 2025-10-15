EduReward Smart Contract

**EduReward** is a Clarity-based smart contract deployed on the **Stacks Blockchain**, designed to **incentivize learning and academic excellence** through transparent, trustless reward distribution.  
It enables educators, institutions, and sponsors to reward students for achievements, milestones, and verified learning outcomes.

---

Features

- **Student Registry:** Register and verify eligible students on-chain.  
- **Milestone Rewards:** Define and trigger rewards for completing academic or skill-based objectives.  
- **STX/Token Incentives:** Send blockchain-based rewards directly to verified learners.  
- **Transparent & Secure:** Built on Clarity for verifiable and predictable on-chain logic.  
- **Composable:** Can integrate with other education-related contracts like `EduCert-X` or `Skill-Proof`.

---

Smart Contract Overview

| Function | Description |
|-----------|--------------|
| `register-student (student principal)` | Adds a new student to the reward registry. |
| `create-reward (student principal) (amount uint) (milestone (string-ascii 50))` | Creates a new milestone reward for a student. |
| `claim-reward (reward-id uint)` | Allows eligible students to claim unlocked rewards. |
| `get-reward (reward-id uint)` | Retrieves details about a specific reward. |
| `list-students` | Returns all registered student principals. |

---

Use Case Example

**Scenario:**  
A university deploys the EduReward contract to distribute rewards to top-performing students each semester.  
Students who achieve a GPA above 4.0 automatically become eligible to claim blockchain-based STX rewards.

---

Deployment Instructions

Prerequisites
- [Clarinet](https://docs.hiro.so/clarinet/getting-started) installed and configured  
- A funded Stacks testnet wallet  
- Basic understanding of Clarity smart contracts  

Steps
1. Clone this repository:
   ```bash
   git clone https://github.com/<your-username>/edureward.git
   cd edureward
