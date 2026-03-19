```markdown
# Trust Conflict Resolver

## Overview
The **Trust Conflict Resolver** is a smart contract designed to deterministically resolve conflicting trust signals for users. It maintains canonical trust scores, applies penalties for severe conflicts, and rewards aligned signals with high integrity. The contract is suitable for decentralized reputation systems and trust management applications.

---

## Features
- Deterministic resolution of conflicting trust signals  
- Conflict detection and automatic penalty enforcement  
- Integrity-based reward system for aligned signals  
- Minimum update interval to prevent rapid score changes  
- On-chain tracking of resolved trust scores and conflict counts  
- Read-only functions for transparent inspection  

---

## Error Codes
| Code | Description |
|------|-------------|
| `ERR-INVALID-SIGNALS` (u600) | Integrity flag or signals invalid |
| `ERR-UPDATE-TOO-SOON` (u601) | Attempted update before minimum resolution gap |

---

## Configuration Constants
- `MIN-RESOLUTION-GAP` – Minimum block interval between trust updates (~1 day)  
- `CONFLICT-THRESHOLD` – Difference between positive and negative signals that triggers a conflict  
- `CONFLICT-PENALTY` – Penalty applied to trust score in case of severe conflict  
- `RESOLUTION-REWARD` – Bonus applied for aligned signals with high integrity  

---

## Data Storage
- `resolved-trust` – Canonical trust score per user  
- `last-resolution-block` – Block height of the last resolution per user  
- `conflict-count` – Number of severe conflicts per user  

---

## Core Functions

### `resolve-trust`
Processes user trust signals:
- **Inputs:**  
  - `positive-signal` (uint)  
  - `negative-signal` (uint)  
  - `integrity-flag` (0 = bad, 1 = neutral, 2 = good)  
- Resolves conflicts based on signal difference and applies penalties/rewards  
- Updates `resolved-trust`, `conflict-count`, and `last-resolution-block`  

### Read-only Functions
- `get-resolved-trust(user)` – Returns the canonical trust score  
- `get-conflict-count(user)` – Returns the total number of conflicts  

---

## Internal Utilities
- `absolute-diff(a, b)` – Computes absolute difference between two values  

---

## How It Works
1. Users submit positive and negative trust signals with an integrity flag.  
2. Contract checks the last resolution to enforce the minimum block gap.  
3. Computes the difference between positive and negative signals:  
   - **Severe conflict:** Increments conflict count and applies a penalty to trust score.  
   - **Aligned signals:** Calculates base score and applies integrity-based reward.  
4. Updates are persisted on-chain for transparency and auditing.  

---

## Use Cases
- Decentralized reputation systems  
- Trust-based access control  
- Fraud detection and anomaly monitoring  
- Collaborative networks and governance systems  

---

## Future Improvements
- Event logging for trust updates and conflicts  
- Batch processing for multiple users  
- Integration with broader reputation or governance systems  
- Enhanced analytics on conflict patterns and score history  
```
