library(shiny)
library(bslib)
library(shinyAce)
library(rstudiothemes)
library(brand.yml)

link_github <- tags$a(
  shiny::icon("github"),
  href = "https://github.com/dieghernan/themeconverter",
  target = "_blank"
)

# Helper: read file or pasted text
read_input <- function(file, text) {
  if (!is.null(file)) {
    paste(readLines(file$datapath, warn = FALSE), collapse = "\n")
  } else if (nzchar(text)) {
    text
  } else {
    NULL
  }
}

# Helper: detect syntax mode for Ace
detect_mode <- function(text) {
  if (grepl("^\\s*\\{", text)) "json" else "xml"
}

# Helper: normalize theme name input for rstudiothemes API
normalize_theme_name <- function(name) {
  if (is.null(name) || is.na(name) || !nzchar(trimws(as.character(name)))) {
    return(NULL)
  }
  name
}

# UI -----
ui <- page_navbar(
  title = "Theme Converter",
  window_title = "Theme Converter App",
  theme = bs_theme(brand = TRUE, version = 5),
  nav_panel(
    title = "App",
    titlePanel("Theme Converter Suite"),

    # Summary pane with app purpose and RStudio theme install instructions
    wellPanel(
      h4("About this app"),
      p(
        "Convert themes between VSCode (.json), tmTheme (.tmTheme), and RStudio (.rstheme) formats."
      ),
      p(
        "Use the three tabs below to provide a source theme by uploading or pasting it, optionally specify a theme name, and then download the converted file."
      ),
      h5("Install & use converted RStudio themes"),
      tags$ul(
        tags$li(
          "Install the rstudiothemes package: ",
          code("install.packages('rstudiothemes')")
        ),
        tags$li("Place the .rstheme file in a convenient folder."),
        tags$li(
          "In RStudio, go to Tools > Global Options > Appearance > Add... to import .rstheme."
        ),
        tags$li(
          "Or run: ",
          code("rstudiothemes::apply_theme('path/to/your.rstheme')")
        )
      )
    ) |>
      tagAppendAttributes(class = "my-4 mx-2"),
    tabsetPanel(
      ## --- TAB 1: VSCode / tmTheme → RStudio ------------------------------------
      tabPanel(
        "To RStudio (.rstheme)",
        sidebarLayout(
          sidebarPanel(
            width = 5,
            textInput(
              "name_rstudio",
              "Theme name",
              value = NULL,
              placeholder = "optional"
            ),
            checkboxInput("italics", "Use italics", TRUE),

            tags$hr(),
            # DRAG & DROP AREA
            div(
              id = "drop_rstudio",
              class = "dropzone",
              "Drag your VSCode (.json) or tmTheme (.tmTheme) file here"
            ),

            fileInput(
              "file_in_rstudio",
              NULL,
              accept = c(".json", ".tmTheme")
            ) |>
              tagAppendAttributes(class = "input-group input-group-sm"),

            tags$hr(),
            textAreaInput(
              "text_in_rstudio",
              "Or paste the theme code",
              height = "200px"
            )
          ),

          mainPanel(
            width = 7,
            h3("Status"),
            verbatimTextOutput("status_rstudio"),
            downloadButton(
              "download_rstudio",
              "Download .rstheme",
              class = "btn-success my-4"
            ),

            fluidRow(
              column(
                6,
                h3("Input"),
                aceEditor(
                  "preview_rstudio_before",
                  mode = "json",
                  theme = "github",
                  readOnly = TRUE,
                  height = "300px"
                )
              ),
              column(
                6,
                h3("Output"),
                aceEditor(
                  "preview_rstudio_after",
                  mode = "css",
                  theme = "github",
                  readOnly = TRUE,
                  height = "300px"
                )
              )
            )
          ) |>
            tagAppendAttributes(class = "pt-3")
        )
      ),

      ## --- TAB 2: tmTheme → VSCode ----------------------------------------------
      tabPanel(
        "tmTheme → VSCode (.json)",
        sidebarLayout(
          sidebarPanel(
            width = 5,
            textInput(
              "name_vscode",
              "Theme name",
              value = NULL,
              placeholder = "optional"
            ),
            tags$hr(),

            div(
              id = "drop_vscode",
              class = "dropzone",
              "Drag your tmTheme (.tmTheme) file here"
            ),

            fileInput("file_in_vscode", NULL, accept = ".tmTheme") |>
              tagAppendAttributes(class = "input-group input-group-sm"),

            tags$hr(),
            textAreaInput(
              "text_in_vscode",
              "Or paste the tmTheme XML",
              height = "200px"
            )
          ),

          mainPanel(
            width = 7,
            h3("Status"),
            verbatimTextOutput("status_vscode"),
            downloadButton(
              "download_vscode",
              "Download VSCode (.json)",
              class = "btn-success my-4"
            ),

            fluidRow(
              column(
                6,
                h3("Input"),
                aceEditor(
                  "preview_vscode_before",
                  mode = "xml",
                  theme = "github",
                  readOnly = TRUE,
                  height = "300px"
                )
              ),
              column(
                6,
                h3("Output"),
                aceEditor(
                  "preview_vscode_after",
                  mode = "json",
                  theme = "github",
                  readOnly = TRUE,
                  height = "300px"
                )
              )
            )
          ) |>
            tagAppendAttributes(class = "pt-3")
        )
      ),

      ## --- TAB 3: VSCode → tmTheme ----------------------------------------------
      tabPanel(
        "VSCode → tmTheme (.tmTheme)",
        sidebarLayout(
          sidebarPanel(
            width = 5,
            textInput(
              "name_tmtheme",
              "Theme name",
              value = NULL,
              placeholder = "optional"
            ),
            tags$hr(),
            div(
              id = "drop_tmtheme",
              class = "dropzone",
              "Drag your VSCode (.json) file here"
            ),

            fileInput("file_in_tmtheme", NULL, accept = ".json") |>
              tagAppendAttributes(class = "input-group input-group-sm"),

            tags$hr(),
            textAreaInput(
              "text_in_tmtheme",
              "Or paste the VSCode JSON",
              height = "200px"
            ),
            tags$hr(),
            textInput(
              "name_tmtheme",
              "Theme name",
              value = NULL,
              placeholder = "optional"
            )
          ),

          mainPanel(
            width = 7,
            h3("Status"),
            verbatimTextOutput("status_tmtheme"),
            downloadButton(
              "download_tmtheme",
              "Download tmTheme (.tmTheme)",
              class = "btn-success my-4"
            ),

            fluidRow(
              column(
                6,
                h3("Input"),
                aceEditor(
                  "preview_tmtheme_before",
                  mode = "json",
                  theme = "github",
                  readOnly = TRUE,
                  height = "300px"
                )
              ),
              column(
                6,
                h3("Output"),
                aceEditor(
                  "preview_tmtheme_after",
                  mode = "xml",
                  theme = "github",
                  readOnly = TRUE,
                  height = "300px"
                )
              )
            )
          ) |>
            tagAppendAttributes(class = "pt-3")
        )
      )
    ),

    # JAVASCRIPT DRAG & DROP HANDLER
    tags$script(HTML(
      "
    function enableDropzone(dropId, inputId) {
      const drop = document.getElementById(dropId);
      const input = document.getElementById(inputId);

      drop.addEventListener('click', () => input.click());

      drop.addEventListener('dragover', (e) => {
        e.preventDefault();
        drop.classList.add('dragover');
      });

      drop.addEventListener('dragleave', () => {
        drop.classList.remove('dragover');
      });

      drop.addEventListener('drop', (e) => {
        e.preventDefault();
        drop.classList.remove('dragover');
        input.files = e.dataTransfer.files;
        input.dispatchEvent(new Event('change'));
      });
    }

    document.addEventListener('DOMContentLoaded', () => {
      enableDropzone('drop_rstudio', 'file_in_rstudio');
      enableDropzone('drop_vscode', 'file_in_vscode');
      enableDropzone('drop_tmtheme', 'file_in_tmtheme');
    });
  "
    ))
  ),
  nav_spacer(),
  nav_item(input_dark_mode()),
  nav_item(link_github),
  navbar_options = navbar_options(
    collapsible = FALSE,
    theme = "auto",
    bg = "#22272e",
    underline = FALSE
  ),
  header = tags$style(HTML(
    "
    .dropzone {
      border: 2px dashed #aaa;
      border-radius: 8px;
      padding: 30px;
      text-align: center;
      color: #666;
      cursor: pointer;
      transition: border-color 0.2s, background-color 0.2s;
      margin-bottom: 15px;
    }
    .dropzone.dragover {
      border-color: #007bff;
      background-color: #eef6ff;
      color: #007bff;
    }
    input[type='file'] {
      display: none;
    }
    a.nav-link.active {display: none;}
    .navbar-brand {font-family: 'Inter Tight'; font-weight: 800;}
  "
  ))
)

