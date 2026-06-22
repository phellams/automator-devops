feat: add dynamic versioning

Notes: 

 - Dynamic Versioning Choice:
    - Both  Get-ConventionalCommitVersion  and  Get-GitAutoVersion  modules are imported in build-module.ps1.
    -  If  "versioning": "conventional"  is configured in  build_config.json , the builder uses Get-ConventionalCommitVersion . Otherwise, it falls back to the default  Get-GitAutoVersion  commit parser.
 - Robust Source Path Resolution:
    -  The builder script now dynamically resolves  SourcePath to ./src/ModuleName  only if the manifest file  ./src/ModuleName/ModuleName.psd1  is present.
    -  If no manifest file is found in the  src/  directory, it safely falls back to the root ( ./ ), ensuring root-based modules compile and package without modification.
 - Drift Configuration:
      - Enabled  "versioning": "conventional"  inside the local build_config.json.