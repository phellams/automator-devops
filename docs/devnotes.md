# Fixes and issues

---

## **Improvements**

- Choco requires VERIFICATION.txt
- Choco also requires LICENSE.txt file inside of tools
- nupsforce choco .nuspec file has been enhanced to allow `packageSourceUrl`, pointing to the url where the package source resides and `title`
- also include LICENSE.txt file inside of tools as requested.


## **Choco Guidelines**

From choco automated review `pwsl`

> **Guidelines**
> Guidelines are strong suggestions that improve the quality of a package version. These are considered something to fix for next time to increase the quality of the package. Over time Guidelines can become Requirements. A package version can be approved without addressing Guideline comments but will reduce the quality of the package.

 - The nuspec has been enhanced to allow `packageSourceUrl`, pointing to the url where the package source resides. This is a strong guideline because it simplifies collaboration. Please add it to the nuspec. More...
 - `ProjectUrl` and `ProjectSourceUrl` are typically different, but not always. Please ensure that `projectSourceUrl` is pointing to software source code or remove the field from the nuspec. More...
 - `Title` (title) matches id exactly. Please consider using something slightly more descriptive for the title in the nuspec. More...
