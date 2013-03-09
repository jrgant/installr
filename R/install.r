


#' @title Extract the file name from some URL
#' @description Gets a character of link to some file, and returns the name of the file in this link.
#' @details
#' The install.packages.zip must use this function, since it is crucial that the name of the file into which the ZIPPED package is downloaded to the computer, will have the same name as the file which is online.
#' @param URL Some url to a file.
#' @return The name of the file in the URL
#' @export
#' @seealso \code{\link{install.URL}}, \code{\link{install.packages.zip}}
#' @examples
#' \dontrun{
#' file.name.from.url("http://cran.r-project.org/bin/windows/base/R-2.15.3-win.exe") # returns: "R-2.15.3-win.exe"
#' }
file.name.from.url <- function(URL) tail(strsplit(URL,   "/")[[1]],1)




#' @title Downloads and installs a ZIP R package Binary (for Windows) from a URL
#' @description Gets a character with a link to an R package Binary, downloads it, and installs it.
#' @details
#' To my knowledge, there is currently three ways to install packages on R:
#' 1. To get the package through a repository (such as CRAN or RForge) through install.packages.
#' 2. To manually download a ZIP file locally to the computer, and use install.packages on it.
#' 3. To get the package from github, by using devtools (but this will require you to first install RTools, and not everyone wishes to do it for just some package).
#' This function aims to combine option 1 and 2, by automatically downloading the ZIP file locally and then running install.packages on it. After being downloaded and installed, the binary is erased from the computer.
#' @param zip_URL a link to a ZIP R package Binary.
#' @return Invisible NULL
#' @export
#' @seealso \code{\link{install.packages}}
#' @examples
#' \dontrun{
#' install.packages.zip("http://cran.r-project.org/bin/windows/contrib/r-release/devtools_1.1.zip")
#' }
install.packages.zip <- function(zip_URL) {
   # zip_URL is the URL for the package_name.zip file
   zip_filename <- file.path(tempdir(), file.name.from.url(zip_URL))   # the name of the zip file MUST be as it was downloaded...
   download.file(zip_URL, destfile=zip_filename, mode = 'wb')   
   install.packages(pkgs= zip_filename, repos=NULL)   
   unlink(zip_filename)
   invisible(NULL)
}
# a simple example of use:
# install.packages.zip(zip_URL="http://cran.r-project.org/bin/windows/contrib/r-release/TeachingSampling_2.0.1.zip")



#' @title Downloads and runs a .exe installer file for some software from a URL
#' @description Gets a character with a link to an installer file, downloads it, runs it, and then erases it.
#' @details
#' This function is used by many functions in the installr package.
#' The .exe file is downloaded into a temporary directory, where it is erased after installation has started (by default - though this can be changed)
#' @param exe_URL A character with a link to an installer file (with the .exe file extension)
#' @param keep_install_file If TRUE - the installer file will not be erased after it is downloaded and run.
#' @param wait should the R interpreter wait for the command to finish? The default is to NOT wait.
#' @param ... parameters passed to 'shell'
#' @return TRUE/FALSE - was the installation successful or not. (this is based on the output of shell of running the command being either 0 or 1/2.  0 means the file was succesfully installed, while 1 or 2 means there was a failure in running the installer.)
#' @seealso \link{shell}
#' @export
#' @author GERGELY DAROCZI, Tal Galili
#' @examples
#' # install.URL() 
install.URL <- function(exe_URL, keep_install_file = FALSE, wait = TRUE, ...) {
   # source: http://stackoverflow.com/questions/15071957/is-it-possible-to-install-pandoc-on-windows-using-an-r-command
   # input: a url of an .exe file to install
   # output: it runs the .exe file (for installing something)   
   exe_filename <- file.path(tempdir(), file.name.from.url(exe_URL))   # the name of the zip file MUST be as it was downloaded...
   download.file(exe_URL, destfile=exe_filename, mode = 'wb')
   if(!keep_install_file & !wait) {
      wait <- TRUE
      warning("wait was set to TRUE since you wanted to installation file removed. In order to be able to run the installer AND remove the file - we must first wait for the isntaller to finish running before removing the file.")
   }
   shell_output <- shell(exe_filename, wait = wait,...) # system(exe_filename) # I suspect shell works better than system
   if(!keep_install_file) unlink(exe_filename, force = TRUE) # on.exit(unlink(exe_filename)) # on.exit doesn't work in case of problems in the running of the file
   # unlink can take some time until done, for some reason.
      #    file.remove(exe_filename)
      #    file.info(exe_filename)
      #    file.access(exe_filename, mode = 0)
      #    file.access(exe_filename, mode = 1)
      #    file.access(exe_filename, mode = 2)
      #    file.access(exe_filename, mode = 3)
   return(shell_output == 0)
   # error code 1/2 means that we couldn't finish running the file
   # # 0 means - the file was succesfully installed.   
}



