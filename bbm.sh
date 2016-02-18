#!/bin/bash
set -x -e
dim=3 # image dimensionality
AP=$ANTSPATH # /home/yourself/code/ANTS/bin/bin/  # path to ANTs binaries
ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=4  # controls multi-threading
export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS
f=$1 ; m=$2 ; mask=$3   # fixed and moving image file names
if [ $# -lt 3 ] ; then 
echo usage is 
echo $0 fixed.nii.gz moving.nii.gz  fixed_brain_mask.nii.gz 
exit
fi
if [[ ! -s $f ]] ; then echo no fixed $f ; exit; fi
if [[ ! -s $mask ]] ; then echo no fixed mask $mask ; exit; fi
if [[ ! -s $m ]] ; then echo no moving $m ;exit; fi
reg=${AP}antsRegistration           # path to antsRegistration
its=10000x1111x5
percentage=0.25
syn="20x20x0,0,5"
nm=BBM
imgs=" $f, $m "
if [[ ! -s  ${nm}0GenericAffine.mat ]] ; then 
$reg -d $dim -r [ $imgs ,1]  \
                        -m mattes[  $imgs , 1 , 32, regular, 0.05 ] \
                         -t translation[ 0.1 ] \
                         -c [1000,1.e-8,20]  \
                        -s 4vox  \
                        -f 6 -l 1 \
                        -m mattes[  $imgs , 1 , 32, regular, 0.1 ] \
                         -t rigid[ 0.1 ] \
                         -c [1000x1000,1.e-8,20]  \
                        -s 4x2vox  \
                        -f 4x2 -l 1 \
                        -m mattes[  $imgs , 1 , 32, regular, 0.1 ] \
                         -t affine[ 0.1 ] \
                         -c [$its,1.e-8,20]  \
                        -s 4x2x1vox  \
                        -f 3x2x1 -l 1 \
                        -m mattes[  $imgs , 1 , 32 ] \
                         -t SyN[ .20, 3, 0 ] \
                         -c [ $syn ]  \
                        -s 1x0.5x0vox  \
                        -f 4x2x1 -l 1 -u 1 -z 1 -x $mask --float 1 \
                       -o [${nm},${nm}_diff.nii.gz,${nm}_inv.nii.gz]
${AP}antsApplyTransforms -d $dim -i $m -r $f -n linear -t ${nm}1Warp.nii.gz -t ${nm}0GenericAffine.mat -o ${nm}_warped.nii.gz --float 1 
fi  

echo Lesion study uses the affine mapping from the previous result.
echo One could also "revise" the template mask by the lesion mask but 
echo here we assume the affine map is not corrupted by the lesion. 
echo We do, however, mask the deformation estimation with a lesion mask.
origmat=${nm}0GenericAffine.mat
nm=BBM_Lesion
$AP/SmoothImage 3 data/lesion.nii.gz 2 data/neg_lesion.nii.gz
$AP/ImageMath 3  data/neg_lesion.nii.gz CorruptImage  data/neg_lesion.nii.gz 
$AP/ImageMath 3 data/neg_lesion.nii.gz Neg data/neg_lesion.nii.gz 
$AP/MultiplyImages 3 data/neg_lesion.nii.gz $2 data/T1_lesioned.nii.gz 
m=data/T1_lesioned.nii.gz
imgs=" $m, $f "
myit=1000
$reg -d $dim -r [${origmat},1] \
    -m mattes[  $imgs , 1 , 32 ] \
    -t SyN[ .20, 3, 0.1 ] \
    -c [ 30x20x0 ]  \
    -s 1x0.5x0vox  \
    -f 4x2x1 -l 1 -u 1 -z 1 -x data/neg_lesion.nii.gz   \
    -o [${nm},${nm}_diff.nii.gz,${nm}_inv.nii.gz]
$AP/ExtractSliceFromImage 3 data/T1_lesioned.nii.gz temp.nii.gz 1 120
$AP/ConvertImagePixelType temp.nii.gz T1_lesioned.jpg 1
$AP/ExtractSliceFromImage 3 ${nm}_diff.nii.gz temp.nii.gz 1 120
$AP/ConvertImagePixelType temp.nii.gz Template2T1_lesioned.jpg 1
