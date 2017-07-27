import os.path as opath
import os

TAXI_HOME = opath.expanduser("~") + '/../taxi'


dpath = {}
taxi_data_home = opath.join(opath.join(opath.dirname(opath.realpath(__file__)), '..'), 'taxi_data')
# --------------------------------------------------------------
dpath['home'] = opath.join(taxi_data_home, 'driversAnalysis')
#
dpath['stateBlock'] = opath.join(dpath['home'], 'stateBlock')
dpath['stateBlockByMonth'] = opath.join(dpath['stateBlock'], 'stateBlockByMonth')
dpath['stateBlockByDriver'] = opath.join(dpath['stateBlock'], 'stateBlockByDriver')


for dn in [
            'home',
            #
            'stateBlock',
                'stateBlockByMonth', 'stateBlockByDriver'
           ]:
    try:
        if not opath.exists(dpath[dn]):
            os.makedirs(dpath[dn])
    except OSError:
        pass

