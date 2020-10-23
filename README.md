# plotVenn
Wrapper to plot euler/venn diagram in R

Install with
`devtools::install_github("gdmcdonald/plotVenn")`

Example
`cars <- mtcars %>%
 transmute(`High Efficiency` = mpg>20,
           `More Cylinders` = cyl>=6)

plotVenn(cars, title = "Overlap between more cylinders\n and high efficiency in mtcars")`

![./ExampleEulerPlot.jpeg](Example Euler Plot)

