dirsource = getDirectory("Choose Source Directory");
Dialog.create("Don't worry be happy");
Dialog.addMessage("Input all stacks to collect ROI data on");
Dialog.addString("Index:", 1);
Dialog.addString("Number of frames:", 2560);
Dialog.addString("Text to include when importing images: ", "aligned");
Dialog.addMessage("**Add a space between different indices**");
Dialog.show();
list= Dialog.getString();
numframes=Dialog.getString();
importstring=Dialog.getString();
list= split(list);
numframes=split(numframes);



dirsavemaster = getDirectory("Choose a Directory to save your time course data");

n=lengthOf(list)

for (index=0; index<n; index++) {
dir = dirsource+"yc"+list[index]+"aligned/";
roiname = dirsource+"yc"+list[index]+"rois.zip";
dirsave = dirsavemaster;
File.makeDirectory(dirsave);

run("Image Sequence...", "open="+dir+" number="+numframes[index]+" starting=1 increment=1 scale=100 file="+importstring+" or=[] sort");
rename("Stack");
run("Split Channels");
close();
imageCalculator("Divide create 32-bit stack", "Stack (green)","Stack (red)");
rename("Ratio");


//Extract ROI timecourses
roiManager("Open", roiname);
roiManager("Show All");
run("Set Measurements...", "  mean redirect=None decimal=3");
roiManager("Multi Measure");
saveAs("Results", dirsave+"yc"+list[index]+"allframesratio_tc.txt");

//Extract ROI centroid
run("Clear Results");
newImage("Mask", "8-bit Black", 256, 256, 1);
roiManager("Show All");
run("Set Measurements...", "  centroid redirect=None decimal=3");
roiManager("Measure");
saveAs("Results", dirsave+prefix+list[index]+suffix+"centroids.txt");

selectWindow("Mask");
run("Close");
selectWindow("ROI Manager");
run("Close");
run("Clear Results");
run("Close All");
}
