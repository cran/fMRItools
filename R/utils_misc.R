#' Transform vector data to an image
#'
#' This fills in parts of a template with values from \code{vec_data}.
#'
#' @param vec_data A V by p matrix, where V is the number of voxels within a
#'   mask and p is the number of vectors to transform into matrix images
#' @param template_image A binary matrix in which V entries are 1 and the rest
#'   of the entries are zero
#'
#' @return A list of masked values from \code{vec_data}
#' 
#' @export
vec2image <- function(vec_data, template_image) {
  each_col <- sapply(split(vec_data, col(vec_data)), function(vd) {
    out <- template_image
    out[out == 1] <- vd
    out[out == 0] <- NA
    return(out)
  }, simplify = F)
  return(each_col)
}

#' Positive skew?
#'
#' Does the vector have a positive skew?
#'
#' @param x The numeric vector for which to calculate the skew. Can also be a matrix,
#'  in which case the skew of each column will be calculated.
#' @return \code{TRUE} if the skew is positive or zero. \code{FALSE} if the skew is negative.
#' @keywords internal
#'
#' @importFrom stats median
skew_pos <- function(x){
  x <- as.matrix(x)
  apply(x, 2, median, na.rm=TRUE) <= colMeans(x, na.rm=TRUE)
}

#' Sign match ICA results
#'
#' Flips all source signal estimates (S) to positive skew
#'
#' @param x The ICA results with entries \code{S} and \code{M}
#' @return \code{x} but with positive skew source signals
#' @keywords internal
#'
sign_flip <- function(x){
  stopifnot(is.list(x))
  stopifnot(("S" %in% names(x)) & ("M" %in% names(x)))
  spos <- skew_pos(x$S)
  x$M[,!spos] <- -x$M[,!spos]
  x$S[,!spos] <- -x$S[,!spos]
  x
}

#' Center cols
#'
#' Efficiently center columns of a matrix. (Faster than \code{scale})
#'
#' @param X The data matrix. Its columns will be centered
#' @return The centered data
#' @keywords internal
colCenter <- function(X) {
  X - rep(colMeans(X), rep.int(nrow(X), ncol(X)))
}

#' Unmask a matrix
#'
#' @param dat The data
#' @param mask The mask
#' @keywords internal
unmask_mat <- function(dat, mask){
  stopifnot(nrow(dat) == sum(mask))
  mdat <- matrix(NA, nrow=length(mask), ncol=ncol(dat))
  mdat[mask,] <- dat
  mdat
}
