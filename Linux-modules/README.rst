Linux_Modules
=============

How to compile the modules
--------------------------
* Compile linaro OS following the turorial in http://www.wmelectronic.at/PDFS/digilent/ZedBoard_GSwEL_Guide.pdf. A folder called "linux-digilent" is created.
* Navigate to the folder where the module is.
* Modify the Makefile to be able to find the folder "linux-digilent"
* Type the following:

.. code-block:: bash

   $ make
