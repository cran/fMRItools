#' PCA-based Dimension Reduction and Prewhitening
#'
#' Performs dimension reduction and prewhitening based on probabilistic PCA using 
#'  SVD. If dimensionality is not specified, it is estimated using the method 
#'  described in Minka (2008).
#'
#' @param X \eqn{V \times T} fMRI timeseries data matrix, centered by columns.
#' @param Q Number of latent dimensions to estimate. If \code{NULL} (default), 
#'  estimated using PESEL (Sobczyka et al. 2020).
#' @param Q_max Maximal number of principal components for automatic 
#'  dimensionality selection with PESEL. Default: \code{100}.
#' @return A list containing the dimension-reduced data (\code{data_reduced}, a 
#'  \eqn{V \times Q} matrix), prewhitening/dimension reduction matrix (\code{H}, 
#'  a \eqn{QxT} matrix) and its (pseudo-)inverse (\code{Hinv}, a \eqn{TxQ} 
#'  matrix), the noise variance (\code{sigma_sq}), the correlation matrix of the
#'  dimension-reduced data (\code{C_diag}, a \eqn{QxQ} matrix), and the 
#'  dimensionality (\code{Q}).
#' 
#' @export
#' 
#' @examples
#' nT <- 30
#' nV <- 400
#' nQ <- 7
#' X <- matrix(rnorm(nV*nQ), nrow=nV) %*% diag(seq(nQ, 1)) %*% matrix(rnorm(nQ*nT), nrow=nQ) 
#' dim_reduce(X, Q=nQ)
#' 
dim_reduce <- function(X, Q=NULL, Q_max=100){

  svd_XtX <- PCA(X, Q=Q, Q_max=Q_max)
  U <- svd_XtX$u
  D1 <- svd_XtX$d[1:Q]
  D2 <- svd_XtX$d[(Q+1):length(svd_XtX$d)]

  #residual variance
  sigma_sq <- mean(D2)

  #prewhitening matrix
  H <- diag(1/sqrt(D1 - sigma_sq)) %*% t(U)
  H_inv <- U %*% diag(sqrt(D1 - sigma_sq))

  #for residual variance after prewhitening
  C_diag <- rowSums(H^2) # diag(H %*% t(H))

  #prewhitened data (transposed)
  X_new <- X %*% t(H)

  list(
    data_reduced=X_new, 
    H=H, 
    H_inv=H_inv, 
    sigma_sq=sigma_sq, 
    C_diag=C_diag, 
    Q=Q
  )
}

#' Check \code{Q2_max}
#'
#' Check \code{Q2_max} and set it if \code{NULL}.
#'
#' @param Q2_max,nQ,nT The args
#' @return \code{Q2_max}, clamped to acceptable range of values.
#' @keywords internal
Q2_max_check <- function(Q2_max, nQ, nT){
  if (!is.null(Q2_max)) {
    if (round(Q2_max) != Q2_max || Q2_max <= 0) {
      stop('`Q2_max` must be `NULL` or a non-negative integer.')
    }
  } else {
    Q2_max <- pmax(round(nT*.50 - nQ), 1)
  }

  # This is to avoid the area of the pesel objective function that spikes close
  #   to rank(X), which often leads to nPC close to rank(X)
  if (Q2_max > round(nT*.75 - nQ)) {
    warning('`Q2_max` too high, setting to 75% of T.')
    Q2_max <- round(nT*.75 - nQ)
  }

  Q2_max
}
