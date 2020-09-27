# Speech-and-Audio-Discriminator
Analyzing time and frequency domain features that capture the discriminating properties of speech and music audio.

Many products/applications process speech and music differently. For example, in hearing aids, a device may have one setting for speech inputs and one for music inputs. Or in cellular telephony, the compression algorithm used for speech inputs may differ from the one used from music inputs. For all of these applications a critical first step is automatically deciding whether the input signal is speech or music. One such algorithm for doing this is the algorithm proposed by Scheirer and Slaney in:
http://www.ee.columbia.edu/~dpwe/papers/ScheiS97-mussp.pdf

# Algorithm Description
In this algorithm, the authors propose extracting a set of features from the input signal and building an automatic classifier that discriminates between speech and music. A subset of this algorithm is implemented here. Specifically, following the details in the paper, the following features have been extracted:
•	Percentage of “Low-Energy” frames: The proportion of frames with RMS power less than 50% of the mean RMS power within a one-second window. The energy distribution for speechis more left-skewed than for music—there are more quiet frames—so this measure will be higher for speech than for music.
•	Spectral Rolloff Point: : The 95th percentile of the power spectral distribution.
•	Spectral centroid:  The “balancing point” of the spectral power distribution. Many kinds of music involve percussive sounds which, by including high-frequency noise, push the
spectral mean higher.
•	Spectral flux: The 2-norm of the frame-to-frame spectral amplitude difference vector.  Music has a higher rate of change, and goes through more drastic frame-to-frame changes than speech does; this value is higher for music than for speech.
•	Zero crossing rate:  The number of time-domain zero-crossings within a speech frame.

1-sec frames with 50% overlap are used to extract each of these features. For the Percentage “Low-energy” feature, the 1-sec frame is further divided into shorter 10-ms frames and the percent of these shorter frames that fall below the mean RMS power of the 1-sec window are calculated.

The resulting features are appended into two data matrices – one for speech and one for music. The rows of these matrices correspond to the number of 1-sec frames processed by the algorithm and the columns correspond to the features extracted (there are 5 columns).

The final step is measuring the separability of these features between the two classes. The Bhattacharyya (BC) distance between the two data sets (features for music and features for speech) is calculated indicating the separability of the two matrices. The range of the distance measure is between 0 (data is completely overlapping) and 1 (data is completely separable). Using this distance measure, the ability of the features to discriminate between speech and music is evaluated.
