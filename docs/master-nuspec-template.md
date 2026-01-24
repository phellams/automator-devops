# Master `.nuspec` template

This template includes the standard NuGet fields, **Chocolatey-specific extensions**, and notes on **PowerShell Gallery** requirements.

### **Important Context**

* **Chocolatey:** deeply relies on the `.nuspec` file. You must manually edit this file to package software.
* **PowerShell Gallery:** typically **auto-generates** the `.nuspec` file from your module manifest (`.psd1`) when you run `Publish-Module`. However, if you are manually creating a `.nupkg` to upload, you can use this template.

---

### **The Master .nuspec Template**

This template contains **every possible field**. Required fields are marked. Optional fields are commented with details.

```xml
<?xml version="1.0" encoding="utf-8"?>
<package xmlns="http://schemas.microsoft.com/packaging/2015/06/nuspec.xsd">
  <metadata>
    <id>your-package-id</id>
    
    <version>1.0.0</version>
    
    <title>Your Package Title</title>
    
    <authors>Original Software Author</authors>
    
    <description>
      # Product Description
      This is a markdown-supported description of the software.
      
      ## Features
      - Feature A
      - Feature B
    </description>

    <owners>YourName, YourCompany</owners>
    
    <packageSourceUrl>https://github.com/your/package-repo</packageSourceUrl>
    
    <projectSourceUrl>https://github.com/original/software-repo</projectSourceUrl>
    
    <docsUrl>https://docs.software.com</docsUrl>
    
    <mailingListUrl>https://forum.software.com</mailingListUrl>
    
    <bugTrackerUrl>https://github.com/original/software-repo/issues</bugTrackerUrl>
    
    <projectUrl>https://software.com</projectUrl>
    
    <iconUrl>https://raw.githubusercontent.com/your/repo/master/icons/icon.png</iconUrl>
    
    <license type="expression">MIT</license>
    <copyright>2024 Original Author</copyright>
    
    <requireLicenseAcceptance>false</requireLicenseAcceptance>
    
    <tags>space separated tags admin foss cross-platform</tags>
    
    <summary>A short summary of your package.</summary>
    
    <releaseNotes>
      * Fixed bug in installation script
      * Updated to version 1.0.0
    </releaseNotes>

    <dependencies>
      <dependency id="chocolatey-core.extension" version="1.1.0" />
      <dependency id="powershell-core" version="7.0.0" />
    </dependencies>
  </metadata>

  <files>
    <file src="tools\**" target="tools" />
    <file src="legal\**" target="legal" />
  </files>
</package>

```

---

### **Field Reference & Definitions**

#### **1. Chocolatey Specific Fields**

These are critical for maintaining high-quality Chocolatey packages.

| Field | Description |
| --- | --- |
| **`packageSourceUrl`** | The URL where **your** packaging scripts (this `.nuspec` and `.ps1` files) reside (e.g., your GitHub repo). |
| **`owners`** | The maintainer of the Chocolatey package (you), distinct from the software `authors`. |
| **`docsUrl`** | Link to the software's Wiki or Documentation. |
| **`mailingListUrl`** | Link to the software's Forum or Community page. |
| **`bugTrackerUrl`** | Link to the software's Issue Tracker. |
| **`projectSourceUrl`** | Link to the software's source code (if it is Open Source). |

#### **2. PowerShell Gallery Specifics**

If you are manually creating a `.nupkg` for PowerShell Gallery (instead of using `Publish-Module`), note the following mapping:

* **`tags`**: This is the most critical field for PS Gallery.
* **Must include:** `PSModule` (if it's a module) or `PSScript` (if it's a script).
* **OS Compatibility:** Use `PSEdition_Desktop` (Windows PowerShell) or `PSEdition_Core` (PowerShell Core / 6+).
* **OS:** `Windows`, `Linux`, `MacOS`.


* **`id`**: Must match the name of your Module Manifest (`.psd1`).
* **`version`**: Must match the `ModuleVersion` in your `.psd1`.

### **Next Step**

Would you like me to generate the accompanying **`chocolateyInstall.ps1`** script template to go with this file?