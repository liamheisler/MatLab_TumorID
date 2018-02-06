%{
The goal of this function is to take in an MRI scan, run filters
and tests over it to isolate/identify the tumor, and then display
the tumor over a dimmed-background original scan. This is a simplified
version of software that could be in MRI scans of patients with 
small and subtle tumors.

Author/Name: Liam Heisler, ljh78@drexel.edu
%}
function mri_findTumor() %Do we want user input?

%User choice, which scan do they want to test?
choice = input('MRI image: '); 1
switch(choice)
    case 1
        im = imread('C:/Users/liamh/OneDrive/Desktop/tumor/mri1.jpg');
    case 2
        im = imread('C:/Users/liamh/OneDrive/Desktop/tumor/mri2.jpg');
    case 3
        im = imread('C:/Users/liamh/OneDrive/Desktop/tumor/mri3.jpg');
    case 4
        im = imread('C:/Users/liamh/OneDrive/Desktop/tumor/mri4.jpg');
    case 5
        im = imread('C:/Users/liamh/OneDrive/Desktop/tumor/mri5.jpg');
    otherwise
        error('Program error, use a number w/in [1, 3]!')
end

%Make sure the images are of similiar sizes. This makes it easier
%when we want to filter via areas later.
imsize = size(im); max = 900;
if (imsize(1) < max)
    im = imresize(im, (max/imsize(1))); 
end

%Show original image, will be used to compare to final later
figure('Name', 'Original image')
imshow(im)

%Convert to a grayscale image, and then reduce the brightness. The
%reduced brightness image will be used in the final product. 
gray = rgb2gray(im);
imbr_reduce = imadjust(gray);
redFact = 0.35;
imbr_reduce = imbr_reduce * redFact;

%Calculate brightness level [0,1]
imbr_redcopy = imbr_reduce; 
imbr_redcopy = mat2gray(imbr_redcopy);
lvl = multithresh(imbr_redcopy, 2);
level = lvl(2);
binary = im2bw(imbr_redcopy, level); 

%Gather struct data about sections of the image. This info
%will be used for shape identifcation. 
cc = bwconncomp(binary);
stats = regionprops(binary, 'Area', 'Perimeter');
perim = cat(1,stats.Perimeter);
area = cat(1,stats.Area);

%Test section of image for circularity. CircularityA has a 
%circularity value that approaches 1 from above as the image
%becomes more circularity. CircularityB is the inverse. Once we
%calculate the circualrity, compare and find.
circularityA = (perim.^2)./(4*pi*area); maxCirc = 1.5;
circularityB = (4*pi*area)./(perim.^2); minCirc = 0.7;
idx = find(circularityB > minCirc);
BW2 = ismember(labelmatrix(cc), idx);

%Filter out small pieces and remove any residual border
p = 3500;
bim = bwareaopen(BW2, p);
brem = imclearborder(bim); 

%Concatenate ("overlay") isolated tumor over the reduced
%brightness original image.
figure('Name', 'Final, overlayed')
final = imbr_reduce;
final(:,:,1) = double(final(:,:,1)) + (256 * brem);
imshow(final)
