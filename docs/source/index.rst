streamsx.testing package
#########################

Overview
========

Testing for IBM Streams SPL and Python applications.

`unittest` integration
======================

    * Test streams by placing conditions on streams in an application, such as this stream must receive at least 100 tuples.
    * Allow a test to be easily executed in different environments, such as standalone and against the public cloud service.

`nose` integration
======================

    * Plugins to allow configuration changes when running tests using `nosetests` without modifying the test code.

.. autosummary::
   :nosignatures: 
   :toctree: generated

   streamsx.testing
   streamsx.testing.nose

Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`

