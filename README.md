# GraphPreProcessor
A PowerShell Module to PreProcess Microsoft Graph Scripts via PowerShell
# 📘 Module Overview

This PowerShell module provides a preprocessing layer for Microsoft Graph-based scripts by analyzing their structure using the Abstract Syntax Tree (AST). Its primary goal is to identify **independent Graph API calls** — that is, calls which do not rely on dynamically generated input — and extract them into **structured batch request definitions** stored as JSON.

These batchable calls are then excluded from the original script, which is transformed into a **parameterized version** that consumes the responses from the batch requests. This process significantly reduces redundant API calls and speeds up execution, especially in repetitive or scheduled contexts.

The module maintains integrity and reusability by:

- Generating a `.GPP` folder next to the script to store:
  - A hash-based **meta file** for change detection,
  - A **parameterized script** with removed batchable calls,
  - The **batch request JSON** used to pre-fetch Graph data.
- Automatically detecting when the original script changes and reprocessing only when necessary.

This approach enables efficient, repeatable, and optimized execution of Microsoft Graph scripts — ideal for automation, CI/CD pipelines, and modular Graph development.
