from setuptools import setup
import streamsx.testing
setup(
  name = 'streamsx.testing',
  packages = ['streamsx.testing'],
  include_package_data=True,
  version = streamsx.testing.__version__,
  description = 'IBM Streams tester',
  long_description = open('DESC.txt').read(),
  author = 'IBM Streams @ github.com',
  author_email = 'debrunne@us.ibm.com',
  license='Apache License - Version 2.0',
  url = 'https://github.com/IBMStreams/streamsx.testing',
  keywords = ['streams', 'ibmstreams', 'streaming', 'analytics', 'streaming-analytics', 'testing'],
  classifiers = [
    'Development Status :: 3 - Alpha',
    'License :: OSI Approved :: Apache Software License',
    'Programming Language :: Python :: 3.5',
    'Programming Language :: Python :: 3.6',
  ],
  install_requires=['streamsx>=1.11.8', 'nose'],
  entry_points = {
    'nose.plugins.0.10': [
    'streamsx-add-config = streamsx.testing.nose:AddConfigurationPlugin',
    'streamsx-jco = streamsx.testing.nose:JobConfigPlugin',
    'streamsx-skip-standalone = streamsx.testing.nose:SkipStandalonePlugin',
    'streamsx-disable-ssl-verify = streamsx.testing.nose:DisableSSLVerifyPlugin'
    ] },
  
  test_suite='nose.collector',
  tests_require=['nose']
)
