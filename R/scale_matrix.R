#' Robust scaling
#' 
#' Centers and scales the columns of a matrix robustly
#'
#' Centers each column on its median, and scales each column by its median
#' 	absolute deviation (MAD). If there are constant-valued columns, they are
#' 	removed if \code{drop_const} or set to \code{NA} if \code{!drop_const}, and
#' 	a warning is raised. If all columns are constant, an error is raised.
#'
#' @param mat A numeric matrix. Its columns will be centered and scaled.
#' @param TOL Columns with MAD below this value will be considered constant.
#'  Default: \code{1e-8}
#' @param drop_const Drop constant columns? Default: \code{TRUE}. If 
#' 	\code{FALSE}, set to \code{NA} instead. 
#' @param doRows Center and scale the rows instead? Default: \code{FALSE}.
#'
#' @export
#' @return The input matrix with its columns centered and scaled.
scale_med <- function(mat, TOL=1e-8, drop_const=TRUE, doRows=FALSE){
  # Transpose.
  if (!doRows) { mat <- t(mat) }

  #	Center.
  mat <- mat - c(rowMedians2(mat, na.rm=TRUE))

  # Scale.
  mad <- 1.4826 * rowMedians2(abs(mat), na.rm=TRUE)
  mad <- as.numeric(mad)
  const_mask <- mad < TOL
  if (any(const_mask)) {
    if (all(const_mask)) {
    stop("All columns are zero-variance.\n")
    } else {
      warning(paste0(
        "Warning: ", sum(const_mask),
        " constant columns (out of ", length(const_mask),
        " ). These will be removed.\n"
      ))
    }
  }
  mad <- mad[!const_mask]
  mat[const_mask,] <- NA
  mat[!const_mask,] <- mat[!const_mask,] / mad

  if (drop_const) { mat <- mat[!const_mask,] }

  # Revert transpose.
  mat <- t(mat)

  mat
}

#' Scale the BOLD timeseries
#'
#' @param BOLD fMRI data as a locations by time (\eqn{V \times T}) numeric 
#' 	matrix.
#' @param scale Option for scaling the BOLD response.
#' 
#' 	\code{"auto"} (default) will use \code{"mean"} scaling except if demeaned 
#'  data is detected (if any mean is less than one), in which case \code{"sd"}
#'  scaling will be used instead.
#' 
#' 	\code{"mean"} scaling will scale the data to percent local signal change.
#' 
#' 	\code{"sd"} scaling will scale the data by local standard deviation.
#' 
#' 	\code{"none"} will only center the data, not scale it. 
#' @param transpose Transpose \code{BOLD} if there are more columns than rows?
#' 	(Because we usually expect the number of voxels to exceed the number of time
#' 	points.) Default: \code{TRUE}.
#'
#' @return Scale to units of percent local signal change and centers
#'
#' @importFrom stats var
#' @export
scale_timeseries <- function(BOLD, scale=c("auto", "mean", "sd", "none"), transpose = TRUE){

	BOLD <- as.matrix(BOLD)
	scale <- match.arg(scale, c("auto", "mean", "sd", "none"))
	stopifnot(is_1(transpose, "logical"))

	# Check orientation, send warning message and transpose if necessary.
	if ((ncol(BOLD) > nrow(BOLD)) & transpose) {
		warning('More columns than rows. Transposing matrix so rows are data locations and columns are time points.')
		BOLD <- t(BOLD)
	}

	nvox <- nrow(BOLD)
	ntime <- ncol(BOLD)

	# Get `v_means`, the mean over time for each location (the mean image)
	v_means <- rowMeans(BOLD, na.rm=TRUE)
	v_means_min <- min(v_means, na.rm = TRUE)

	# Determine `"auto"` scaling.
	if (scale == "auto") {
		scale <- if (v_means_min > 1) { "mean" } else { "sd" }
		# cat("Using", scale, "scaling.\n")
	}

	# Center and scale.
	BOLD <- BOLD - v_means
	if (scale == "mean") {
		if (v_means_min < .1) {
			stop("Some local means are less than 0.1. Please set `scale_BOLD` to `'none'` or `'sd'`.")
		} else if (v_means_min < 1) {
			warning("Scaling to percent signal change when locations have means less than 1 may cause errors or produce aberrant results.")
		}
		BOLD <- 100*BOLD / v_means
	} else if (scale == "sd") {
		v_sd <- sqrt(apply(BOLD, 1, var, na.rm=TRUE))
		v_sd[is.na(v_sd)] <- 0
		if (min(v_sd) < 1e-6) {
			stop("Some local sds are less than 1e-6. Please set `scale_BOLD` to `'none'`.")
		}
		BOLD <- BOLD / v_sd
	}

	BOLD
}

#' Scale a design matrix
#' 
#' Scale the columns of a matrix by dividing each column by its 
#' 	highest-magnitude value, and then subtracting its mean.
#'
#' @param x A \eqn{T \times K} numeric matrix. In the context of a
#' 	design matrix for a GLM analysis of task fMRI, \eqn{T} is the number of time
#' 	points and \eqn{K} is the number of task covariates.
#' @param doRows Scale the rows instead? Default: \code{FALSE}.
#'
#' @return The scaled design matrix
#' 
#' @export
#' 
#' @examples 
#' scale_design_mat(cbind(seq(7), 1, rnorm(7)))
scale_design_mat <- function(x, doRows=FALSE) {
	stopifnot(is.matrix(x))
	stopifnot(is.numeric(x))
	stopifnot(!any(is.na(x)))

	if (!doRows) { x <- t(x) }

	x <- x / apply(x, 1, max)
	x <- x - apply(x, 1, mean)

	if (!doRows) { x <- t(x) }

	x
}