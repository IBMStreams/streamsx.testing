"""
Nose plugins for IBM Streams application testing.
"""

import nose.plugins.base
import os

from streamsx.topology.context import ContextTypes, ConfigParams, JobConfig

class _TesterPlugin(nose.plugins.base.Plugin):
    def __init__(self):
        super(_TesterPlugin, self).__init__()
        self.enabled = False

    def _add_action(self, test, action):
         if not hasattr(test.test, '_streamsx_testing_actions'):
             test.test._streamsx_testing_actions = []
         test.test._streamsx_testing_actions.append(action)


class JobConfigPlugin(_TesterPlugin):
    """Job configuration plugin.

    Plugin that modifies the job configuration object for
    the application under test.

    Enabled with ``--with-streamsx-jco``.

    These options are supported:

        * ``--streamsx-jco-default-tag=tag`` - Sets the resource tag for the default host pool. The default host pool is where transformations/operators with explicit resource tags are assigned to and by default maps to the resource tag ``application``.
    """
    name = 'streamsx-jco'
    score = 2000

    def options(self, parser, env=os.environ):
        super(JobConfigPlugin, self).options(parser, env=env)
        parser.add_option("--streamsx-jco-default-tag", action="store",
            dest="streamsx_jco_default_tag",
            default=env.get('STREAMSX_JCO_DEFAULT_TAG'),
            help="Resource tag to use for default host pool [STREAMSX_JCO_DEFAULT_TAG]")

    def configure(self, options, conf):
        super(JobConfigPlugin, self).configure(options, conf)
        self.enabled = options.enable_plugin_streamsx_jco
        if self.enabled:
            self._jco = {}
            if options.streamsx_jco_default_tag:
                self._jco['configInstructions'] = {"convertTagSet": [ {"targetTagSet":[options.streamsx_jco_default_tag] } ]}
        else:
            self._jco = None

    def beforeTest(self, test):
        if self._jco:
            self._add_action(test, _JobConfigAction(self._jco))

class _JobConfigAction(object):
    def __init__(self, jco):
        self._jco = jco

    def __str__(self):
        return JobConfigPlugin.name + '(' + str(self._jco) + ')'

    def __call__(self, tester, test, ctxtype, config):
        if ContextTypes.STANDALONE == ctxtype:
            return
        if ConfigParams.JOB_CONFIG in config:
            jc = JobConfig.from_overlays(config[ConfigParams.JOB_CONFIG].as_overlays())
            if not jc.raw_overlay:
                jc.raw_overlay = self._jco
            else:
                jc.raw_overlay.update(self._jco)
            jc.add(config)
        else:
            jc = JobConfig()
            jc.raw_overlay = self._jco
            jc.add(config)

class SkipStandalonePlugin(_TesterPlugin):
    """Skip standalone tests.

    Automatically skips any tests that have been configured for
    standalone using ``Tester.setup_standalone()``.

    Enabled with ``--with-streamsx-skip-standalone``.
    """
    name = 'streamsx-skip-standalone'
    score = 1900

    def configure(self, options, conf):
        super(SkipStandalonePlugin, self).configure(options, conf)
        self.enabled = options.enable_plugin_streamsx_skip_standalone

    def beforeTest(self, test):
        if self.enabled:
            self._add_action(test, _SkipAction(SkipStandalonePlugin.name, ContextTypes.STANDALONE))

class _SkipAction(object):
    def __init__(self, name, type_):
        self._name = name
        self._type = type_

    def __str__(self):
        return self._name

    def __call__(self, tester, test, ctxtype, config):
        if self._type == ctxtype:
            test.skipTest('streamsx-skip-standlone enabled')

class DisableSSLVerifyPlugin(_TesterPlugin):
    """Disable SSL certification verification.

    Disables SSL certification when running distributed tests.
    This is useful when a test instance with a self-signed certificate,
    such as the IBM Streams Quick Start edition.

    Enabled with ``--with-streamsx-disable-ssl-verify``.
    """
    name = 'streamsx-disable-ssl-verify'
    score = 1901

    def configure(self, options, conf):
        super(DisableSSLVerifyPlugin, self).configure(options, conf)
        self.enabled = options.enable_plugin_streamsx_disable_ssl_verify

    def beforeTest(self, test):
        if self.enabled:
            self._add_action(test, _AddConfigAction(ContextTypes.DISTRIBUTED,
                {ConfigParams.SSL_VERIFY:False}))

class AddConfigurationPlugin(_TesterPlugin):
    """Add arbitrary configuration to a test

    Enabled with ``--with-streamsx-add-config``.

    This plugin adds arbitrary configuration items to a test's
    ``test_config`` dictionary by updating with the dictionary value supplied
    by the options.
    

    These options must be set when using this plugin.

        * ``--streamsx-test-context CONTEXT`` - Context that will have its configuration added to. Any test that runs with a different context will not have its 
        * ``--streamsx-test-config CODE`` - Code that is executed using built-in method `exec`. The execution must set the local variable ``cfg`` to a dictionary that will then be used as ``test.test_config.update(cfg)`` before the test is run.

    Example::

        nosetests --with-streamsx-add-config --streamsx-test-context STANDALONE --streamsx-test-config "cfg = {'topology.keepArtifacts':True}"

    """
    name = 'streamsx-add-config'
    score = 1902

    def options(self, parser, env=os.environ):
        super(AddConfigurationPlugin, self).options(parser, env=env)
        parser.add_option("--streamsx-test-context", action="store",
            dest="streamsx_test_context",
            default=env.get('STREAMSX_TEST_CONTEXT'),
            help="Context type to add configuration to [STREAMSX_TEST_CONTEXT]")
        parser.add_option("--streamsx-test-config", action="store",
            dest="streamsx_test_config",
            default=env.get('STREAMSX_TEST_CONFIG'),
            help="Additional configuration to be added to test configuration [STREAMSX_TEST_CONFIG]")

    def configure(self, options, conf):
        super(AddConfigurationPlugin, self).configure(options, conf)
        self.enabled = options.enable_plugin_streamsx_add_config
        if self.enabled:
            self._add_ctx = options.streamsx_test_context
            exec_locals = {}
            exec(options.streamsx_test_config, globals(), exec_locals)
            self._add_cfg = {}
            self._add_cfg.update(exec_locals['cfg'])
 
    def beforeTest(self, test):
        if self.enabled and self._add_ctx and self._add_cfg:
            self._add_action(test, _AddConfigAction(self._add_ctx, self._add_cfg))

class _AddConfigAction(object):
    def __init__(self, ctxtype, kvs):
        self._ctxtype = ctxtype
        self._kvs = kvs

    def __str__(self):
        return 'Context:' + str(self._ctxtype) + ' Configs:' + str(self._kvs)

    def __call__(self, tester, test, ctxtype, config):
        if self._ctxtype == ctxtype:
            config.update(self._kvs)