#' @title Downloads and installs pandoc
#' @description Downloads and installs the latest version of pandoc for Windows.
#' @details
#' pandoc is a free open source software for converting documents from many filetypes to many filetypes.  For details, see \url{http://johnmacfarlane.net/pandoc/}.
#' 
#' Credit: the code in this function is based on GERGELY DAROCZIs coding in his answer on the Q&A forum StackOverflow, and also G. Grothendieck for the non-XML addition to the function. 
#' I thank them both!
#' @return TRUE/FALSE - was the installation successful or not.
#' @export
#' @author GERGELY DAROCZI, G. Grothendieck, Tal Galili
#' @param page_with_download_url a link to the list of download links of pandoc
#' @param use_regex (default TRUE) should the regex method be used to extract exe links, or should the XML package be used.
#' @source \url{http://stackoverflow.com/questions/15071957/is-it-possible-to-install-pandoc-on-windows-using-an-r-command}
#' @examples
#' \dontrun{
#' install.pandoc() 
#' }
install.pandoc <- function(
   page_with_download_url = 'http://code.google.com/p/pandoc/downloads/list',
   use_regex = T
) {
   # source: http://stackoverflow.com/questions/15071957/is-it-possible-to-install-pandoc-on-windows-using-an-r-command
   # published on: http://www.r-statistics.com/2013/02/installing-pandoc-from-r-on-windows/
   
   
   if(use_regex) {
      page     <- readLines(page_with_download_url, warn = FALSE)
      pat <- "//pandoc.googlecode.com/files/pandoc-[0-9.]+-setup.exe"; 
      target_line <- grep(pat, page, value = TRUE); 
      m <- regexpr(pat, target_line); 
      URL      <- regmatches(target_line, m) # (The http still needs to be prepended.
      URL      <- paste('http', URL, sep = ':')
   } else { # use XML
      if(!require(XML)) stop("You need to install the {XML} package in order to use this function.")
      page     <- readLines(page_with_download_url, warn = FALSE)
      pagetree <- htmlTreeParse(page, error=function(...){}, useInternalNodes = TRUE, encoding='UTF-8')
      URL      <- xpathSApply(pagetree, '//tr[2]//td[1]//a ', xmlAttrs)[1]
      URL      <- paste('http', URL, sep = ':')
   }
   
   install.URL(URL)
}

#' @title Check if a number is integer
#' @description Returns TRUE/FALSE on whether a number is integer or not.
#' @details
#' Surprising as it may be, R doesn't come with a handy function to check if the number is integer.
#' This function does just this.
#' @param N A number (if a vector is supplied only the first element is checked - without warning)
#' @return TRUE/FALSE on whether a number is integer or not.
#' @author VitoshKa
#' @source \url{http://stackoverflow.com/questions/3476782/how-to-check-if-the-number-is-integer}
#' @examples
#' check.integer <- installr:::check.integer
#' check.integer(4) # TRUE
#' check.integer(3243) #TRUE
#' check.integer(3243.34) #FALSE
#' check.integer("sdfds") #FALSE
#' check.integer(1e4) #TRUE
#' check.integer(1e6) #TRUE
#' check.integer(1e600) #FALSE - the function is having a hardtime with Inf...
#' rm(check.integer)
check.integer <- function(N){
   # source: http://stackoverflow.com/questions/3476782/how-to-check-if-the-number-is-integer
   # author: VitoshKa
   
   # notice that the function "is.integer" is used by based R for checking the object if it is of type integer.
   
   # TODO: one day - to vectorize this.
   
   !length(grep("[^[:digit:]]", format(N[1], scientific = FALSE)))
}
# check.integer(3)


