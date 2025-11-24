# puncta_counting
Counting puncta found in cells

🧪 What is puncta_counting?
This set of programs helps you count “puncta” (small spots or dots) in images of cells. For example when you have microscopy images with stained cells, you might want to know how many little puncta appear inside each cell or region of interest (ROI).
These scripts are written in MATLAB.


🔍 What the main scripts do
- puncta_counting.m — the main “driver” script that ties things together: loads image(s), loads ROIs, counts puncta in each ROI, and outputs results.
- countPunctaInROIs.m — given an image and defined ROIs, this counts how many puncta lie in each ROI.
- countPunctaAreaInROIs.m — computes area‑based metrics (e.g., puncta per area) inside ROIs.
- fitGaussianMixtureToImage.m — a helper to model the image intensity distribution (for thresholding) via a Gaussian mixture.
- loadFijiROIZip.m — loads ROI definitions exported from FIJI (or ImageJ) as a .zip file.
- measurements_with_FIJI_masks.m — if you exported masks from FIJI rather than ROIs, this helps you measure within those masks.
- example_data/ — a sample folder of images & ROIs so you can test the workflow before using your own images.

🚀 How to use puncta_counting
1. Install MATLAB
Make sure you have MATLAB installed on your computer.

2. Download or clone the repository
You can download a ZIP of the repository or clone it via command line.
For example:
git clone https://github.com/emjmakesstuff/puncta_counting.git
Then open the folder in MATLAB.

3. Open MATLAB and set current folder
In MATLAB, set the “Current Folder” to the repository folder (where puncta_counting.m lives).

4. Try the example data
Inside example_data/, there should be some sample image(s) and ROIs.
Run puncta_counting.m. It should process the example image(s) and output results. This gives you a sense of how it works.
