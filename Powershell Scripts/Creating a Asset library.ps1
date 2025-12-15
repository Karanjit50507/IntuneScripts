Connect-SPOService -url https://angleauto-admin.sharepoint.com/

Get-SPOOrgAssetsLibrary

Add-SPOOrgAssetsLibrary -LibraryUrl https://angleauto.sharepoint.com/Asset%20Library/Forms/AllItems.aspx -OrgAssetType OfficeTemplateLibrary -CdnType Public