# Server ----
server <- function(input, output, session) {
  # --- 1. Convert to RStudio -------------------------------------------------
  converted_rstudio <- reactive({
    raw <- read_input(input$file_in_rstudio, input$text_in_rstudio)
    req(raw)

    extension <- detect_mode(raw)
    ext <- switch(extension, "json" = ".json", "xml" = ".tmTheme")

    tmp_in <- tempfile(fileext = ext)
    tmp_out <- tempfile(fileext = ".rstheme")
    writeLines(raw, tmp_in)

    tryCatch(
      {
        rstudiothemes::convert_to_rstudio_theme(
          path = tmp_in,
          outfile = tmp_out,
          use_italics = input$italics,
          name = normalize_theme_name(input$name_rstudio)
        )
        list(ok = TRUE, path = tmp_out)
      },
      error = function(e) list(ok = FALSE, msg = e$message)
    )
  })

  observe({
    raw <- read_input(input$file_in_rstudio, input$text_in_rstudio)
    if (is.null(raw)) {
      return()
    }
    updateAceEditor(
      session,
      "preview_rstudio_before",
      value = raw,
      mode = detect_mode(raw)
    )
  })

  observe({
    conv <- converted_rstudio()
    if (!conv$ok) {
      return()
    }
    after <- paste(readLines(conv$path, warn = FALSE), collapse = "\n")
    updateAceEditor(
      session,
      "preview_rstudio_after",
      value = after,
      mode = "css"
    )
  })

  output$status_rstudio <- renderText({
    raw <- read_input(input$file_in_rstudio, input$text_in_rstudio)
    if (is.null(raw)) {
      return("Upload or paste a theme to convert.")
    }
    if (!converted_rstudio()$ok) {
      return(paste0("❌ Error: ", converted_rstudio()$msg))
    }
    "✅ Conversion completed."
  })

  output$download_rstudio <- downloadHandler(
    filename = function() "new_theme.rstheme",
    content = function(file) file.copy(converted_rstudio()$path, file)
  )

  # --- 2. tmTheme → VSCode ---------------------------------------------------
  converted_vscode <- reactive({
    raw <- read_input(input$file_in_vscode, input$text_in_vscode)
    req(raw)

    tmp_in <- tempfile(fileext = ".tmTheme")
    tmp_out <- tempfile(fileext = ".json")
    writeLines(raw, tmp_in)

    tryCatch(
      {
        rstudiothemes::convert_tm_to_vs_theme(
          path = tmp_in,
          outfile = tmp_out,
          name = normalize_theme_name(input$name_vscode)
        )
        list(ok = TRUE, path = tmp_out)
      },
      error = function(e) list(ok = FALSE, msg = e$message)
    )
  })

  observe({
    raw <- read_input(input$file_in_vscode, input$text_in_vscode)
    if (is.null(raw)) {
      return()
    }
    updateAceEditor(
      session,
      "preview_vscode_before",
      value = raw,
      mode = detect_mode(raw)
    )
  })

  observe({
    conv <- converted_vscode()
    if (!conv$ok) {
      return()
    }
    after <- paste(readLines(conv$path, warn = FALSE), collapse = "\n")
    updateAceEditor(
      session,
      "preview_vscode_after",
      value = after,
      mode = "json"
    )
  })

  output$status_vscode <- renderText({
    raw <- read_input(input$file_in_vscode, input$text_in_vscode)
    if (is.null(raw)) {
      return("Upload or paste a tmTheme file.")
    }
    if (!converted_vscode()$ok) {
      return(paste0("❌ Error: ", converted_vscode()$msg))
    }
    "✅ Conversion completed."
  })

  output$download_vscode <- downloadHandler(
    filename = function() "new_theme.json",
    content = function(file) file.copy(converted_vscode()$path, file)
  )

  # --- 3. VSCode → tmTheme ---------------------------------------------------
  converted_tmtheme <- reactive({
    raw <- read_input(input$file_in_tmtheme, input$text_in_tmtheme)
    req(raw)

    tmp_in <- tempfile(fileext = ".json")
    tmp_out <- tempfile(fileext = ".tmTheme")
    writeLines(raw, tmp_in)

    tryCatch(
      {
        rstudiothemes::convert_vs_to_tm_theme(
          path = tmp_in,
          outfile = tmp_out,
          name = normalize_theme_name(input$name_tmtheme)
        )
        list(ok = TRUE, path = tmp_out)
      },
      error = function(e) list(ok = FALSE, msg = e$message)
    )
  })

  observe({
    raw <- read_input(input$file_in_tmtheme, input$text_in_tmtheme)
    if (is.null(raw)) {
      return()
    }
    updateAceEditor(
      session,
      "preview_tmtheme_before",
      value = raw,
      mode = detect_mode(raw)
    )
  })

  observe({
    conv <- converted_tmtheme()
    if (!conv$ok) {
      return()
    }
    after <- paste(readLines(conv$path, warn = FALSE), collapse = "\n")
    updateAceEditor(
      session,
      "preview_tmtheme_after",
      value = after,
      mode = "xml"
    )
  })

  output$status_tmtheme <- renderText({
    raw <- read_input(input$file_in_tmtheme, input$text_in_tmtheme)
    if (is.null(raw)) {
      return("Upload or paste a VSCode file.")
    }
    if (!converted_tmtheme()$ok) {
      return(paste0("❌ Error: ", converted_tmtheme()$msg))
    }
    "✅ Conversion completed."
  })

  output$download_tmtheme <- downloadHandler(
    filename = function() "new_theme.tmTheme",
    content = function(file) file.copy(converted_tmtheme()$path, file)
  )
}

shinyApp(ui, server)
