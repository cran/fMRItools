% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/DCT_FFT_detrending.R
\name{temporal_filter}
\alias{temporal_filter}
\alias{detrend}
\title{Temporal filtering (bandpass, highpass, lowpass) with DCT or FFT}
\usage{
temporal_filter(
  X,
  TR,
  hpf = 0.008,
  lpf = NULL,
  method = c("DCT", "FFT"),
  verbose = FALSE
)

detrend(X, TR, hpf = 0.008, method = c("DCT", "FFT"))
}
\arguments{
\item{X}{A numeric matrix, with each column being a timeseries to filter
For fMRI data, \code{X} should be \code{T} timepoints by \code{V} brain
locations.

Alternatively, a single integer giving the number of timepoints in data.
The return value will be the suitable set of DCT bases. Only works with
\code{method == "DCT"}.}

\item{TR}{The time step between adjacent rows of \code{X}, in seconds.}

\item{hpf}{The frequency of the highpass filter, in Hertz. Default: \code{.008}.}

\item{lpf}{The frequency of the lowpass filter, in Hertz. Default: \code{NULL}
(skip lowpass filtering). If both are provided, \code{lpf > hpf} must be true.}

\item{method}{\code{"DCT"} (default) or \code{"FFT"}. FFT is not compatible
with \code{lpf} yet.}

\item{verbose}{Print messages? Default: \code{FALSE}.}
}
\value{
Filtered \code{X}, or if \code{X} was an integer, the set of DCT
bases to use for nuisance regression (not including an intercept).
}
\description{
Temporal filtering (bandpass, highpass, lowpass) with DCT or FFT
}
\examples{
temporal_filter(matrix(rnorm(700), nrow=100), TR=.72)
}
