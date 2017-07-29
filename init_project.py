import os.path as opath
import os

TAXI_HOME = opath.expanduser("~") + '/../taxi'


dpath = {}
taxi_data_home = opath.join(opath.join(opath.dirname(opath.realpath(__file__)), '..'), 'taxi_data')
dpath['geo'] = opath.join(taxi_data_home, 'geo')
ZONE_UNIT_KM = 0.5
# --------------------------------------------------------------
dpath['home'] = opath.join(taxi_data_home, 'driversAnalysis')
#
dpath['stateBlock'] = opath.join(dpath['home'], 'stateBlock')
dpath['stateBlockByMonth'] = opath.join(dpath['stateBlock'], 'stateBlockByMonth')
dpath['stateBlockByDriver'] = opath.join(dpath['stateBlock'], 'stateBlockByDriver')
dpath['arranged'] = opath.join(dpath['stateBlockByDriver'], 'arranged')
dpath['chunk'] = opath.join(dpath['home'], 'chunk')
dpath['chunkInit'] = opath.join(dpath['chunk'], 'chunkInit')
dpath['chunkHalfHourZone'] = opath.join(dpath['chunk'], 'chunkHalfHourZone')

for dn in [
            'home',
            #
            'stateBlock',
                'stateBlockByMonth', 'stateBlockByDriver', 'arranged',
            'chunk',
                'chunkInit', 'chunkHalfHourZone',
           ]:
    try:
        if not opath.exists(dpath[dn]):
            os.makedirs(dpath[dn])
    except OSError:
        pass

