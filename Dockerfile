# stanfordcni/cni-dcm-convert
#
# Use SciTran Data lib to convert raw DICOM data (zip) from Siemens or GE to
# various formats (montage, nifti, png).
# See http://github.com/vistalab/scitran-data for source code.
#

FROM ubuntu-debootstrap:trusty

MAINTAINER Michael Perry <lmperry@stanford.edu>

# Install dependencies
RUN apt-get update && apt-get -y install python-dev \
   python-virtualenv \
   git \
   libjpeg-dev \
   zlib1g-dev \
   curl \
   bsdtar

# Link libs: pillow jpegi and zlib support hack
RUN ln -s /usr/lib/x86_64-linux-gnu/libjpeg.so /usr/lib
RUN ln -s /usr/lib/x86_64-linux-gnu/libz.so /usr/lib

# Install scitran.data dependencies
RUN pip install \
    numpy==1.9.0 \
    pytz==2017.2 \
    pillow==4.2.1 \
    git+https://github.com/vistalab/pydicom.git@0.9.9_value_vr_mismatch \
    git+https://github.com/nipy/nibabel.git@3bc31e9a6191fc54667b3387ed5dfaced46bf755 \
    git+https://github.com/moloney/dcmstack.git@6d49fe01235c08ae63c76fa2f3943b49c9b9832d

RUN pip install git+https://github.com/vistalab/scitran-data.git@0ebebcb2f91c9292eb7249425dcaedce50f23804

# Install tagged version of dcm2niix
ENV TAG=v1.0.20200331
RUN curl -#L  https://github.com/rordenlab/dcm2niix/releases/download/$TAG/dcm2niix_lnx.zip \
    | bsdtar -xf- -C /usr/bin && chmod +x /usr/bin/dcm2nii*

# Make directory for flywheel spec (v0)
ENV FLYWHEEL /flywheel/v0
RUN mkdir -p ${FLYWHEEL}

# Put the code in place
COPY manifest.json ${FLYWHEEL}/
COPY run ${FLYWHEEL}/run
RUN chmod +x ${FLYWHEEL}/run

# Set the entrypoint
ENTRYPOINT ["/flywheel/v0/run"]
