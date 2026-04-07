# Theme Converter App

A small Shiny app for converting editor themes between VSCode and tmTheme
formats.

> [!NOTE]
>
> This app has been created using AI.

## Overview

This app lets you:

-   Convert tmTheme `.tmTheme` files into VSCode `.json`
-   Convert VSCode `.json` files into tmTheme `.tmTheme`

Input can be provided by file upload, drag-and-drop, or pasting the theme text
directly.

## Features

-   Two conversion modes:
    1.  tmTheme → VSCode
    2.  VSCode → tmTheme
-   Real-time input/output preview using Ace editor widgets
-   Optional theme name entry for converted output

## Requirements

-   R 4.0 or newer
-   `shiny`
-   `bslib`
-   `shinyAce`
-   `rstudiothemes`

## Setup

1.  Open the project folder in RStudio or your preferred R environment.
2.  Install required packages if needed:

``` r
install.packages(c("shiny", "bslib", "shinyAce", "rstudiothemes"))
```

## Run the app

From the project directory, run:

``` r
shiny::runApp("app.R")
```

or simply open `app.R` in RStudio and click **Run App**.

## Usage

1.  Choose a conversion tab.
2.  Upload or paste a theme file.
3.  Optionally enter a theme name and select italics for RStudio conversions.
4.  Review the preview panels.
5.  Download the converted theme file.

## Files

-   `app.R` - Shiny application source
-   `_brand.yml` - Theme and branding configuration for the app UI
