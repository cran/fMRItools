% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot_FC.R
\name{cor_mat}
\alias{cor_mat}
\title{Un-vectorize correlation matrix}
\usage{
cor_mat(
  x_diag,
  diag_val = NA,
  names = NULL,
  newOrder = NULL,
  lowerOnly = FALSE
)
}
\arguments{
\item{x_diag}{The vectorized lower triangular correlation matrix.}

\item{diag_val}{The value to put on the diagonals of the correlation matrix.
Default: \code{NA}.}

\item{names}{(Optional) row/column names.}

\item{newOrder}{(Optional) new index order.}

\item{lowerOnly}{Set the upper triangle to \code{NA}? Default: \code{FALSE}.}
}
\value{
A square correlation matrix
}
\description{
Converted a vectorized lower triangular correlation matrix back to its full
matrix form.
}
\keyword{internal}
