Modules
=======

How to compile the modules
--------------------------
* Compile linaro OS following the turorial in <ADD LINK HERE>. A folder called "linux-digilent" is created.
* Navigate to the folder where the module is.
* Modify the Makefile to be able to find the folder "linux-digilent"
* Type the following:

.. code-block:: bash

   $ make ARCH=arm CROSS_COMPILE=arm-xilinx-linux-gnueabi-
