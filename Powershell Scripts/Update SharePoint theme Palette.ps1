Connect-SPOService -Url https://angleauto-admin.sharepoint.com

Remove-SPOTheme -Identity “AAF test”

$themepalette2 = @{
"themePrimary" = "#a34cdf";
"themeLighterAlt" = "#a34cdf";
"themeLighter" = "#a34cdf";
"themeLight" = "#a34cdf";
"themeTertiary" = "#a34cdf";
"themeSecondary" = "#a34cdf";
"themeDarkAlt" = "#a34cdf";
"themeDark" = "#a34cdf";
"themeDarker" = "#a34cdf";
"neutralLighterAlt" = "#a34cdf";
"neutralLighter" = "#a34cdf";
"neutralLight" = "#a34cdf";
"neutralQuaternaryAlt" = "#a34cdf";
"neutralQuaternary" = "#ffffff";
"neutralTertiaryAlt" = "#a34cdf";
"neutralTertiary" = "#a34cdf";
"neutralSecondary" = "#a34cdf";
"neutralPrimaryAlt" = "#a34cdf";
"neutralPrimary" = "#a34cdf";
"neutralDark" = "#a34cdf";
"black" = "#a34cdf";
"white" = "#ffffff";
}

Add-SPOTheme -Identity “AAF test” -Palette $themepalette2 -IsInverted $false

$themepalette = @{
"themePrimary" = "#ff539f";
"themeLighterAlt" = "#fff8fb";
"themeLighter" = "#ffe4f0";
"themeLight" = "#ffcce3";
"themeTertiary" = "#ff98c7";
"themeSecondary" = "#ff69ac";
"themeDarkAlt" = "#e64c91";
"themeDark" = "#c2407a";
"themeDarker" = "#8f2f5a";
"neutralLighterAlt" = "#260043";
"neutralLighter" = "#250042";
"neutralLight" = "#24003f";
"neutralQuaternaryAlt" = "#21003b";
"neutralQuaternary" = "#200038";
"neutralTertiaryAlt" = "#1f0036";
"neutralTertiary" = "#c8c8c8";
"neutralSecondary" = "#d0d0d0";
"neutralPrimaryAlt" = "#dadada";
"neutralPrimary" = "#ffffff";
"neutralDark" = "#f4f4f4";
"black" = "#f8f8f8";
"white" = "#280046";
}


$themepalette1 = @{
"themePrimary" = "#ff539f";
"themeLighterAlt" = "#0a0306";
"themeLighter" = "#290d1a";
"themeLight" = "#4d1930";
"themeTertiary" = "#993261";
"themeSecondary" = "#e04a8e";
"themeDarkAlt" = "#ff65aa";
"themeDark" = "#ff7db8";
"themeDarker" = "#ff9fca";
"neutralLighterAlt" = "#ffffff";
"neutralLighter" = "#ffffff";
"neutralLight" = "#ffffff";
"neutralQuaternaryAlt" = "#ffffff";
"neutralQuaternary" = "#ffffff";
"neutralTertiaryAlt" = "#ffffff";
"neutralTertiary" = "#0d0017";
"neutralSecondary" = "#12001f";
"neutralPrimaryAlt" = "#160027";
"neutralPrimary" = "#280046";
"neutralDark" = "#1e0036";
"black" = "#23003d";
"white" = "#ffffff";
}

$themepalette2 = @{
"themePrimary" = "#a34cdf";
"themeLighterAlt" = "#a34cdf";
"themeLighter" = "#ffffff";
"themeLight" = "#a34cdf";
"themeTertiary" = "#a34cdf";
"themeSecondary" = "#a34cdf";
"themeDarkAlt" = "#a34cdf";
"themeDark" = "#a34cdf";
"themeDarker" = "#a34cdf";
"neutralLighterAlt" = "#a34cdf";
"neutralLighter" = "#a34cdf";
"neutralLight" = "#a34cdf";
"neutralQuaternaryAlt" = "#a34cdf";
"neutralQuaternary" = "#ffffff";
"neutralTertiaryAlt" = "#a34cdf";
"neutralTertiary" = "#a34cdf";
"neutralSecondary" = "#a34cdf";
"neutralPrimaryAlt" = "#a34cdf";
"neutralPrimary" = "#a34cdf";
"neutralDark" = "#a34cdf";
"black" = "#a34cdf";
"white" = "#a34cdf";
}
