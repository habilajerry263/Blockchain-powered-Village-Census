# 🏘️ Blockchain-powered Village Census

A smart contract system for conducting transparent and tamper-proof village census operations on the Stacks blockchain. This contract enables efficient population tracking, household management, and verification processes.

## ✨ Features

- 🏠 **Household Management** - Create and track households with addresses and member counts
- 👥 **Resident Registration** - Register residents with personal information and household associations
- 🔍 **Verification System** - Census officers can verify both residents and households
- 👮 **Officer Management** - Contract owner can appoint and remove census officers
- 📊 **Statistical Tracking** - Real-time population and household statistics
- 🔄 **Census Rounds** - Support for multiple census rounds with historical data
- 🔒 **Access Control** - Role-based permissions for different operations

## 🚀 Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Stacks wallet for interactions

### Installation

1. Clone this repository:
```bash
git clone <repository-url>
cd Blockchain-powered-Village-Census
```

2. Check the contract:
```bash
clarinet check
```

3. Run tests (optional):
```bash
npm install
npm test
```

## 📋 Contract Functions

### 👑 Administrative Functions (Contract Owner Only)

#### `appoint-census-officer`
Appoints a new census officer who can verify residents and households.
```clarity
(contract-call? .Blockchain-powered-Village-Census appoint-census-officer 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

#### `remove-census-officer`
Removes a census officer from active duty.
```clarity
(contract-call? .Blockchain-powered-Village-Census remove-census-officer 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

#### `set-census-status`
Activates or deactivates the census registration process.
```clarity
(contract-call? .Blockchain-powered-Village-Census set-census-status true)
```

#### `start-new-census-round`
Begins a new census round, archiving current statistics.
```clarity
(contract-call? .Blockchain-powered-Village-Census start-new-census-round)
```

#### `complete-census-round`
Closes the current census round and marks it as completed.
```clarity
(contract-call? .Blockchain-powered-Village-Census complete-census-round)
```

### 🏠 Household Management

#### `create-household`
Creates a new household with an address.
```clarity
(contract-call? .Blockchain-powered-Village-Census create-household "123 Main Street, Village")
```

### 👤 Resident Management

#### `register-resident`
Registers a new resident in a household.
```clarity
(contract-call? .Blockchain-powered-Village-Census register-resident "John Doe" u25 u1)
```

#### `update-resident`
Updates resident information (only by original registrar or census officer).
```clarity
(contract-call? .Blockchain-powered-Village-Census update-resident u1 "John Smith" u26)
```

### ✅ Verification Functions (Census Officers Only)

#### `verify-resident`
Marks a resident as verified.
```clarity
(contract-call? .Blockchain-powered-Village-Census verify-resident u1)
```

#### `verify-household`
Marks a household as verified.
```clarity
(contract-call? .Blockchain-powered-Village-Census verify-household u1)
```

### 📖 Read-Only Functions

#### `get-resident`
Retrieve information about a specific resident.
```clarity
(contract-call? .Blockchain-powered-Village-Census get-resident u1)
```

#### `get-household`
Retrieve information about a specific household.
```clarity
(contract-call? .Blockchain-powered-Village-Census get-household u1)
```

#### `get-current-census-info`
Get current census status and statistics.
```clarity
(contract-call? .Blockchain-powered-Village-Census get-current-census-info)
```

#### `get-village-stats`
Retrieve statistics for a specific census round.
```clarity
(contract-call? .Blockchain-powered-Village-Census get-village-stats u1)
```

#### `is-census-officer`
Check if an address is an active census officer.
```clarity
(contract-call? .Blockchain-powered-Village-Census is-census-officer 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

## 🔐 Permission System

- **Contract Owner**: Can manage census officers, control census status, and manage census rounds
- **Census Officers**: Can verify residents and households
- **Regular Users**: Can create households and register residents
- **Resident Registrars**: Can update information for residents they registered

## 📊 Data Structures

### Resident
```clarity
{
  name: (string-ascii 100),
  age: uint,
  household-id: uint,
  registered-at: uint,
  verified: bool,
  registrar: principal
}
```

### Household
```clarity
{
  head-of-household: uint,
  address: (string-ascii 200),
  members-count: uint,
  created-at: uint,
  last-updated: uint,
  verified: bool
}
```

### Village Stats
```clarity
{
  total-residents: uint,
  total-households: uint,
  verified-residents: uint,
  census-start: uint,
  census-end: uint,
  completed: bool
}
```

## 🔄 Typical Workflow

1. **Setup Phase**:
   - Contract owner deploys the contract
   - Appoint census officers
   - Activate census registration

2. **Registration Phase**:
   - Community members create households
   - Register residents in households
   - Update information as needed

3. **Verification Phase**:
   - Census officers verify households and residents
   - Ensure data accuracy and completeness

4. **Completion Phase**:
   - Complete the census round
   - Archive statistics for historical record
   - Prepare for next census round if needed

## ⚠️ Error Codes

- `u400` - Invalid input parameters
- `u401` - Unauthorized access
- `u404` - Resource not found
- `u409` - Resource already exists
- `u423` - Census is locked/inactive

## 🔧 Development

### Running Tests
```bash
clarinet test
```

### Local Development
```bash
clarinet console
```

## 📝 License

This project is open source and available under the [MIT License](LICENSE).