#' @title Asks the user for a row number from a data.frame table
#' @description The function gets a data.frame and asks the user to choose a row number.  Once choosen, that row number is returned from the function.
#' @details
#' This function is used in \code{installr} when we are not sure what version of the software to download, or when various actions are available for the user to choose from.
#' If the user doesn't give a valid row number, the function repeats its questions until a valid row number is chosen (or the user escapes)
#' @param TABLE a data.frame table with rows from which we wish the user to choose a row.  If TABLE is not a data.frame, it will be coerced into one.
#' @param header_text the text the users sees (often a question) as a title for the printed table - explaining which row he should choose from
#' @param questions_text the question the users see after the printing of the table - explaining which row he should choose from
#' @return The row number the user has choosen from the data.frame table.
#' @source On how to ask the user for input: \url{http://stackoverflow.com/questions/5974967/what-is-the-correct-way-to-ask-for-user-input-in-an-r-program}
#' @examples
#' \dontrun{
#' version_table <- data.frame(versions = c("devel", "V 1.0.0", "V 2.0.0"))
#' installr:::ask.user.for.a.row(version_table)
#' }
ask.user.for.a.row <- function(TABLE, 
                               header_text = "Possible versions to download (choose one)",
                               questions_text = "Please review the table of versions from above, \n  and enter the row number of the file-version you'd like to install: ") {
   # http://stackoverflow.com/questions/5974967/what-is-the-correct-way-to-ask-for-user-input-in-an-r-program
   # based on code by Joris Meys
   if(class(TABLE) != "data.frame") {
      TABLE <- as.data.frame(TABLE)
      colnames(TABLE)[1] <- "Choose:"
   }
   
   rownames(TABLE) <- seq_len(nrow(TABLE))# makes sure that the table's row names are in the "rownames"
   
   correct_input <- F
   nrow_TABLE <- nrow(TABLE)
   
   while(!correct_input){# n is the row number from the user
      cat("=============",header_text,"====================\n")      
      print(TABLE)
      ROW_id <- readline(questions_text)
      ROW_id <- as.numeric(ROW_id)
      correct_input <- 
         !is.na(ROW_id) && # don't check other condition if this is not met.
         check.integer(ROW_id) & # is integer AND
         ROW_id >= 1 & # make sure our ROW_id is within range (between 1 and the number of rows in the table)
         ROW_id <= nrow_TABLE
      if(!correct_input) cat("Wrong input: Please enter a valid number (integer, between 1 to the number of rows) \n  for the row number of your choice\n")
      # if(is.na(n)){break}  # breaks when hit enter
   }
   
   ROW_id
}

# ask.user.for.a.row(TABLE)




#' @title Downloads and installs Rtools
#' @description Allows the user to choose, downloads and install - the latest version of Rtools for Windows.
#' @details
#' RTools is a collection of software for building packages for R under Microsoft Windows, or for building R itself (version 1.9.0 or later).
#' The original collection was put together by Prof. Brian Ripley; it is currently being maintained by Duncan Murdoch.
#' @param choose_version if TRUE, allows the user to choose which version of RTools to install.  Useful if you wish to install the devel version of RTools, or if you are running on an old version of R which requires an old version of R.
#' @param latest_Frozen if FALSE (and choose_version is FALSE) the function installs the latest devel version of RTools (good for people using the devel version of R).  If TRUE (default), the latest frozen version of RTools is installed.
#' @param page_with_download_url the URL of the RTools download page.
#' @return TRUE/FALSE - was the installation successful or not.
#' @export
#' @references
#' RTools homepage (for other resources and documentation): \url{http://cran.r-project.org/bin/windows/Rtools/}
#' @examples
#' \dontrun{
#' install.Rtools() # installs the latest frozen version of RTools
#' install.Rtools(F, F) # installs the latest devel version of RTools
#' install.Rtools(T) # choose your version
#' }
install.Rtools <- function(choose_version = FALSE,
                           latest_Frozen = FALSE,
                           page_with_download_url = 'http://cran.r-project.org/bin/windows/Rtools/'
) {
   # choose_version==T allows the user to choose which version of Rtools he wishes to install
   # latest_Frozen==T means we get the latest Rtools version which is Frozen (when writing this function it is Rtools215.exe)
   # latest_Frozen==F means we get the latest Rtools version which is not Frozen (when writing this function it is Rtools30.exe)
   
   
   if(!require(XML)) stop("You need to install the {XML} package in order to use this function.")
   TABLE <- readHTMLTable(page_with_download_url, header=T,stringsAsFactors=F)[[1]]
   # example: http://stackoverflow.com/questions/1395528/scraping-html-tables-into-r-data-frames-using-the-xml-package
   
   
   if(choose_version) {
      cat("Please remember you are using: ", R.version$version.string , "\n")
      ROW_id <- ask.user.for.a.row(TABLE)
      exe_filename <- TABLE[ROW_id,"Download"] # the version the user asked for
   } else { # if we choose the version for the user, we rely on latest_Frozen
      if(latest_Frozen) {
         ss <- TABLE[,"Frozen?"] == "Yes"
         exe_filename <- TABLE[ss,"Download"][1] # the latest Frozen filename
      } else { # choose the latest un-frozen (e.g: bleeding edge)
         ss <- TABLE[,"Frozen?"] == "No"
         exe_filename <- TABLE[ss,"Download"] # the latest un-Frozen filename
      }
   }
   
   
   URL <- paste(page_with_download_url, exe_filename, sep = '')
   
   install.URL(URL)   
}




