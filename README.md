# APB Design & Verification

## Overview
This project implements and verifies an **AMBA APB (Advanced Peripheral Bus) slave interface** with a 64 KB memory space. The design follows the standard APB protocol with IDLE, SETUP, and ACCESS phases, and has been verified using a SystemVerilog testbench with functional coverage, assertions, and directed/random tests.

---

## Features
- **Protocol**: AMBA APB (2-cycle minimum transfer)
- **Memory**: 64 KB total capacity (65,536 bytes)
- **Data Bus Width**: 64-bit (PWDATA / PRDATA)
- **Address Bus**: 32-bit (parameterizable base address)
- **Endianness**: Little-endian
- **Alignment**: 8-byte aligned
- **Error Conditions**:
  - Address outside 64 KB window
  - Misaligned access
- **Throughput**: One request per APB transfer, no outstanding transactions
- **Reset**: Active-low asynchronous (`PRESETn`)
- **Strobe Support**: Byte-enable writes via `PSTRB[7:0]`

---

## Microarchitecture
The slave design is implemented using a **Mealy FSM** with the following states:
- **IDLE**
- **SETUP**
- **ACCESS**

Key signals:
- `PSELx`, `PENABLE`, `PWRITE`, `PREADY`, `PSLVERR`
- `PWDATA`, `PRDATA`, `PADDR`
- Internal handshake with `req`, `we`, and `rdata_valid`

---

## Operations
### Write
1. **SETUP**: `PSEL=1`, `PENABLE=0`, `PWRITE=1`
2. **ACCESS**: `PENABLE=1`; slave asserts `PREADY` once `rdata_valid=1`
3. Write occurs with byte enables applied (`PSTRB`)
4. Transfer completes when `PREADY=1`

### Read
1. **SETUP**: `PSEL=1`, `PENABLE=0`, `PWRITE=0`
2. **ACCESS**: `PENABLE=1`; slave asserts `PREADY` once `rdata_valid=1`
3. Transfer completes when `PREADY=1`

---

## Verification Environment
The testbench is built in **SystemVerilog UVM-like structure** with the following components:
- **apb_driver** – Drives transactions onto DUT
- **apb_monitor** – Captures bus activity
- **apb_env** – Integrates all components
- **apb_agent** – Bundles driver, monitor, and sequencer
- **apb_scb (scoreboard)** – Compares DUT output with reference model
- **apb_coverage** – Collects functional coverage
- **apb_test** – Defines test scenarios

---

## Test Plan
| Feature                  | Purpose                                      | Example Tests |
|---------------------------|----------------------------------------------|---------------|
| Reset                    | Ensure safe state recovery                   | `apb_reset_test` |
| Write/Read Transactions  | Verify correct memory read/write             | `apb_successive_wr_test`, `apb_random_addr_wr_test` |
| Strobe Support (PSTRB)   | Validate sparse byte writes                  | `apb_strobe_test` |
| Error Handling (PSLVERR) | Detect invalid/misaligned accesses           | `apb_slave_error_aor_test`, `apb_addr_misaligned_test` |
| Protocol Violation       | Ensure slave responds correctly              | `apb_violation_test` |
| Boundary Conditions      | Validate upper/lower memory limits           | `apb_boundary_test` |
| Stress Tests             | Check reliability under randomized scenarios | `apb_random_stress_test` |

---

## Assertions
Some key assertions include:
- `apb_sel_enable_assert`: PSELx HIGH → next cycle PENABLE HIGH
- `apb_pready_assert`: Transfer must wait until PREADY HIGH
- `apb_pslverr_assert`: PSLVERR must assert on invalid access
- `apb_reset_assert`: Bus returns to default after reset
- `apb_valid_write_assert`: PWDATA stable during valid writes
- `apb_valid_read_assert`: PRDATA stable during valid reads

---

## Coverage Plan
- **PSELx_cp**: Slave select activity
- **PENABLE_cp**: Setup/Access phase coverage
- **PWRITE_cp**: Read vs. Write operations
- **PREADY_cp**: Wait-state behavior
- **PADDR_cp**: Full address range coverage
- **PWDATA_cp / PRDATA_cp**: Data range exercised
- **PSLVERR_cp**: Error scenarios
- **cross_addr_data_pwrite**: Cross coverage of address/data operations

---

## Results
- **Functional Tests**: All directed and random tests passed (PASS counts in thousands; FAIL = 0)
- **Error Handling**: Proper PSLVERR response for misaligned/out-of-range addresses
- **Assertions**: Majority passed; few reset assertions flagged for review
- **Coverage**: Achieved high functional coverage across protocol features

---

## Future Improvements
- Extend verification with **UVM sequence library** for better reusability
- Add **constrained randomization** for deeper corner-case exploration
- Enhance **reset handling robustness**
- Integrate with **formal verification** for APB protocol compliance

---

## References
- ARM AMBA APB Protocol Specification
- Project documentation: *APB Design & Verification Doc.pdf*
