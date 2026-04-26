# Real-Time XAS Workflow

The runnable set includes a compact Gaussian-field real-time propagation input:

- [`runnable/08-x-ray-spectroscopy/h2o-real-time-gaussian-field.inp`](../../runnable/08-x-ray-spectroscopy/h2o-real-time-gaussian-field.inp)

The fuller real-time XAS workflow is more staged: it can use precomputed XAS_TDP states and a
custom basis file, then propagate the response with field settings chosen for the spectrum of
interest. Existing tutorial material in this repository is the better starting point:

- [`rtp_field_xas/tutorial_rtp.ipynb`](../../../rtp_field_xas/tutorial_rtp.ipynb)
- [`rtp_field_xas/Data/RTP.inp`](../../../rtp_field_xas/Data/RTP.inp)

The small runnable input is therefore a smoke-testable bridge, while the tutorial remains the
right place for the production-style workflow.