#' @title Downloads and installs git and git-gui for windows
#' @description Allows the user to downloads and install the latest version of git for Windows.
#' @details
#' Git is a distributed revision control and source code management system with an emphasis on speed.
#' @param page_with_download_url the URL of the git download page.
#' @return TRUE/FALSE - was the installation successful or not.
#' @export
#' @references
#' git homepage: \url{http://git-scm.com/}
#' git download page: \url{http://git-scm.com/download/win}
#' @examples
#' \dontrun{
#' install.git() # installs the latest version of git
#' }
install.git <- function(page_with_download_url="http://git-scm.com/download/win") {
   # "http://git-scm.com/download/win"
   # get download URL:
   page     <- readLines(page_with_download_url, warn = FALSE)
   # https://msysgit.googlecode.com/files/Git-1.8.1.2-preview20130201.exe
   pat <- "//msysgit.googlecode.com/files/Git-[0-9.]+-preview[0-9.]+.exe"; 
   target_line <- grep(pat, page, value = TRUE); 
   m <- regexpr(pat, target_line); 
   URL      <- regmatches(target_line, m) # (The http still needs to be prepended.
   URL      <- paste('https', URL, sep = ':')[1] # we might find the same file more than once - so we'll only take its first one
   
   # install.
   install.URL(URL)   
}



#' @title Downloads and installs MikTeX for windows
#' @description Allows the user to downloads and install the latest version of MikTeX for Windows.
#' @details
#' MiKTeX is a typesetting system for Microsoft Windows that is developed by Christian Schenk. It consists of an implementation of TeX and a set of related programs. MiKTeX provides the tools necessary to prepare documents using the TeX/LaTeX markup language, as well a simple tex editor (TeXworks).
#' 
#' MiKTeX is essential for using Sweave, knitr, and creating Vignette for R packages.
#' @param version gets the values 32 and 64. Deciding if we should install version 32bit or 64bit. If missing (default) the user is prompted for a decisioin.
#' @param page_with_download_url the URL of the MikTeX download page.
#' @return TRUE/FALSE - was the installation successful or not.
#' @export
#' @references
#' MikTeX homepage: \url{http://miktex.org/}
#' MikTeX download page: \url{http://miktex.org/download}
#' @examples
#' \dontrun{
#' install.MikTeX() # installs the latest version of git
#' }
install.MikTeX  <- function(version, page_with_download_url="http://miktex.org/download") {
   if(missing(version)) {
      version <- ifelse(ask.user.for.a.row(data.frame(version = c(32, 64)), "Which version of MiKTeX do you want?") == 1,
                        32, 64)
   } else { 
      if(!(version %in% c(32,64)))       version <- ifelse(ask.user.for.a.row(data.frame(version = c(32, 64)), "Which version of MiKTeX do you want?") == 1,
                                                           32, 64)      
   }
   
   # get download URL:
   if(version == 32) {
      page     <- readLines(page_with_download_url, warn = FALSE)
      #"http://mirrors.ctan.org/systems/win32/miktex/setup/basic-miktex-2.9.4757.exe
      # "http://mirrors.ctan.org/systems/win32/miktex/setup/basic-miktex-2.9.4757-x64.exe"
      pat <- "//mirrors.ctan.org/systems/win32/miktex/setup/basic-miktex-[0-9.]+.exe"; 
      target_line <- grep(pat, page, value = TRUE); 
      m <- regexpr(pat, target_line); 
      URL      <- regmatches(target_line, m) # (The http still needs to be prepended.
      URL      <- paste('http', URL, sep = ':')[1] # we might find the same file more than once - so we'll only take its first one
   } else { # else -> version == 64
      page     <- readLines(page_with_download_url, warn = FALSE)
      #"http://mirrors.ctan.org/systems/win32/miktex/setup/basic-miktex-2.9.4757.exe
      # "http://mirrors.ctan.org/systems/win32/miktex/setup/basic-miktex-2.9.4757-x64.exe"
      pat <- "//mirrors.ctan.org/systems/win32/miktex/setup/basic-miktex-[0-9.]+-x64.exe"; 
      target_line <- grep(pat, page, value = TRUE); 
      m <- regexpr(pat, target_line); 
      URL      <- regmatches(target_line, m) # (The http still needs to be prepended.
      URL      <- paste('http', URL, sep = ':')[1] # we might find the same file more than once - so we'll only take its first one      
   }
   # install.
   install.URL(URL)   
}

