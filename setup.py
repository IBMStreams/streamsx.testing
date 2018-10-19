from setuptools import setup
setup(
  name = 'streamsx.testing',
  packages = ['streamsx.testing'],
  include_package_data=True,
  version = '0.1.1',
  description = 'IBM Streams tester',
  long_description = open('DESC.txt').read(),
  author = 'IBM Streams @ github.com',
  author_email = 'debrunne@us.ibm.com',
  license='Apache License - Version 2.0',
  url = 'https://github.com/IBMStreams/streamsx.testing',
  keywords = ['streams', 'ibmstreams', 'streaming', 'analytics', 'streaming-analytics'],
  classifiers = [
    'Development Status :: 3 - Alpha',
    'License :: OSI Approved :: Apache Software License',
    'Programming Language :: Python :: 3.5',
    'Programming Language :: Python :: 3.6',
  ],
  #install_requires=['streamsx==1.11.2a', 'nose'],
  entry_points = {
    'nose.plugins.0.10': [
    'streamsx-jco = streamsx.testing.nose:JobConfigPlugin',
    'streamsx-skip-standalone = streamsx.testing.nose:SkipStandalonePlugin',
    ] },
  
  test_suite='nose.collector',
  tests_require=['nose']
)
