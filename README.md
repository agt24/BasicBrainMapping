BasicBrainMapping
=================

A simple and "fast" brain registration example

We use a brain mask to restrict the registration focus

Similar strategies may be used for brains with missing data e.g. lesions 

Both cases are illustrated in this [example script](https://github.com/stnava/BasicBrainMapping/blob/master/bbm.sh).

Before running the script make sure the ANTs executable directory is in your default path.

Run the script from the BasicBrainMapping directory like this:
```
./bbm.sh data/IXI/T_template2.nii.gz ./data/IXI594-Guys-1089-T1.nii.gz ./data/IXI/T_templateExtractionMask.nii.gz
```

![T1_lesioned](https://raw.github.com/stnava/BasicBrainMapping/master/T1_lesioned.jpg?raw=true)
![Template2T1_lesioned](https://raw.github.com/stnava/BasicBrainMapping/master/Template2T1_lesioned.jpg?raw=true)