# install.MikTeX()   

# 
# installR <- function(what) {
# # matches a character with what to install...
# 
# }
# 


#' @title Downloads and installs RStudio for windows
#' @description Allows the user to downloads and install the latest version of RStudio for Windows.
#' @details
#' RStudio is a free and open source integrated development environment (IDE) for R, a programming language for statistical computing and graphics.
#' @param page_with_download_url the URL of the RStudio download page.
#' @return TRUE/FALSE - was the installation successful or not.
#' @export
#' @references
#' \itemize{
#' \item RStudio homepage: \url{http://www.rstudio.com/}
#' \item devtools::source_url \url{http://rgm3.lab.nig.ac.jp/RGM/r_function?p=devtools&f=source_url}
#' } 
#' @examples
#' \dontrun{
#' install.RStudio() # installs the latest version of git
#' }
install.RStudio  <- function(page_with_download_url="http://www.rstudio.com/ide/download/desktop") {    
   # get download URL:
   page     <- readLines(page_with_download_url, warn = FALSE)
   # http://download1.rstudio.org/RStudio-0.97.318.exe#
   pat <- "//download1.rstudio.org/RStudio-[0-9.]+.exe"; 
   target_line <- grep(pat, page, value = TRUE); 
   m <- regexpr(pat, target_line); 
   URL      <- regmatches(target_line, m) # (The http still needs to be prepended.
   URL      <- paste('http', URL, sep = ':')[1] # we might find the same file more than once - so we'll only take its first one
   
   # install.
   install.URL(URL)   
}




#' @title Downloads and installs ImageMagick for windows
#' @description Allows the user to downloads and install the latest version of ImageMagick for Windows.
#' @details
#' ImageMagick® is a software suite to create, edit, compose, or convert bitmap images. It can read and write images in a variety of formats (over 100) including DPX, EXR, GIF, JPEG, JPEG-2000, PDF, PhotoCD, PNG, Postscript, SVG, and TIFF. Use ImageMagick to resize, flip, mirror, rotate, distort, shear and transform images, adjust image colors, apply various special effects, or draw text, lines, polygons, ellipses and Bézier curves.
#' This function downloads Win32 dynamic at 16 bits-per-pixel.
#' @param page_with_download_url the URL of the ImageMagick download page.
#' @return TRUE/FALSE - was the installation successful or not.
#' @export
#' @references
#' \itemize{
#' \item ImageMagick homepage: \url{http://www.imagemagick.org/script/index.php}
#' } 
#' @examples
#' \dontrun{
#' install.ImageMagick() # installs the latest version of git
#' }
install.ImageMagick  <- function(page_with_download_url="http://www.imagemagick.org/script/binary-releases.php") {    
   # get download URL:
   page     <- readLines(page_with_download_url, warn = FALSE)
   # http://www.imagemagick.org/download/binaries/ImageMagick-6.8.3-8-Q16-x86-dll.exe
   pat <- "//www.imagemagick.org/download/binaries/ImageMagick-[0-9.]+-8-Q16-x86-dll.exe"; 
   target_line <- grep(pat, page, value = TRUE); 
   m <- regexpr(pat, target_line); 
   URL      <- regmatches(target_line, m) # (The http still needs to be prepended.
   URL      <- paste('http', URL, sep = ':')[1] # we might find the same file more than once - so we'll only take its first one
   
   # install.
   install.URL(URL)   
}







