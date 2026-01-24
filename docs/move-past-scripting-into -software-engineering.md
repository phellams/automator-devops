# Move-past-scripting-into -software-engineering

### 1. The "Copy-Paste" Problem -> The "Build" Solution

**Current State:** You copy-paste helpers into `.psm1` files or have a "libs" folder you manually manage.
**The Problem:** If you find a bug in `Helper-A`, you have to fix it in 5 different modules.
**The Solution:** **Build Pipelines (Compile time composition)**.

In modern PowerShell dev, we distinguish between **Source Code** (many small files) and **Artifacts** (one big `.psm1`).

* **Development:** You keep every function in its own file (e.g., `Get-User.ps1`, `Test-Connection.ps1`).
* **Build:** You use a tool to "stitch" them all together into one `.psm1` file when you publish.

**Tools to use:**

* **ModuleBuilder:** (Most popular) A module that automatically scans your `Public\` and `Private\` folders and compiles them into a single valid `.psm1` file.
* **Invoke-Build / PSake:** Task runners that handle the "stitching" logic.

**How it changes your workflow:**
Instead of copying code, you have a **SharedUtils** repository. Your build script pulls that repo and compiles it into your final module.

---

### 2. Replacing the "Global Hashtable" (`$GLOBAL:__modulename`)

**Current State:** You store internal functions/state in a global hashtable.
**The Problem:**

1. **Pollution:** You are writing to the Global scope, which is shared by the entire shell. If two modules use `__config`, they collide.
2. **Discovery:** `Get-Command` cannot see functions inside a hashtable. You lose tab-completion and Help features.
3. **Testing:** It makes Pester testing difficult because the state persists across tests.

**The Solution: Module Scope (`$Script:` Scope)**
PowerShell Modules have their own internal "private" scope. You don't need a global variable to store state or private functions; the Module *is* the container.

* **For State (Variables):**
Use `$Script:MyVariable`. This variable is visible to *every function inside the module*, but invisible to the user.
```powershell
# Inside MyModule.psm1
$Script:ConnectionCache = @{} # Only functions in this module can see this

```


* **For Internal Functions:**
Just define the function but **do not export it**.
```powershell
# PublicFunction.ps1
Function Get-Something {
    # This calls the private function effortlessly
    $token = Get-InternalToken 
}

```


In your `.psd1` manifest, under `FunctionsToExport`, only list the public ones. The private ones remain available internally but hidden from the user.

---

### 3. Architecture: The "Public/Private" Scaffold

This is the standard directory structure used by almost all professional modules (dbatools, PSFramework, etc.).

**Directory Structure:**

```text
MyModule/
├── Public/           # Functions users run (Get-MyWidget.ps1)
├── Private/          # Helpers users NEVER see (Get-AuthToken.ps1)
├── Classes/          # Custom C# or PS Classes
├── MyModule.psd1     # Manifest
└── MyModule.psm1     # The Loader Script

```

**The Loader Script (`MyModule.psm1`):**
Instead of manually including files, your `.psm1` just iterates over the folders and dot-sources everything.

```powershell
# MyModule.psm1 template
$public = Join-Path $PSScriptRoot "Public\*.ps1"
$private = Join-Path $PSScriptRoot "Private\*.ps1"

# Load private first (so public can use them immediately)
Get-ChildItem $private | ForEach-Object { . $_.FullName }
Get-ChildItem $public  | ForEach-Object { . $_.FullName }

```

*Note: If you use **ModuleBuilder** (mentioned in step 1), it replaces this loader script with a compiled file for better performance.*

---

### 4. Handling "Heavy" C# Code

**Current State:** You extract C# into functions.
**Recommendation:**
If you have "a lot" of C# or complex classes:

1. **Stop using `Add-Type` strings inside `.ps1` files.** It makes debugging the C# hard.
2. **Create a C# Project (Class Library):** Write your C# in Visual Studio/VS Code as a real `.cs` project.
3. **Compile to DLL:** Build a `.dll`.
4. **Load the DLL:** Your `.psm1` simply does `Import-Module ".\bin\MyAssembly.dll"`.
5. **Wrapper Functions:** Write "Cmdlets" in C# directly, OR write "Advanced Functions" in PowerShell that wrap the C# methods to make them feel "PowerShell-native" (handling pipeline input, Write-Verbose, etc.).

---

### 5. Shared Libraries (The "Common" Module)

If you have helpers used by **5+ different modules**:

1. Create a module called `MyCorp.Common`.
2. Put all generic helpers (Logging, Auth, API wrappers) there.
3. Publish `MyCorp.Common` to your internal repository.
4. In your other modules (e.g., `MyCorp.UserMgmt`), edit the manifest (`.psd1`):
```powershell
# MyCorp.UserMgmt.psd1
RequiredModules = @( 'MyCorp.Common' )

```



Now, when a user installs `UserMgmt`, PowerShell automatically installs and loads `Common`. No more copy-pasting.

### Summary Checklist for Refactoring

1. [ ] **Kill the Global Hashtable:** Move state to `$Script:` variables and helpers to Private functions.
2. [ ] **Adopt Public/Private Folders:** Separate your logic into individual files.
3. [ ] **Use a Build Tool:** Look into `ModuleBuilder` to compile your project.
4. [ ] **Centralize Helpers:** If a helper is used twice, it's a private function. If it's used in two *modules*, it's a dependency module.

Would you like an example of how the **Loader Script** logic works vs the **ModuleBuilder** logic?