# Title Guidelines for Chocolatey & PowerShell Gallery 

### **Guidelines & Examples**

#### **1. Chocolatey (Human-Focused)**

Chocolatey treats the Title as a marketing headline. It is displayed prominently in the Chocolatey GUI and on the website search results.

* **Guideline:** Use spaces, proper capitalization, and a short description of what it is.
* **Format:** `[Product Name] (Extension/Context)` or `[Product Name] - [Short Tagline]`
* **Word Count:** 3–6 words.

**Example for `pwsl`:**

```xml
<title>Pwsl - WSL2 Utility Wrapper</title>

```

* *How it looks:* Users see "Pwsl - WSL2 Utility Wrapper" in bold text.

#### **2. PowerShell Gallery (Function-Focused)**

PowerShell Gallery is strictly utilitarian. Users install packages by typing the name. The Gallery displays the **ID** as the title.

* **Guideline:** Since the Gallery displays the ID as the header, you should generally keep the Title field in the `.nuspec` identical to the ID, or omit it (if auto-generating). If you manually define it, keep it simple.
* **Format:** `[ModuleName]` (PascalCase)
* **Word Count:** 1 word (The module name).

**Example for `pwsl`:**

```xml
<title>Pwsl</title>
<title>pwsl</title>

```

* *How it looks:* Users see **pwsl** (the ID) in big bold letters.

---

### **Visual Comparison Table**

| Feature | Chocolatey (`choco`) | PowerShell Gallery (`Find-Module`) |
| --- | --- | --- |
| **Primary Display** | Uses `<title>` field. | Uses `<id>` field. |
| **Spaces Allowed?** | **Yes** (Encouraged). | **No** (ID cannot have spaces). |
| **Punctuation?** | **Yes** (Hyphens, brackets). | **No** (Only alphanumeric). |
| **Best Practice** | `Pwsl - WSL2 Utility` | `Pwsl` |
| **User Experience** | Users search for "WSL utility". | Users search for "Pwsl". |

### **Recommendation for your Workflow**

If you are maintaining **one** `.nuspec` file for **both** repositories (which is tricky but possible), you have to choose a compromise.

**The "Hybrid" Strategy:**
Use the **Chocolatey style** for the title. PowerShell Gallery will largely ignore it and show the ID anyway, so you might as well make it look good for the Chocolatey users.

```xml
<metadata>
  <id>pwsl</id>
  
  <title>Pwsl - WSL2 Utility Wrapper</title>
  ...
</metadata>

```

**Result:**

* **Chocolatey Website:** Displays "Pwsl - WSL2 Utility Wrapper"
* **PowerShell Gallery:** Displays "pwsl" (It ignores the title field).

This gives you the best of both worlds without breaking either.