#' @title Downloads and installs GraphicsMagick for windows
#' @description Allows the user to downloads and install the latest version of GraphicsMagick for Windows.
#' @details
#' GraphicsMagick is the swiss army knife of image processing. Comprised of 282K physical lines (according to David A. Wheeler's SLOCCount) of source code in the base package (or 964K including 3rd party libraries) it provides a robust and efficient collection of tools and libraries which support reading, writing, and manipulating an image in over 88 major formats including important formats like DPX, GIF, JPEG, JPEG-2000, PNG, PDF, PNM, and TIFF.
#' This function downloads Win32 dynamic at 16 bits-per-pixel.
#' @param page_with_download_url the URL of the ImageMagick download page.
#' @return TRUE/FALSE - was the installation successful or not.
#' @export
#' @references
#' \itemize{
#' \item GraphicsMagick homepage: \url{http://www.graphicsmagick.org/}
#' } 
#' @examples
#' \dontrun{
#' install.GraphicsMagick() # installs the latest version of git
#' }
install.GraphicsMagick  <- function(page_with_download_url="http://sourceforge.net/projects/graphicsmagick/") {    
   # get download URL:
   page     <- readLines(page_with_download_url, warn = FALSE)
   # http://downloads.sourceforge.net/project/graphicsmagick/graphicsmagick-binaries/1.3.17/GraphicsMagick-1.3.17-Q16-windows-dll.exe?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fgraphicsmagick%2Ffiles%2F&ts=1362862824&use_mirror=garr
   # http://sourceforge.net/projects/graphicsmagick/files/graphicsmagick-binaries/1.3.17/GraphicsMagick-1.3.17-Q8-windows-dll.exe/download
   pat <- "//sourceforge.net/projects/graphicsmagick/files/graphicsmagick-binaries/[0-9.]+/GraphicsMagick-[0-9.]+-Q16-windows-dll.exe"  
   target_line <- grep(pat, page, value = TRUE); 
   m <- regexpr(pat, target_line); 
   URL      <- regmatches(target_line, m) # (The http still needs to be prepended.
   URL      <- paste('http', URL, sep = ':')[1] # we might find the same file more than once - so we'll only take its first one
   
   # install.
   install.URL(URL)   
}




#' @title Downloads and installs GitHub for windows
#' @description Allows the user to downloads and install the latest version of GitHub for Windows.
#' @details
#' "The easiest way to use Git on Windows." (at least so they say...)
#' @param URL the URL of the GitHub download page.
#' @return TRUE/FALSE - was the installation successful or not.
#' @export
#' @references
#' \itemize{
#' \item GitHub homepage: \url{https://github.com/}
#' \item GitHub for windows download page: \url{http://windows.github.com/}
#' } 
#' @examples
#' \dontrun{
#' install.GitHub() # installs the latest version of git
#' }
install.GitHub <- function(URL = "http://github-windows.s3.amazonaws.com/GitHubSetup.exe") {
   # https://help.github.com/articles/set-up-git
   install.URL(URL)
}










#' @title Read R Code from a File in an https URL
#' @description source.https causes R to accept its input from a File in an https URL.
#' Input is read and parsed from that file until the end of the file is reached, then the parsed expressions are evaluated sequentially in the chosen environment.
#' @details
#' "The easiest way to use Git on Windows." (at least so they say...)
#' @param URL the URL of the .r file to download and source.
#' @param ... parameters to pass to \link{source}
#' @param remove_r_file if to remove the .r file after it was sourced.
#' @return Nothing.
#' @export
#' @seealso \link{source}
#' @references
#' Other solutions to the source.https problem:
#' \itemize{
#' \item Using RCurl: \url{http://tonybreyal.wordpress.com/2011/11/24/source.https-sourcing-an-r-script-from-github/}
#' \item devtools::source_url \url{http://rgm3.lab.nig.ac.jp/RGM/r_function?p=devtools&f=source_url}
#' \item A erlevant (OLD) discussion: http://stackoverflow.com/questions/7715723/sourcing-r-script-over-https
#' }
#' @examples
#' \dontrun{
#' source.https("https://raw.github.com/talgalili/installr/master/R/install.r") 
#' }
source.https <- function(URL,..., remove_r_file = T) {
   # this is an alternative to this code: http://tonybreyal.wordpress.com/2011/11/24/source.https-sourcing-an-r-script-from-github/
   # but one which does not require RCurl
   r_filename <- file.path(tempdir(), file.name.from.url(URL))   # the name of the zip file MUST be as it was downloaded...
   download.file(URL, destfile=r_filename, mode = 'wb')     
   source(r_filename,...)
   if(remove_r_file) unlink(r_filename)
   invisible(T)
}

