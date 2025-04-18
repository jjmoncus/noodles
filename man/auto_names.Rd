% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{auto_names}
\alias{auto_names}
\title{Get names of a dataset, then auto-name them}
\usage{
auto_names(data)
}
\description{
When mapping over variables in \code{data}, we frequently
start by taking \code{names} and then using \code{purrr::set_names}
to name each element after itself. This is a shortcut for that
}
