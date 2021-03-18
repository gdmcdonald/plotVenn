#' plotVenn
#'
#' Wrapper for eulerr::euler() to enable quick and painless venn diagrams.
#'
#' @param df Input data frame, one row per element, one column per set. 1 if that element is in that set, 0 otherwise. Column names are set names.
#' @param title Title for the plot
#' @param not_in_set_name Name for the set of elements not included in the sets provided, default "None". If not_in_set_name = NULL then don't plot these elements.
#' @param shape shape can be either "circle" (default) or "ellipse". "ellipse" will be able to fit area to size of set in more cases.
#' @param input either "disjoint" (default) or "union". See eulerr::euler().
#' @param control  See eulerr::euler().
#' @param random_seed Set the random seed to fix the orientation of the plot to be reproducible. Try a few numbers till you get one you like the look of.
#' @param legend TRUE Should the plot have a legend? TRUE (default) or FALSE
#'
#' @return returns a base R plot of a Venn diagram.
#' @export
#'
#' @examples
#' cars <- mtcars %>%
#'  transmute(`High Efficiency` = mpg>20,
#'            `More Cylinders` = cyl>=6)
#'
#' plotVenn(cars, title = "Overlap between more cylinders\n and high efficiency in mtcars")
#'
plotVenn <- function(df,
                     title = "",
                     not_in_set_name = "None",
                     shape = "circle",
                     input = "disjoint",
                     control = list(),
                     random_seed = 1,
                     legend = TRUE){
 #count elements
  venn_counts <-
    df %>%
    dplyr::group_by_all() %>%
    dplyr::summarise(count = n(),
                     .groups = "drop")

  set_size <- venn_counts$count

  #create set and intersection names
  names(set_size) <-
    venn_counts %>%
    select(-count) %>%
    t() %>%
    as.data.frame() %>%
    tibble::rownames_to_column(var = "name") %>%
    dplyr::mutate(dplyr::across(tidyselect::starts_with("V"),
                                ~dplyr::if_else(.,name,""))) %>%
    dplyr::select(-name) %>%
    sapply(function(x){paste(stringi::stri_remove_empty(x),
                             collapse="&")})

  # Account for elements not in any set
  num_empty <- sum(names(set_size) == "")
  if (num_empty<2){
    if (is.null(not_in_set_name)){
      set_size <- set_size[-(names(set_size) == "")] # remove them if specified
    } else {
      names(set_size)[names(set_size) == ""] <- not_in_set_name # otherwise rename them
    }
  } else {
    stop(paste0("Too many unnamed categories, max 1 unnamed category, but you have ",num_empty,"."))
  }

  #set up for plot
  set.seed(random_seed) # fix the orientation of the plot to be reproducible
  venn_fit <-
    eulerr::euler(set_size,
                  counts = list(cex =3),
                  input = input,
                  shape = shape,
                  control = control)
  #make plot
  plot(venn_fit,
       key = TRUE,
       counts = TRUE,
       quantities = TRUE,
       legend = legend,
       labels = identical(legend, TRUE),
       main = title)
}