# 
# # being able to source from github
# source("http://www.r-statistics.com/wp-content/uploads/2012/01/source.https.r.txt")
# source.https("source url for install.packages.zip")
# install.packages.zip("URL/installR.zip")
# # actually use functions...
# 
# 






#' @title Shut down the operating system with the command `shutdown'
#' @export
#' @description
#' There is a command \command{shutdown} in both Windows and Linux,
#' and this function uses it to shut down a computer.
#'
#' After the time \code{wait} has passed, R will execute \command{shutdown -s -t 0} (for Windows) or \command{shutdown -h now} to shut down the computer.
#' 
#' This function is a modified version of Yihui's shutdown function from the {fun} package.
#' @param s time to wait before shutting down (in seconds), added to m and h; passed to \code{\link[base]{Sys.sleep}}
#' @param m time to wait before shutting down (in minutes), added to s and h; passed to \code{\link[base]{Sys.sleep}}
#' @param h time to wait before shutting down (in hours), added to s and m; passed to \code{\link[base]{Sys.sleep}}
#' @return The status code of \code{\link[base]{system}}.
#' @author Yihui Xie <\url{http://yihui.name}>, and Tal Galili
#' @seealso \code{\link[base]{system}},\code{\link[base]{shell}}, \code{\link[base]{Sys.sleep}}, \code{\link{is.windows}}
#' @references \url{http://cos.name/en/topic/shut-down-your-windows-with-r} , \url{https://github.com/yihui/fun/blob/master/R/shutdown.R}
#' @examples
#' \dontrun{
#' ## when your code is extremely time-consuming, you may need this function; e.g. you go to sleep, and R is running long computation... complex graphics... and long long computation... at last,
#' shutdown()
#' ## the next day you wake up, "thank you, R" :)
#' }
shutdown = function(s=0, m=0, h=0) {
   
   wait <- s + m*60 + h*60*60
   Sys.sleep(wait)
   
   ifelse(is.windows(), 
          shell("shutdown -s -t 0", wait = F),# without wait =F, the shuting down will not work properly since Windows will wait for R to close (which will be waiting for Windows to shutdown)
          system("shutdown -h now"))
}





#' @title Installing software from R
#' @export
#' @description Gives the user the option to download software from within R.
#' @param use_GUI a logical indicating whether a graphics menu should be used if available.  If TRUE, and on Windows, it will use \link{winDialog}, otherwise it will use \link[utils]{menu}.
#' @param ... not in use
#' @return TRUE/FALSE - if the software was installed succesfully or no.
#' @seealso \link{updateR}, \link{install.R}, \link{install.URL}, 
#' \link{install.RStudio}, \link{install.Rtools}, \link{install.pandoc}, \link{install.packages.zip},
#' \link{install.MikTeX}, \link{install.git}, \link{install.git}, \link{check.for.updates.R}
#' 
#' @examples
#' \dontrun{
#' installr()
#' }
installr <- function(use_GUI = TRUE, ...) {
   choices <- c("R",
                "RStudio",
                "Rtools",
                "git",
                "MikTeX",
                "pandoc",
                "GitHub",
                "ImageMagick",
                "GraphicsMagick",
                "Cancel")
   
   the_answer <- menu(choices, graphics = use_GUI, title = "Which software (for Windows) would you like to install?")            
   
   switch(the_answer, 
          install.R(),
          install.RStudio(),
          install.Rtools(),
          install.git(),
          install.MikTeX(),
          install.pandoc(),
          install.GitHub(),
          install.ImageMagick(),
          install.GraphicsMagick(),
          return(FALSE)
   )
}
