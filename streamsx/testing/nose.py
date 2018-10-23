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



